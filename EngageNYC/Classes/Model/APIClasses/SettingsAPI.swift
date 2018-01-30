//
//  SettingsAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 11/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation

final class SettingsAPI
{
    
    private static var sharedInstance: SettingsAPI = {
        let instance = SettingsAPI()
        return instance
    }()
    
    class var shared:SettingsAPI!{
        get{
            return sharedInstance
        }
    }
    
    func getOfflineSyncTime()->String{
        
        let  settingRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.settings.rawValue, isPredicate:false) as! [Setting]
        
        return (settingRes.first?.offlineSyncTime)!
        
    }
    
    func getSettings()->[Setting]?{
        let settingRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.settings.rawValue, isPredicate:false) as? [Setting]
        
        return settingRes
        
        
    }
    
    func updateSettings(objSettings:SettingsDO){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["offlineSyncTime"] = objSettings.offlineSyncTime as AnyObject
        updateObjectDic["isSyncON"] = objSettings.isSyncOn as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.settings.rawValue, updateKeyValue: updateObjectDic,isPredicate: false)
        
    }
    
   
}
