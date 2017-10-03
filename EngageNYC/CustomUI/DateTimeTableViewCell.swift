//
//  DateTimeTableViewCell.swift
//  TestApplication
//
//  Created by Kamal on 30/07/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit

class DateTimeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var btnToday:UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var frameAdded = false
    
    class var expandHeight:CGFloat{ get {return 316 } }
    class var defaultHeight:CGFloat{ get {return 44 } }
    
    @IBAction func dateTimeChanged(_ sender: Any) {
        
        
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        Utilities.selectedDateTimeDictYYYYMMDD[Utilities.currentApiName] = dateFormatter.string(from: datePicker.date)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MM-dd-yyyy"
        detail.text = dateFormatter1.string(from: datePicker.date)


        Utilities.caseConfigDict[Utilities.currentApiName] = datePicker.date as AnyObject?
        
        //Utilities.selectedDateTimeDictInMMDDYYYY[Utilities.currentApiName] = detail.text
        //Utilities.selectedDatePicker[Utilities.currentApiName] = datePicker.date
        
        print(datePicker.date)
    }
    
    @IBAction func btnTodayAction(_ sender: UIButton)
    {
       // datePicker.setDate(Date(), animated: false)
         datePicker.date = Date()
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: todaysDate)
        detail.text = dateString
        
        Utilities.caseConfigDict[Utilities.currentApiName] = datePicker.date as AnyObject?
        
    }
    
    func checkHeight(){
        datePicker.isHidden = (frame.size.height < DateTimeTableViewCell.expandHeight)
         btnToday.isHidden = (frame.size.height < DateTimeTableViewCell.expandHeight)
    }
    
    func watchFrameChanges() {
        if(!frameAdded){
            addObserver(self , forKeyPath: "frame", options: .new, context: nil )
            frameAdded = true
            checkHeight()
        }
    }
    
    func ignoreFrameChanges() {
        if(frameAdded){
            removeObserver(self, forKeyPath: "frame")
            frameAdded = false
        }
    }

    deinit {
        print("deinit called");
        ignoreFrameChanges()
    }

    

    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame"{
            checkHeight()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}