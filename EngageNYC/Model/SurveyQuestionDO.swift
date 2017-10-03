//
//  SurveyQuestionDO.swift
//  MTXGIS
//
//  Created by Kamal on 26/02/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import Foundation

class SurveyQuestionDO{
    var questionId:String!
    var questionText:String!
    var questionType:String!
    var questionNumber:String!
    var choices: String? = nil
    var isRequired:Bool!
    
    var skipLogicArray : [[String:SkipLogic]] = []
    
    var isSkipLogic:String!
    var getDescriptionAnswer:String!
    
    
    init(questionId:String,questionText:String,questionType:String,questionNumber:String,isRequired:Bool,choices:String,
         skipLogicArray:[[String:SkipLogic]],isSkipLogic:String,getDescriptionAnswer:String) {
        self.questionId = questionId
        self.questionText = questionText
        self.questionType = questionType
        self.questionNumber = questionNumber
        self.isRequired = isRequired
        self.choices = choices
        self.skipLogicArray = skipLogicArray
        self.isSkipLogic = isSkipLogic
        self.getDescriptionAnswer = getDescriptionAnswer
        
    }
}


class SkipLogic{
    var skipLogicType:String!
    var questionNumber:String!
    var selectedAnswer:String!
    var showTextValue:String!
    
    init(skipLogicType:String,questionNumber:String,selectedAnswer:String,showTextValue:String){
        self.skipLogicType = skipLogicType
        self.questionNumber = questionNumber
        self.selectedAnswer = selectedAnswer
        self.showTextValue = showTextValue
        
    }
}

class SkipLogicParentChild{
    
    
    var childQuesionNumber:String!
    var parentQuestionNumber:String!
    var selectedAnswer:String!
    var skipLogicType:String!
    var showTextValue:String!
    
    init(childQuesionNumber:String,parentQuestionNumber:String,selectedAnswer:String,skipLogicType:String,showTextValue:String){
        
        self.childQuesionNumber = childQuesionNumber
        self.parentQuestionNumber = parentQuestionNumber
        self.selectedAnswer = selectedAnswer
        self.skipLogicType = skipLogicType
        self.showTextValue = showTextValue
        
    }
}

class SurveyResult:NSObject,NSCoding{
    
    var questionId:String!
    
    var questionType:String!
    var getDescription:String!
    var selectedAnswer:String!
    var multiOption = [String]()
    
    init(questionId:String,questionType:String,getDescription:String,selectedAnswer:String,multiOption:[String]){
        
        self.questionId = questionId
        self.questionType = questionType
        self.getDescription = getDescription
        self.selectedAnswer = selectedAnswer
        
        self.multiOption = multiOption
        
    }
    
    func encode(with aCoder: NSCoder) {
        // super.encodeWithCoder(aCoder) is optional, see notes below
        aCoder.encode(self.questionId, forKey: "questionId")
        aCoder.encode(self.questionType, forKey: "questionType")
        aCoder.encode(self.getDescription, forKey: "getDescription")
        aCoder.encode(self.selectedAnswer, forKey: "selectedAnswer")
        aCoder.encode(self.multiOption, forKey: "multiOption")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        // super.init(coder:) is optional, see notes below
        self.questionId = aDecoder.decodeObject(forKey: "questionId") as! String
        self.questionType = aDecoder.decodeObject(forKey: "questionType") as! String
        self.getDescription = aDecoder.decodeObject(forKey: "getDescription") as! String
        self.selectedAnswer = aDecoder.decodeObject(forKey: "selectedAnswer") as! String
        self.multiOption = aDecoder.decodeObject(forKey: "multiOption") as! [String]
    }
    
   
}




struct structSurveyQuestion {
    var key:String!
    var objectSurveyQuestion:SurveyQuestionDO!
}