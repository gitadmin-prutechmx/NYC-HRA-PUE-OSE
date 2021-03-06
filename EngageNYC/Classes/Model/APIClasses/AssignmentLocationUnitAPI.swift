//
//  AssignmentLocationUnitAPI.swift
//  EngageNYC
//
//  Created by Kamal on 14/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import Foundation
import SalesforceSDKCore

final class AssignmentLocationUnitAPI:SFCommonAPI {
    
    
    private static var sharedInstance: AssignmentLocationUnitAPI = {
        let instance = AssignmentLocationUnitAPI()
        return instance
    }()
    
    class var shared:AssignmentLocationUnitAPI!{
        get{
            return sharedInstance
        }
    }
    
    
    /// Get all the locationUnits from core data.
    ///
    /// - Returns: array of assignmentlocationUnits.
    func getAllAssignmentLocationUnits(assignmentId:String)->[String:AssignmentLocationUnitDO] {
        
        let assignmentLocationUnitRes = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue,predicateFormat: "assignmentId == %@",predicateValue: assignmentId, isPredicate:true) as! [AssignmentLocationUnit]
        
        var assignmentLocUnitDict:[String:AssignmentLocationUnitDO] = [:]
        if(assignmentLocationUnitRes.count > 0){
            
            for assignmentLocUnitData in assignmentLocationUnitRes{
                
                if assignmentLocUnitDict[assignmentLocUnitData.assignmentLocUnitId!] == nil{
                    assignmentLocUnitDict[assignmentLocUnitData.assignmentLocUnitId!] = AssignmentLocationUnitDO(assignmentLocationUnitId: assignmentLocUnitData.assignmentLocUnitId!, attempted: assignmentLocUnitData.attempted!, contacted: assignmentLocUnitData.contacted!,surveySyncDate:assignmentLocUnitData.surveySyncDate!)
                }
            }
            
          
        }
        
        return assignmentLocUnitDict
        
    }
    
    
    
    func getAllUpdatedAssignmentLocationUnits() -> [AssignmentLocationUnit]?{
        
        let assignmentLocUnitResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue ,predicateFormat: "actionStatus == %@ || actionStatus == %@",predicateValue:actionStatus.create.rawValue,predicateValue2: actionStatus.edit.rawValue, isPredicate:true) as? [AssignmentLocationUnit]
        
        return assignmentLocUnitResults
    }
    
    
    
    func syncUpCompletion(completion: @escaping (()->()))
    {
        if let arrAssignmentLocUnits = getAllUpdatedAssignmentLocationUnits(){
            
            let assignmentLocUnitGroup = DispatchGroup()
            
            for assignmentLocUnit in arrAssignmentLocUnits{
                
                var assignmentLocUnitDict:[String:String] = [:]
                var assignmentLocUnitParams:[String:String] = [:]
                
                
                var sfdcClientId = assignmentLocUnit.contactId
                var sfdcAssignmentLocUnitId = assignmentLocUnit.assignmentLocUnitId
                
                
                //...........assignmentLocUnit info
                
                let isiOSAssignmentLocUnitId = Utility.isiOSGeneratedId(generatedId: sfdcAssignmentLocUnitId!)

                //if isiOSLocationUnitId is a UUID string then get salesforce assignmentlocationUnit from unit object
                if(isiOSAssignmentLocUnitId != nil){
                    let assignmentLocUnitId = LocationUnitAPI.shared.getSalesforceAssignmentLocationUnitId(iOSAssignmentLocUnitId: sfdcAssignmentLocUnitId!)

                    sfdcAssignmentLocUnitId = assignmentLocUnitId //update assignmentLocUnit id here
                    
                    if(Utility.isiOSGeneratedId(generatedId: assignmentLocUnitId) != nil){
                        print("Error:- ios assignmentlocationunitid")
                        return
                    }
                    else{
                        //update assignmentLocationUnitId here
                        
                       // updateAssignmentLocationUnitId(salesforceAssignmentLocUnitId: assignmentLocUnitId, iOSAssignmentLocUnitId: assignmentLocUnit.assignmentLocUnitId!)
                    }
                }
                
                
                let isiOSClientId = Utility.isiOSGeneratedId(generatedId: sfdcClientId!)
                
                //if isiOSClientId is a UUID string then get salesforce clientid from contact object
                if(isiOSClientId != nil){
                    let clientId = ContactAPI.shared.getSalesforceClientId(iOSClientId: sfdcClientId!)
                    
                    sfdcClientId = clientId //update clientId
                    
                    if(Utility.isiOSGeneratedId(generatedId: clientId) != nil){
                        print("Error:- ios clientId")
                        return
                    }
                    else{
                        //update assignmentLocationUnitId here
                        
                       // updateClientId(salesforceClientId: clientId, iOSClientId: assignmentLocUnit.contactId!)
                    }
                }
                
                
                
                //reason, reknockneeded
                //intake :- update to survyed
                //tenantId:- update to contactId
                
                assignmentLocUnitDict["assignmentLocationUnitId"] = sfdcAssignmentLocUnitId
                
                assignmentLocUnitDict["iOSAssignmentLocUnitId"] = assignmentLocUnit.assignmentLocUnitId
                
                
                assignmentLocUnitDict["intake"] = assignmentLocUnit.surveyed
                assignmentLocUnitDict["attempt"] = assignmentLocUnit.attempted
                assignmentLocUnitDict["contact"] = assignmentLocUnit.contacted
                assignmentLocUnitDict["contactOutcome"] = assignmentLocUnit.contactOutcome
                assignmentLocUnitDict["surveyId"] = assignmentLocUnit.surveyId
                assignmentLocUnitDict["tenantId"] = sfdcClientId
                
                assignmentLocUnitDict["notes"] = assignmentLocUnit.notes
                
                assignmentLocUnitDict["lastCanvassedBy"] = assignmentLocUnit.lastCanvassedBy
                
                if(assignmentLocUnit.followUpDate != ""){
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    
                    if let date =  dateFormatter.date(from: assignmentLocUnit.followUpDate!){
                        
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        assignmentLocUnitDict["followUpDate"] = dateFormatter.string(from: date)
                        
                    }
                    else{
                        assignmentLocUnitDict["followUpDate"] = assignmentLocUnit.followUpDate!
                    }
                    
                }
                
                assignmentLocUnitDict["followUpType"] = assignmentLocUnit.followUpType
                
                assignmentLocUnitParams["unit"] = Utility.jsonToString(json: assignmentLocUnitDict as AnyObject)!
                
                let req = SFRestRequest(method: .POST, path: SalesforceRestApiUrl.updateAssignmentLocationUnit, queryParams: nil)
                
                do {
                    
                    let bodyData = try JSONSerialization.data(withJSONObject: assignmentLocUnitParams, options: [])
                    req.setCustomRequestBodyData(bodyData, contentType: "application/json")
                }
                catch{
                    
                    
                }
                
                req.endpoint = ""
                
                assignmentLocUnitGroup.enter()
                
                self.sendRequest(request: req, callback: { (response) in
                    
                    DispatchQueue.main.async {
                        
                        self.parseAssignmentLocationUnit(jsonObject: response as! Dictionary<String, AnyObject>)
                        
                        assignmentLocUnitGroup.leave()
                        
                        print("AssignmentLocationUnitGroup: \(assignmentLocUnit.assignmentLocUnitId!)")
                    }
                    
                    
                    
                }) { (error) in
                    Logger.shared.log(level: .error, msg: error)
                    Utility.displayErrorMessage(errorMsg: error)
                    //failure(error)
                }
                
            }
            
            assignmentLocUnitGroup.notify(queue: .main) {
                completion()
            }
            
        }
        else{
            completion()
        }
        
        
    }
    
    func parseAssignmentLocationUnit(jsonObject: Dictionary<String, AnyObject>){
        
        let assignmentLocUnitId = jsonObject["iOSAssignmentLocUnitId"] as? String
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["actionStatus"] = "" as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue:  assignmentLocUnitId,isPredicate: true)
        
        //update sync date
        if(assignmentLocUnitId !=  nil){
           LocationUnitAPI.shared.updateSyncDate(assignmentLocUnitId: assignmentLocUnitId!)
        }
        
    
    }
    
   
    
    
    func createNewTempAssignmentLocationUnit(assignmentLocUnitId:String,assignmentId:String){
    
        
        let assignmentLocUnit = AssignmentLocationUnit(context:context)
        assignmentLocUnit.actionStatus = ""
        assignmentLocUnit.assignmentLocUnitId = assignmentLocUnitId
        assignmentLocUnit.attempted = ""
        assignmentLocUnit.contacted = ""
        assignmentLocUnit.surveyed = ""
        assignmentLocUnit.contactOutcome = ""
        assignmentLocUnit.contactId = ""
        assignmentLocUnit.followUpType = ""
        assignmentLocUnit.followUpDate = ""
        assignmentLocUnit.assignmentId = assignmentId
        assignmentLocUnit.notes = ""
        assignmentLocUnit.lastCanvassedBy = ""
        assignmentLocUnit.surveySyncDate = ""
        assignmentLocUnit.surveyId = ""
        assignmentLocUnit.iOSAssignmentLocUnitId = assignmentLocUnitId
        
        
        appDelegate.saveContext()
        
    }
    

    
    func updateAssignmentLocationUnit(assignmentLocUnitInfo:AssignmentLocationUnitInfoDO){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        if(assignmentLocUnitInfo.contacted == boolVal.no.rawValue){
            assignmentLocUnitInfo.contactOutcome = assignmentLocUnitInfo.contactOutcomeNo == contactOutcomePlaceholder.selectOutcome.rawValue ? "" : assignmentLocUnitInfo.contactOutcomeNo
        }
        else{
            assignmentLocUnitInfo.contactOutcome = assignmentLocUnitInfo.contactOutcomeYes == contactOutcomePlaceholder.selectOutcome.rawValue ? "" : assignmentLocUnitInfo.contactOutcomeYes
        }
        
        updateObjectDic["attempted"] = assignmentLocUnitInfo.attempted as AnyObject?
        updateObjectDic["contacted"] = assignmentLocUnitInfo.contacted as AnyObject?
        updateObjectDic["surveyed"] = assignmentLocUnitInfo.surveyed as AnyObject?
        updateObjectDic["contactOutcome"] = assignmentLocUnitInfo.contactOutcome as AnyObject?
        updateObjectDic["contactId"] = assignmentLocUnitInfo.contactId as AnyObject?
        updateObjectDic["followUpType"] = assignmentLocUnitInfo.followUpType as AnyObject?
        updateObjectDic["followUpDate"] = assignmentLocUnitInfo.followUpDate as AnyObject?
        updateObjectDic["notes"] = assignmentLocUnitInfo.notes as AnyObject?
        updateObjectDic["actionStatus"] = actionStatus.edit.rawValue as AnyObject?
        updateObjectDic["lastCanvassedBy"] = "" as AnyObject?
        
        let queryString = getQueryString(assignmentLocUnitId: assignmentLocUnitInfo.assignmentLocationUnitId)
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue , updateKeyValue: updateObjectDic, predicateFormat: queryString, predicateValue:  assignmentLocUnitInfo.assignmentLocationUnitId,isPredicate: true)
        
    }
    
    func updateClientId(salesforceClientId:String,iOSClientId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["contactId"] = salesforceClientId as AnyObject
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "contactId == %@", predicateValue:  iOSClientId,isPredicate: true)
        
    }
    
    func updateAssignmentLocationUnitId(salesforceAssignmentLocUnitId:String,iOSAssignmentLocUnitId:String){
        
        var updateObjectDic:[String:AnyObject] = [:]
        
        updateObjectDic["assignmentLocUnitId"] = salesforceAssignmentLocUnitId as AnyObject
        
        
        ManageCoreData.updateRecord(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue, updateKeyValue: updateObjectDic, predicateFormat: "assignmentLocUnitId == %@", predicateValue:  iOSAssignmentLocUnitId,isPredicate: true)
        
    }
    
    
    
   
    
    
}


extension AssignmentLocationUnitAPI{
    
    func getAssignmentLocationUnit(assignmentLocUnitId:String) -> AssignmentLocationUnit?{
        
        let queryString = getQueryString(assignmentLocUnitId: assignmentLocUnitId)
        
        let assignmentLocUnitResults = ManageCoreData.fetchData(salesforceEntityName: coreDataEntity.assignmentLocationUnit.rawValue ,predicateFormat: queryString,predicateValue:assignmentLocUnitId, isPredicate:true) as! [AssignmentLocationUnit]
        
        if(assignmentLocUnitResults.count > 0){
            return assignmentLocUnitResults.first
        }
        
        return nil
    }
    
    func getQueryString(assignmentLocUnitId:String)->String{
        
        var queryString = ""
        let isiOSAssignmentLocUnitId = Utility.isiOSGeneratedId(generatedId: assignmentLocUnitId)
        
        //if isiOSAssignmentLocUnitId is a UUID string
        if(isiOSAssignmentLocUnitId != nil){
            queryString = "iOSAssignmentLocUnitId == %@"
        }
        else{
            queryString = "assignmentLocUnitId == %@"
        }
        
        return queryString
        
        
    }
    
}
