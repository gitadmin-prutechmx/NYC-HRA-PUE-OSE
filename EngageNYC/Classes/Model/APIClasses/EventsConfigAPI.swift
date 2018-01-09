//
//  EventsAPI.swift
//  EngageNYCDev
//
//  Created by Kamal on 09/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class EventsConfigAPI : SFCommonAPI
{
    
    private static var sharedInstance: EventsConfigAPI = {
        let instance = EventsConfigAPI()
        return instance
    }()
    
    class var shared:EventsConfigAPI!{
        get{
            return sharedInstance
        }
    }
    
    /// Get Events Config from rest api. We are saving these Events to core data for offline use.
    ///
    /// - Parameters:
    ///   - callback: callback block.
    ///   - failure: failure block.
    func syncDownWithCompletion(completion: @escaping (()->()))
    {
        let req = SFRestRequest(method: .GET, path: SalesforceRestApiUrl.eventsConfig, queryParams: nil)
        req.endpoint = ""
        //req.endpoint = kSFDefaultRestEndpoint
        self.sendRequest(request: req, callback: { (response) in
            self.EventsConfigFromJSONList(jsonResponse: response as! Dictionary<String, AnyObject>)
            completion()
        }) { (error) in
            print(error)
            //failure(error)
        }
    }
    
    /// Get event config from core data.
    ///
    /// - Returns: array of events.
    func getEventsConfig()->MetadataConfig? {
        
        let eventConfigResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.metadataConfig.rawValue ,predicateFormat: "type == %@", predicateValue: MetadataConfigEnum.events.rawValue,isPredicate:true) as! [MetadataConfig]
        
        if(eventConfigResults.count > 0){
            return eventConfigResults.first
        }
        
        return nil
    }
    
    /// Convert the provided JSON into array of Events objects.
    ///
    /// - Parameter jsonResponse: json fetched from api.
    /// - Returns: nothing.
    private func EventsConfigFromJSONList(jsonResponse:Dictionary<String, AnyObject>){
        
        ManageCoreData.DeleteAllRecords(salesforceEntityName: coreDataEntity.metadataConfig.rawValue,completion: { isSuccess in
            
            if(isSuccess){
                let metadataConfig = MetadataConfig(context: context)
                metadataConfig.configData = jsonResponse as NSObject?
                metadataConfig.type = MetadataConfigEnum.events.rawValue
                
                appDelegate.saveContext()
            }
        })
        
    }
    
    
}




