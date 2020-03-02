//
//  FilterViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 18/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
import Localize_Swift
import UIKit
import ActionSheetPicker_3_0
import SwiftGifOrigin
import Firebase
import CoreLocation
import ANLoader
import SendBirdSDK
import SQLite
import EFInternetIndicator
class FilterViewController: UIViewController, CLLocationManagerDelegate,InternetStatusIndicable{
   var internetConnectionIndicator:InternetViewIndicator?
var allaudiance = NSMutableArray()
    @IBOutlet weak var groupBtn: UIButton!
    let defaults = UserDefaults.standard
    var userId = ""
    @IBOutlet weak var groupText: UITextField!
    var selectedAudianceName = NSMutableArray()
    var selectedAudianceId = NSMutableArray()
    var sentAudianceIds = ""
    var categoryArr = NSMutableArray()
    var categoryListArr = NSMutableArray()
    var needMappingID = ""
    var needTitle = ""
    var deviceToken = ""
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    var latitude = ""
    var longitude = ""
     var groupListArray = [Group]()
    @IBOutlet var outletSlider: UISlider!
    @IBOutlet var outlletRadiusValue: UILabel!
    @IBOutlet var outletCategoryTxt: UITextField!
    var sentAudianceSelectAllGroup = ""
    var sentAudianceSelectIndivisualUser = ""
    @IBOutlet weak var applyLbl: UILabel!
    @IBOutlet weak var radousLbl: UILabel!
    @IBOutlet weak var catLable: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var grpLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
            self.navigationController?.navigationBar.topItem?.title = " "
self.startMonitoringInternet()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        
        let refreshedToken = GlobalClass.sharedInstance.nullToNil(value: FIRInstanceID.instanceID().token() as AnyObject)
        UserDefaults.standard.setValue(refreshedToken, forKey: "FCMTOEKN")
        deviceToken = UserDefaults.standard.value(forKey: "FCMTOEKN") as! String
        
        self.findCurrentLocation();
        self.updateUI()
        
        self.getAudianceAPiCall()
         NotificationCenter.default.addObserver(self, selector: #selector(TagADeedsViewController.methodOfReceivedAudianceNotification(notification:)), name: Notification.Name("audianceselecte"), object: nil)
    }
func setText()
{
    applyLbl.text = "Apply Filters".localized()
    radousLbl.text = "Radius".localized()
    catLable.text = "Select category".localized()
    grpLbl.text = "Filter by group".localized()
    applyBtn.setTitle("Apply".localized(), for: UIControlState.normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        setText()
self.navigationItem.title = "Filter".localized()
        self.downloadCategoryData()
        self.groupText.setBottomBorder()
        let network = NetworkManager.sharedInstance
        network.reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.view.hideAllToasts()
                self.view.makeToast(Validation.ERROR.localized())
            }
        }
        
        network.reachability.whenReachable = { reachability in
            
            self.downloadCategoryData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ANLoader.hide()
    }
    
    func updateUI(){

        //Check filter applied or not, if not then default values show otherwise set value need to show
        //Already set values are stored in Userdefaults
        let flag = self.defaults.value(forKey: "FILTERSTATUS") as! Bool
        if flag {

            self.outletSlider.value = Float(defaults.value(forKey: "DEED_RADIUS") as! Int)
            self.outlletRadiusValue.text = String(format: "%d Metres(%d Kms)",(defaults.value(forKey: "DEED_RADIUS") as! Int),(defaults.value(forKey: "DEED_RADIUS") as! Int)/1000)
            self.outletCategoryTxt.text = defaults.value(forKey: "CATEGORY") as? String
            self.groupText.text = defaults.value(forKey: "GROUPNAME") as? String
        }
        else{

//decide either radius come default or from setting screen
            
                print(self.outletSlider.value)
                let radius = Int(self.outletSlider.value)
                // self.outletSlider.value = 35.0
                if(radius > 1000)
                {
                    self.outlletRadiusValue.text = String(format: "%d Metres(%d Kms)",radius,radius/1000)
                }
                else{
                    self.outlletRadiusValue.text = String(format: "%d Metres",radius)
                }
                self.outletCategoryTxt.text = "All"
                self.groupText.text = "All"
          
         
           
        }
    }
    
    //Set Radius for notification
    @IBAction func sliderAction(sender: UISlider) {
        
        let currentValue = Int(sender.value)
        print(currentValue)
        if(currentValue > 1000){
             outlletRadiusValue.text = String(format: "%d Metre(%d Km)",currentValue,currentValue/1000)
     
        }else{
            outlletRadiusValue.text = String(format: "%d Metre",currentValue)
       
        }
       
        
    }
    
    //When click o apply the server will get users current updated location and set Values to Userdefaults.(Radius, category, filterstatus)
    @IBAction func applyAction(_ sender: Any) {
      
        let radius:Int? = Int(CGFloat((self.outlletRadiusValue.text! as NSString).doubleValue))
       UserDefaults.standard.set(Int(CGFloat((self.outlletRadiusValue.text! as NSString).doubleValue)), forKey: "radius")
        self.updateFilterRadiusAndLocation(radiusVal: radius!, Device_ID: deviceToken);
        defaults.set(Int(CGFloat((self.outlletRadiusValue.text! as NSString).doubleValue)), forKey: "DEED_RADIUS")
        
        defaults.set(self.outletCategoryTxt.text, forKey: "CATEGORY")
       print(self.allaudiance.count)
         print(selectedAudianceId.count)
     

        
        defaults.set(self.groupText.text, forKey: "GROUPNAME")
        let name = defaults.value(forKey: "GROUPNAME") as! String
        if(name == "All"){
              defaults.set("All", forKey: "GROUP")
        }else{
         //   let number = defaults.value(forKey: "selectedAudianceArrayCount") as! String
            let selectedAud = defaults.value(forKey: "selectedAudiance") as! String
              defaults.set(selectedAud, forKey: "GROUP")
        }
        defaults.set(true, forKey: "FILTERSTATUS")
        
        self.navigationController?.popViewController(animated: true)
    }
    @objc func methodOfReceivedAudianceNotification(notification: Notification) {
        // Take Action on Notification
        //retrive data for preferance
        GlobalClass.sharedInstance.openDb()
        do {
            let users = try Constant.database.prepare(Constant.audianceTable)
            for user in users {
                print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid]), nameQty: \(user[Constant.audQty]), nameStatus: \(user[Constant.audstatus])")
                let status = user[Constant.audstatus]
                var id = ""
                var name = ""
                if(status == "y"){
                    name = user[Constant.audname]
                    id = user[Constant.audid]
                    selectedAudianceName.add(name)
                    selectedAudianceId.add(id)
                    
                }else{
                    
                }
                //  print("\(selectedPreferenceName)\(selectedPreferenceId)")
                
            }
        } catch {
            print(error)
        }
        var title = ""
        print("\(selectedAudianceName)\(selectedAudianceId)\((selectedAudianceName.count))")
        defaults.set(selectedAudianceId.count, forKey: "selectedAudianceArrayCount")
        print()
        //    let neednames = selectedNeedNames.componentsJoined(by: ",")
        if(selectedAudianceName.contains("All groups")){
            sentAudianceSelectAllGroup = "Y"
        }
        else if(selectedAudianceName.contains("All indivisual users")){
            sentAudianceSelectIndivisualUser = "Y"
            
        }
        else{
            sentAudianceSelectIndivisualUser = "N"
            sentAudianceSelectAllGroup = "N"
        }
        sentAudianceIds = selectedAudianceId.componentsJoined(by: ",")
        print(sentAudianceIds)
         defaults.set(sentAudianceIds, forKey: "selectedAudiance")
        if(selectedAudianceId.count == 0){
            title = ""
        }
        else{
            if(selectedAudianceId.count > 1){
                if(sentAudianceSelectAllGroup == "Y"){
                    title = ("All")
                }
                else{
                    title = ("Selected - \(selectedAudianceName[0]) & \(selectedAudianceName.count-1) other(s)")
                }
                
            }
            else{
                title = ("Selected - \(selectedAudianceName[0])")
            }
        }
        //  self.selectAudianceBTn.setTitle(title, for: .normal)
        self.groupText.text = title
        
    }
    //get groupList
    func getAudianceAPiCall()
    {
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.showGroupList
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@",userId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                print(jsonObj!)
                for values in jsonObj!{
                    let group_id = (values as AnyObject).value(forKey: "group_id") as! String
                    //   let group_logo = (values as AnyObject).value(forKey: "group_logo") as! String
                    let group_name = (values as AnyObject).value(forKey: "group_name") as! String
                    
                    let groups = Group(group_name: group_name , group_imageURL: "" , group_id: group_id )
                    print(groups)
                    self.allaudiance.add(groups)
//                    //insert values to DB
//
//                    let insertUser = Constant.audianceTable.insert(Constant.audname <- group_name, Constant.audid <- group_id,Constant.audQty <- "0",Constant.audstatus <- "n")
//
//                    do {
//                        try Constant.database.run(insertUser)
//                        print("INSERTED USER")
//                    } catch {
//                        print(error)
//                    }
//                    //End
                    self.sentAudianceSelectAllGroup = "Y"
                   
                  
                    //                    self.groupListArray.append(groups)
                    //                    print(self.groupListArray.count)
                }
                DispatchQueue.main.async{
                    if(self.allaudiance.count == 0){
                        self.groupBtn.isHidden = true
                        self.grpLbl.isHidden = true
                        self.groupText.isHidden = true
                    }
                    else{
                        self.groupBtn.isHidden = false
                        self.grpLbl.isHidden = false
                        self.groupText.isHidden = false
                    }
                }
            }
            
        }
        
        task.resume()
    }
    @IBAction func groupBtnPress(_ sender: UIButton) {
        selectedAudianceId.removeAllObjects()
        selectedAudianceName.removeAllObjects()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AudianceViewController") as! AudianceViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.receivedText = "filter"
        self.present(vc, animated: true, completion: nil)
    }
    //Select category
    @IBAction func categoryAction(_ sender: Any) {
        
        if self.categoryListArr.count == 0{
            
            self.view.hideAllToasts();
            self.navigationController?.view.makeToast("Categories are empty.".localized());
            return;
        }
        
        ActionSheetStringPicker.show(withTitle: "Select Category",
                                     rows: self.categoryListArr as! [Any] ,
                                     initialSelection: 0,
                                     doneBlock: {
                                        picker, indexe, values in
                                        
                                        if indexe == 0{
                                            
                                            GlobalClass.sharedInstance.filterCategoryValue = "All"
                                              self.outletCategoryTxt.text = "All"
                                            return
                                        }
                                        else{
                                        self.outletCategoryTxt.text = values as? String
                                        }
                                        let item = self.categoryArr[indexe]
                                        GlobalClass.sharedInstance.filterCategoryValue = (item as AnyObject).value(forKey:"Need_Name") as! String
                                        GlobalClass.sharedInstance.filterCategoryId = (item as AnyObject).value(forKey:"NeedMapping_ID") as! String
                                        
                                        return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //MAKR:- Download category data
    func downloadCategoryData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.need_type
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let needtype = jsonObj!.value(forKey: "g_need") as? NSArray {
                    
                    self.categoryListArr.removeAllObjects();
                    self.categoryArr.removeAllObjects();
                    
                    for item in needtype {
                        
                        do {
                            
                            try self.categoryListArr.add((item as AnyObject).value(forKey:"Need_Name") as! String)
                            
                            let needItem = item as? NSDictionary
                            try self.categoryArr.add(needItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }

                    }
                    
                    
                    do {
                        
                        try self.categoryArr.insert("All", at: 0)
                        try self.categoryListArr.insert("All", at: 0)
                        
                    } catch {
                        // Error Handling
                        print("Some error occured.")
                    }

                }
                if let needtype1 = jsonObj!.value(forKey: "c_need") as? NSArray {
                    
                    //                    self.categoryListArr.removeAllObjects();
                    //                    self.categoryArr.removeAllObjects();
                    
                    for item in needtype1 {
                        
                        do {
                            
                            try self.categoryListArr.add((item as AnyObject).value(forKey:"Need_Name") as! String)
                            
                            let needItem = item as? NSDictionary
                            try self.categoryArr.add(needItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        self.categoryArr.insert("All", at: 0)
                        self.categoryListArr.insert("All", at: 0)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    //Update filter value and User current location on server
    func updateFilterRadiusAndLocation(radiusVal : Int, Device_ID: String) {
     
        let urlString = Constant.BASE_URL + Constant.update_location
        let url:NSURL = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@&device_id=%@&lat=%@&lng=%@&radius=%d",userId,Device_ID,latitude,longitude,radiusVal)
 
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request as URLRequest)
        task.resume()
    }
    
    // MARK: - Find Current locationCurrent
    func findCurrentLocation(){
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locManager = CLLocationManager()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }
    }
    
    //Method will get current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let location = locations.last! as CLLocation
        
        latitude = String(format:"%f",location.coordinate.latitude)
        longitude = String(format:"%f",location.coordinate.longitude)
        
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
}
