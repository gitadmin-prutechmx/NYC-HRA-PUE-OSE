//
//  Utilities.swift
//  Knock
//
//  Created by Kamal on 12/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation
import UIKit
import ArcGIS

class Utilities {
    
   
    
    static var basemapMobileMapPackage:AGSMobileMapPackage!
    
    static var basemapLocator:AGSLocatorTask?
    
    static var currentSegmentedControl:String = ""
    
    // for skiplogic survey
    static var skipLogicParentChildDict : [String:[SkipLogic]] = [:]
    
    static var prevSkipLogicParentChildDict : [String:[SkipLogic]] = [:]
    
    static var isSubmitSurvey:Bool = false

    static var answerSurvey:String = ""
   
    static var SurveyOutput:[String:SurveyResult]=[:]
    
    static var surveyQuestionArray = [structSurveyQuestion]()
 
    static var surveyQuestionArrayIndex = -1

    static var currentSurveyPage = 0
    
    static var totalSurveyQuestions = 0
    

    
    class func deleteSkipSurveyData(startingIndex:Int,count:Int){
        
        for questionIndex in startingIndex...count {
            
            
            //Clear data which questions skipped
            let objTempSurveyQues =  Utilities.surveyQuestionArray[questionIndex].objectSurveyQuestion
            
            if(Utilities.SurveyOutput[(objTempSurveyQues?.questionNumber)!] != nil){
                
                //delete data from dictionary
                Utilities.SurveyOutput.removeValue(forKey: (objTempSurveyQues?.questionNumber)!)
            }
            
            
        }
        
        
        
    }

    
    class func convertToJSON(text: String) ->  [String: Any]? {
        
        if let data = text.data(using: .utf8) {
            
            do {
                
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
            } catch {
                
                print(error.localizedDescription)
                
            }
            
        }
        
        return nil
        
    }
    
    class func jsonToString(json: AnyObject)->String?{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            
           
            
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            
           // print(convertedString!)
            
            return convertedString!
            
           // print(convertedString) // <-- here is ur string
            
        } catch let myJSONError {
            print(myJSONError)
        }
        
        return nil
        
    }
    
    class func decryptJsonData(jsonEncryptString:String) -> String{
        
        
        
          //  var returnjsonData:Data?
        
            
            //Remove first two characters
            
            let startIndex = jsonEncryptString.index(jsonEncryptString.startIndex, offsetBy: 1)
            
            let headString = jsonEncryptString.substring(from: startIndex)
            
            
        
            //Remove last two characters
            
            let endIndex = headString.index(headString.endIndex, offsetBy: -1)
            
            let trailString = headString.substring(to: endIndex)
            
            
            let decryptData = try! trailString.aesDecrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
            
            
            
           // returnjsonData = decryptData.data(using: .utf8)
            
        
        
        
        return decryptData
        
    }

}

