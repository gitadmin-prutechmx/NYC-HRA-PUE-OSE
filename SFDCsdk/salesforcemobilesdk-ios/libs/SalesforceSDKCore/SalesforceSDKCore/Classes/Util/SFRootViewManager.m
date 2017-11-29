/*
 Copyright (c) 2013-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SFRootViewManager.h"
#import "SFApplicationHelper.h"

@interface SFRootViewManager()

@property (nonatomic, weak) UIWindow* previousKeyWindow;
@property (nonatomic, strong) NSMutableOrderedSet *delegates;

@end

@implementation SFRootViewManager {
    UIViewController *_modalViewController;
}

@synthesize mainWindow = _mainWindow;

+ (SFRootViewManager *)sharedManager
{
    static SFRootViewManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SFRootViewManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _delegates = [NSMutableOrderedSet orderedSet];
    }
    
    return self;
}

- (UIWindow *)mainWindow
{
    if (_mainWindow == nil) {
        // Try to set a sane value for mainWindow, if it hasn't been set already.
        _mainWindow = [SFApplicationHelper sharedApplication].windows[0];
        if (_mainWindow == nil) {
            [SFSDKCoreLogger e:[self class] format:@"UIApplication has no defined windows."];
        }
    }
    return _mainWindow;
}

- (void)addDelegate:(id<SFRootViewManagerDelegate>)delegate
{
    @synchronized (self) {
        [_delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<SFRootViewManagerDelegate>)delegate
{
    @synchronized (self) {
        [_delegates removeObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)enumerateDelegates:(void (^)(id<SFRootViewManagerDelegate> delegate))block
{
    @synchronized(self) {
        [_delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id<SFRootViewManagerDelegate> delegate = [obj nonretainedObjectValue];
            if (delegate) {
                if (block) block(delegate);
            }
        }];
    }
}

//
// NB: There are a number of edge cases that don't play nicely with this approach, all of them having
// to do one way or another with the presentation of modal views (UIAlertView, UIActionSheet, popover
// views) in the old view at the time of showing the new view.  This approach covers a lot of standard
// ground, but implementing an approach with an alternate UIWindow may yield more comprehensive results.
// Whatever the implementation, it promises to be complex.  As of iOS 6.1, Apple simply does not make
// the presentation of an "uber" view easy to implement on the edges.
//
- (void)pushViewController:(UIViewController *) viewController {
    
    if (!viewController)
        return;
  
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        UIViewController *currentViewController = strongSelf.mainWindow.rootViewController;
        while (currentViewController.presentedViewController != nil && !currentViewController.presentedViewController.isBeingDismissed) {
            //stop if we find that an alert has been presented
            if ([strongSelf alertIsPresented:currentViewController]) {
                [strongSelf saveAlert:currentViewController.presentedViewController];
                break;
            }
            currentViewController = currentViewController.presentedViewController;
        }
        
        if (currentViewController) {
            //invoke delegates and then present
            if (currentViewController!=viewController)
                [strongSelf presentViewController:viewController using:currentViewController];
            else
                [SFSDKCoreLogger d:[strongSelf class] format:@"pushViewController: View controller (%@) has already been presented.", viewController];
        } else {
            [SFSDKCoreLogger d:[strongSelf class] format:@"pushViewController: Making view controller (%@) the root view controller.", viewController];
            strongSelf.mainWindow.rootViewController = viewController;
            [strongSelf saveCurrentKeyWindow];
            [strongSelf.mainWindow makeKeyAndVisible];
        }
    });
    
}

- (void)popViewController:(UIViewController *) viewController {
    
    if (!viewController)
        return;
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        UIViewController *currentViewController = strongSelf.mainWindow.rootViewController;
        if (currentViewController != viewController) {
            // look for controller
            while (currentViewController && currentViewController.presentedViewController!=viewController) {
                currentViewController = currentViewController.presentedViewController;
            }
            // if controller is found dismiss the view, invoke delegates && restore Alerts if required.
            if (viewController == currentViewController.presentedViewController) {
                [SFSDKCoreLogger d:[strongSelf class] format:@"popViewController: View controller (%@) is now being dismissed from presentation.", viewController];
                [strongSelf dismissPresentedViewController:currentViewController];
            }else{
                [SFSDKCoreLogger d:[strongSelf class] format:@"popViewController: View controller (%@) not found in the view controller stack.  No action taken.", viewController];
            }
        } else {
            [SFSDKCoreLogger d:[strongSelf class] format:@"popViewController: Removing rootViewController (%@).", viewController];
            strongSelf.mainWindow.rootViewController = nil;
            [strongSelf restorePreviousKeyWindow];
            
        }
    });
}

#pragma mark - Private
- (void)saveCurrentKeyWindow
{
    for (UIWindow* w in [SFApplicationHelper sharedApplication].windows) {
        if ([w isKeyWindow]) {
            self.previousKeyWindow = w;
            break;
        }
    }
}

- (void)restorePreviousKeyWindow
{
    [self.previousKeyWindow makeKeyAndVisible];
    self.previousKeyWindow = nil;
}

- (BOOL)alertWasPresent{
    return self->_modalViewController?YES:NO;
}

- (BOOL)alertIsPresented:(UIViewController *) current {
    return [current.presentedViewController isKindOfClass:[UIAlertController class]];
}

- (void)saveAlert:(UIViewController *) alert {
    self ->_modalViewController = alert;
    [alert dismissViewControllerAnimated:NO completion:nil];
}

- (void)restoreAlert:(UIViewController *) presentingViewController {
    [presentingViewController presentViewController:self->_modalViewController  animated:NO completion:^{
        self ->_modalViewController = nil;
    }];
}

- (void)presentViewController:(UIViewController *)toBePresented using:(UIViewController *)presentingViewController {
    [self enumerateDelegates:^(id<SFRootViewManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(rootViewManager:willPushViewControler:)]) {
            [delegate rootViewManager:self willPushViewControler:toBePresented];
        }
    }];
    [presentingViewController presentViewController:toBePresented animated:NO completion:nil];
}

- (void)dismissPresentedViewController :(UIViewController *)presentingViewController {
    __weak typeof (self) weakSelf = self;
    [presentingViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if ([strongSelf alertWasPresent]) {
            [strongSelf restoreAlert:presentingViewController];
        }
        [strongSelf enumerateDelegates:^(id<SFRootViewManagerDelegate> delegate) {
            if ([delegate respondsToSelector:@selector(rootViewManager:didPopViewControler:)]) {
                [delegate rootViewManager:strongSelf didPopViewControler:presentingViewController.presentedViewController];
            }
        }];
    }];
}
@end
