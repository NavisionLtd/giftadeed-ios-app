////
////  TagADeedViewController.swift
////  GiftADeed
////
////  Created by nilesh sinha on 06/04/18.
////  Copyright © 2018 Mayur Yergikar. All rights reserved.
////
///*
// •    This screen will enable the app user to tag a needy person and enter details about the category of deed to be shared among other app users.
// •    The app user will be able to take a picture of the needy person(s) at that moment or pick one from the gallery of his device. The Snap (button) will open the camera and the user can click a photo. The Browse (button) will open the photo gallery in the phone from which the User can select the photo to upload. After the photo has been selected/clicked it will appear in the preview box. The User can change the photo as per requirement, but if a photo is uploaded/selected then it cannot be made blank. The User will have to again go to Tag a Deed option to get a blank page. Photo option is not mandatory.
// •    User will then select the category of deed to be fulfilled. After clicking on Select Category, a single select popup will open which has the following options eg. Food, Cloth, Shelter, Water etc. The user can select the required category by clicking on it. There is a Cancel button at the bottom of the popup. When a Category is selected, it is displayed in the Select Category option and its symbol appears next to it. There will be master data- entry screen to manage the categories in the Web Admin interface. Category option is mandatory.
// •    Container available checkbox - It is an optional checkbox for food and water. On Tag a Deed, below the Description, this option should be given with a check box. If the User selects a category like Food, or water then the Container Available checkbox option should be enabled, otherwise it should be disabled/invisible. <Checkbox> Container Available. Under the Container Available checkbox, there should be a note saying that "Whether that needy person has a food plate/water container to receive the donated food/water?”
// •    App user’s location will be captured either by default, automatically by the system (based on device’s GPS feature) or by allowing the user to enter the name of the nearest mapped location (Google location). Location is mandatory.
// •    A more detailed description of the deed that can help the prospective deed fulfillers to understand the exact requirement can be entered here. For example, if the deed is for clothes for an adult, this can be detailed out in this field.Description is mandatory.The Description will have a character limit of 500 chars. The User will not be able to type after 500 chars.
// •    There should be a ‘Deed Validity’ slider option. Here the person should be able to select the time period for which the deed should be valid. The slider will be from 1 hr to 48 hrs. The deed will expire from the UI after its validity period(to be noted by API developer). By default, the validity period will be selected as 3 hrs.
// •    On clicking “Post” button, a confirmation pop-up message will show asking the user whether or not to post the deed. If user presses “No”, system will return to this screen again. If user presses “Yes”, an appropriate message “Your tag was successful” will be displayed to the user and credit points will be allocated to the user for tagging a deed.Also, the total credits points will be displayed. A push notification will be sent to the Tagger and also the other Users who are within a 10 km radius from the tagged deed. The distance will be set by the super admin from the back end. The notification will have the GAD symbol at the left. Next to it will be the Category name, and below the category name will be the deed description.
// •    After a point earning activity/task like Tag a Deed and Fulfil a Deed, the user should be able to share the app. The Share message should be as follows: 
//Hey! 
//I am using ‘Gift-A-Deed’ charity mobile app. 
//You can download it from: 
//https://play.google.com/store/apps/details?id=giftadeed.kshantechsoft.com.giftadeed 
//After clicking on the app link, the user should be taken to the Gift-A-Deed play store page.
// •    After tagging a deed, the User should be directed to the map view. The tagged Deed should be highlighted on map view when the user is directed to the map view after the deed is tagged.
// */
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
////import SwiftGifOrigin
////import ANLoader
////import Localize_Swift
//extension UIView {
//    
//    func addTopBorder(_ color: UIColor, height: CGFloat) {
//        let border = UIView()
//        border.backgroundColor = color
//        border.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(border)
//        border.addConstraint(NSLayoutConstraint(item: border,
//                                                attribute: NSLayoutAttribute.height,
//                                                relatedBy: NSLayoutRelation.equal,
//                                                toItem: nil,
//                                                attribute: NSLayoutAttribute.height,
//                                                multiplier: 1, constant: height))
//        self.addConstraint(NSLayoutConstraint(item: border,
//                                              attribute: NSLayoutAttribute.top,
//                                              relatedBy: NSLayoutRelation.equal,
//                                              toItem: self,
//                                              attribute: NSLayoutAttribute.top,
//                                              multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: border,
//                                              attribute: NSLayoutAttribute.leading,
//                                              relatedBy: NSLayoutRelation.equal,
//                                              toItem: self,
//                                              attribute: NSLayoutAttribute.leading,
//                                              multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: border,
//                                              attribute: NSLayoutAttribute.trailing,
//                                              relatedBy: NSLayoutRelation.equal,
//                                              toItem: self,
//                                              attribute: NSLayoutAttribute.trailing,
//                                              multiplier: 1, constant: 0))
//    }
//    func addBottomBorder(_ color: UIColor, height: CGFloat) {
//        let border = UIView()
//        border.backgroundColor = color
//        border.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(border)
//        border.addConstraint(NSLayoutConstraint(item: border,
//                                                attribute: NSLayoutAttribute.height,
//                                                relatedBy: NSLayoutRelation.equal,
//                                                toItem: nil,
//                                                attribute: NSLayoutAttribute.height,
//                                                multiplier: 1, constant: height))
//        self.addConstraint(NSLayoutConstraint(item: border,
//                                              attribute: NSLayoutAttribute.bottom,
//                                              relatedBy: NSLayoutRelation.equal,
//                                              toItem: self,
//                                              attribute: NSLayoutAttribute.bottom,
//                                              multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: border,
//                                              attribute: NSLayoutAttribute.leading,
//                                              relatedBy: NSLayoutRelation.equal,
//                                              toItem: self,
//                                              attribute: NSLayoutAttribute.leading,
//                                              multiplier: 1, constant: 0))
//        self.addConstraint(NSLayoutConstraint(item: border,
//                                              attribute: NSLayoutAttribute.trailing,
//                                              relatedBy: NSLayoutRelation.equal,
//                                              toItem: self,
//                                              attribute: NSLayoutAttribute.trailing,
//                                              multiplier: 1, constant: 0))
//    }
//}
//class TagADeedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate ,GMSAutocompleteViewControllerDelegate {
//    
////                                              multiplier: 1, constant: 0))
////    }
////}
////class TagADeedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate ,GMSAutocompleteViewControllerDelegate,UITableViewDelegate,UITableViewDataSource {
////
////  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return groupListArray.count
////    }
////
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
////        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SubCategoryTableViewCell
////        let values = groupListArray[indexPath.row]
////        print(values)
////        cell.typeLbl.text = values.group_name
////    //    cell.numberLbl.text = values.group_id
////        //cell.numberLbl.text = values.group_imageURL
////        return cell
////    }
////    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        let cell = tableView.cellForRow(at: indexPath) as! SubCategoryTableViewCell
////        print(cell.typeLbl?.text as! String)
////            selectedAudianceArray.add(self.audianceArray[indexPath.row])
////     //   print(selectedAudianceArray)
//////        deletedValue = UserDefaults.standard.string(forKey: "delete") ?? "0"
////  //       nc.addObserver(self, selector: #selector(deleteValues), name: Notification.Name("rowdelete"), object: nil)
////
////        // Register to receive notification in your class
////        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "rowdelete"), object: nil)
////
////
////
////
////        if(selectedAudianceArray.contains(self.audianceArray[indexPath.row])){
////     //  remove duplicate selected items from array
////        }
////
////        else{
////
////                selectedAudianceArray.add(self.audianceArray[indexPath.row])
////
////        }
////       // print(selectedAudianceArray)
////    }
////    // handle notification
////    @objc func showSpinningWheel(_ notification: NSNotification) {
////        print(notification.userInfo ?? "")
////        if let dict = notification.userInfo as NSDictionary? {
////            if let id = dict["delete"] as? String{
////                selectedAudianceArray.remove(id)
////                // do something with your image
////            }
////           // print(selectedAudianceArray)
////        }
////    }
////    @objc func donePress(){
////
////
////        let alert = UIAlertController(title: "Alert", message: "Message\(selectedAudianceArray)", preferredStyle: UIAlertControllerStyle.alert)
////        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
////            switch action.style{
////            case .default:
////                print("default")
////
////            case .cancel:
////                print("cancel")
////
////            case .destructive:
////                print("destructive")
////
////
////            }}))
////        self.present(alert, animated: true, completion: nil)
////    }
////    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
////        let cell = tableView.cellForRow(at: indexPath) as! SubCategoryTableViewCell
////        print(cell.typeLbl?.text as! String)
////       let deletedItem = cell.typeLbl?.text as! String
////      //    UserDefaults.standard.set(deletedItem, forKey: "delete")
////     //   nc.post(name: Notification.Name("rowdelete"), object: nil)
////
////        let imageDataDict:[String: String] = ["delete": deletedItem]
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        
//        guard section == 0 else { return nil }
//        
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44.0))
//        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 130, height: 44.0))
//        // here is what you should add:
//        doneButton.center = footerView.center
//        
//        doneButton.setTitle("Done?", for: .normal)
//        doneButton.backgroundColor = .lightGray
//        doneButton.layer.cornerRadius = 10.0
//     //   doneButton.shadow = true
//      //  doneButton.addTarget(self, action: #selector(donePress), for: .touchUpInside)
//       // footerView.addSubview(doneButton)
//        
//        return footerView
//    }
//
//   /* tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
//       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SubCategoryTableViewCell
//       cell.typeLbl.text = audianceArray[indexPath.row] as! String
//        return cell
//   }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! SubCategoryTableViewCell
//        print(cell.typeLbl?.text as! String)
//        selectedAudianceArray.add(self.audianceArray[indexPath.row])
//           print(selectedAudianceArray)
//    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! SubCategoryTableViewCell
//       print(cell.typeLbl?.text as! String)
//    }
// */
//    
//    @IBOutlet weak var selectAudianceBtn: UIButton!
//    @IBOutlet weak var audianceTableView: UITableView!
//    @IBOutlet weak var outletScrollview: UIScrollView!
//    @IBOutlet var animationView: UIView!
//    @IBOutlet var animationImageView: UIImageView!
//    
//    @IBOutlet  var outletDeedPic: UIImageView!
//  
//    @IBOutlet weak var outletAudience: UITextField!
//    @IBOutlet  var outletCategory: UITextField!
//    @IBOutlet  var outletLocation: UILabel!
//    @IBOutlet  var outletValidity: UISlider!
//    @IBOutlet  var outletDescription: UITextView!
//    @IBOutlet  var outletHours: UILabel!
//    @IBOutlet  var outletSwitch: UISwitch!
//    @IBOutlet  var outletIconPic: UIImageView! 
//    @IBOutlet  var outletContainerView: UIView!
//    @IBOutlet  var outletContainerViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var outletCoverView: UIView!
//    @IBOutlet weak var uploadPicLbl: UILabel!
//    @IBOutlet weak var snapButton: UIButton!
//    @IBOutlet weak var browseBtn: UIButton!
//    @IBOutlet weak var selectLocLbl: UILabel!
//    @IBOutlet weak var deedValidityLbl: UILabel!
//    @IBOutlet weak var hrOutlet: UILabel!
//    @IBOutlet weak var descriptionLbl: UILabel!
//    @IBOutlet weak var selectPreferenceBtn: UIButton!
//    @IBOutlet weak var menuTagADeedTitle: UINavigationItem!
//    @IBOutlet weak var postBtn: UIButton!
//    @IBOutlet weak var addressBtn: UIButton!
//    let defaults = UserDefaults.standard
//    var userId = ""
//     let nc = NotificationCenter.default
//    var deletedValue = ""
//    var audianceArray = NSMutableArray()
//    var selectedAudianceArray = NSMutableArray()
//    var categoryArr = NSMutableArray()
//    var categoryListArr = NSMutableArray()
//    var organizationLoistArray = NSMutableArray()
//    let imagePicker = UIImagePickerController()
//    var imageBase64 = ""
//    var geoPoint = ""
//    var addressString = ""
//    var containerStatus = ""
//    var needMappingID = ""
//    var needTitle = ""
//    var deedImage = ""
//   
//    var currentVC: UIViewController!
//    var currentLatLong = CLLocation()
//    var locManager = CLLocationManager()
//    var height : CGFloat = 0.0
//    var width : CGFloat = 0.0
//    var paddress = ""
//    var categoryStr = ""
//     var imageFlag : Bool!
//    var addressFlag : Bool!
//    var deviceToken = ""
//    var selectedPreferenceName = NSMutableArray()
//    var selectedPreferenceId = NSMutableArray()
//     var selectedAudianceName = NSMutableArray()
//     var selectedAudianceId = NSMutableArray()
//    var sentAudianceIds = ""
//     var sentAudianceSelectAllGroup = ""
//    var sentAudianceSelectIndivisualUser = ""
//    @IBOutlet weak var preferanceTextLabel: UILabel!
//    var groupListArray = [Group]()
//    var preferenceDict = [String: String]()
//    @IBAction func addressButtonPress(_ sender: UIButton) {
////    var addressFlag : Bool!
////    var deviceToken = ""
////
////
////    @IBAction func addressButtonPress(_ sender: UIButton) {
////        if sender.isSelected {
////            sender.isSelected = false
////            paddress = "FALSE"
////          addressBtn .setBackgroundColor(color: UIColor.white, forState: UIControlState.normal)
////        }
////        else{
//    }
//    
//
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//       
//
//        outletCategory.setBottomBorder()
//      //  outletContainerView.addBottomBorder(.darkText, height: 1.0)
//        outletLocation.addBottomBorder(.darkText, height: 1.0)
//       // outletLocation.addTopBorder(.darkText, height: 1.0)
//        selectAudianceBtn.addBottomBorder(.darkText, height: 1.0)
//        selectPreferenceBtn.addBottomBorder(.darkText, height: 1.0)
//         audianceTableView.isHidden = true
//     //   audianceArray = ["My Organization","Other Organization","Public"]
////       // outletLocation.addTopBorder(.darkText, height: 1.0)
////        selectAudianceBtn.addBottomBorder(.darkText, height: 1.0)
//       
//        setText()
//        addressBtn.backgroundColor = .clear
//        addressBtn.layer.cornerRadius = 5
//        addressBtn.layer.borderWidth = 0
//        addressBtn.layer.borderColor = UIColor.black.cgColor
//        
//        outletDeedPic.backgroundColor = .clear
//        outletDeedPic.layer.cornerRadius = 5
//        outletDeedPic.layer.borderWidth = 1
//        outletDeedPic.layer.borderColor = UIColor.black.cgColor
//        // Do any additional setup after loading the view.
//        imageFlag = false
//        self.containerStatus = "0"
//        if Device.IS_IPHONE {
//            
//            outletSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//        }
//        else{
//            
//            outletSwitch.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        }
//        
//        imagePicker.delegate = self
//        self.automaticallyAdjustsScrollViewInsets = false
//        self.findCurrentLocation()
//
//        DispatchQueue.main.async{
//            
//            self.outletContainerView.isHidden = true
//            self.outletContainerViewHeight.constant = 0.0
//            self.outletContainerViewHeight.constant = 0.0
//        }
//    }
//    @objc func setText(){
//        self.menuTagADeedTitle.title = "Tag A Deed".localized();
//        self.uploadPicLbl.text = "Upload Picture".localized();
//        self.selectLocLbl.text = "Select Location".localized();
//        self.outletCategory.placeholder = "Select category".localized();
//        self.deedValidityLbl.text = "Deed Validity (1 to 48)".localized();
//        //self.hrOutlet.text = "OR LOGIN WITH".localized();
//        self.descriptionLbl.text = "Description".localized();
//        //self.outletDescription.placeholder = "Description".localized();
//        self.postBtn.setTitle("Post".localized(using: "Localizable"), for: UIControlState.normal)
//       //  self.addressBtn.setTitle("Tap here to set it as a permanant address.".localized(using: "Localizable"), for: UIControlState.normal)
//         self.snapButton.setTitle("Snap".localized(using: "Localizable"), for: UIControlState.normal)
//          self.browseBtn.setTitle("Browse".localized(using: "Localizable"), for: UIControlState.normal)
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        //for audiance table first row selected
//        self.audianceTableView.allowsMultipleSelection = true
//        self.audianceTableView.allowsMultipleSelectionDuringEditing = true
//        
//        if(selectedAudianceArray.count == 0){
//            
//        }
//        else{
//        let indexPath = IndexPath(row: 0, section: 0)
//        audianceTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
//        if(selectedAudianceArray.contains(self.audianceArray[0])){
//            
//        }
//        else{
//        selectedAudianceArray.add(self.audianceArray[0])
//        }
//        }
//    }
//    @objc func methodOfReceivedNotification(notification: Notification) {
//        // Take Action on Notification
//        //retrive data for preferance
//        GlobalClass.sharedInstance.openDb()
//        do {
//            let users = try Constant.database.prepare(Constant.preferenceTable)
//            for user in users {
//                print("userId: \(user[Constant.id]), name: \(user[Constant.prefname]), nameid: \(user[Constant.prefid]), nameQty: \(user[Constant.prefQty]), nameStatus: \(user[Constant.prefstatus])")
//                let status = user[Constant.prefstatus]
//                var qty = ""
//                var name = ""
//                if(status == "y"){
//                    qty = user[Constant.prefQty]
//                    name = user[Constant.prefname]
//                    selectedPreferenceName.add(name)
//                    selectedPreferenceId.add(qty)
//                  preferenceDict.updateValue(qty, forKey: name)
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
//     //   print("\(selectedPreferenceId)\(selectedPreferenceName)\((selectedPreferenceId.count))")
//        print(preferenceDict)
//        let preferences = (preferenceDict.flatMap({ (key, value) -> String in
//            return "\(key):\(value)"
//        }) as Array).joined(separator: ",")
//        
//        print(preferences)
////        }
////        var title = ""
////     //   print("\(selectedPreferenceId)\(selectedPreferenceName)\((selectedPreferenceId.count))")
////        print(preferenceDict)
////
////        if(selectedPreferenceId.count == 0){
////            title = ""
////        }
////        else{
////            if(selectedPreferenceId.count > 1){
////                 title = (" \(selectedPreferenceName[0]):\(selectedPreferenceId[0]) & \(selectedPreferenceName.count-1) other")
////
//        self.preferanceTextLabel.text = preferences
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
//                     id = user[Constant.audid]
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
//    //    let neednames = selectedNeedNames.componentsJoined(by: ",")
//        if(selectedAudianceName.contains("All groups")){
//            sentAudianceSelectAllGroup = "Y"
//        }
//        else if(selectedAudianceName.contains("All indivisual users")){
//            sentAudianceSelectIndivisualUser = "Y"
//          
//        }
//        else{
//             sentAudianceSelectIndivisualUser = "N"
//             sentAudianceSelectAllGroup = "N"
//        }
//        sentAudianceIds = selectedAudianceId.componentsJoined(by: ",")
//        print(sentAudianceIds)
//        if(selectedAudianceId.count == 0){
//            title = ""
//        }
//        else{
//            if(selectedAudianceId.count > 1){
//                title = ("you have selected - \(selectedAudianceName[0]) & \(selectedAudianceName.count-1) other")
//            }
//            else{
//                title = ("you have selected - \(selectedAudianceName[0])")
//            }
//        }
//        self.outletAudience.text = title
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        NotificationCenter.default.addObserver(self, selector: #selector(TagADeedViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("preferenceselecte"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(TagADeedViewController.methodOfReceivedAudianceNotification(notification:)), name: Notification.Name("audianceselecte"), object: nil)
//        userId = defaults.value(forKey: "User_ID") as! String
//        self.downloadCategoryData()
//        let network = NetworkManager.sharedInstance
//        network.reachability.whenUnreachable = { reachability in
//            DispatchQueue.main.async {
//                self.view.hideAllToasts()
//                self.view.makeToast(Validation.ERROR.localized())
//            }
//        }
//        network.reachability.whenReachable = { reachability in
//            DispatchQueue.main.async {
//                if self.geoPoint != ""{
//                    let latLong = self.geoPoint.components(separatedBy: ",")
//                    self.getAddressForLatLng(latitude: String(format:"%@",latLong[0]), longitude: String(format:"%@",latLong[1]))
//                }
//                self.downloadCategoryData()
//            }
//        }
//    }
//   
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        ANLoader.hide()
//    }
//    
//    @IBAction func menuBarAction(_ sender: Any) {
//       
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
//        UIApplication.shared.keyWindow?.rootViewController = viewController
////        ANLoader.hide()
////    }
////
////    @IBAction func menuBarAction(_ sender: Any) {
//    }
//    
//    //Slider for Validity
//    @IBAction func sliderValueChanged(sender: UISlider) {
//        
//        let currentValue = Int(sender.value)
//        outletHours.text = "\(currentValue) hr(s)"
//    }
//    
//    //Switch for container
//    @IBAction func switchAction(_ sender: Any) {
//        
//        if outletSwitch.isOn {
//            
//            self.containerStatus = "1"
//        } else {
//            
//            self.containerStatus = "0"
//        }
//    }
//    @IBAction func permanentLocationSwitch(_ sender: Any) {
//        if outletSwitch.isOn {
//             paddress = "Y"
//        } else {
//            
//            paddress = "N"
//        }
//    }
//    @IBAction func selectPreferanceBtnPress(_ sender: UIButton) {
//        if(outletCategory.text?.count == 0){
//            self.view.makeToast("Please select category")
//        }
//        else{
//            self.view.hideAllToasts()
//            selectedPreferenceName.removeAllObjects()
//            selectedPreferenceId.removeAllObjects()
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "popup") as! SubCategoryDeedViewController 
//            vc.modalPresentationStyle = .overFullScreen
//            vc.modalTransitionStyle = .crossDissolve
//            vc.type_name = self.outletCategory.text!
//            vc.type_id = self.needMappingID
//            print(self.outletCategory.text as Any,self.needMappingID,vc.type_id)
//            self.present(vc, animated: true, completion: nil)
//        }
//    }
////            vc.type_id = self.needMappingID
////            print(self.outletCategory.text as Any,self.needMappingID,vc.type_id)
////            self.present(vc, animated: true, completion: nil)
////        }
////    }
//    //To Select Audience
//    @IBAction func selectAudience(_ sender: UIButton) {
//      //  GlobalClass.sharedInstance.openDb()
//        selectedAudianceId.removeAllObjects()
//        selectedAudianceName.removeAllObjects()
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "AudianceViewController") as! AudianceViewController
//        vc.modalPresentationStyle = .overFullScreen
//        vc.modalTransitionStyle = .crossDissolve
////    @IBAction func selectAudience(_ sender: UIButton) {
////        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//      //  print(self.outletCategory.text as Any,self.needMappingID,vc.type_id)
//        self.present(vc, animated: true, completion: nil)
//////        }
//////    }
////    //To Select Audience
////    @IBAction func selectAudience(_ sender: UIButton) {
////
////        if(audianceTableView.isHidden){
////            audianceTableView.isHidden = false
////         getAudianceAPiCall()
//
//    }
//  
//    //To Select category
//    @IBAction func selectCategory(_ sender: Any) {
//        GlobalClass.sharedInstance.openDb()
////    }
////
////    //To Select category
////    @IBAction func selectCategory(_ sender: Any) {
////        GlobalClass.sharedInstance.openDb()
////        //update values to reset previous content
////        let updateUser = Constant.preferenceTable.update(Constant.prefstatus <- "n",Constant.prefQty <- "0")
////        do {
//        UserDefaults.standard.removeObject(forKey: "launchedBefore")
//        let deleteUser = Constant.preferenceTable.delete()
//        do {
//            try Constant.database.run(deleteUser)
//        } catch {
//            print(error)
//        }
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
//                                             initialSelection: 0,
//                                             doneBlock: {
//                                                picker, indexe, values in
//                                               
//                                                self.outletCategory.text = values as? String
//                                                
//                                                let item = self.categoryArr[indexe]
//                                                self.needTitle = (item as AnyObject).value(forKey:"Need_Name") as! String
//                                                self.needMappingID = (item as AnyObject).value(forKey:"NeedMapping_ID") as! String
//                                                
//                                                DispatchQueue.main.async {
//                                                    
//                                                    let iconURL = String(format: "%@%@", Constant.BASE_URL ,(item as AnyObject).value(forKey:"Icon_Path") as! String)
//                                                    
//                                                    self.outletIconPic.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "login_logo"))
//                                                }
//                                                
//                                                if ((self.outletCategory.text?.isEqual("Water"))! || (self.outletCategory.text?.isEqual("Food"))!){
//                                       
//                                                    if Device.IS_IPHONE {
//                                                        
//                                                        self.outletContainerViewHeight.constant = 65.0
//                                                        self.outletContainerViewHeight.constant = 65.0
//                                                    }
//                                                    else {
//                                                        
//                                                        self.outletContainerViewHeight.constant = 85.0
//                                                        self.outletContainerViewHeight.constant = 85.0
//                                                    }
//                                                    self.outletContainerView.isHidden = false
//                                                }
//                                                else{
//                                                    
//                                                    self.outletContainerView.isHidden = true
//                                                    self.outletContainerViewHeight.constant = 0.0
//                                                    self.outletContainerViewHeight.constant = 0.0
//                                                }
//                                                return
//                                                }, cancel: { ActionStringCancelBlock in return }, origin: sender)
//    }
//    
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
//                        self.outletLocation.text = self.addressString
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
//    
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
//    // Handle the user's selection.
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//
//        self.addressString = place.formattedAddress!
//        self.outletLocation.text = self.addressString
//
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
//    
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
//        let discription = outletDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
////            self.navigationController?.view.makeToast("Select Category")
////            return
////        }
////
////        let discription = outletDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
////        if discription.count == 0 {
////
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
//        
//        let optionMenu = UIAlertController(title: "", message: "Do you really want to post.", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "Yes", style: .default, handler:
//        {
//            (alert: UIAlertAction!) -> Void in
//            
//            self.outletCoverView.isHidden = false
//            
//            if self.imageFlag {
//                
//                self.saveImageMethodCall()
//            }
//            else{
//               
//                let validaty:Int? = Int(CGFloat((self.outletHours.text! as NSString).doubleValue))
//                
//                self.deedImage = ""
//                self.tagADeedMethod(needMappingID: self.needMappingID, geoPoint: self.geoPoint, imageName: self.deedImage, needTitle: self.needTitle, discription: discription, addressString: self.addressString, paddressString: self.paddress, hourVal: validaty!, containerStatus: self.containerStatus)
//
//            }
//        })
//        
//        let resendAction = UIAlertAction(title: "No", style: .destructive, handler:
//        {
//            (alert: UIAlertAction!) -> Void in
//         
//            self.outletCoverView.isHidden = true
//            return
//        })
//        
//        optionMenu.addAction(okAction)
//        optionMenu.addAction(resendAction)
//        self.present(optionMenu, animated: true, completion: nil)
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
//               // ANLoader.hide()
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
//                
//                DispatchQueue.main.async {
//                    
//                    let validaty:Int? = Int(CGFloat((self.outletHours.text! as NSString).doubleValue))
//                    
//                    let discription = self.outletDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
//                    self.deedImage = imageName
//                    self.tagADeedMethod(needMappingID: self.needMappingID, geoPoint: self.geoPoint, imageName: self.deedImage, needTitle: self.needTitle, discription: discription, addressString: self.addressString, paddressString: self.paddress, hourVal: validaty!, containerStatus: self.containerStatus)
//                //    let paramString = String(format: "User_ID=%@&NeedMapping_ID=%@&Geopoint=%@&Tagged_Photo_Path=%@&Tagged_Title=%@&Description=%@&Address=%@&PAddress=%@&validity=%d&container=%@,sub_type_pref=%@&all_groups=%@,all_individuals=%@,user_grp_ids=%@", userId,needMappingID,geoPoint,imageName,needTitle,discription,addressString,paddress,hourVal,containerStatus,"",sentAudianceSelectAllGroup,sentAudianceSelectIndivisualUser,sentAudianceIds)
//                }
//                
//            } else if let error = error {
//                
//                self.outletCoverView.isHidden = true
//                DispatchQueue.main.async {
//                    
//                    self.view.makeToast(Validation.ERROR)
//                }
//            } else {
//               
//                // no data and no error... what happened???
//                self.outletCoverView.isHidden = true
//                DispatchQueue.main.async {
//               
//                    self.view.makeToast(Validation.ERROR)
//                }
//            }
//        }
//        task.resume()
//    }
//    
//    //save data to server
//    func tagADeedMethod(needMappingID: String,geoPoint: String,imageName: String,needTitle: String,discription: String,addressString: String,paddressString: String,hourVal: Int, containerStatus: String){
//
//        
//        let preferences = (preferenceDict.flatMap({ (key, value) -> String in
//            return "\(key):\(value)"
//        }) as Array).joined(separator: ",")
//        
//        print(preferences)
//        
//        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
//        
//        let urlString = Constant.BASE_URL + Constant.tag_need
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
//        if(sentAudianceSelectIndivisualUser == "Y"){
//            sentAudianceIds = ""
//        }
//        else{
//            
//        }
//        let paramString = String(format: "User_ID=%@&NeedMapping_ID=%@&Geopoint=%@&Tagged_Photo_Path=%@&Tagged_Title=%@&Description=%@&Address=%@&PAddress=%@&validity=%d&container=%@&sub_type_pref=%@&all_groups=%@&all_individuals=%@&user_grp_ids=%@", userId,needMappingID,geoPoint,imageName,needTitle,discription,addressString,paddress,hourVal,containerStatus,preferences,sentAudianceSelectAllGroup,sentAudianceSelectIndivisualUser,sentAudianceIds)
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
//                        self.outletCoverView.isHidden = true
//                        self.view.hideAllToasts()
//                        self.navigationController?.view.makeToast(Validation.ERROR)
//                    }
//                    return
//                }
//
//                if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
//                    
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
//                        
//                        if let checkstatus = jsonObj!.value(forKey: "checkstatus") as? NSArray {
//                            
//                            self.animationView.isHidden=false
//                            self.animationImageView.image = UIImage.gif(name: "thumb")
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                
//                                let status = String(format: "%@",(checkstatus[0] as AnyObject).value(forKey:"status") as! String)
//                                
//                                self.outletCoverView.isHidden = true
//                                
//                                if status.isEqual("1"){
//                                    
//                                    let Total_credits = String(format: "%d",(checkstatus[0] as AnyObject).value(forKey:"Total_credits") as! Int)
//                                    let credits_earned = String(format: "%@",(checkstatus[0] as AnyObject).value(forKey:"credits_earned") as! String)
//                                    let alertTitle = String(format: "You have tagged %@ need",self.needTitle)
//                                    let alertMessage = String(format: "You have earned %@ point(s) and Your total point(s) are %@",credits_earned,Total_credits)
//                                    
//                                    // create the alertl
//                                    let alert = UIAlertController(title: alertTitle , message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
//                                    
//                                    // add the actions (buttons)
//                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (actionSheetController) -> Void in
//                                        
//                                        DispatchQueue.main.async {
//                                            
//                                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
//                                            UIApplication.shared.keyWindow?.rootViewController = viewController
//                                        }
//                                    }))
//                                    
//                                    alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.destructive, handler: { (actionSheetController) -> Void in
//                                        
//                                        // set up activity view controller
//                                        let textToShare = [ Constant.GAD_SHARE_TEXT ]
//                                        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//                                        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop ]
//                                        activityViewController.completionWithItemsHandler = {
//                                            (activity, success, items, error) in
//                                            
//                                            DispatchQueue.main.async {
//                                                
//                                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
//                                                UIApplication.shared.keyWindow?.rootViewController = viewController
//                                            }
//                                        }
//                                        
//                                        if Device.IS_IPHONE {
//                                            
//                                            self.present(activityViewController, animated: true, completion: nil)
//                                        }
//                                        else {
//                                            
//                                            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
//                                            activityViewController.popoverPresentationController?.sourceView = self.view
//                                            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//                                            
//                                            self.present(activityViewController, animated: true, completion: nil)
//                                        }
//                                    }))
//                                    self.present(alert, animated: true, completion: nil)
//                                }
//                                else if status.isEqual("0"){
//                                    
//                                    self.outletCoverView.isHidden = true
//                                    self.view.hideAllToasts()
//                                    self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
//                                }
//                            }
//                        }
//                    }
//                }
//            }else if let error = error {
//                
//                self.outletCoverView.isHidden = true
//                DispatchQueue.main.async {
//                    
//                    self.view.makeToast(Validation.ERROR)
//                }
//            } else {
//                
//                // no data and no error... what happened???
//                self.outletCoverView.isHidden = true
//                DispatchQueue.main.async {
//                    
//                    self.view.makeToast(Validation.ERROR)
//                }
//            }
//        }
//        task.resume()
//    }
//    
//    
//    // MARK: Image Picker
//    @IBAction func cameraAction(_ sender: Any) {
//        
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .camera
//        
//        present(imagePicker, animated: true, completion: nil)
//    }
//    
//    @IBAction func photoLibAction(_ sender: Any) {
//    
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
//        
//        present(imagePicker, animated: true, completion: nil)
//    }
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
//            self.outletDeedPic.image = editedImage;
//           
//        }
//        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            
//            self.outletDeedPic.image = originalImage;
//         
//        }
//        picker.dismiss(animated: true)
//        imageFlag = true
//        self.imageBase64 = GlobalClass.sharedInstance.encodeToBase64String(image:self.outletDeedPic.image!)!
//        
//    
//    }
//    
//    //MARK:- Download category data
//    func downloadCategoryData (){
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
//        
//        let task = session.dataTask(with: request as URLRequest) {
//            (
//            
//            data, response, error) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                
//              //  ANLoader.hide()
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
//                if let needtype = jsonObj!.value(forKey: "needtype") as? NSArray {
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
//            }
//            
//        }
//        task.resume()
//    }
//}
//
//extension UIButton {
//    
//    /// Sets the background color to use for the specified button state.
//    func setBackgroundColor(color: UIColor, forState: UIControlState) {
//        
//        let minimumSize: CGSize = CGSize(width: 1.0, height: 1.0)
//        
//        UIGraphicsBeginImageContext(minimumSize)
//        
//        if let context = UIGraphicsGetCurrentContext() {
//            context.setFillColor(color.cgColor)
//            context.fill(CGRect(origin: .zero, size: minimumSize))
//        }
//        
//        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
