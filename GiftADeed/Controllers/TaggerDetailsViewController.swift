//
//  TaggerDetailViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 05/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

/*
 •    Details view will show up when once the user taps on a particular tagged deed.
 •    The top most part of the screen will show the photo that is tagged by the Tagger. If the tagger has not tagged any photo, then a default image will be shown.
 •    The next part of this screen will show all the details entered by the tagger/editor. This will have the Deed type along with the Deed symbol. In front of that, the tagged/edited date will be shown. Below that Deed type, there will be Container Available (Only for Food, and Water). Below that there will be Tagged By.
 •    Below Tagged By, there will be the detailed location of the Tag, along with the distance from the current location. In front of the Address, there will be a google maps symbol, clicking on which the User will be directed to the map view of that specific deed. The Map view should have an ‘i’ icon at the top left of the screen. On clicking it, a message should be displayed 'Distances displayed may not be accurate'.
 •    Below the address details, the detailed description of the deed will be shown. Below the detailed description of the deed, there will be Edit deed, Endorse deed (Along with No. of endorsements), and No. of Views option.
 •    Clicking on Edit deed will direct the User to the Edit Deed screen.
 •    The Endorse Deed function is just to highlight the genuineness of the deed. To Endorse a Deed, the User has to be within 100 feet of the tag, or else an error message will be shown if the User clicks on Endorse.If the user is within 100 feet, clicking on Endorse will Endorse the deed, and the Endorsement count will increase by 1. If a User has endorsed a specific deed once, then the Endorse button will change colour from Black to Orange, and the User cannot endorse the deed again, or undo the endorsement. An error message will be shown if the User clicks on the Endorse button again.
 •    No. of Views will be shown after No. of Endorsements. Only unique Views will be counted i.e. one User will be counted only once.
 •    Below this section, there will be a Comments section where the users can post their messages/comments. It will be like a message board for that tagged Deed. It will be similar to the Product Review option of shopping websites. This is an optional field. The character limit for each comment will be 140 chars. One user can post multiple comments. There will be a scroll bar to view all the comments. For the commenters, only their First Name will be shown. In case the User has selected ‘Anonymous’, in the My Profile Privacy settings, then Anonymous will be displayed instead of the First Name of that User.
 •    Below the Comments section, there will be ‘Report User’, and ‘Report deed’ options. From here, the Users can report the deed or the Deed tagger to the Admin.
 •    Below this, there will be a “Gift Now” button. This will direct the user to the “Gift a Deed section”.
 •    Report option is required on deed details page.
 •    There are 2 types of report buttons - 'Report User' and 'Report Deed'.
 •    'Report User' will report the user as spam to the admin, and the admin can block the reported User for custom days (manual input or dropdown) or permanently. A confirmation popup will be shown after a User clicks on Report User. If a User has Reported other User for a specific tagged Deed, then that Reported User cannot be reported again by the same person for that same Deed (A message will be shown in this case). Different Users can report him/her for the same Deed. The same person can report him/her again for another Deed.
 •    'Report Deed' will report the deed as spam and the deed will automatically get deleted from the app UI. A confirmation popup will be shown after a User clicks on Report Deed. Once a Deed vanishes from the UI, no further action is possible for it. If a User is about to perform any action on a deed while it vanished from the UI, then the User will be shown a message “This deed does not exist anymore”, and the user will be directed to the previous page.
 •    A User cannot report himself/herself and his/her own deeds.
 •    If the admin bans a certain user, then that user will be automatically logged out of the app after any api calling action performed by the User. A toast message will also be shown to the User “Youraccount has been blocked”.
 */

import UIKit
import CoreLocation
import Foundation
import Toast_Swift
import SwiftGifOrigin
import ANLoader
import Localize_Swift
import EFInternetIndicator
class TaggerDetailsViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,InternetStatusIndicable{
  
     var internetConnectionIndicator:InternetViewIndicator?
    var commentsArr = NSMutableArray()
    let defaults = UserDefaults.standard
    var userId = ""
    var deedId = ""
    var taggerID = ""
    var need = ""
    var group = ""
    var cat_type = ""
    var groupid = ""
    var reported: Int = 0
    var iconURL = ""
    var charactorURL = ""
    var custom_icon = ""
    var latlongStr = ""
    var addressStr = ""
    var discriptionStr = ""
    var validatyStr = ""
    var subtype = ""
    var ownerId = ""
    var needMapId = ""
    var contanerStatus = ""
    var is_endorse: Int = 0
    var endorseDist  = ""
    var permanant = ""
    @IBOutlet var animationView: UIView!
    @IBOutlet var animationImageView: UIImageView!
    
    @IBOutlet weak var endorseDate: UILabel!
    @IBOutlet weak var reviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet  var outletContainerAvailable: UILabel!
    @IBOutlet weak var containerLabel: UILabel!
    @IBOutlet weak var outletPreferenceSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var containerConstrin: NSLayoutConstraint!
    @IBOutlet  var outletCharacterImg: UIImageView!
    @IBOutlet  var outletProfilePic: UIImageView!
    @IBOutlet  var outletTagName: UILabel!
    @IBOutlet  var outletDate: UILabel!
    
    @IBOutlet weak var commentsCountLbl: UILabel!
    @IBOutlet weak var taggedByGroup: UILabel!
    @IBOutlet  var outletTagedBy: UILabel!
    @IBOutlet  var outletAddress: UILabel!
    @IBOutlet  var outletDistance: UILabel!
     @IBOutlet  var outletDiscription: UILabel!
   // @IBOutlet weak var outletDiscription: UITextView!
    @IBOutlet  var outletViews: UILabel!
    @IBOutlet  var outletLikes: UILabel!
    @IBOutlet  var outletComment: UITextField!
    @IBOutlet  var outletLoadingView: UIView!
    @IBOutlet  var outletEndorse: UIButton!
    
    @IBOutlet weak var storyOfNeedLbl: UILabel!
    @IBOutlet weak var deedLocationTxt: UILabel!
    @IBOutlet weak var storyOfNeedView: UIView!
    @IBOutlet weak var preferenceTitleText: UILabel!
    @IBOutlet weak var subTyeText: UILabel!
    @IBOutlet  var outletCommentTableView: UITableView!
    @IBOutlet weak var giftNowBtn: UIButton!
    @IBOutlet weak var taggedByLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var reportUserBtn: UIButton!
    @IBOutlet weak var reportDeedBtb: UIButton!
    
    @IBOutlet weak var getDirectionBtn: UILabel!
    @IBOutlet weak var otherCommentLbl: UILabel!
    @IBOutlet weak var postMsgLbl: UILabel!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var coomentTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerLbl: UILabel!
    var locManager = CLLocationManager()
    var tagerLatLong = CLLocation()
    var currentLatLong = CLLocation()
    func addBoldText(fullString: NSString, boldPartsOfString: Array<NSString>, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedStringKey.font:font!]
        let boldFontAttribute = [NSAttributedStringKey.font:boldFont!]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        for i in 0 ..< boldPartsOfString.count {
            boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartsOfString[i] as String))
        }
        return boldString
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Chk internet connection
        self.startMonitoringInternet()
          self.navigationController?.navigationBar.topItem?.title = " "
        self.tabBarController?.tabBar.isHidden = true
        outletCommentTableView.layer.borderColor = UIColor.darkGray.cgColor
        outletCommentTableView.layer.borderWidth = 0.5
        self.storyOfNeedView.layer.cornerRadius = 5
        self.storyOfNeedView.layer.borderWidth = 0.5
        self.storyOfNeedView.layer.borderColor = UIColor.darkGray.cgColor
        setText()
        // Do any additional setup after loading the view.
        //    self.outletTagName.addBottomBorder(UIColor.black, height: 1.0)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.findCurrentLocation()
        userId = defaults.value(forKey: "User_ID") as! String
        //add navigation bar button to share an detais of deed
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(TaggerDetailViewController.shareButtonPressed))
        
        self.navigationItem.rightBarButtonItem = shareButton
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .postNotifi, object: nil)
    }
    @objc func shareButtonPressed() {
        //Do something now!
        // Screenshot:
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
       
        let text = "Hey!\nSomeone needs your help to fulfil a deed.\n\(self.need.localized()) is needed here \n http://maps.google.com/maps?saddr=\(self.latlongStr)\n\niOS: \(Constant.GAD_IOS_LINK.localized())\n\nAndroid: \(Constant.GAD_ANDROID_LINK.localized()) \n Also, check the website at https://www.giftadeed.com"
        // let textToShare = [ Constant.GAD_SHARE_TEXT,img! ] as [Any]
        let textToshare = [text,img!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: textToshare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop ]
        
        if Device.IS_IPHONE {
            
            self.present(activityViewController, animated: true, completion: nil)
        }
        else {
            
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    func setText()
    {
       // self.outletTagName.text = "".localized()
//        containerLbl.text = "Container avalible".localized()
//        taggedByLbl.text = "Tagged By:".localized()
//        editBtn.setTitle("Edit".localized(), for: UIControlState.normal)
//        commentLbl.text = "COMMENTS".localized()
//        reportUserBtn.setTitle("Report User".localized(), for: UIControlState.normal)
//        reportDeedBtb.setTitle("Report Deed".localized(), for: UIControlState.normal)
//        giftNowBtn.setTitle("Gift Now".localized(), for: UIControlState.normal)
        }
    override func viewWillAppear(_ animated: Bool) {
        self.commentsArr.removeAllObjects()
        self.title = "Deed Details".localized()
        userId = defaults.value(forKey: "User_ID") as! String
        self.downloadData()
        
        let network = NetworkManager.sharedInstance
        network.reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.view.hideAllToasts()
                self.view.makeToast(Validation.ERROR.localized())
            }
        }
        
        network.reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.downloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.title = "Back"
        NotificationCenter.default.removeObserver(self, name: .postNotifi, object: nil)
        ANLoader.hide()
        self.view.alpha = 1
    }
    
    //Redirect to perticuler tag Map view
    @IBAction func directionAction(_ sender: Any) {
        
        //If details screen not able to download data then it will show error messge and stop to navigate to map view other wise it will navigate
        if self.latlongStr.isEqual(""){
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast(Validation.ERROR.localized())
            return
        }
        
        let mapView = self.storyboard?.instantiateViewController(withIdentifier: "MapTaggerLocationViewController") as! MapTaggerLocationViewController
        
        let latlongStr = self.latlongStr
        let latlong = latlongStr.components(separatedBy: ",")
        
        mapView.lat = (latlong[0] as NSString).doubleValue
        mapView.long = (latlong[1] as NSString).doubleValue
        mapView.needTitle = self.need
        if(self.cat_type == "C"){
             mapView.charactorURL = self.custom_icon
        }
        else{
             mapView.charactorURL = self.charactorURL
        }
       
        mapView.taggerID = self.needMapId
        self.navigationController?.pushViewController(mapView, animated: true)
    }
    
    //MARK:- When User wants to Edit tag the function will send following info to next screen
    @IBAction func editDeed(_ sender: Any) {
        
        let editDeed = self.storyboard?.instantiateViewController(withIdentifier: "TagADeedsViewController") as! TagADeedsViewController
        editDeed.editFlag = true
        editDeed.subType = self.subtype
        editDeed.validity = self.validatyStr
        editDeed.desc = self.discriptionStr
        editDeed.ownerId = self.ownerId
        editDeed.charactorURL = self.charactorURL
        editDeed.geoPoint = self.latlongStr
        editDeed.addressString = self.addressStr
        editDeed.containerChk = self.contanerStatus
        editDeed.needMappingID = self.needMapId
        editDeed.needTitle = self.need
        editDeed.needGroupTitle = self.group
        editDeed.needGroupMappingID = self.groupid
        editDeed.deedImage = self.iconURL
        editDeed.deedId = deedId
        editDeed.pAddress = self.permanant
        editDeed.cat_type = self.cat_type
        print("\(self.iconURL)\(self.subtype)\(self.latlongStr)\(self.addressStr)\(self.permanant)")
        self.navigationController?.pushViewController(editDeed, animated: true)
    }
    //Find current location
    func findCurrentLocation(){
        if (CLLocationManager.locationServicesEnabled())
        {
            locManager = CLLocationManager()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        var currentLocation = locations.last! as CLLocation
        currentLocation = locManager.location!
        currentLatLong = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    //MARK:- Download deed details data and set on UI
    func downloadData(){
        self.view.alpha = 0.5
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.deed_details
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "userId=%@&deedId=%@", userId,deedId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
                self.view.alpha = 1
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async {
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            DispatchQueue.main.async {
                
                //  self.outletLoadingView.isHidden = true
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        GlobalClass.sharedInstance.blockStatus = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if let deed_details = jsonObj!.value(forKey: "deed_details") as? NSArray {
                        
                        DispatchQueue.main.async{
                            self.view.alpha = 1
                            self.group = ((deed_details[0] as AnyObject).value(forKey: "group_name") as? String) ?? "Not available"
                            self.cat_type = ((deed_details[0] as AnyObject).value(forKey: "cat_type") as? String)!
                            self.groupid = ((deed_details[0] as AnyObject).value(forKey: "group_id") as? String) ?? "0"
                            self.contanerStatus = ((deed_details[0] as AnyObject).value(forKey: "container") as? String)!
                            self.needMapId = ((deed_details[0] as AnyObject).value(forKey: "needMapId") as? String)!
                            self.subtype = ((deed_details[0] as AnyObject).value(forKey: "sub_types") as? String)!
                            self.permanant = ((deed_details[0] as AnyObject).value(forKey: "is_permenant") as? String)!
                            print(self.permanant)
                            self.ownerId = ((deed_details[0] as AnyObject).value(forKey: "ownerId") as? String)!
                            self.validatyStr = ((deed_details[0] as AnyObject).value(forKey: "validity") as? String)!
                            
                            let iconString =  (deed_details[0] as AnyObject).value(forKey:"imgUrl") as! String
                            let iconUrl = iconString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                          
                            
                           
                            let charecterIconString = (deed_details[0] as AnyObject).value(forKey:"characterPath") as? String ?? "char"
                            let charecterUrl = charecterIconString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                          
                            if(self.cat_type == "C"){
                                                             self.iconURL = String(format: "%@%@", Constant.Custom_BASE_URL,iconUrl)
                                  self.charactorURL = String(format: "%@%@", Constant.Custom_BASE_URL ,charecterUrl)
                                                      }
                                                      else{
                                                       self.iconURL = String(format: "%@%@", Constant.BASE_URL,iconUrl)
                                                      self.charactorURL = String(format: "%@%@", Constant.BASE_URL ,charecterUrl)
                                                      }
                            
                            
                            let customIconString = (deed_details[0] as AnyObject).value(forKey:"characterPath") as? String ?? "char"
                            let customUrl = customIconString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                            
                            self.custom_icon = String(format: "%@%@", Constant.Custom_BASE_URL ,customUrl)
                            
                            if((deed_details[0] as AnyObject).value(forKey:"imgUrl") as! String == ""){
                                self.outletProfilePic.contentMode = .scaleAspectFit
                            }else{
                                self.outletProfilePic.contentMode = .center
                            }
                            
                            self.outletProfilePic.sd_setImage(with: URL(string: self.iconURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
                         
                            
                            self.is_endorse  = (deed_details[0] as AnyObject).value(forKey:"is_endorse") as! Int
                            self.endorseDist = (deed_details[0] as AnyObject).value(forKey:"endorse_dist") as! String
                            print(self.is_endorse)
                            if self.is_endorse == 1{
                                
                                self.outletEndorse.setImage(UIImage(named: "checkTag"), for: .normal)
                            }
                            else{
                                
                                self.outletEndorse.setImage(UIImage(named: "checkTag"), for: .normal)
                                
                            }
                            
                            self.need = ((deed_details[0] as AnyObject).value(forKey: "tagName") as? String)!
                            self.outletTagName.text = ("\(self.need)".localized())
                            print(self.subtype)
                          //  self.preferenceTitleText.text = ("\(self.need) Preferences for person / people :")
                            //  self.preferenceTitleText.addBottomBorder(UIColor.black, height: 1.0)
                         
                            self.taggerID = ((deed_details[0] as AnyObject).value(forKey: "ownerId") as? String)!
                            self.reported = ((deed_details[0] as AnyObject).value(forKey:"is_reported") as? Int)!
                            
                            self.outletDate.text =  GlobalClass.sharedInstance.converDateFormate(dateString:((deed_details[0] as AnyObject).value(forKey: "date") as? String)!)
                            
                            //If need is water and food then only show container other wise not
                            
                            if(self.cat_type == "C"){
                               // self.containerLabel.isHidden = true
                                //     self.outletLabelSpacing.constant = 0
                                self.contanerStatus = "0"
                               // self.preferenceTitleText.isHidden = true
                                self.subTyeText.isHidden = true
                                self.containerConstrin.constant = 0
                                self.outletPreferenceSpacing.constant = 0
                                   self.subTyeText.text = ""
                              
                                self.outletCharacterImg.sd_setImage(with: URL(string: self.custom_icon), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
                            }
                            else{
                                   self.outletCharacterImg.sd_setImage(with: URL(string: self.charactorURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
                                let preferenceTxt = "Preferences for person / people :"
                                
                                   self.subTyeText.text = ("\(self.need.localized()) \(preferenceTxt.localized()) \(self.subtype.localized())").localized()
                                if self.need.isEqual("Water") || self.need.isEqual("Food"){
                                   // self.preferenceTitleText.isHidden = false
                                    self.subTyeText.isHidden = false
                                    let containerStatus = ((deed_details[0] as AnyObject).value(forKey: "container") as? String)!
                                    if containerStatus.isEqual("1") {
                                        
                                        
                                        self.containerLabel.halfTextColorChange(fullText: "Container : Available", changeText: "Available")
                                        self.containerLabel.isHidden = false
                                          self.containerConstrin.constant = 21
                                        // self.outletPreferenceSpacing.constant = 20
                                        //   self.outletLabelSpacing.constant = 21
                                        self.containerLabel.text = "Container : Available".localized()
                                        //  self.outletContainerAvailable.text = "Yes"
                                    }
                                    else{
                                        self.containerLabel.isHidden = false
                                        self.containerConstrin.constant = 21
                                       // self.outletPreferenceSpacing.constant = 20
                                        //   self.outletLabelSpacing.constant = 21
                                        self.containerLabel.text = "Container : Not available".localized()
                                        //  self.outletContainerAvailable.text = "No"
                                    }
                                }
                                else{
                                    
                                    //   self.outletContainerAvailable.isHidden = true
                                    self.containerLabel.isHidden = true
                                      self.containerConstrin.constant = 0
                                    //     self.outletLabelSpacing.constant = 0
                                    self.contanerStatus = "0"
                                }
                            }
                            
                            
                            
                            
                            self.latlongStr = String(format: "%@", (deed_details[0] as AnyObject).value(forKey:"geoPts") as! String)
                            let latlong = self.latlongStr.components(separatedBy: ",")
                            let lat    = (latlong[0] as NSString).doubleValue
                            let long = (latlong[1] as NSString).doubleValue
                            self.tagerLatLong = CLLocation(latitude: lat, longitude: long)
                            
                            //Find distance between user current location and deed location
                            let distanceInKM = self.currentLatLong.distance(from: self.tagerLatLong) / 1000
                            let kmText = "km(s) away"
                            self.outletDistance.text = String(format: "%.04f \(kmText.localized())", distanceInKM)
                            
                            let fullName = String(format: "%@ %@",((deed_details[0] as AnyObject).value(forKey: "fName") as? String)!, ((deed_details[0] as AnyObject).value(forKey: "lName") as? String)!)
                            
                            let privacyStaus = (deed_details[0] as AnyObject).value(forKey: "privacy") as! String
                            let tagByTxt = "Deed tagged by :"
                            if privacyStaus.isEqual("Public"){
                                
                                self.outletTagedBy.text = ("\(tagByTxt.localized()) \(fullName)").localized()
                            }
                            else{
                                
                                self.outletTagedBy.text = ("\(tagByTxt.localized()) : Anonymous ").localized()
                            }
                            let tagByGrpTxt = "Tagged by group :"
                            self.taggedByGroup.text = ("\(tagByGrpTxt.localized()) \(self.group)").localized()
                            self.deedLocationTxt.text = "Deed Location".localized()
                            self.storyOfNeedLbl.text = "Story of need".localized()
                            self.addressStr = ((deed_details[0] as AnyObject).value(forKey: "address") as? String)!
                            self.discriptionStr = ((deed_details[0] as AnyObject).value(forKey: "desc") as? String)!
                            
                            self.outletAddress.text = self.addressStr
                            if(self.discriptionStr.count>0){
                                self.outletDiscription.text = self.discriptionStr
                            }
                            else{
                                self.outletDiscription.text = "Not avilable".localized()
                            }
                            self.outletViews.text =  (deed_details[0] as AnyObject).value(forKey: "views") as? String
                            self.outletLikes.text =  (deed_details[0] as AnyObject).value(forKey: "endorse") as? String
                            self.editBtn.setTitle("Edit".localized(), for: .normal)
                            self.commentLbl.text = "COMMENT".localized()
                            self.postBtn.setTitle("Post".localized(), for: .normal)
                            self.postMsgLbl.text = "Press enter to post".localized()
                            self.otherCommentLbl.text = "Comment's".localized()
                            self.giftNowBtn.setTitle("Gift Now".localized(), for: .normal)
                             self.reportDeedBtb.setTitle("Report Deed".localized(), for: .normal)
                             self.reportUserBtn.setTitle("Report User".localized(), for: .normal)
                           // self.getDirectionBtn.text = "Get Directions".localized()
                            if(self.outletLikes.text == "0"){
                                self.endorseDate.isHidden = true
                                
                            }else{
                                self.endorseDate.isHidden = false
                                let text = "Last endorsed on :"
                                self.endorseDate.text = ("\(text) \(((deed_details[0] as AnyObject) .value(forKey:"last_endorse_time") as! String))")
                            }
                            
                            if let comments = (deed_details[0] as AnyObject).value(forKey: "comments") as? NSArray {
                                if(comments.count == 0){
                                     self.reviewHeightConstraint.constant = 0
                                   // self.outletCommentTableView.isHidden = true
                                }else{
                                    for item in comments {
                                        
                                        do {
                                            
                                            let comment = item as? NSDictionary
                                            try self.commentsArr.add(comment!)
                                            
                                        } catch {
                                            // Error Handling
                                            print("Some error occured.")
                                        }
                                        
                                    }
                                    
                                    DispatchQueue.main.async{
                                      //  self.outletCommentTableView.isHidden = false
                                         self.reviewHeightConstraint.constant = 100
                                        self.updateUI()
                                    }
                                }
                             
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    //Messages always last message so to reload data and scrollup to last message
    func updateUI() {
        
        if  self.commentsArr.count != 0{
            
            outletCommentTableView.reloadData()
            
            self.commentsCountLbl.text = ("\(self.commentsArr.count) Review's")
            self.goToBottom()
        }
        else{
           
            self.commentsCountLbl.text = ("\(self.commentsArr.count) Review")
        }
    }
    
    //MARK:- TableView data source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var numOfSections: Int = 0
        if commentsArr.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No comment's available".localized()
            noDataLabel.textColor     = UIColor.darkGray
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
             return commentsArr.count
   
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? UITableViewCell!
        cell?!.layer.cornerRadius=2
        
        let item = self.commentsArr[indexPath.section] as? NSDictionary
        
        cell?!.detailTextLabel!.text = (item as AnyObject).value(forKey:"comment") as? String
        
        let privacyType = (item as AnyObject).value(forKey:"privacy") as! String
        if privacyType.isEqual("Public"){
            
            cell?!.textLabel!.text = (item as AnyObject).value(forKey:"fName") as? String
        }
        else{
            
            cell?!.textLabel!.text = "Anonymous"
        }
        
        return cell!!
    }
    
    //Resize table view cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 5
    }
    
    //If uer current location and deed location is less than 100 feeet then only user will endore
    @IBAction func endorseAction(_ sender: Any) {
        print("\(userId)\(self.ownerId)")
        if self.ownerId.isEqual(userId){
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("You cannot endorse your own tag.".localized())
            return
        }
        
        if self.is_endorse == 1{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("You have already endorse.".localized())
            return
        }
        
        // self.outletLoadingView.isHidden = false
        
        let distanceInMeters = self.currentLatLong.distance(from: tagerLatLong)
        let distanceInFeet = distanceInMeters * 3.280839895
        var dist = Int(self.endorseDist)
        if Int(distanceInFeet)<=dist ?? 100{
            
        }
        else{
            let text = "You need to be within"
            let text1 = "feet area of the needy person"
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("\(text.localized()) \(self.endorseDist) \(text1.localized())")
            return
        }
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.endorse_deed
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "userId=%@&deedId=%@", userId,deedId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            // self.outletLoadingView.isHidden = true
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        GlobalClass.sharedInstance.blockStatus = true
                    }
                    return
                }
                
                let status = jsonObj?.value(forKey:"status") as? Int
                
                if status==1{
                    
                    DispatchQueue.main.async {
                        
                        let temp = Int(self.outletLikes.text!)!+1
                        self.outletLikes.text = String(format: "%d",temp)
                        
                        self.outletEndorse.setImage(UIImage(named: "checkTag"), for: .normal)
                        // self.animationView.isHidden=false
                        // self.animationImageView.image = UIImage.gif(name: "thumb")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        // your code here
                        
                        // self.animationView.isHidden=true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            
                            self.view.hideAllToasts()
                            self.navigationController?.view.makeToast("Thank you for endorsing.".localized())
                            self.viewDidLoad()
                        }
                        
                    }
                }
                else if status==0{
                    
                    DispatchQueue.main.async {
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast("You have already endorse.".localized())
                    }
                }
            }
        }
        task.resume()
    }
    
    //Navigate to Gift view screen
    @IBAction func giftAction(_ sender: Any) {
        
        let tagger = self.storyboard?.instantiateViewController(withIdentifier: "GiftADeedViewController") as! GiftADeedViewController
        tagger.deedId = self.deedId
        tagger.need = need
        tagger.tagerLatLong = self.tagerLatLong
        self.navigationController?.pushViewController(tagger, animated: true)
    }
    
    //Send comment
    @IBAction func sendAction(_ sender: Any) {
        
        outletComment.resignFirstResponder()
        
        guard let comment = outletComment.text?.trimmingCharacters(in: .whitespacesAndNewlines), comment.count != 0 else {
            
            return
        }
        
        //self.outletLoadingView.isHidden = false
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.post_comment
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "deedId=%@&userId=%@&comment=%@", deedId,userId,comment)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        outletComment.text = ""
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            //  self.outletLoadingView.isHidden = true
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        GlobalClass.sharedInstance.blockStatus = true
                    }
                    return
                }
                
                let status = jsonObj?.value(forKey:"status") as? Int
                
                if status==1{
                    
                    let privacyStaus = self.defaults.value(forKey: "PRIVACY") as! String
                    let commentDict: [String: String] =
                        ["comment" : comment ,
                         "fName" : self.defaults.value(forKey: "Fname") as! String ,
                         "privacy" : privacyStaus]
                    
                    do {
                        
                        try self.commentsArr.add(commentDict)
                        
                    } catch {
                        // Error Handling
                        print("Some error occured.")
                    }
                    
                    
                    DispatchQueue.main.async{
                        
                        self.updateUI()
                    }
                }
                else{
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
            }
        }
        task.resume()
    }
    
    //Report to User
    //MARK:- Report user : Self report is not posssible
    @IBAction func reportUserAction(_ sender: Any) {
        
        //  self.outletLoadingView.isHidden = false
        
        if userId.isEqual(self.taggerID){
            
            // self.outletLoadingView.isHidden = true
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("You cannot report yourself".localized())
            return;
        }
        else if self.reported ==  1{
            
            //self.outletLoadingView.isHidden = true
            self.navigationController?.view.makeToast("You already reported".localized())
            return;
        }
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.report_user
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "reporterId=%@&tagId=%@&taggerId=%@", userId,deedId,self.taggerID)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            //  self.outletLoadingView.isHidden = true
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        GlobalClass.sharedInstance.blockStatus = true
                    }
                    return
                }
                
                let status = jsonObj?.value(forKey:"status") as? Int
                
                if status==1{
                    
                    DispatchQueue.main.async {
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast("User reported successfully".localized())
                    }
                }
                else{
                    
                    DispatchQueue.main.async {
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast(Validation.ERROR.localized())
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK:- Report deed
    //Report deed : Self deed report is not posssible
    @IBAction func reportDeedAction(_ sender: Any) {
        
        // self.outletLoadingView.isHidden = false
        
        if userId.isEqual(self.taggerID){
            
            DispatchQueue.main.async {
                
                //self.outletLoadingView.isHidden = true
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast("You cannot report your own deed".localized())
            }
            return;
        }
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.report_deed
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "reporterId=%@&deedId=%@", userId,deedId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            // self.outletLoadingView.isHidden = true
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            let convertedString = String(data: data!, encoding:String.Encoding.utf8)
            print(convertedString!)
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        GlobalClass.sharedInstance.blockStatus = true
                    }
                    return
                }
                
                let status = jsonObj?.value(forKey:"status") as? Int
                
                if status==1{
                    
                    DispatchQueue.main.async {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else{
                    
                    DispatchQueue.main.async {
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast(Validation.ERROR.localized())
                    }
                }
            }
        }
        task.resume()
    }
    
    func goToBottom() {
        
        do {
            let lastIndexPath = self.lastIndexPath()
            outletCommentTableView.scrollToRow(at: lastIndexPath!, at: .bottom, animated: false)
        } catch let _ {
            print("Error")
        }
    }
    
    func lastIndexPath() -> IndexPath? {
        
        do {
            let lastSectionIndex: Int = max(0, outletCommentTableView.numberOfSections - 1)
            let lastRowIndex: Int = max(0, outletCommentTableView.numberOfRows(inSection: lastSectionIndex) - 1)
            return IndexPath(row: lastRowIndex, section: lastSectionIndex)
        } catch let exception {
            print("Error")
        }
    }
}
