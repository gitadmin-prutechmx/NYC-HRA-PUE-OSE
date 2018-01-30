//
//  RefreshAll.swift
//  EngageNYC
//
//  Created by Kamal on 12/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

/**
 Creating only one instance of RefreshViewController, so it can be resued whenever refresh is made.
 */
class RefreshAll: BroadcastReceiverNSObject
{
    
    // The Singleton
    class var sharedInstance: RefreshAll
    {
        struct Singleton { static let instance = RefreshAll()}
        return Singleton.instance
    }
    
    
    
    /**
     -This method will fire a full refresh Data from all models/api classes we have.
     */
    func refreshFullData(isLogout:Bool? = false)
    {
        presentRefreshView {
            self.synUpAllObjects(isLogout: isLogout)
        }
    }
    
    func refreshDataWithOutModel()
    {
        self.synUpAllObjects(isLogout: false,isBackgroundSync:true)
    }
    
    
    
    
    func synUpAllObjects(isLogout:Bool? = false,isBackgroundSync:Bool?=false){
        // 1. AssignmentLocation
        // 2. New Unit
        // 3. Contact
        // 4. AssignmentLocationUnit
        // 5. Survey
        // 6. Cases
        // 7. Issues
        
        AssignmentLocationAPI.shared.syncUpCompletion {
            LocationUnitAPI.shared.syncUpCompletion {
                ContactAPI.shared.syncUpCompletion {
                    AssignmentLocationUnitAPI.shared.syncUpCompletion {
                        SurveyAPI.shared.syncUpCompletion {
                            CaseAPI.shared.syncUpCompletion {
                                IssueAPI.shared.syncUpCompletion {
                                    EventsAPI.shared.syncUpCompletion {
                                        if(isLogout)!{
                                            
                                            if(Static.timer != nil){
                                                Static.timer?.invalidate()
                                            }
                                            SFAuthenticationManager.shared().logout()
                                        }
                                        else{
                                            
                                            if(isBackgroundSync == false){
                                                self.syncDownAllObjects()
                                            }
                                            else{
                                                
                                                 Logger.shared.log(level: .info, msg: "Background syncing finish..")
                                                Static.isBackgroundSync = false
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    func syncDownAllObjects(){
        
        UserDetailAPI.shared.syncDownWithCompletion {
            
            AssignmentDetailAPI.shared.syncDownWithCompletion {
                
                ChartAPI.shared.syncDownWithCompletion {
                    
                    PicklistAPI.shared.syncDownWithCompletion{
                        
                        CaseConfigAPI.shared.syncDownWithCompletion{
                            
                            EventsConfigAPI.shared.syncDownWithCompletion{
                                
                                EventsAPI.shared.syncDownWithCompletion{
                                    
                                    
                                    DispatchQueue.main.async {
                                        if let refreshView  = Static.refreshView {
                                            refreshView.dismiss(animated: true, completion: nil)
                                            Static.refreshView = nil
                                            
                                            Static.isRefreshBtnClick = false
                                            
                                            self.callNotifications()
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
        }
        
        
        
        
    }
    
    func callNotifications(){
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.DASHBOARD_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.LOCATIONLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.UNITLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
        CustomNotificationCenter.sendNotification(notificationName: SF_NOTIFICATION.CLIENTLISTING_SYNC.rawValue, sender: nil, userInfo: nil)
        
    }
    
    func presentRefreshView(completion: (() -> Swift.Void)!){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if Static.refreshView == nil {
            if let refreshView = RefreshStoryboard().instantiateViewController(withIdentifier: "RefreshViewController") as? RefreshViewController
            {
                appDelegate?.window?.rootViewController?.present(refreshView, animated: true, completion: {
                    completion()
                })
                Static.refreshView = refreshView
            }
        }
        else
        {
            appDelegate?.window?.rootViewController?.present(Static.refreshView!, animated: true, completion: {
                completion()
            })
        }
    }
    
    /**
     -This method will fire a full refresh Data from all models/api classes we have. It won't present any activity model you need to take care for this.
     */
    //    func refreshFullDataWithoutModel()
    //    {
    //        self.fireFullRefresh()
    //    }
    
}



