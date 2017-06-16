//
//  MapLocationViewController.swift
//  Knock
//
//  Created by Kamal on 15/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import ArcGIS

struct locationDataStruct
{
    var locId : String = ""
    var locName : String = ""
    var fullAddress: String = ""
}

class MapLocationViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate , AGSGeoViewTouchDelegate, AGSCalloutDelegate, UISearchBarDelegate {
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var newLocLbl: UILabel!
    @IBOutlet weak var newCaseLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var dataAssignment: UILabel!
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var assignmentId:String!
    var assignmentName:String!
    
    
    var address:String = "Waterville, NewYork, USA"
    var locationId:String!
    
    
    
    var locationDictionaryArray:Dictionary<String, AnyObject> = [:]
    
    var locationNameArray = [String]()
    var fullAddressArray = [String]()
    var locationIdArray = [String]()
    
    private var mapPackage:AGSMobileMapPackage!
    
    
    
    var locatorTask:AGSLocatorTask?
    private var geocodeParameters:AGSGeocodeParameters!
    private var reverseGeocodeParameters:AGSReverseGeocodeParameters!
    //private var graphicsOverlay:AGSGraphicsOverlay!
    private var locatorTaskOperation:AGSCancelable!
    
    private var markerGraphicsOverlay = AGSGraphicsOverlay()
    private var routeGraphicsOverlay = AGSGraphicsOverlay()
    
    
    var searchActive : Bool = false
    var filtered:[String] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            
           
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
           // self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        let newLocTapGesture = UITapGestureRecognizer(target: self, action: Selector(("NewLocLblTapped:")))
        
        // add it to the image view;
        newLocLbl.addGestureRecognizer(newLocTapGesture)
        // make sure imageView can be interacted with by user
        newLocLbl.isUserInteractionEnabled = true
        
        let newCaseTapGesture = UITapGestureRecognizer(target: self, action: Selector(("NewCaseLblTapped:")))
        
        // add it to the image view;
        newCaseLbl.addGestureRecognizer(newCaseTapGesture)
        // make sure imageView can be interacted with by user
        newCaseLbl.isUserInteractionEnabled = true

        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.0/255.0, green: 102.0/255.0, blue: 204.0/255.0, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        imageView.contentMode = .scaleAspectFit
        
        
        let image = UIImage(named: "MTXLogoWhite")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchBar.delegate = self
        
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        populateLocationData()
        
        
        dataAssignment.text = assignmentName
        
        //initialize map package
        self.mapPackage = AGSMobileMapPackage(name: "NewYorkCity")
        
        //initialize geocode params
        self.geocodeParameters = AGSGeocodeParameters()
        self.geocodeParameters.resultAttributeNames.append(contentsOf: ["Match_addr"])
        self.geocodeParameters.minScore = 75
        
        
        SVProgressHUD.show(withStatus: "Loading Map..", maskType: SVProgressHUDMaskType.gradient)
        
        
        
        //load map package
        self.mapPackage.load { [weak self] (error: Error?) in
            if error != nil {
                // SVProgressHUD.showErrorWithStatus(error.localizedDescription)
            }
            else {
                if let weakSelf = self {
                    if weakSelf.mapPackage.maps.count > 0 {
                        //assign the first map from the map package to the map view
                        weakSelf.mapView.map = weakSelf.mapPackage.maps[0]
                        
                        //touch delegate
                        weakSelf.mapView.touchDelegate = weakSelf
                        
                        //add graphic overlays
                        weakSelf.mapView.graphicsOverlays.addObjects(from: [weakSelf.routeGraphicsOverlay, weakSelf.markerGraphicsOverlay])
                        
                        self?.locatorTask = self?.mapPackage.locatorTask
                        
                        //print(weakSelf.mapPackage.locatorTask)
                        
                        
                        
                        var IsInitialViewPoint:Bool = true
                        
                        
                        if((self?.locDataArray.count)! > 0){
                            
                            self!.address = (self?.locDataArray[0].fullAddress)!
                            self!.locationId = (self?.locDataArray[0].locId)!
                            
                            IsInitialViewPoint = false
                        }
                        
                        //SVProgressHUD.dismiss()
                        
                        weakSelf.geocodeSearchText(text: self!.address,setIntialViewPoint: IsInitialViewPoint)
                        
                    }
                    else {
                        // SVProgressHUD.showErrorWithStatus("No mobile maps found in the map package")
                    }
                }
            }
        }
    }
    
    
    
    var locDataArray = [locationDataStruct]()
    
    func populateLocationData(){
        
 
        let locationResults = ManageCoreData.fetchData(salesforceEntityName: "Location",isPredicate:false) as! [Location]
        
        if(locationResults.count > 0){
            
            for locationData in locationResults{
                
                let objectLocStruct:locationDataStruct = locationDataStruct(locId: locationData.id!,locName: "NO LOCATION NAME",fullAddress: locationData.name!)
                
                
                locDataArray.append(objectLocStruct)
               
            }
        }
        
        tableView.reloadData()
        
        
        
        
    }

    
    
    func NewLocLblTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        //self.performSegue(withIdentifier: "showAddLocationIdentifier", sender: nil)
         //  _ = self.navigationController?.popViewControllerAnimated(true)
    }
    
    func NewCaseLblTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        //self.performSegue(withIdentifier: "showAddCaseIdentifier", sender: nil)
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    var filteredStruct = [locationDataStruct]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredStruct = locDataArray.filter {
            
            var isSearch = false
            
            isSearch =  ($0.locName.lowercased() as NSString).contains(searchText.lowercased())
            
            if(isSearch == false){
                isSearch = ($0.fullAddress.lowercased() as NSString).contains(searchText.lowercased())
                
                
            }
            
            return isSearch
            
            
        }
        
        if(filteredStruct.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
        
        /*
         filtered = fullAddressArray.filter({ (text) -> Bool in
         let tmp: NSString = text
         let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
         return range.location != NSNotFound
         })
         if(filtered.count == 0){
         searchActive = false;
         } else {
         searchActive = true;
         }
         self.tableView.reloadData()
         */
    }
    
    //method returns the symbol for the route graphic
    func routeSymbol() -> AGSSimpleLineSymbol {
        let symbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.blue, width: 5)
        return symbol
    }
    
    //method returns a graphic object for the point and attributes provided
    private func graphicForPoint(point: AGSPoint, attributes: [String: AnyObject]?) -> AGSGraphic {
        let markerImage = UIImage(named: "MapMarker")!
        let symbol = AGSPictureMarkerSymbol(image: markerImage)
        symbol.leaderOffsetY = markerImage.size.height/2
        symbol.offsetY = markerImage.size.height/2
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: attributes)
        return graphic
    }
    
    private func geocodeSearchText(text:String,setIntialViewPoint:Bool) {
        
        if self.locatorTask == nil {
            return
        }
        
        //dismiss the callout if already visible
        self.mapView.callout.dismiss()
        
        //remove all previous graphics
        self.markerGraphicsOverlay.graphics.removeAllObjects()
        
        
        self.locatorTask?.geocode(withSearchText: text, parameters: self.geocodeParameters, completion: { [weak self] (results:[AGSGeocodeResult]?, error:Error?) -> Void in
            if let error = error {
               print(error.localizedDescription)
            }
            else {
                if let results = results , results.count > 0 {
                    var graphic:AGSGraphic?=nil
                    
                    if(setIntialViewPoint==false){
                        //create a graphic for the first result and add to the graphics overlay
                        graphic = self?.graphicForPoint(point: results[0].displayLocation!, attributes: results[0].attributes as [String : AnyObject]?)
                        self?.markerGraphicsOverlay.graphics.add(graphic!)
                        
                    }
                    
                    //zoom to the extent of the result
                    if let extent = results[0].extent {
                        self?.mapView.setViewpointGeometry(extent, completion: nil)
                        
                        
                        if(setIntialViewPoint==false){
                            
                            self?.showCalloutForGraphic(graphic: graphic!, tapLocation: results[0].displayLocation!, animated: true, offset: false)
                        }
                        
                        SVProgressHUD.dismiss()
                    }
                    
                    
                }
                else {
                    //provide feedback in case of failure
                    //self?.showAlert("No results found")
                }
            }
        })
        
    }
    
    
    private func showCalloutForGraphic(graphic:AGSGraphic, tapLocation:AGSPoint, animated:Bool, offset:Bool) {
        
        
        
        self.mapView.callout.title = graphic.attributes["Match_addr"] as? String
        
        //self.mapView.callout.accessoryButtonHidden = true
        
        self.mapView.callout.delegate = self
        self.mapView.callout.accessoryButtonImage = UIImage(named: "ForwardIcon")
        
        self.mapView.callout.show(for: graphic, tapLocation: tapLocation, animated: animated)
        
    }
    
    //MARK: - AGSCalloutDelegate
    
    func didTapAccessoryButton(for callout: AGSCallout) {
        //hide the callout
        //self.mapView.callout.dismiss()
        
        //confirmation
        /*let alertController = UIAlertController(title: "Go to Units", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
         //action for Yes
         let alertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: nil)
         alertController.addAction(alertAction)
         
         //action for cancel
         let cancelAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
         alertController.addAction(cancelAlertAction)*/
        
        
        //present alert controller
        //self.presentViewController(alertController, animated: true, completion: nil)
        
        
         self.performSegue(withIdentifier: "ShowUnitsIdentifier", sender: nil)
        

    }
    
    
   
    
    
    
    //MARK: - AGSGeoViewTouchDelegate
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        
        //show the callout for the first graphic found
        //  self.showCalloutForGraphic(result.graphics.first!, tapLocation: mapPoint, animated: true, offset: false)
        
        
        //dismiss the callout if already visible
        self.mapView.callout.dismiss()
        
        //identify graphics at the tapped location
        self.mapView.identify(self.markerGraphicsOverlay, screenPoint: screenPoint, tolerance: 5, returnPopupsOnly: false, maximumResults: 1) { (result: AGSIdentifyGraphicsOverlayResult) -> Void in
            if let error = result.error {
                print(error)
            }
            else if result.graphics.count > 0 {
                //show callout for the first graphic in the array
                //self.showCalloutForGraphic(result.graphics.first!, tapLocation: mapPoint, animated: true, offset: false)
                
                self.showCalloutForGraphic(graphic: result.graphics[0], tapLocation: mapPoint, animated: true, offset: false)
            }
        }
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        
      //  self.tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSource
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return filteredStruct.count
        }
        
        return locDataArray.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as!
        LocationCustomViewCell
        
        /*  if(searchActive){
         cell.dataFullAddress.text = filtered[indexPath.row]
         }
         else{
         
         cell.dataLocation.text = locationNameArray[indexPath.row]
         cell.dataFullAddress.text = fullAddressArray[indexPath.row]
         cell.dataLocId.text = locationIdArray[indexPath.row]
         
         }*/
        
        if(searchActive){
            cell.dataFullAddress.text = filteredStruct[indexPath.row].fullAddress
            cell.dataLocation.text = filteredStruct[indexPath.row].locName
            cell.dataLocId.text = filteredStruct[indexPath.row].locId
        }
        else{
            
            cell.dataLocation.text = locDataArray[indexPath.row].locName
            cell.dataFullAddress.text = locDataArray[indexPath.row].fullAddress
            cell.dataLocId.text = locDataArray[indexPath.row].locId
            
        }
        
        return cell
        
        
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        let fullAddress =  locDataArray[indexPath.row].fullAddress
        
        self.geocodeSearchText(text: fullAddress,setIntialViewPoint: false)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    @IBAction func UnwindBackFromUnit(segue:UIStoryboardSegue) {
        
        print("UnwindBackFromUnit")
        
    }


}