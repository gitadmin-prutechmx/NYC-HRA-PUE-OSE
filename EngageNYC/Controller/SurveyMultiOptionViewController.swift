
import UIKit
import AudioToolbox

class SurveyMultiOptionViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var toolBarView: UIView!
    
    
    @IBOutlet weak var getDescriptionTextField: UITextField!
    
    //@IBOutlet weak var showTextLbl: UILabel!
    @IBOutlet weak var showTextLbl: UITextView!
    
    @IBOutlet weak var surveyName: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    //@IBOutlet weak var optionsCollectionView: UICollectionView!
    //@IBOutlet weak var textView: UIView!
    //@IBOutlet weak var radioOptionsView: UIView!
    
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    
    @IBOutlet weak var radioOptionsView: UIView!
    
    
    var objSurveyQues:SurveyQuestionDO!
    var optionsIdArray = [String]()
    var optionsTextArray = [String]()
    
    var optionsDic : [String:String] = [:]
    
    var radiobuttonCurrentValue:String = ""
    
    @IBOutlet weak var flagView: UIStackView!
    @IBOutlet weak var prevBtnOutlet: UIButton!
    
    @IBOutlet weak var questionsView: UIView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //optionsCollectionView.flashScrollIndicators()
        
        self.toolBarView.layer.borderWidth = 2
        self.toolBarView.layer.borderColor =  UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 86.0/255.0, blue: 153.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
       self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        getDescriptionTextField.layer.borderColor = UIColor.gray.cgColor
        
        getDescriptionTextField.layer.borderWidth = 1.0
        
        getDescriptionTextField.layer.cornerRadius = 10.0
        
        
//        if let layout = optionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
//        {
//            layout.scrollDirection = .vertical
//        }
        
        /* let btnName = UIButton()
         btnName.setImage(UIImage(named: "ExitSurvey"), forState: .Normal)
         btnName.frame = CGRectMake(0, 0, 30, 30)
         btnName.addTarget(self, action: Selector("action"), forControlEvents: .TouchUpInside)
         
         //.... Set Right/Left Bar Button item
         let rightBarButton = UIBarButtonItem()
         rightBarButton.customView = btnName
         self.navigationItem.rightBarButtonItem = rightBarButton
         */
        
        let rightExitSurveyBarButtonItem = UIBarButtonItem(image: UIImage(named: "ExitSurvey.png"), style: .plain, target: self, action: #selector(SurveyRadioOptionViewController.exitFromSurvey))
        
        self.navigationItem.rightBarButtonItem  = rightExitSurveyBarButtonItem

        
     
        self.navigationItem.title =  SalesforceConnection.surveyName
        

        
        
        let leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action:  nil)
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
        
        
        
        
        objSurveyQues = Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        questionText.text = objSurveyQues.questionText
        
        if(Utilities.SurveyOutput[objSurveyQues.questionNumber] != nil){
            let objSurveyOutput:SurveyResult = Utilities.SurveyOutput[objSurveyQues.questionNumber]!
            getDescriptionTextField.text = objSurveyOutput.getDescription
        }
        
        
        
        // let options = objSurveyQues.choices!.replace("\r\n", withString:";")
        let options = objSurveyQues.choices!
        
        print(options)
        
        optionsTextArray = options.components(separatedBy: ";")
        
        
        /*  for optionData in objSurveyQues.singleOptionsString!
         {
         optionsIdArray.append(optionData.componentsSeparatedByString(";")[1])
         optionsTextArray.append(optionData.componentsSeparatedByString(";")[0])
         
         optionsDic[optionData.componentsSeparatedByString(";")[1]] = optionData.componentsSeparatedByString(";")[0]
         }
         */
        
        pageControl.numberOfPages = Utilities.surveyQuestionArray.count
        
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        
        
        // optionsCollectionView.delegate = self
        // optionsCollectionView.dataSource = self
        
        //view.frame.width
        
        // Do any additional setup after loading the view.
    }
    
    //func exitFromSurvey(_: UIBarButtonItem!)  {
    func exitFromSurvey()
    {
        
        let alertCtrl = Alert.showUIAlert(title: "Message", message: "Are you sure want to exit from survey?", vc: self)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            //Do some stuff
        }
        alertCtrl.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            
            Utilities.isExitFromSurvey = true
            Utilities.isSubmitSurvey = false

            
            SurveyUtility.saveInProgressSurveyToCoreData(surveyStatus: Utilities.inProgressSurvey)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUnitView"), object: nil)
          
            self.performSegue(withIdentifier: "UnwindBackFromSurveyIdentifier", sender: self)
    
        }
        alertCtrl.addAction(okAction)
        
        
    }
    
    @IBAction func switchSurvey(_ sender: Any) {
        
       SurveyUtility.SwitchNewSurvey(vc: self)
        
    }
    
    
    @IBAction func inTake(_ sender: Any) {
        
        SurveyUtility.InTake(vc: self)
    }
    
    
    @IBAction func access(_ sender: Any)
    {
        if UIApplication.shared.canOpenURL(URL(string: "https://access.nyc.gov")!)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "https://access.nyc.gov")!, options: [UIApplicationOpenURLOptionUniversalLinksOnly:""], completionHandler: { (completed) in
                    self.navigationController?.popToRootViewController(animated: true)
                })
            } else
            {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string : "https://access.nyc.gov")!)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedOptions = []
        let surveyOutputObject = Utilities.SurveyOutput[objSurveyQues.questionNumber]
        
        if(surveyOutputObject != nil){
            selectedOptions = (surveyOutputObject?.multiOption)!
        }
        
        
        
        if(Utilities.surveyQuestionArrayIndex == 0)
        {
            
            prevBtnOutlet.isHidden = true
            // self.navigationItem.leftBarButtonItem = nil
            //self.navigationItem.setHidesBackButton(true, animated:true);
        }
            
        else{
            prevBtnOutlet.isHidden = false
            //self.navigationItem.title = "Back"
        }
        
        
        
        pageControl.currentPage = Utilities.surveyQuestionArrayIndex
        
        //  self.navigationItem.title = String(Utilities.currentSurveyPage) + " / " + String(Utilities.totalSurveyQuestions)
        
        //self.surveyName.text = "Survey: 59 Booster St, New York, NY ,12201"
        
        //self.optionsCollectionView.reloadData()
        
        self.surveyName.text = "Unit: " + SalesforceConnection.unitName + "  |  " + SalesforceConnection.fullAddress
        
        // flagView.isHidden = true
        
    }
    
    
    var isSkipLogic:Bool = false
    
    @IBAction func nextQuestion(_ sender: UIButton) {
        
        isSkipLogic = false
        
        isNextButtonPressed = true
        
        if(objSurveyQues.isRequired == false && radiobuttonCurrentValue.isEmpty){
            radiobuttonCurrentValue = ""
            
        }
        else if(objSurveyQues.isRequired == true && selectedOptions.count == 0){
            // JLToast.makeText("This is required field.", duration: 1).show()
            
            self.questionsView.shake()
            
            return
        }
        
        var getDescription:String = ""
        
        if(getDescriptionTextField.isHidden == false){
            getDescription = getDescriptionTextField.text ?? "";
        }
        else if (showTextLbl.isHidden == false){
            getDescription = showTextLbl.text ?? "";
        }
        else
        {
            getDescription = ""
        }
        
        let objSurveyResult:SurveyResult =  SurveyResult(questionId:objSurveyQues.questionId, questionType: objSurveyQues.questionType, getDescription: getDescription, selectedAnswer: radiobuttonCurrentValue,multiOption: selectedOptions)
        
        Utilities.SurveyOutput[objSurveyQues.questionNumber] = objSurveyResult
        
        
        // Utilities.SurveyOutput[objSurveyQues.questionId] = radiobuttonCurrentValue
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        //Move to End of Survey
        if(objSurveyQues.isSkipLogic == "true"){
            let skipLogicArr:[[String:SkipLogic]] =  objSurveyQues.skipLogicArray
            
            for objectSkipLogic in skipLogicArr{
                if(objectSkipLogic[radiobuttonCurrentValue] != nil){
                    let tempObject:SkipLogic = objectSkipLogic[radiobuttonCurrentValue]!
                    
                    if(tempObject.skipLogicType == "End of Survey"){
                        
                        //Here we have to delete key value
                        
                        
                        if(SalesforceConnection.selectedTenantForSurvey == ""){
                            
                            
                            toolBarView.shake()
                            
                            self.view.makeToast("Please select client first.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                                if didTap {
                                    print("completion from tap")
                                } else {
                                    print("completion without tap")
                                }
                            }
                            
                            return
                            
                        }
                
                        else{
                        let startingIndex  = Utilities.surveyQuestionArrayIndex + 1
                        
                        let count = Utilities.totalSurveyQuestions - 1
                        
                        
                        /* let count  = (Utilities.totalSurveyQuestions-1) - Utilities.surveyQuestionArrayIndex
                         
                         let startingIndex = Utilities.surveyQuestionArrayIndex + 1
                         
                         //Utilities.surveyQuestionArrayIndex+1  --> starting index = (0+1)=1
                         // count :-> looping count  ((3-1)-0) = 2
                         
                         */
                        
                        Utilities.deleteSkipSurveyData(startingIndex: startingIndex, count: count)
                        
                        
                        
                        
                       SurveyUtility.goToSubmitSurveyPage(vc: self)
                            
                        return
                            
                        }
                        
                    }
                }
            }
        }
        
        
        
        if(Utilities.surveyQuestionArrayIndex == Utilities.totalSurveyQuestions - 1){
            
            
            if(SalesforceConnection.selectedTenantForSurvey == ""){
                
                
                toolBarView.shake()
                
                self.view.makeToast("Please select client first.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                    if didTap {
                        print("completion from tap")
                    } else {
                        print("completion without tap")
                    }
                }
                
                return
                
            }
                
            else{
                
                SurveyUtility.goToSubmitSurveyPage(vc: self)
            }
            

            
            
        }
            
        else{
            
            
            let currentIndex = Utilities.surveyQuestionArrayIndex
            
            //handle SkipLogic
            var objSurveyQues =  Utilities.surveyQuestionArray[currentIndex].objectSurveyQuestion
            
            if(Utilities.skipLogicParentChildDict[(objSurveyQues?.questionNumber)!] != nil){
                
                let arrayValue:[SkipLogic]  = Utilities.skipLogicParentChildDict[objSurveyQues!.questionNumber]!
                
                for object in arrayValue{
                    
                    if(Utilities.SurveyOutput[objSurveyQues!.questionNumber] != nil){
                        let objectSurveyResult:SurveyResult =  Utilities.SurveyOutput[objSurveyQues!.questionNumber]!
                        
                        if(objSurveyResult.multiOption.contains(object.selectedAnswer)){
                            
                            //skip question
                            
                            if(currentIndex == Utilities.totalSurveyQuestions - 1){
                                
                                
                                if(SalesforceConnection.selectedTenantForSurvey == ""){
                                    
                                    
                                    toolBarView.shake()
                                    
                                    self.view.makeToast("Please select client first.", duration: 1.0, position: .center , title: nil, image: nil, style:nil) { (didTap: Bool) -> Void in
                                        if didTap {
                                            print("completion from tap")
                                        } else {
                                            print("completion without tap")
                                        }
                                    }
                                    
                                    return
                                    
                                }
                                    
                                else{
                                    
                                    SurveyUtility.goToSubmitSurveyPage(vc: self)
                                    return
                                }
                                
                            }
                                
                            else{
                                
                                
                                let numberofQuestionsSkip = (Int(object.questionNumber)! - Int(objSurveyQues!.questionNumber)!)-1 //childquestionnumber - parentquestionumber
                                
                                
                                let count  = currentIndex + numberofQuestionsSkip
                                
                                
                                let startingIndex = currentIndex + 1
                                
                                if(startingIndex < count){
                                    Utilities.deleteSkipSurveyData(startingIndex: startingIndex, count: count)
                                }
                                
                                
                                Utilities.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                                
                                Utilities.currentSurveyPage = Int(object.questionNumber)! - 1
                                
                                /*
                                 
                                 //Clear data which questions skipped
                                 let objTempSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
                                 
                                 //delete data from dictionary
                                 Utilities.SurveyOutput.removeValue(forKey: (objTempSurveyQues?.questionNumber)!)
                                 
                                 */
                                
                                
                                
                                objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
                                
                                isSkipLogic = true
                                
                                break;
                            }
                            
                        }
                    }
                    
                }
                
            }//end of if skiplogic
            
            
            if(isSkipLogic == false){
                
                Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex + 1
                
                Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex + 1
                
                objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
                
            }
            
            
            
            if(objSurveyQues?.questionType == "Single Select"){
                
                
                
                //  self.navigationItem.title = "Previous"
                
                let surveyRadioButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyRadioButtonVCIdentifier") as! SurveyRadioOptionViewController
                
                SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyRadioButtonVC)
                
                
                
                //self.navigationController?.pushViewController(surveyRadioButtonVC, animated: true)
                
                
                
            }
                
            else if(objSurveyQues?.questionType == "Multi Select"){
                
                let surveyMultiButtonVC = storyboard.instantiateViewController(withIdentifier: "surveyMultiOptionVCIdentifier") as! SurveyMultiOptionViewController
                
                SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyMultiButtonVC)
                
                
                //self.navigationController?.pushViewController(surveyMultiButtonVC, animated: true)
                
                
            }
                
            else if(objSurveyQues?.questionType == "Text Area"){
                
                //    self.navigationItem.title = "Previous"
                
                let surveyTextFieldVC = storyboard.instantiateViewController(withIdentifier: "surveyTextFiedVCIdentifier") as! SurveyTextViewController
                
                
                SurveyUtility.TransitionVC(subType: kCATransitionFromRight, sourceVC: self, destinationVC: surveyTextFieldVC)
                
               // self.navigationController?.pushViewController(surveyTextFieldVC, animated: true)
                
                
                
                
            }
            
        }//end of else
        
        
    }
    
    var isPrevSkip:Bool = false
    @IBAction func prevQuestion(_ sender: UIButton) {
        isPrevSkip = false
        
        //handle SkipLogic
        let objSurveyQues =  Utilities.surveyQuestionArray[Utilities.surveyQuestionArrayIndex].objectSurveyQuestion
        
        // let parentIndex = Int((objSurveyQues?.questionNumber)!)! - 1
        
        
        //6
        if(Utilities.prevSkipLogicParentChildDict[(objSurveyQues?.questionNumber)!] != nil){
            
            let arrayValue:[SkipLogic]  = Utilities.prevSkipLogicParentChildDict[(objSurveyQues?.questionNumber)!]! //parent object result
            
            for object in arrayValue{
                
                //let childIndex = Int((object.questionNumber)!)! - 1
                
                //3
                if(Utilities.SurveyOutput[object.questionNumber] != nil){
                    let objectSurveyResult:SurveyResult =  Utilities.SurveyOutput[object.questionNumber]! //child object result
                    
                    if(objectSurveyResult.questionType == "Multi Select"){
                        if(objectSurveyResult.multiOption.contains(object.selectedAnswer)){
                            //skip question
                            
                            Utilities.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                            isPrevSkip = true
                            
                            //Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
                            break;
                            
                        }
                    }
                        
                        
                    else if(objectSurveyResult.selectedAnswer == object.selectedAnswer){
                        
                        //skip question
                        
                        Utilities.surveyQuestionArrayIndex = Int(object.questionNumber)! - 1
                        
                        isPrevSkip = true
                        
                        //Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
                        
                        break;
                        
                    }
                }
                
            }
            
        }
        if(isPrevSkip == false){
            
            Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
            
        }
        
        
        
        
        SurveyUtility.goToPreviousQuestion(sourceVC:self)

        
        //self.navigationController?.popViewController(animated: true);
        
        
        
    }
    
    
    
    
    var widthToUse : CGFloat?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        optionsCollectionView.reloadData()
        
        widthToUse = size.width - 140
        
        let collectionViewLayout = optionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.invalidateLayout()
        
        //self.optionsCollectionView?
        
    }
    
    var isNextButtonPressed:Bool = false
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(isNextButtonPressed == false)
        {
            //Utilities.currentSurveyPage = Utilities.surveyQuestionArrayIndex
            
            // Utilities.surveyQuestionArrayIndex = Utilities.surveyQuestionArrayIndex - 1
            
        }
        else{
            isNextButtonPressed = false
        }
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            print("Landscape")
            //here you can do the logic for the cell size if phone is in landscape
        } else {
            print("Portrait") //logic if not landscape
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionsTextArray.count
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! SurveyOptionsButtonCell
        
        
        
        
        cell.contentView.layer.cornerRadius = 10.0;
        cell.contentView.layer.borderWidth = 1.0;
        cell.contentView.layer.borderColor = UIColor.clear.cgColor;
        cell.contentView.layer.masksToBounds = true;
        
        cell.layer.shadowColor = UIColor.gray.cgColor;
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0);
        cell.layer.shadowRadius = 2.0;
        cell.layer.shadowOpacity = 1.0;
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath;
        
        
        if let object = Utilities.SurveyOutput[objSurveyQues.questionNumber] {
            
            if(object.multiOption.contains(optionsTextArray[indexPath.row]))
            {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition:UICollectionViewScrollPosition.centeredVertically)
                
                selectedOptions.append(optionsTextArray[indexPath.row])
                
                //radiobuttonCurrentValue = object.selectedAnswer
                
                cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) //green
                
                
                if(objSurveyQues.isSkipLogic == "true"){
                    let skipLogicArr:[[String:SkipLogic]] =  objSurveyQues.skipLogicArray
                    
                    for objectSkipLogic in skipLogicArr{
                        if(objectSkipLogic[object.selectedAnswer] != nil){
                            let tempObject:SkipLogic = objectSkipLogic[object.selectedAnswer]!
                            
                            if(tempObject.skipLogicType == "Show Text"){
                                getDescriptionTextField.isHidden = true
                                showTextLbl.isHidden = false
                            }
                            else if(tempObject.skipLogicType == "Input Text"){
                                showTextLbl.isHidden = true
                                getDescriptionTextField.isHidden = false
                                
                            }
                            else{
                                showTextLbl.isHidden = true
                                getDescriptionTextField.isHidden = true
                            }
                        }
                        else{
                            showTextLbl.isHidden = true
                            getDescriptionTextField.isHidden = true
                        }
                    }
                    
                    
                }
                
                
                
                
                
                
                
            }
                
                
                
                
                
            else{
                cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
                
                
            }
        }
            
            
        else{
            
            cell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
            
        }
        
        
        
        cell.optionText.text = optionsTextArray[indexPath.row]
        cell.optionId.text = optionsTextArray[indexPath.row]
        
        
        
        
        
        return cell
    }
    
    
    
    var selectedOptions = [String]()
    var selectedOption = ""
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath as IndexPath) as! SurveyOptionsButtonCell
        
        selectedOption = currentCell.optionId.text!
        
        
        
        
        if selectedOptions.contains(selectedOption){
            
            currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
            
            selectedOptions = selectedOptions.filter{$0 != selectedOption}
            print(selectedOption)
            
        }
        else{
            selectedOptions.append(selectedOption)
            currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 206.0/255.0, blue: 35.0/255.0, alpha: 1) // green
            print(selectedOption)
            
        }
        
        
        
        
        
        // radiobuttonCurrentValue = currentCell.optionId.text!
        
        
        showTextLbl.isHidden = true
        getDescriptionTextField.isHidden = true
        
        if(objSurveyQues.isSkipLogic == "true"){
            let skipLogicArr:[[String:SkipLogic]] =  objSurveyQues.skipLogicArray
            
            for objectSkipLogic in skipLogicArr{
                
                for selectedValue in selectedOptions{
                    
                    if(objectSkipLogic[selectedValue] != nil){
                        let tempObject:SkipLogic = objectSkipLogic[selectedValue]!
                        if(tempObject.skipLogicType == "Show Text"){
                            showTextLbl.isHidden = false
                            showTextLbl.text = tempObject.showTextValue
                            
                            getDescriptionTextField.isHidden = true
                            break;
                            
                        }
                        else if(tempObject.skipLogicType == "Input Text"){
                            showTextLbl.isHidden = true
                            getDescriptionTextField.isHidden = false
                            break;
                            
                            
                        }
                        //                        else{
                        //                            showTextLbl.isHidden = true
                        //                            getDescriptionTextField.isHidden = true
                        //
                        //                        }
                    }
                    //                    else{
                    //                        showTextLbl.isHidden = true
                    //                        getDescriptionTextField.isHidden = true
                    //                        break;
                    //                    }
                }
                
            }
            
            
        }
        
        
    }
    /*
     func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
     let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! SurveyRadioButtonCell
     
     currentCell.backgroundColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1) //blue
     
     }
     
     */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //
        
        //CGRectGetWidth(collectionView.frame)
        
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        // let width = collectionView.bounds.width - collectionViewLayout!.sectionInset.left - collectionViewLayout!.sectionInset.right
        
        var collectionViewWidth = collectionView.bounds.width
        
        if let w = widthToUse
        {
            collectionViewWidth = w
        }
        
        let width = collectionViewWidth - collectionViewLayout!.sectionInset.left - collectionViewLayout!.sectionInset.right - 170
        
        return CGSize(width: width, height:50)
        
        
        
        //return CGSizeMake(collectionView.bounds.size.width , 50)
    }
    
    
    
}