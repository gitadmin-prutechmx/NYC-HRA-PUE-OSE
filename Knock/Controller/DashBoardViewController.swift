//
//  DashBoardViewController.swift
//  Knock
//
//  Created by Kamal on 13/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import Charts



class DashBoardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate
{
    let reuseIdentifier = "cell"
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var colChart: UICollectionView!
    
    var assignmentIdArray = [String]()
    var assignmentArray = [String]()
    var assignmentEventIdArray = [String]()
    
    var totalLocArray = [String]()
    var totalUnitsArray = [String]()
    
    var eventDict: [String:EventDO] = [:]
    
    
    let status = ["Completed", "In Progress", "Pending"]
    let values = [4.0, 3.0, 3.0]
    
    var timer = Timer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        var width = UIScreen.main.bounds.width
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//        width = width - 10
//        layout.itemSize = CGSize(width: width / 2, height: width / 2)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        colChart!.collectionViewLayout = layout
        
        if self.revealViewController() != nil {
            
            
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            // self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
       
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        imageView.contentMode = .scaleAspectFit
        
        
        let image = UIImage(named: "NYC")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        //self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        

        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "headerCellID")
        
        tableView.headerView(forSection: 0)
        
       // startTwoMinSyncing()
        
        NotificationCenter.default.addObserver(self, selector:#selector(DashBoardViewController.UpdateAssignmentView), name: NSNotification.Name(rawValue: "UpdateAssignmentView"), object:nil
        )
        
        populateChartData()
    }
    
    
    func UpdateAssignmentView(){
        
        print("UpdateAssignmentView")
        populateEventAssignmentData()
        populateChartData()
        
        
        //updateTableViewData()
    }
    
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateAssignmentView")
    }
    
    
    
    func startTwoMinSyncing(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(DashBoardViewController.checkConnection), userInfo: nil, repeats: true)
    }
    
    func checkConnection(){
        
        if(Network.reachability?.isReachable)!{
            
            syncDataWithSalesforce()
        }
        
    }
    
    var editLocationResultsArr = [EditLocation]()
    var unitResultsArr = [Unit]()
    var editUnitResultsArr = [EditUnit]()
    var surveyUnitResultsArr = [SurveyUnit]()
    var tenantResultsArr  = [Tenant]()
    var tenantAssignResultsArr = [TenantAssign]()
    var surveyResResultsArr = [SurveyResponse]()
    
    func syncDataWithSalesforce(){
        
        
        
        
        SalesforceConnection.loginToSalesforce(companyName: SalesforceConnection.companyName) {_ in
            
            self.editLocationResultsArr = ManageCoreData.fetchData(salesforceEntityName: "EditLocation",predicateFormat: "actionStatus == %@" ,predicateValue: "edit", isPredicate:true) as! [EditLocation]
            
            self.unitResultsArr = ManageCoreData.fetchData(salesforceEntityName: "Unit",predicateFormat: "actionStatus == %@" ,predicateValue: "create",isPredicate:true) as! [Unit]
            
            self.tenantResultsArr = ManageCoreData.fetchData(salesforceEntityName: "Tenant",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create", isPredicate:true) as! [Tenant]
            
            self.surveyResResultsArr = ManageCoreData.fetchData(salesforceEntityName: "SurveyResponse",predicateFormat: "actionStatus == %@" ,predicateValue: "edit", isPredicate:true) as! [SurveyResponse]
            
            
            self.editUnitResultsArr = ManageCoreData.fetchData(salesforceEntityName: "EditUnit",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create",isPredicate:true) as! [EditUnit]
            
            // self.surveyUnitResultsArr = ManageCoreData.fetchData(salesforceEntityName: "SurveyUnit",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create",isPredicate:true) as! [SurveyUnit]
            
            
            
            // self.tenantAssignResultsArr = ManageCoreData.fetchData(salesforceEntityName: "TenantAssign",predicateFormat: "actionStatus == %@ OR actionStatus == %@" ,predicateValue: "edit",predicateValue2: "create", isPredicate:true) as! [TenantAssign]
            
            
            
            //sync symbol
            
            
            //AssignmentDetail api and chart api call after push : Here data delete?
            
            
            if(self.editLocationResultsArr.count > 0){
                self.updateEditLocData()
            }
            else if(self.unitResultsArr.count > 0){
                self.updateUnitData()
            }//end of if
            else if(self.tenantResultsArr.count > 0){
                self.updateTenantData()
            }
            else if(self.surveyResResultsArr.count > 0){
                self.updateSurveyResponseData()
            }
            else if(self.editUnitResultsArr.count > 0){
                self.updateEditUnitData()
            }
            
            
        }
    }
    
    
    
    func updateEditLocData(){
        
        let locGroup = DispatchGroup()
        
        
        
        var locDict:[String:String] = [:]
        var editLoc : [String:String] = [:]
        
        
        
        
        
        if(self.editLocationResultsArr.count>0){
            
            for editLocData in self.editLocationResultsArr{
                
                locGroup.enter()
                
                locDict = Utilities.editLocData(canvassingStatus: editLocData.canvassingStatus!, assignmentLocationId: editLocData.assignmentLocId!, notes: editLocData.notes!, attempt: editLocData.attempt!)
                
                
                
                editLoc["location"] = Utilities.encryptedParams(dictParameters: locDict as AnyObject)
                
                
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.updateLocation, params: editLoc){ jsonData in
                    
                   
                    Utilities.parseEditLocation(jsonObject: jsonData.1)
                    locGroup.leave()
                    
                    
                    print("locGroup: \(editLocData.notes!)")
                    
                    
                    
                }//login to unit rest api
                
                
            }//end for loop
            
        }//end of if
            
        else{
            locGroup.enter()
            locGroup.leave()
        }
        
        locGroup.notify(queue: .main) {
            
            //Utilities.resetAllActionStatusFromEditLocation()
            
            if(self.unitResultsArr.count>0){
                self.updateUnitData()
            }
            else if(self.tenantResultsArr.count > 0){
                self.updateTenantData()
            }
            else if(self.surveyResResultsArr.count > 0){
                self.updateSurveyResponseData()
            }
            else if(self.editUnitResultsArr.count > 0){
                self.updateEditUnitData()
            }
            
            
        }
        
    }
    
    
    func updateUnitData(){
        
        let unitGroup = DispatchGroup()
        
        
        
        var unitDict:[String:String] = [:]
        var saveUnit : [String:String] = [:]
        
        
        if(self.unitResultsArr.count > 0){
            
            
            
            for unitData in self.unitResultsArr{
                
                unitGroup.enter()
                
                unitDict = Utilities.createUnitDicData(unitName: unitData.name!, apartmentNumber: unitData.apartment!, locationId: unitData.locationId!, assignmentLocId: unitData.assignmentLocId!, notes: unitData.notes!, iosLocUnitId: unitData.id!, iosAssignLocUnitId: unitData.assignmentLocUnitId!)
                
                
                
                saveUnit["unit"] = Utilities.encryptedParams(dictParameters: unitDict as AnyObject)
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.createUnit, params: saveUnit){ jsonData in
                    
                    
                    
                    _ = Utilities.parseAddNewUnitResponse(jsonObject: jsonData.1)
                    
                    unitGroup.leave()
                    
                    print("UnitGroup: \(unitData.name!)")
                    
                }//login to salesforce
                
            }//end for loop
            
        }
        else{
            unitGroup.enter()
            unitGroup.leave()
        }
        
        
        
        unitGroup.notify(queue: .main) {
            
            //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
            
            if(self.tenantResultsArr.count > 0){
                self.updateTenantData()
            }
            else if(self.surveyResResultsArr.count > 0){
                self.updateSurveyResponseData()
            }
            else if(self.editUnitResultsArr.count > 0){
                self.updateEditUnitData()
            }
            
            
        }
    }
    
    
    func updateTenantData(){
        
        let tenantGroup = DispatchGroup()
        
        var tenantDict:[String:String] = [:]
        var editTenant : [String:String] = [:]
        
        
        
        if(self.tenantResultsArr.count > 0){
            
            
            
            for tenantData in self.tenantResultsArr{
                
                tenantGroup.enter()
                
                let tenantId = tenantData.id!
                let locUnitId = tenantData.unitId!
                
                tenantDict = Utilities.createAndEditTenantData(firstName: tenantData.firstName!, lastName: tenantData.lastName!, email: tenantData.email!, phone: tenantData.phone!, dob: tenantData.dob!, locationUnitId: locUnitId, currentTenantId: tenantId, iOSTenantId: tenantId,type:tenantData.actionStatus!)
                
                
                
                editTenant["tenant"] = Utilities.encryptedParams(dictParameters: tenantDict as AnyObject)
                
                
                
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.createTenant, params: editTenant){ jsonData in
                    
                    
                    _ = Utilities.parseTenantResponse(jsonObject: jsonData.1)
                    tenantGroup.leave()
                    print("tenantGroup: \(tenantData.firstName!)")
                    
                    
                }//login to unit rest api
            }//end for loop
            
        }
        else{
            tenantGroup.enter()
            tenantGroup.leave()
        }
        
        
        
        tenantGroup.notify(queue: .main) {
            //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTenantView"), object: nil)
            
            if(self.surveyResResultsArr.count > 0){
                self.updateSurveyResponseData()
            }
            else if(self.editUnitResultsArr.count > 0){
                self.updateEditUnitData()
            }
           
            
        }
        
        
        
    }
    
    
    func updateSurveyResponseData(){
        
        let surveyResponseGroup = DispatchGroup()
        
        
        var surveyResponseStr:String = ""
        var formatString:String = ""
        var responseDict : [String:AnyObject] = [:]
        var surveyResponseParam : [String:String] = [:]
        
        
        if(self.surveyResResultsArr.count > 0){
            
            for surveyResData in self.surveyResResultsArr{
                
                surveyResponseGroup.enter()
                
                responseDict["surveyId"] = surveyResData.surveyId! as AnyObject?
                responseDict["assignmentLocUnitId"] = surveyResData.assignmentLocUnitId! as AnyObject?
                //unitid
                responseDict["QuestionList"] = surveyResData.surveyQuestionRes! as AnyObject?
                
                
                formatString = Utilities.jsonToString(json: responseDict as AnyObject)!
                
                print("formatString \(formatString)")
                
                surveyResponseStr = try! formatString.aesEncrypt(SalesforceConfig.key, iv: SalesforceConfig.iv)
                
                print("surveyResponseStr \(surveyResponseStr)")
                
                surveyResponseParam["surveyResponseFile"] = surveyResponseStr
                
                
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.submitSurveyResponse, params: surveyResponseParam){ jsonData in
                    
                    
                    Utilities.parseSurveyResponse(jsonObject: jsonData.1)
                    surveyResponseGroup.leave()
                    print("surveyResponseGroup: \(surveyResData.surveyId!)")
                    
                }//login to unit rest api
            }//end for loop
            
        }
            
        else{
            surveyResponseGroup.enter()
            surveyResponseGroup.leave()
        }
        
        surveyResponseGroup.notify(queue: .main) {
            
            if(self.editUnitResultsArr.count > 0){
                self.updateEditUnitData()
            }
          
            
            //assignmentdetail and charrts api
            
        }
        
        
    }
    
    
    
    
    func updateEditUnitData(){
        
        let editUnitGroup = DispatchGroup()
        
        
        
        var updateUnit : [String:String] = [:]
        var editUnitDict : [String:String] = [:]
        
        
        
        
        if(self.editUnitResultsArr.count > 0){
            
            
            for editUnitData in self.editUnitResultsArr{
                
                editUnitGroup.enter()
                
                
                editUnitDict = Utilities.editUnitTenantAndSurveyDicData(tenantStatus: editUnitData.tenantStatus!, notes: editUnitData.unitNotes!, attempt: editUnitData.attempt!, contact: editUnitData.isContact!, reKnockNeeded: editUnitData.reKnockNeeded!, inTakeStatus: editUnitData.inTakeStatus!, assignmentLocationUnitId: editUnitData.assignmentLocUnitId!,selectedSurveyId: editUnitData.surveyId!,selectedTenantId: editUnitData.tenantId!,lastCanvassedBy: "")
                
                
                
                updateUnit["unit"] = Utilities.encryptedParams(dictParameters: editUnitDict as AnyObject)
                
                SalesforceConnection.SalesforceData(restApiUrl: SalesforceRestApiUrl.updateUnit, params: updateUnit){ jsonData in
                    
                    Utilities.parseEditUnit(jsonObject: jsonData.1)
                    editUnitGroup.leave()
                    print("editUnitGroup: \(editUnitData.tenantStatus!)")
                    
                }//login to unit rest api
                
                
                
            }
        }
            
        else{
            editUnitGroup.enter()
            editUnitGroup.leave()
        }
        
        
        
        
        
        editUnitGroup.notify(queue: .main) {
            
        }
        
    }
    
    
        
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        populateEventAssignmentData()
        

    }
    
   //MARK: - chartMethods
 
    func barChartData(custumView:UIView)
    {
        
        let colors = getColors()
        
        let chart = BarChartView(frame: custumView.frame)
  
        //let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        //let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        
        var dataEntries: [BarChartDataEntry] = []
        //String(describing: languages)z
        for i in 0..<chart1StatusArray.count
        {
            let dataEntry =   BarChartDataEntry(x: chart1ValueArray[i], y: Double(i))
            dataEntries.append(dataEntry)
        }
        
      
        
        //chart.isUserInteractionEnabled = true
        
        let d = Description()
        d.text = " "
        chart.chartDescription = d
        
        
        let set = BarChartDataSet( values: dataEntries, label: "")
        set.colors = colors
        
        
        let chartData = BarChartData(dataSet: set)
        chart.data = chartData
        chart.noDataText = "No data available"
        
        custumView.addSubview(chart)
        
        
    }
    
    func circleChartData(custumView:UIView,chartValue:String,chartColor:UIColor)
    {
       // let colors = getColors()
        
        
        let chart = GaugeView(frame: custumView.frame)
        
       // chart.percentage = 80
        
        chart.labelText = chartValue
        
        chart.thickness = 10
        
        chart.labelFont = UIFont.systemFont(ofSize: 40, weight: UIFontWeightThin)
        chart.labelColor = UIColor.black
        //chart.gaugeBackgroundColor = UIColor.green
        chart.gaugeColor = chartColor
       
        chart.isUserInteractionEnabled = true
        chart.accessibilityLabel = "Gauge"

        
        
        custumView.addSubview(chart)
    }

    func updateChartData(custumView:UIView)
    {
        
        let chart = LineChartView(frame: custumView.frame)
        var entries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = status[index]
            entries.append( entry)
        }
        // 3. chart setup
        let set = LineChartDataSet( values: entries, label: "")
      
        var colors: [UIColor] = []
        
        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        set.colors = colors
        let data = LineChartData(dataSet: set)
        chart.data = data
        chart.noDataText = "No data available"
        chart.isUserInteractionEnabled = true
        
        let d = Description()
        //d.text = "iOSCharts.io"
        chart.chartDescription = d
        
        custumView.addSubview(chart)
    }
    
    
    func getColors()->[UIColor]{
        
        var colors: [UIColor] = []
        
        // Color object : get rgb
        
        let completedColor = UIColor(red: CGFloat(18.0/255), green: CGFloat(136.0/255), blue: CGFloat(189.0/255), alpha: 1)
        let InProgressColor = UIColor(red: CGFloat(173.0/255), green: CGFloat(235.0/255), blue: CGFloat(253.0/255), alpha: 1)
        let PendingColor = UIColor(red: CGFloat(54.0/255), green: CGFloat(191.0/255), blue: CGFloat(244.0/255), alpha: 1)
        // let BlankColor = UIColor(red: CGFloat(235.0/255), green: CGFloat(237.0/255), blue: CGFloat(248.0/255), alpha: 1)
        
        colors.append(completedColor)
        colors.append(InProgressColor)
        colors.append(PendingColor)
        
        return colors
        // colors.append(BlankColor)

    }
    
    
    
    
    var chart1Label:String = ""
    var chart1StatusArray = [String]()
    var chart1ValueArray = [Double]()
    
    var chart2Label:String = ""
    var chart2Value:String = ""
    
    var chart3Label:String = ""
    var chart3Value:String = ""
    
    var chart4Label:String = ""
    var chart4Value:String = ""
    
    
    func populateChartData(){
        
        chart1Label = ""
        chart1StatusArray = []
        chart1ValueArray = []
        
        chart2Label = ""
        chart2Value = ""
        
        chart3Label = ""
        chart3Value = ""
        
        chart4Label = ""
        chart4Value = ""

        
         let chart1Results = ManageCoreData.fetchData(salesforceEntityName: "Chart",predicateFormat: "chartType == %@",predicateValue: "Chart1",isPredicate:true) as! [Chart]
        
        if(chart1Results.count > 0){
            
            for chart1Data in chart1Results{
              
                chart1StatusArray.append(chart1Data.chartLabel!)
                chart1ValueArray.append(Double(chart1Data.chartValue!)!)

               chart1Label = chart1Data.chartLabel!

            }
        }
        
        let chart2Results = ManageCoreData.fetchData(salesforceEntityName: "Chart",predicateFormat: "chartType == %@",predicateValue: "Chart2",isPredicate:true) as! [Chart]
        
        if(chart2Results.count > 0){
            
            chart2Label = chart2Results[0].chartLabel!
            chart2Value = chart2Results[0].chartValue!
           
        }
        
        let chart3Results = ManageCoreData.fetchData(salesforceEntityName: "Chart",predicateFormat: "chartType == %@",predicateValue: "Chart3",isPredicate:true) as! [Chart]
        
        if(chart3Results.count > 0){
            
            chart3Label = chart3Results[0].chartLabel!
            chart3Value = chart3Results[0].chartValue!
            
        }
        
        let chart4Results = ManageCoreData.fetchData(salesforceEntityName: "Chart",predicateFormat: "chartType == %@",predicateValue: "Chart4",isPredicate:true) as! [Chart]
        
        if(chart4Results.count > 0){
            
            chart4Label = chart4Results[0].chartLabel!
            chart4Value = chart4Results[0].chartValue!
            
        }
        
        
       
        
        colChart.reloadData()
       
        
        
    }
    
    func populateEventAssignmentData()
    {
        assignmentIdArray = []
        assignmentArray = []
        assignmentEventIdArray = []
        totalLocArray = []
        totalUnitsArray = []
        eventDict = [:]
        
        
        createEventDictionary()
        
        //location count and unit count
       
        
        //location --> assignmentid
        //units----> locationId
        
        let assignmentResults = ManageCoreData.fetchData(salesforceEntityName: "Assignment",isPredicate:false) as! [Assignment]
            
        if(assignmentResults.count > 0){
                
            for assignmentdata in assignmentResults{
                    assignmentArray.append(assignmentdata.name!)
                    assignmentIdArray.append(assignmentdata.id!)
                    assignmentEventIdArray.append(assignmentdata.eventId!)
                    totalLocArray.append(assignmentdata.totalLocations!)
                    totalUnitsArray.append(assignmentdata.totalUnits!)
                }
            }

        tableView.reloadData()
        
       
    
     
    }
    
    func createEventDictionary(){
        
        
        
        let eventResults =  ManageCoreData.fetchData(salesforceEntityName: "Event", isPredicate:false) as! [Event]
        
        if(eventResults.count > 0){
            
            for eventData in eventResults{
                
                if eventDict[eventData.id!] == nil{
                    eventDict[eventData.id!] = EventDO(eventId: eventData.id!, eventName: eventData.name!, startDate: eventData.startDate!, endDate: eventData.endDate!)
                }
                
                
            }
        }
        
    }
    

    
    // MARK: - Models
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)as!ChartCollectionViewCell
        
        //cell.lblChart.text = chart1Label
        
        //cell.chartView = UIView()
        
        if indexPath.row == 0
        {
           
           barChartData(custumView: cell.chartView)
            
           cell.lblChart.text = chart1Label
           
        }
        
        if indexPath.row == 1
        {
            circleChartData(custumView: cell.chartView, chartValue: chart2Value, chartColor: UIColor.green)
            
             cell.lblChart.text = chart2Label
           
        }
        if indexPath.row == 2
        {
           circleChartData(custumView: cell.chartView, chartValue: chart3Value, chartColor: UIColor.red)
           
             cell.lblChart.text = chart3Label
            
        }
        if indexPath.row == 3
        {
            circleChartData(custumView: cell.chartView, chartValue: chart4Value, chartColor: UIColor.yellow)
           
             cell.lblChart.text = chart4Label
           // updateChartData(custumView: cell.chartView)
            
        }
        
        
       
        
        
        //cell.myLabel.text = self.items[indexPath.item]
        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }

    
    // MARK: UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignmentArray.count
    }
    
    // cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataRowId", for: indexPath) as! EventAssignmentViewCell
        
        cell.assignmentName.text = assignmentArray[indexPath.row]
        
        let eventObject = eventDict[assignmentEventIdArray[indexPath.row]]
 
        cell.eventName.text = eventObject?.eventName
        
        cell.locations.text = totalLocArray[indexPath.row]
        cell.units.text = totalUnitsArray[indexPath.row]
        cell.assignmentId.text = assignmentIdArray[indexPath.row]

        cell.completePercent.text = ""
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        
        let identifier = "headerCellID"
        var cell: HeaderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? HeaderTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? HeaderTableViewCell
        }
        
        return cell
    
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  35.0
    }
    
    
    
    @IBAction func UnwindBackFromMapLocation(segue:UIStoryboardSegue) {
        
        print("UnwindBackFromMapLocation")
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        SalesforceConnection.assignmentId =  assignmentIdArray[indexPath.row]
          SalesforceConnection.assignmentName = assignmentArray[indexPath.row]
        
        
        
    }
    
     func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        let currentCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! EventAssignmentViewCell
        
        
        SalesforceConnection.assignmentId =  currentCell.assignmentId.text!
        SalesforceConnection.assignmentName = currentCell.assignmentName.text!
        
    }


}
