////
////  TagADeedsViewController.swiftpk
////  GiftADeed
////
////  Created by navin on 3/4/19.
////  Copyright © 2019 GiftADeed. All rights reserved.
////Ref No : 4.1 WBS SRS 31 (priority 1)
//
//import UIKit
//import CoreLocation
//import Foundation
//import ActionSheetPicker_3_0
//import Toast_Swift
//import GooglePlaces
//import Foundation
//import SwiftGifOrigin
//import ANLoader
//import Localize_Swift
//import MMDrawController
//import  SQLite
//import LabelSwitch
//extension TagADeedsViewController: LabelSwitchDelegate {
//    func switchChangToState(_ state: LabelSwitchState) {
//        switch state {
//        case .L: print("circle on left")
//        parmanentAddress = "N"
//        print("circle on left")
//        case .R: print("circle on right")
//        parmanentAddress = "Y"
//        }
//    }
//}
//extension Array where Element: Any {
//
//    var toDictionary: [Int:Element] {
//        var dictionary: [Int:Element] = [:]
//        for (index, element) in enumerated() {
//            dictionary[index] = element
//        }
//        return dictionary
//    }
//
//}
//
//class TagADeedsViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate ,GMSAutocompleteViewControllerDelegate{
//    @IBOutlet weak var sliderValueLbl: UILabel!
//    var preferenceDict = [String: String]()
//    var needMappingID = ""
//    var needTitle = ""
//    var categoryTypeTitle = ""
//    var needGroupMappingID = ""
//    var needGroupTitle = ""
//    let imagePicker = UIImagePickerController()
//    var imageBase64 = ""
//    var addressString = ""
//    var geoPoint = ""
//    var categoryArr = NSMutableArray()
//    var categoryListArr = NSMutableArray()
//    var groupArr = NSMutableArray()
//    var groupListArr = NSMutableArray()
//    var selectedPreferenceName = NSMutableArray()
//    var selectedPreferenceId = NSMutableArray()
//    var selectedAudianceName = NSMutableArray()
//    var selectedAudianceId = NSMutableArray()
//    var sentAudianceIds = ""
//    var sentAudianceSelectAllGroup = ""
//    var sentAudianceSelectIndivisualUser = ""
//    var locManager = CLLocationManager()
//    var currentLatLong = CLLocation()
//    let defaults = UserDefaults.standard
//    var userId = ""
//    var cat_type = ""
//    var pAddress = ""
//    var parmanentAddress = ""
//    var containerStatus = ""
//    var imageFlag : Bool = false
//    var deedImage = ""
//    var deedId = ""
//    var validity = ""
//    var subType = ""
//    var desc = ""
//    var ownerId = ""
//    var charactorURL = ""
//    var containerChk = ""
//    var editedImg = ""
//    let nc = NotificationCenter.default
//    var data = ""
//    // Handle the user's selection.
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        self.addressString = place.formattedAddress!
//        addressLabel.text = self.addressString
//        geoPoint = String(format:"%f,%f", place.coordinate.latitude, place.coordinate.longitude)
//        dismiss(animated: true, completion: nil)
//    }
//
//    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        // TODO: handle the error.
//        print("Error: ", error.localizedDescription)
//    }
//
//    // User canceled the operation.
//    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//    @IBOutlet weak var selectAudianceHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var sliderValidity: UISlider!
//    var editFlag : Bool = false
//    @IBOutlet weak var selectAudianceBTn: UIButton!
//    @IBOutlet weak var labelSwitchOne: LabelSwitch!
//    @IBOutlet weak var labelSwitch: LabelSwitch!
//    @IBOutlet weak var addressLabel: UILabel!
//    @IBOutlet weak var deedImageView: UIImageView!
//    @IBOutlet weak var cameraBtn: UIButton!
//    @IBOutlet weak var browseBtn: UIButton!
//    @IBOutlet weak var categoryIcon: UIImageView!
//    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var parmanantLocation: UILabel!
//    @IBOutlet weak var descriptionTextView: UITextView!
//    @IBOutlet weak var descriptionLbl: UILabel!
//    @IBOutlet weak var validityLbl: UILabel!
//    @IBOutlet weak var selectLocationLbl: UILabel!
//    @IBOutlet weak var selectPreferenceBtn: UIButton!
//    @IBOutlet weak var selectGroupBtn: UIButton!
//    @IBOutlet weak var selectCategoryBtn: UIButton!
//    @IBOutlet weak var selectAddressBtn: UIButton!
//    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var postBtn: UIButton!
//    @IBOutlet weak var menuBtn: UIBarButtonItem!
//    @IBOutlet weak var selectGroupTitle: UITextField!
//    @IBOutlet weak var groupHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var preferenceHeightConstrint: NSLayoutConstraint!
//    @IBOutlet weak var selectLocLabelHeightConstraints: NSLayoutConstraint!
//    @IBOutlet weak var addressHeightConstraints: NSLayoutConstraint!
//    @IBOutlet weak var pSwitchHeightConstraints: NSLayoutConstraint!
//    @IBOutlet weak var plocationHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var selectCategoryText: UITextField!
//    @IBOutlet weak var selectPreferenceText: UITextField!
//    @IBOutlet weak var selectAudianceText: UITextField!
//    func removeSpecialCharsFromString(text: String) -> String {
//        let okayChars : Set<Character> =
//            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ,-".characters)
//        return String(text.characters.filter {okayChars.contains($0) })
//    }
//    func removeSpecialNumFromString(text: String) -> String {
//        let okayChars : Set<Character> =
//            Set("1234567890,".characters)
//        return String(text.characters.filter {okayChars.contains($0) })
//    }
//    override func viewWillAppear(_ animated: Bool) {
//
//        userId = defaults.value(forKey: "User_ID") as! String
//
//        NotificationCenter.default.addObserver(self, selector: #selector(TagADeedsViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("preferenceselecte"), object: nil)
//        let network = NetworkManager.sharedInstance
//        network.reachability.whenUnreachable = { reachability in
//            DispatchQueue.main.async {
//                self.view.hideAllToasts()
//                self.view.makeToast(Validation.ERROR)
//            }
//        }
//        network.reachability.whenReachable = { reachability in
//            DispatchQueue.main.async {
//                if self.geoPoint != ""{
//                    let latLong = self.geoPoint.components(separatedBy: ",")
//                    self.getAddressForLatLng(latitude: String(format:"%@",latLong[0]), longitude: String(format:"%@",latLong[1]))
//                }
//                //self.downloadCategoryData()
//                self.downloadOwnGroupData()
//            }
//        }
//    }
//    func convertToDictionary(text: String) -> [String: Any]? {
//        if let data = text.data(using: .utf8) {
//            do {
//                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//        return nil
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.categoryIcon.isHidden = true
//        self.tabBarController?.tabBar.isHidden = true
//        GlobalClass.sharedInstance.openDb()
//        print(editFlag)
//
//        //  let user = Constant.preferenceTable.filter(Constant.prefid == id)
//        let updateUser = Constant.preferenceTable.update(Constant.prefstatus <- "n",Constant.prefQty <- "0")
//        do {
//            try Constant.database.run(updateUser)
//        } catch {
//            print(error)
//        }
//        //end
//        self.descriptionTextView.layer.cornerRadius = 5
//        self.descriptionTextView.layer.borderWidth = 1
//        self.descriptionTextView.layer.borderColor = UIColor.black.cgColor
//
//        if(editFlag){
//            self.navigationItem.title = "Edit A Deed"
//            //For back button in navigation bar
//            let backButton = UIBarButtonItem()
//            backButton.title = "Back"
//            self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
//            self.menuBtn.image = UIImage (named: "Back")
//            self.postBtn.setTitle("Save", for: .normal)
//            self.selectAudianceBTn.isHidden = true
//            self.selectAudianceHeightConstraint.constant = 0
//            self.selectAudianceBTn.isHidden = true
//            //set deed details on form outlet's
//            //put existing deed image and send baseurl to edit url
//            print(self.deedImage)
//            if !self.deedImage.isEqual(""){
//                let deedImage = self.deedImage.components(separatedBy: "/");
//                let imageName = deedImage.last!.components(separatedBy: ".");
//                editedImg = imageName.first!
//            }
//            else{
//                editedImg = ""
//            }
//            print(editedImg)
//            self.deedImageView.sd_setImage(with: URL(string: self.deedImage), placeholderImage: UIImage(named: ""))
//            self.categoryIcon.sd_setImage(with: URL(string: self.charactorURL), placeholderImage: UIImage(named: "Placeholder"))
//            self.selectGroupTitle.isUserInteractionEnabled = false
//            self.selectGroupBtn.isUserInteractionEnabled = false
//            self.selectGroupTitle.text = self.needGroupTitle
//            //  self.selectCategoryBtn.setTitle(self.needTitle, for: .normal)
//            self.selectCategoryText.text = self.needTitle
//            print(self.needGroupTitle)
//            self.selectGroupTitle.text = self.needGroupTitle
//            let string = self.subType
//            let array = string.components(separatedBy: ",")
//            print(array)
//            if(array.count > 1){
//                //  self.selectPreferenceBtn.setTitle(("\(array[0]) & \(array.count - 1) Other(s)"), for: .normal)
//                self.selectPreferenceText.text = ("\(array[0]) & \(array.count - 1) Other(s)")
//            }
//            else{
//                self.selectPreferenceText.text = array[0]
//                //  self.selectPreferenceBtn.setTitle(array[0], for: .normal)
//            }
//
//
//            var title = ""
//            print(preferenceDict)
//            let preferences = (preferenceDict.flatMap({ (key, value) -> String in
//                return "\(key):\(value)"
//            }) as Array).joined(separator: ",")
//            //        print(preferenceDict.first!)
//            print(preferences)
//            //            let dic = array.toDictionary
//            //         print(dic)
//            //Convert preference string into pref name array , pref qty array
//            let str = string.components(separatedBy: CharacterSet.decimalDigits).joined()
//            print(str)
//            let strs = removeSpecialCharsFromString(text: str)
//            let nums = removeSpecialNumFromString(text: string)
//            print("\(strs)\(nums)")
//            let nameArray = strs.components(separatedBy: ",")
//            let qtyArray = nums.components(separatedBy: ",")
//            print("\(nameArray)\(qtyArray)")
//            GlobalClass.sharedInstance.openDb()
//            GlobalClass.sharedInstance.createPreferenceTable()
//            var reversedNames = [String]()
//            var reversedQty = [String]()
//            for arrayIndex in stride(from: nameArray.count - 1, through: 0, by: -1) {
//                reversedNames.append(nameArray[arrayIndex])
//            }
//            for arrayIndex in stride(from: qtyArray.count - 1, through: 0, by: -1) {
//                reversedQty.append(qtyArray[arrayIndex])
//            }
//            //  print("\(reversedNames)\(reversedQty)")
//
//            for (key, value) in zip(nameArray, qtyArray) {
//                print("\(key)\(value)")
//                //update table with value
//                //update
//
//                let user = Constant.preferenceTable.filter(Constant.prefname == key)
//                let updateUser = user.update(Constant.prefstatus <- "y",Constant.prefQty <- value)
//                do {
//                    try Constant.database.run(updateUser)
//                } catch {
//                    print(error)
//                }
//                //end
//                //                let insertUser = Constant.preferenceTable.insert(Constant.prefname <- key, Constant.prefid   <- key,Constant.prefQty <- value,Constant.prefstatus <- "y")
//                //                print(insertUser)
//                //                do {
//                //                    try Constant.database.run(insertUser)
//                //                    print("INSERTED USER")
//                //                } catch {
//                //                    print(error)
//                //                }
//            }
//
//            //retrive data
//            do {
//                let query = Constant.preferenceTable.select(Constant.prefname,Constant.prefQty,Constant.prefstatus)
//                    .filter(Constant.prefstatus == "y" && Constant.prefmapid == self.needMappingID && Constant.prefQty > "0")
//                let users = try Constant.database.prepare(query)
//                var qty = ""
//                var name = ""
//                for user in users {
//                    qty = user[Constant.prefQty]
//                    name = user[Constant.prefname]
//                    selectedPreferenceName.add(name)
//                    selectedPreferenceId.add(qty)
//                    print("\(qty)\(name)\(preferenceDict)")
//                    preferenceDict.updateValue(qty, forKey: name)
//                }
//            } catch {
//                print(error)
//            }
//            print("\(selectedPreferenceName)\(selectedPreferenceId)")
//
//            self.addressLabel.text = addressString
//            print(pAddress)
//
//            if(pAddress == "Y")
//            {
//                parmanentAddress = "Y"
//                labelSwitch.curState = .R
//            }
//            else{
//                parmanentAddress = "N"
//                labelSwitch.curState = .L
//            }
//
//            self.sliderValueLbl.text = "\(self.validity) hr(s)"
//            self.sliderValidity.value = Float(self.validity)!
//            print(self.containerChk)
//            if(self.cat_type == "C"){
//                self.containerStatus = "0"
//                self.containerView.isHidden = true
//                self.containerViewHeight.constant = 0
//                self.containerViewHeight.constant = 0
//
//            }
//            else {
//                if(self.containerChk == "0"){
//                    self.containerStatus = "0"
//                    self.containerView.isHidden = true
//                    self.containerViewHeight.constant = 0
//                    self.containerViewHeight.constant = 0
//                }
//                else{
//                    self.containerStatus = "1"
//                    self.containerView.isHidden = false
//                    if Device.IS_IPHONE {
//
//                        self.containerViewHeight.constant = 100.0
//                        self.containerViewHeight.constant = 100.0
//                    }
//                    else {
//
//                        self.containerViewHeight.constant = 120.0
//                        self.containerViewHeight.constant = 120.0
//                    }
//
//                }
//            }
//
//
//            if(self.desc.count > 0){
//                DispatchQueue.main.async{
//                    self.descriptionTextView.text = self.desc
//                    self.descriptionTextView.isHidden = false
//                    self.descriptionHeightConstraint.constant = 80.0
//                    self.descriptionHeightConstraint.constant = 80.0
//                }
//
//            }
//            else{
//                DispatchQueue.main.async{
//                    self.descriptionTextView.text = ""
//                    //                     self.selectGroupBtn.isEnabled = true
//                    self.descriptionTextView.isHidden = false
//                    self.descriptionHeightConstraint.constant = 40.0
//                    self.descriptionHeightConstraint.constant = 40.0
//                }
//            }
//        }
//        else{
//            // continue with new tag
//            parmanentAddress = "N"
//            labelSwitchOne.curState = .R
//            self.findCurrentLocation()
//            DispatchQueue.main.async{
//                self.selectGroupBtn.isUserInteractionEnabled = true
//                self.containerView.isHidden = true
//                self.containerViewHeight.constant = 0.0
//                self.containerViewHeight.constant = 0.0
//                self.labelSwitch.delegate = self
//                self.containerStatus = "0"
//                self.labelSwitch.circleShadow = false
//                self.labelSwitch.fullSizeTapEnabled = true
//                self.labelSwitchOne.delegate = self
//
//                self.labelSwitchOne.circleShadow = false
//                self.labelSwitchOne.fullSizeTapEnabled = true
//            }
//        }
//        automaticallyAdjustsScrollViewInsets = false
//
//
//        descriptionTextView.addBottomBorder(UIColor.black, height: 1.0)
//
//        self.downloadOwnGroupData()
//        //self.downloadCategoryData()
//        imagePicker.delegate = self
//        cameraBtn.backgroundColor = .clear
//        cameraBtn.layer.cornerRadius = 5
//        cameraBtn.layer.borderWidth = 1
//        cameraBtn.layer.borderColor = UIColor.gray.cgColor
//        browseBtn.backgroundColor = .clear
//        browseBtn.layer.cornerRadius = 5
//        browseBtn.layer.borderWidth = 1
//        browseBtn.layer.borderColor = UIColor.gray.cgColor
//        // selectLocationLbl.addBottomBorder(UIColor.gray, height: 1)
//        // parmanantLocation.addBottomBorder(UIColor.gray, height: 1)
//        // validityLbl.addBottomBorder(UIColor.gray, height: 1)
//        //  descriptionLbl.addBottomBorder(UIColor.gray, height: 1)
//        selectGroupBtn.addBottomBorder(UIColor.gray, height: 1)
//        selectCategoryBtn.addBottomBorder(UIColor.gray, height: 1)
//        selectPreferenceBtn.addBottomBorder(UIColor.gray, height: 1)
//        selectAddressBtn.addBottomBorder(UIColor.gray, height: 1)
//        selectAudianceBTn.addBottomBorder(UIColor.gray, height: 1)
//        NotificationCenter.default.addObserver(self, selector: #selector(TagADeedsViewController.methodOfReceivedAudianceNotification(notification:)), name: Notification.Name("audianceselecte"), object: nil)
//
//    }
//    //Find user current location
//    func findCurrentLocation(){
//
//        if (CLLocationManager.locationServicesEnabled())
//        {
//            locManager = CLLocationManager()
//            locManager.delegate = self
//            locManager.desiredAccuracy = kCLLocationAccuracyBest
//            locManager.startUpdatingLocation()
//        }
//    }
//
//    //Get user address from user current location (lat, long)
//    func getAddressForLatLng(latitude: String, longitude: String) {
//
//        let url = NSURL(string: "\(Constant.GOOGLE_PLACES_BASE_URL)latlng=\(latitude),\(longitude)&key=\(Constant.GooglePlacesApp_ID)")
//
//
//        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = 60.0
//        let session = URLSession(configuration: sessionConfig)
//
//
//        let request = NSMutableURLRequest(url: url! as URL)
//
//        let task = session.dataTask(with: request as URLRequest) {
//            (
//
//            data, response, error) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//                ANLoader.hide()
//            }
//
//            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
//
//                DispatchQueue.main.async{
//
//                    self.view.hideAllToasts()
//                    self.navigationController?.view.makeToast(Validation.ERROR)
//                }
//                return
//            }
//
//            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
//            {
//
//                if let result = jsonObj!["results"] as? NSArray {
//
//                    DispatchQueue.main.async {
//
//                        let address = (result[0] as AnyObject)["formatted_address"] as? String
//                        self.addressString = address!
//                        if(self.data == "P"){
//                            self.selectAddressBtn.isEnabled = false
//                            self.labelSwitch.curState = .R
//                            self.parmanentAddress = "Y"
//                            self.labelSwitch.isUserInteractionEnabled = false
//                            let markerAddress = UserDefaults.standard.string(forKey: "markerAddress")
//                            self.addressLabel.text = markerAddress
//                        }
//                        else{
//                            self.addressLabel.text = self.addressString
//                            self.selectAddressBtn.isEnabled = true
//                            self.labelSwitch.curState = .L
//                            self.parmanentAddress = "N"
//                            self.labelSwitch.isUserInteractionEnabled = true
//                        }
//                    }
//                }
//            }
//
//        }
//        task.resume()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//
//        var currentLocation = locations.last! as CLLocation
//
//        currentLocation = locManager.location!
//        currentLatLong = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
//
//        geoPoint = String(format:"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
//
//        self.getAddressForLatLng(latitude: String(format:"%f",currentLocation.coordinate.latitude), longitude: String(format:"%f",currentLocation.coordinate.longitude))
//
//        self.locManager.stopUpdatingLocation()
//    }
var text = "".localized()
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Error while updating location " + error.localizedDescription)
//    }
//
//    // Mark: Google Autocomplete
//    @IBAction func autocompleteClicked(_ sender: UIButton) {
//        let autocompleteController = GMSAutocompleteViewController()
//        autocompleteController.delegate = self
//        present(autocompleteController, animated: true, completion: nil)
//    }
//
//    @IBOutlet weak var menuBtnPress: UINavigationItem!
//    @IBAction func menuBtnPress(_ sender: UIBarButtonItem) {
//        if(editFlag){
//
//            self.navigationController?.popViewController(animated: true)
//        }
//        else if(self.data == "P"){
//            // self.navigationController?.popViewController(animated: true)
//            if let drawer = self.drawer() ,
//                let manager = drawer.getManager(direction: .left){
//                let value = !manager.isShow
//                drawer.showLeftSlider(isShow: value)
//            }
//        }
//        else{
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
//            UIApplication.shared.keyWindow?.rootViewController = viewController
//            //            if let drawer = self.drawer() ,
//            //                let manager = drawer.getManager(direction: .left){
//            //                let value = !manager.isShow
//            //                drawer.showLeftSlider(isShow: value)
//            //            }
//        }
//    }
//
//    //MARK:- Download category data
//    func downloadCategoryData (mapId : String){
//
//        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
//
//        let urlString = Constant.BASE_URL + Constant.need_type
//
//        let url:NSURL = NSURL(string: urlString)!
//
//        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = 60.0
//        let session = URLSession(configuration: sessionConfig)
//
//        let request = NSMutableURLRequest(url: url as URL)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
//        request.httpMethod = "POST"
//        let paramString = String(format: "group_id=%@",mapId)
//        request.httpBody = paramString.data(using: String.Encoding.utf8)
//        let task = session.dataTask(with: request as URLRequest) {
//            (
//
//            data, response, error) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//                ANLoader.hide()
//            }
//
//            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
//
//                DispatchQueue.main.async{
//
//                    //self.view.hideAllToasts()
//                    //self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
//                }
//                return
//            }
//
//            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
//
//                if let needtype = jsonObj!.value(forKey: "g_need") as? NSArray {
//
//                    self.categoryListArr.removeAllObjects();
//                    self.categoryArr.removeAllObjects();
//
//                    for item in needtype {
//
//                        do {
//
//                            try self.categoryListArr.add((item as AnyObject).value(forKey:"Need_Name") as! String)
//
//                            let needItem = item as? NSDictionary
//                            try self.categoryArr.add(needItem!)
//
//                        } catch {
//                            // Error Handling
//                            print("Some error occured.")
//                        }
//
//                    }
//                }
//                if let needtype1 = jsonObj!.value(forKey: "c_need") as? NSArray {
//
//                    //                    self.categoryListArr.removeAllObjects();
//                    //                    self.categoryArr.removeAllObjects();
//
//                    for item in needtype1 {
//
//                        do {
//
//                            try self.categoryListArr.add((item as AnyObject).value(forKey:"Need_Name") as! String)
//
//                            let needItem = item as? NSDictionary
//                            try self.categoryArr.add(needItem!)
//
//                        } catch {
//                            // Error Handling
//                            print("Some error occured.")
//                        }
//
//                    }
//                }
//            }
//
//        }
//        task.resume()
//    }
//    //download group data
//    func downloadOwnGroupData (){
//        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
//        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
//
//        let urlString = Constant.BASE_URL + Constant.showGroupList
//
//        let url:NSURL = NSURL(string: urlString)!
//
//        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = 60.0
//        let session = URLSession(configuration: sessionConfig)
//
//        let request = NSMutableURLRequest(url: url as URL)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
//        request.httpMethod = "POST"
//        let paramString = String(format: "user_id=%@",userId)
//        request.httpBody = paramString.data(using: String.Encoding.utf8)
//        let task = session.dataTask(with: request as URLRequest) {
//            (
//
//            data, response, error) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//                ANLoader.hide()
//            }
//
//            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
//
//                DispatchQueue.main.async{
//                    //self.view.hideAllToasts()
//                    //self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
//                }
//                return
//            }
//
//            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
//
//                self.groupListArr.removeAllObjects();
//                self.groupArr.removeAllObjects();
//
//                for item in jsonObj! {
//
//                    do {
//
//                        try self.groupListArr.add((item as AnyObject).value(forKey:"group_name") as! String)
//
//                        let groupItem = item as? NSDictionary
//                        try self.groupArr.add(groupItem!)
//
//                    } catch {
//                        // Error Handling
//                        print("Some error occured.")
//                    }
//
//                }
//
//            }
//
//        }
//        task.resume()
//    }
//    @IBAction func selectPreferenceBtnPress(_ sender: UIButton) {
//        if(self.needTitle.count == 0){
//            self.view.makeToast("Please select category")
//        }
//        else{
//            self.subType = ""
//            self.view.hideAllToasts()
//            selectedPreferenceName.removeAllObjects()
//            selectedPreferenceId.removeAllObjects()
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! SubCategoryDeedViewController
//            vc.modalPresentationStyle = .overFullScreen
//            vc.modalTransitionStyle = .crossDissolve
//            vc.type_name = self.needTitle
//            vc.type_id = self.needMappingID
//            print(self.needTitle as Any,self.needMappingID,vc.type_id)
//            self.present(vc, animated: true, completion: nil)
//        }
//    }
//    @objc func methodOfReceivedNotification(notification: Notification) {
//
//        print(preferenceDict)
//
//        do {
//            let query = Constant.preferenceTable.select(Constant.prefname,Constant.prefQty,Constant.prefstatus)
//                .filter(Constant.prefstatus == "y" && Constant.prefmapid == self.needMappingID && Constant.prefQty > "0")
//            let users = try Constant.database.prepare(query)
//            var qty = ""
//            var name = ""
//            for user in users {
//                qty = user[Constant.prefQty]
//                name = user[Constant.prefname]
//                selectedPreferenceName.add(name)
//                selectedPreferenceId.add(qty)
//                print("\(qty)\(name)\(preferenceDict)")
//                preferenceDict.updateValue(qty, forKey: name)
//            }
//        } catch {
//            print(error)
//        }
//        print("\(selectedPreferenceName)\(selectedPreferenceId)")
//        var title = ""
//        print(preferenceDict)
//        let preferences = (preferenceDict.flatMap({ (key, value) -> String in
//            return "\(key):\(value)"
//        }) as Array).joined(separator: ",")
//        //        print(preferenceDict.first!)
//        print(preferences)
//        if(preferences == ""){
//
//        }
//        else{
//            var titleLbl = ""
//            if(preferenceDict.count > 1){
//                //    self.selectPreferenceBtn.setTitle(("\(preferenceDict.first!.key):\(preferenceDict.first!.value) & \(preferenceDict.count - 1) Other's"), for: .normal)
//                self.selectPreferenceText.text = ("\(preferenceDict.first!.key):\(preferenceDict.first!.value) & \(preferenceDict.count - 1) Other's")
//            }
//            else{
//                titleLbl = ("\(preferenceDict.first!.key):\(preferenceDict.first!.value)")
//                self.selectPreferenceText.text  = titleLbl
//                //   self.selectPreferenceBtn.setTitle(titleLbl, for: .normal)
//            }
//        }
//    }
//    @IBAction func contsinerSwichPress(_ sender: UISwitch) {
//        if(sender.isOn){
//            self.containerStatus = "1"
//        }
//        else{
//            self.containerStatus = "0"
//        }
//    }
//    @objc func methodOfReceivedAudianceNotification(notification: Notification) {
//        // Take Action on Notification
//        //retrive data for preferance
//        GlobalClass.sharedInstance.openDb()
//        do {
//            let users = try Constant.database.prepare(Constant.audianceTable)
//            for user in users {
//                print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid]), nameQty: \(user[Constant.audQty]), nameStatus: \(user[Constant.audstatus])")
//                let status = user[Constant.audstatus]
//                var id = ""
//                var name = ""
//                if(status == "y"){
//                    name = user[Constant.audname]
//                    id = user[Constant.audid]
//                    selectedAudianceName.add(name)
//                    selectedAudianceId.add(id)
//                }else{
//
//                }
//                //  print("\(selectedPreferenceName)\(selectedPreferenceId)")
//
//            }
//        } catch {
//            print(error)
//        }
//        var title = ""
//        print("\(selectedAudianceName)\(selectedAudianceId)\((selectedAudianceName.count))")
//        //    let neednames = selectedNeedNames.componentsJoined(by: ",")
//        if(selectedAudianceName.contains("All groups")){
//            sentAudianceSelectAllGroup = "Y"
//        }
//        else if(selectedAudianceName.contains("All indivisual users")){
//            sentAudianceSelectIndivisualUser = "Y"
//
//        }
//        else{
//            sentAudianceSelectIndivisualUser = "N"
//            sentAudianceSelectAllGroup = "N"
//        }
//        sentAudianceIds = selectedAudianceId.componentsJoined(by: ",")
//        print(sentAudianceIds)
//        if(selectedAudianceId.count == 0){
//            title = ""
//        }
//        else{
//            if(selectedAudianceId.count > 1){
//                if(sentAudianceSelectAllGroup == "Y"){
//                    title = ("Selected - All Group's")
//                }
//                else{
//                    title = ("Selected - \(selectedAudianceName[0]) & \(selectedAudianceName.count-1) other(s)")
//                }
//
//            }
//            else{
//                title = ("Selected - \(selectedAudianceName[0])")
//            }
//        }
//        //  self.selectAudianceBTn.setTitle(title, for: .normal)
//        self.selectAudianceText.text = title
//    }
//    @IBAction func selectAudianceBtnPress(_ sender: UIButton) {
//        selectedAudianceId.removeAllObjects()
//        selectedAudianceName.removeAllObjects()
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "AudianceViewController") as! AudianceViewController
//        vc.modalPresentationStyle = .overFullScreen
//        vc.modalTransitionStyle = .crossDissolve
//        self.present(vc, animated: true, completion: nil)
//    }
//    @IBAction func sliderValueChange(_ sender: UISlider) {
//        let currentValue = Int(sender.value)
//        sliderValueLbl.text = "\(currentValue) hr(s)"
//    }
//    @IBAction func cameraBtnPress(_ sender: UIButton) {
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .camera
//
//        present(imagePicker, animated: true, completion: nil)
//    }
//    @IBAction func browseBtnPress(_ sender: UIButton) {
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
//
//        present(imagePicker, animated: true, completion: nil)
//    }
//    @IBAction func selectGroupBtnPress(_ sender: UIButton) {
//        if self.groupListArr.count == 0{
//            self.view.hideAllToasts()
//            self.navigationController?.view.makeToast("Group list is empty.")
//            return
//        }
//        ActionSheetStringPicker.show(withTitle: "Select Group",
//                                     rows: self.groupListArr as! [Any] ,
//                                     initialSelection: 0,
//                                     doneBlock: {
//                                        picker, indexe, values in
//                                        DispatchQueue.main.async{
//                                            //    self.selectGroupBtn.setTitle(values as? String, for: .normal) }
//                                            self.selectGroupTitle.text = values as? String
//                                        }
//                                        let item = self.groupArr[indexe]
//                                        self.needGroupTitle = (item as AnyObject).value(forKey:"group_name") as! String
//                                        self.needGroupMappingID = (item as AnyObject).value(forKey:"group_id") as! String
//
//                                        print("\(self.needGroupTitle)\(self.needGroupMappingID)")
//
//                                        if(self.needGroupTitle.count > 0){
//                                            self.downloadCategoryData(mapId: self.needGroupMappingID)
//                                        }else{}
//
//                                        return
//        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
//    }
//    @IBAction func selectCategoryBtnPress(_ sender: UIButton) {
//        GlobalClass.sharedInstance.openDb()
//        preferenceDict.removeAll()
//        if(editFlag){
//            self.downloadCategoryData(mapId: self.needGroupMappingID)
//        }
//        else{
//            //self.selectPreferenceBtn.setTitle("Select preference", for: .normal)
//            //    self.selectPreferenceText.text = "Select preference"
//        }
//        UserDefaults.standard.removeObject(forKey: "launchedBefore")
//
//        let updateUser = Constant.preferenceTable.update(Constant.prefstatus <- "n",Constant.prefQty <- "0")
//        do {
//            try Constant.database.run(updateUser)
//        } catch {
//            print(error)
//        }
//        //end
//        let deleteUser1 = Constant.audianceTable.delete()
//        do {
//            try Constant.database.run(deleteUser1)
//        } catch {
//            print(error)
//        }
//        if self.categoryListArr.count == 0{
//            self.view.hideAllToasts()
//            self.navigationController?.view.makeToast("Categories are empty.")
//            return
//        }
//        ActionSheetStringPicker.show(withTitle: "Select Category",
//                                     rows: self.categoryListArr as! [Any] ,
//                                     initialSelection: 0,
//                                     doneBlock: {
//                                        picker, indexe, values in
//                                        DispatchQueue.main.async{
//                                            // self.selectCategoryBtn.setTitle(values as? String, for: .normal)
//                                            self.selectCategoryText.text = values as? String
//                                            self.categoryIcon.isHidden = false
//                                        }
//
//
//                                        let item = self.categoryArr[indexe]
//                                        self.needTitle = (item as AnyObject).value(forKey:"Need_Name") as! String
//                                        self.needMappingID = (item as AnyObject).value(forKey:"NeedMapping_ID") as! String
//                                        self.categoryTypeTitle = (item as AnyObject).value(forKey:"type") as! String
//                                        DispatchQueue.main.async {
//
//                                            if  let img = (item as AnyObject).value(forKey:"Character_Path") as? String {
//                                                print("Success")
//                                                //Character_Path Icon_Path
//                                                let iconURL = String(format: "%@%@", Constant.BASE_URL ,(item as AnyObject).value(forKey:"Character_Path") as! String)
//
//                                                self.categoryIcon.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "login_logo"))
//                                            }
//                                            else {
//                                                //Character_Path Icon_Path
//                                                let iconURL = String(format: "%@%@%@", Constant.BASE_URL,"/image/group_category/" ,(item as AnyObject).value(forKey:"Icon_Path") as! String)
//
//                                                self.categoryIcon.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "login_logo"))
//                                                print("Failure")
//                                            }
//
//
//                                        }
//                                        //  print(self.selectCategoryBtn.titleLabel?.text! as Any)
//                                        //  self.selectCategoryText.text = values as? String
//                                        //  self.selectPreferenceBtn.setTitle("Select preference", for: .normal)
//                                        print(self.needTitle)
//
//                                        //Hide preference table
//                                        if (( self.categoryTypeTitle.isEqual("C"))){
//
//                                            if Device.IS_IPHONE {
//                                                self.preferenceHeightConstrint.constant = 0.0
//                                                self.containerViewHeight.constant = 0.0
//                                                self.containerViewHeight.constant = 0.0
//                                            }
//                                            else {
//                                                self.preferenceHeightConstrint.constant = 0.0
//                                                self.containerViewHeight.constant = 0.0
//                                                self.containerViewHeight.constant = 0.0
//                                            }
//                                            self.selectAudianceText.text = self.needGroupTitle
//                                            self.selectAudianceText.isEnabled = false
//                                            self.selectAudianceBTn.isEnabled = false
//                                            self.sentAudianceIds = self.needGroupMappingID
//                                            self.containerView.isHidden = true
//                                            self.selectPreferenceBtn.isHidden = true
//                                            self.selectPreferenceText.isHidden = true
//                                        }
//                                        else {
//                                            if (( self.needTitle.isEqual("Water")) || ( self.needTitle.isEqual("Food"))){
//
//                                                if Device.IS_IPHONE {
//                                                    self.preferenceHeightConstrint.constant = 40.0
//                                                    self.containerViewHeight.constant = 100.0
//                                                    self.containerViewHeight.constant = 100.0
//                                                }
//                                                else {
//                                                    self.preferenceHeightConstrint.constant = 60.0
//                                                    self.containerViewHeight.constant = 120.0
//                                                    self.containerViewHeight.constant = 120.0
//                                                }
//                                                self.containerView.isHidden = false
//                                                self.selectPreferenceBtn.isHidden = false
//                                                self.selectPreferenceText.isHidden = false
//                                            }
//                                            else{
//                                                if Device.IS_IPHONE {
//                                                    self.preferenceHeightConstrint.constant = 40.0}
//                                                else{
//                                                    self.preferenceHeightConstrint.constant = 60.0
//                                                }
//                                                self.selectAudianceText.isEnabled = true
//                                                self.selectAudianceBTn.isEnabled = true
//                                                self.selectPreferenceBtn.isHidden = false
//                                                self.selectPreferenceText.isHidden = false
//                                                self.containerView.isHidden = true
//                                                self.containerViewHeight.constant = 0.0
//                                                self.containerViewHeight.constant = 0.0
//                                            }
//                                        }
//                                        return
//        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
//    }
//
//    //save image to server
//    func saveImageMethodCall(){
//
//        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
//
//        let urlString = Constant.BASE_URL + Constant.saveimg
//
//        let url:NSURL = NSURL(string: urlString)!
//
//        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = 60.0
//        let session = URLSession(configuration: sessionConfig)
//
//        let charset = NSMutableCharacterSet.alphanumeric()
//        let request = NSMutableURLRequest(url: url as URL)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
//        request.httpMethod = "POST"
//        let paramString = String(format: "name=test.png&image=%@",self.imageBase64.addingPercentEncoding(withAllowedCharacters: charset as CharacterSet)!)
//        request.httpBody = paramString.data(using: String.Encoding.utf8)
//
//        let task = session.dataTask(with: request as URLRequest) {
//            (
//
//            data, response, error) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//                ANLoader.hide()
//            }
//
//            if let data = data {
//
//                guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
//
//                    DispatchQueue.main.async {
//
//                        self.view.makeToast(Validation.NETWORK_ERROR)
//                    }
//                    return
//                }
//
//                guard let imageName = String(data: data, encoding: .utf8) else{
//
//                    DispatchQueue.main.async{
//
//                        self.view.hideAllToasts()
//                        self.navigationController?.view.makeToast("Some error occured, While image uploading.")
//                    }
//                    return
//                }
//                print(imageName)
//                DispatchQueue.main.async {
//
//                    let validaty:Int? = Int(CGFloat((self.sliderValueLbl.text! as NSString).doubleValue))
//
//                    let discription = self.descriptionTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//                    self.deedImage = imageName
//                    self.tagADeedMethod(needMappingID: self.needMappingID, geoPoint: self.geoPoint, imageName: self.deedImage, needTitle: self.needTitle, discription: discription, addressString: self.addressString, paddressString: self.parmanentAddress, hourVal: validaty!, containerStatus: self.containerStatus)
//
//                }
//
//            } else if let error = error {
//
//                //    self.outletCoverView.isHidden = true
//                DispatchQueue.main.async {
//
//                    self.view.makeToast(Validation.ERROR)
//                }
//            } else {
//
//                // no data and no error... what happened???
//                //  self.outletCoverView.isHidden = true
//                DispatchQueue.main.async {
//
//                    self.view.makeToast(Validation.ERROR)
//                }
//            }
//        }
//        task.resume()
//    }
//    //save data to server to tag a new deed
//    func tagADeedMethod(needMappingID: String,geoPoint: String,imageName: String,needTitle: String,discription: String,addressString: String,paddressString: String,hourVal: Int, containerStatus: String){
//        print("\(editedImg)\(editedImg.count)\(self.deedImage))")
//
//        var preferences  = ""
//        let string = self.subType
//        let array = string.components(separatedBy: ",")
//        print(array)
//        let strings = array.joined(separator: ",")
//
//        print(self.subType)
//        var urlString =  ""
//        var paramString = ""
//        if(strings.isEmpty){
//            preferences = (preferenceDict.flatMap({ (key, value) -> String in
//                return "\(key):\(value)"
//            }) as Array).joined(separator: ",")
//            print(preferences)
//        }
//        else{
//            preferences = strings
//        }
//        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
//        if(editFlag){
//            let charset = NSMutableCharacterSet.alphanumeric()
//            urlString = Constant.BASE_URL + Constant.edit_deed
//
//
//            if(self.deedImage.count == 0){
//                paramString = String(format: "User_ID=%@&deedId=%@&NeedMapping_ID=%@&Geopoint=%@&Tagged_Photo_Path=%@&Tagged_Title=%@&Description=%@&Address=%@&PAddress=%@&validity=%d&container=%@&sub_type_pref=%@", userId,deedId,needMappingID,geoPoint,editedImg,needTitle,discription,self.addressLabel.text!,self.parmanentAddress,hourVal,containerStatus,preferences)
//                print(paramString)
//
//            }
//            else{
//                paramString = String(format: "User_ID=%@&deedId=%@&NeedMapping_ID=%@&Geopoint=%@&Tagged_Photo_Path=%@&Tagged_Title=%@&Description=%@&Address=%@&PAddress=%@&validity=%d&container=%@&sub_type_pref=%@", userId,deedId,needMappingID,geoPoint,self.deedImage,needTitle,discription,self.addressLabel.text!,self.parmanentAddress,hourVal,containerStatus,preferences)
//                print(paramString)
//            }
//
//        }
//        else{
//            urlString = Constant.BASE_URL + Constant.tag_need
//            paramString = String(format: "User_ID=%@&NeedMapping_ID=%@&Geopoint=%@&Tagged_Photo_Path=%@&Tagged_Title=%@&Description=%@&Address=%@&PAddress=%@&validity=%d&container=%d&sub_type_pref=%@&all_groups=%@&all_individuals=%@&user_grp_ids=%@&from_group=%@", userId,needMappingID,geoPoint,imageName,needTitle,discription,self.addressLabel.text!,self.parmanentAddress,hourVal,containerStatus,preferences,sentAudianceSelectAllGroup,sentAudianceSelectIndivisualUser,sentAudianceIds,self.needGroupMappingID)
//            print(paramString)
//        }
//        if(self.data == "P"){
//
//            let markerAddress = UserDefaults.standard.string(forKey: "markerAddress")
//            let markerGeo  = UserDefaults.standard.string(forKey: "markerGeo")
//            urlString = Constant.BASE_URL + Constant.tag_need
//            paramString = String(format: "User_ID=%@&NeedMapping_ID=%@&Geopoint=%@&Tagged_Photo_Path=%@&Tagged_Title=%@&Description=%@&Address=%@&PAddress=%@&validity=%@&container=%d&sub_type_pref=%@&all_groups=%@&all_individuals=%@&user_grp_ids=%@&from_group=%@", userId,needMappingID,markerGeo!,imageName,needTitle,discription,markerAddress!,self.parmanentAddress,hourVal,containerStatus,preferences,sentAudianceSelectAllGroup,sentAudianceSelectIndivisualUser,sentAudianceIds,self.needGroupMappingID)
//            print(paramString)
//        }
//        print(paramString)
//        let url:NSURL = NSURL(string: urlString)!
//
//        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = 60.0
//        let session = URLSession(configuration: sessionConfig)
//
//        let request = NSMutableURLRequest(url: url as URL)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
//        request.httpMethod = "POST"
//        if(sentAudianceSelectIndivisualUser == "Y"){
//            sentAudianceIds = ""
//        }
//        else{
//
//        }
//
//
//        print(paramString)
//        request.httpBody = paramString.data(using: String.Encoding.utf8)
//
//        let task = session.dataTask(with: request as URLRequest) {
//            (
//
//            data, response, error) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//                ANLoader.hide()
//            }
//
//            if let data = data {
//
//                guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
//
//                    DispatchQueue.main.async{
//
//                        //  self.outletCoverView.isHidden = true
//                        self.view.hideAllToasts()
//                        self.navigationController?.view.makeToast(Validation.ERROR)
//                    }
//                    return
//                }
//
//                if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
//                    print(jsonObj as Any)
//                    let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
//                    if blockStatus == 1 && blockStatus != nil {
//
//                        DispatchQueue.main.async {
//
//                            GlobalClass.sharedInstance.deInitClass()
//                            GlobalClass.sharedInstance.clearLocalData()
//                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
//                            UIApplication.shared.keyWindow?.rootViewController = viewController
//
//                            GlobalClass.sharedInstance.blockStatus = true
//                        }
//                        return
//                    }
//
//                    DispatchQueue.main.async {
//                        if(self.editFlag){
//                            let status = jsonObj?.value(forKey: "status") as! Int
//                            if(status == 1){
//                                self.view.makeToast("Deed updated successfully")
//                                self.navigationController?.popToRootViewController(animated: true)
//                            }
//                            else{
//                                self.view.makeToast("Something went wrong,Data not save")
//                            }
//                        }
//                        else{
//                            if let checkstatus = jsonObj!.value(forKey: "checkstatus") as? NSArray {
//                                self.view.addSubview(self.someImageView) //This add it the view controller without constraints
//                                self.someImageViewConstraints() //This function is outside the viewDidLoad function that controls the constraints
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                    let status = String(format: "%@",(checkstatus[0] as AnyObject).value(forKey:"status") as! String)
//                                    if status.isEqual("1"){
//                                        self.someImageView.removeFromSuperview()
//                                        let Total_credits = String(format: "%d",(checkstatus[0] as AnyObject).value(forKey:"Total_credits") as! Int)
//                                        let credits_earned = String(format: "%@",(checkstatus[0] as AnyObject).value(forKey:"credits_earned") as! String)
//                                        let alertTitle = String(format: "You have tagged %@ need",self.needTitle)
//                                        let alertMessage = String(format: "You have earned %@ point(s) and Your total point(s) are %@",credits_earned,Total_credits)
//
//                                        // create the alertl
//                                        let alert = UIAlertController(title: alertTitle , message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
//
//                                        // add the actions (buttons)
//                                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (actionSheetController) -> Void in
//
//                                            DispatchQueue.main.async {
//
//                                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
//                                                UIApplication.shared.keyWindow?.rootViewController = viewController
//                                            }
//                                        }))
//
//                                        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.destructive, handler: { (actionSheetController) -> Void in
//
//                                            // set up activity view controller
//                                            let textToShare = [ Constant.GAD_SHARE_TEXT ]
//                                            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//                                            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop ]
//                                            activityViewController.completionWithItemsHandler = {
//                                                (activity, success, items, error) in
//
//                                                DispatchQueue.main.async {
//
//                                                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                                                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
//                                                    UIApplication.shared.keyWindow?.rootViewController = viewController
//                                                }
//                                            }
//
//                                            if Device.IS_IPHONE {
//
//                                                self.present(activityViewController, animated: true, completion: nil)
//                                            }
//                                            else {
//
//                                                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
//                                                activityViewController.popoverPresentationController?.sourceView = self.view
//                                                activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//
//                                                self.present(activityViewController, animated: true, completion: nil)
//                                            }
//                                        }))
//                                        self.present(alert, animated: true, completion: nil)
//                                    }
//                                    else if status.isEqual("0"){
//
//                                        //  self.outletCoverView.isHidden = true
//                                        self.view.hideAllToasts()
//                                        self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }else if let error = error {
//
//                //  self.outletCoverView.isHidden = true
//                DispatchQueue.main.async {
//
//                    self.view.makeToast(Validation.ERROR)
//                }
//            } else {
//
//                // no data and no error... what happened???
//                //   self.outletCoverView.isHidden = true
//                DispatchQueue.main.async {
//
//                    self.view.makeToast(Validation.ERROR)
//                }
//            }
//        }
//        task.resume()
//    }
//
//    // MARK: Image Picker
//
//
//    // MARK: - UIImagePickerControllerDelegate Methods
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//
//        picker.dismiss(animated: true)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
//
//            self.deedImageView.image = editedImage;
//
//        }
//        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//
//            self.deedImageView.image = originalImage;
//
//        }
//        self.deedImageView.contentMode = UIViewContentMode.scaleToFill
//        picker.dismiss(animated: true)
//        imageFlag = true
//        self.imageBase64 = GlobalClass.sharedInstance.encodeToBase64String(image:self.deedImageView.image!)!
//
//
//    }
//    //Validate all data
//    @IBAction func postAction(_ sender: Any) {
//
//        if self.needMappingID.count == 0{
//
//            self.view.hideAllToasts()
//            self.navigationController?.view.makeToast("Select Category")
//            return
//        }
//
//        if self.needTitle.count == 0 {
//
//            self.view.hideAllToasts()
//            self.navigationController?.view.makeToast("Select Category")
//            return
//        }
//
//        let discription = descriptionTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        if discription.count > 500{
//
//            self.view.hideAllToasts()
//            self.navigationController?.view.makeToast("Enter Description less than 500 characters")
//            return
//        }
//        if addressString.count == 0 {
//
//            self.view.hideAllToasts()
//            self.navigationController?.view.makeToast("Select Address")
//            return
//        }
//        if needGroupMappingID.count == 0 {
//
//            self.view.hideAllToasts()
//            self.navigationController?.view.makeToast("Select Group")
//            return
//        }
//        if(self.selectCategoryText.text == "Money"){
//
//        }else if(self.selectCategoryText.text == ""){
//            self.view.hideAllToasts()
//            self.navigationController?.view.makeToast("Select preference")
//            return
//        }
//        //        else if preferenceDict.count == 0 {
//        //
//        //            self.view.hideAllToasts()
//        //            self.navigationController?.view.makeToast("Select preference")
//        //            return
//        //        }
//        //        else{
//        //
//        //        }
//        if(editFlag){
//            let optionMenu = UIAlertController(title: "", message: "Do you really want to edit this deed.", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "Yes", style: .default, handler:
//            {
//                (alert: UIAlertAction!) -> Void in
//
//
//                let validaty:Int? = Int(CGFloat((self.sliderValueLbl.text! as NSString).doubleValue))
//                //
//                //                    self.tagADeedMethod(needMappingID: self.needMappingID, geoPoint: self.geoPoint, imageName: self.editedImg, needTitle: self.needTitle, discription: discription, addressString: self.addressString, paddressString: self.parmanentAddress, hourVal: validaty!, containerStatus: self.containerStatus)
//                if self.imageFlag {
//
//                    self.saveImageMethodCall()
//                }
//                else{
//
//                    let validaty:Int? = Int(CGFloat((self.sliderValueLbl.text! as NSString).doubleValue))
//
//                    self.deedImage = ""
//                    self.tagADeedMethod(needMappingID: self.needMappingID, geoPoint: self.geoPoint, imageName: self.deedImage, needTitle: self.needTitle, discription: discription, addressString: self.addressString, paddressString: self.parmanentAddress, hourVal: validaty!, containerStatus: self.containerStatus)
//
//                }
//            })
//
//            let resendAction = UIAlertAction(title: "No", style: .destructive, handler:
//            {
//                (alert: UIAlertAction!) -> Void in
//
//                //   self.outletCoverView.isHidden = true
//                return
//            })
//
//            optionMenu.addAction(okAction)
//            optionMenu.addAction(resendAction)
//            self.present(optionMenu, animated: true, completion: nil)
//        }
//        else{
//            let optionMenu = UIAlertController(title: "", message: "Do you really want to post.", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "Yes", style: .default, handler:
//            {
//                (alert: UIAlertAction!) -> Void in
//
//                //  self.outletCoverView.isHidden = false
//
//                if self.imageFlag {
//
//                    self.saveImageMethodCall()
//                }
//                else{
//
//                    let validaty:Int? = Int(CGFloat((self.sliderValueLbl.text! as NSString).doubleValue))
//
//                    self.deedImage = ""
//                    self.tagADeedMethod(needMappingID: self.needMappingID, geoPoint: self.geoPoint, imageName: self.deedImage, needTitle: self.needTitle, discription: discription, addressString: self.addressString, paddressString: self.parmanentAddress, hourVal: validaty!, containerStatus: self.containerStatus)
//
//                }
//            })
//
//            let resendAction = UIAlertAction(title: "No", style: .destructive, handler:
//            {
//                (alert: UIAlertAction!) -> Void in
//
//                //   self.outletCoverView.isHidden = true
//                return
//            })
//
//            optionMenu.addAction(okAction)
//            optionMenu.addAction(resendAction)
//            self.present(optionMenu, animated: true, completion: nil)
//        }
//
//    }
//    let someImageView: UIImageView = {
//        let theImageView = UIImageView()
//        theImageView.image = UIImage.gif(name: "thumb")//UIImage(named: "yourImage.png")
//        theImageView.translatesAutoresizingMaskIntoConstraints = false //You need to call this property so the image is added to your view
//        return theImageView
//    }()
//    // do not forget the `.isActive = true` after every constraint
//    func someImageViewConstraints() {
//        someImageView.widthAnchor.constraint(equalToConstant: 180).isActive = true
//        someImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
//        someImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        someImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 28).isActive = true
//    }
//}
//
//
