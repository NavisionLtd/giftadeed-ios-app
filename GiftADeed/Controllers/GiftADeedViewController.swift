//
//  GiftADeedViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 16/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    While donating/giving a deed, the deed fulfiller will have an option to upload a picture of the deed recipient/beneficiary.
 •    While donating/giving a deed, the deed fulfiller will have an option to enter remarks about the deed.
 •    Once the above two options are entered, user can then click Submit button. While donating/giving a deed, the deed fulfiller must be within 100 feet of the location where the deed was originally tagged or within 100feet of the needy person who is a beneficiary of the donation. The app will validate this condition on the click of Submit button. If the deed fulfiller is not within a distance of 100feet from the deed beneficiary/recipient, app will show a pop-up containing appropriate message and will not allow the user to submit the information unless this condition is met.
 •    This pop-up message will show up once the app user clicks the “Submit” button.
 •    If the app user presses “No” on the confirmation pop-up, the user will be returned back to Gift A Deed page.
 •    If the app user presses “Yes” on the confirmation pop-up, the user will be returned back to Gift A Deed page and based on the category of deed fulfilled, appropriate Virtual character will be shown. Also, Credits earned and total credits will be shown.
 •    Sharing on social media like FB and Twitter should be enabled.
 •    After a point earning activity/task like Tag a Deed and Fulfil a Deed, the user should be able to share the app. The Share message should be as follows: Hey! I am using ‘Gift-A-Deed’ charity mobile app. You can download it from: iOS and android app link After clicking on the app link, the user should be taken to the Gift-A-Deed play store page.
 •    Once a deed has been gifted/fulfilled, it will vanish from the UI. Once a Deed vanishes from the UI, no further action is possible for it. If a User is about to perform any action on a deed while it vanished from the UI, then the User will be shown a message “This deed does not exist anymore”, and the user will be directed to the previous page.
 */
import EFInternetIndicator
import Localize_Swift
import UIKit
import Toast_Swift
import SwiftGifOrigin
import CoreLocation
import ANLoader
import LabelSwitch
extension GiftADeedViewController: LabelSwitchDelegate {
    func switchChangToState(_ state: LabelSwitchState) {
        switch state {
        case .L: print("circle on left")
        self.fullfilled = "N"
        print("circle on left")
        case .R: print("circle on right")
        self.fullfilled = "Y"
        }
    }
}

class GiftADeedViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate,UITextFieldDelegate,InternetStatusIndicable{
   var internetConnectionIndicator:InternetViewIndicator?

    @IBOutlet weak var labelSwitch: LabelSwitch!
    @IBOutlet  var outletDescription: UITextField!
    @IBOutlet  var outletDeedPic: UIImageView!
    let imagePicker = UIImagePickerController()
    var imageBase64 = ""
    var deedId = ""
    var need = ""
    var cameraFlag : Bool = false
    var deedImage = ""
    var fullfilled = ""
    var locManager = CLLocationManager()
    var tagerLatLong = CLLocation()
    var currentLatLong = CLLocation()
    var i : Int = 1
    @IBOutlet weak var outletCoverView: UIView!
    var distance = ""
    @IBOutlet weak var peopleBenifitLbl: UILabel!
    @IBOutlet weak var fullfillCompletLbl: UILabel!
    @IBOutlet var animationView: UIView!
    @IBOutlet var animationImageView: UIImageView!
    
    @IBOutlet weak var tellDescriptionLbl: UILabel!
    @IBOutlet weak var browseBtn: UIButton!
    @IBOutlet weak var snapBtn: UIButton!
    @IBOutlet weak var uploadPictureLbl: UILabel!
    @IBOutlet weak var startWritingLbl: UILabel!
    @IBOutlet weak var postBtn: UIButton!
    let defaults = UserDefaults.standard
    var userId = ""
    @IBOutlet weak var isFullfillBtnPress: UISwitch!
    @IBOutlet weak var benifitedQty: UITextField!
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
      
if(textField == benifitedQty)
{
            if string.characters.count == 0 {
            return true
            }
            let currentText = benifitedQty.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let newString = (currentText as NSString).replacingCharacters(in: range, with: string) as NSString
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789") &&
                newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 && newString.length <= 5
        }
else if(textField == self.outletDescription){
    if string.characters.count == 0 {
        return true
    }
    let currentText = benifitedQty.text ?? ""
    let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
    let newString = (currentText as NSString).replacingCharacters(in: range, with: string) as NSString
    return prospectiveText.containsOnlyCharactersIn(matchCharacters: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_.#$&%^!@0123456789") &&
        newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 && newString.length <= 50
        }
else{
    return true
        }
        
    }
  
    @IBAction func infoBtnPress(_ sender: UIButton) {
        let alert = UIAlertController(title: "Peoples benifited", message: "Please mention the number of people benifited by fulfillment of this deed", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
         self.appDistance()
self.fullfilled = "N"
          self.navigationController?.navigationBar.topItem?.title = " "
        self.benifitedQty.delegate = self
        self.benifitedQty.text = String(i)
        labelSwitch.curState = .R
        outletDescription.addBottomBorder(UIColor.black, height: 0.5)
        outletDescription.layer.borderWidth = 0.5
        outletDescription.layer.borderColor = UIColor.black.cgColor
        
        // Do any additional setup after loading the view.
        self.findCurrentLocation()
      // setText()
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        imagePicker.delegate = self
        userId = defaults.value(forKey: "User_ID") as! String
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "Gift A Deed".localized()
        self.fullfillCompletLbl.text = "Is this deed fulfilled completly?".localized()
        self.peopleBenifitLbl.text = "People benefited?".localized()
        self.outletDescription.placeholder = "Tell people about your gift".localized()
        self.snapBtn.setTitle("Snap".localized(), for: .normal)
        self.browseBtn.setTitle("Browse".localized(), for: .normal)
        self.postBtn.setTitle("Submit".localized(), for: .normal)
    }
//        userId = defaults.value(forKey: "User_ID") as! String
//        self.automaticallyAdjustsScrollViewInsets = false
//        self.title = "Gift A Deed"
//    }
//    func setText(){
//        uploadPictureLbl.text = "Upload Picture".localized()
//         tellDescriptionLbl.text = "Tell people about your gift".localized()
//        startWritingLbl.text = "Start writing here...".localized()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    //    ANLoader.hide()
    }
    
    @IBAction func plusBtnPress(_ sender: UIButton) {
   
       
    }
    @IBAction func minusBtnPress(_ sender: UIButton) {
      
    }
    @IBAction func isFullFillDeedBtnPress(_ sender: UISwitch) {
        if(sender.isOn){
             self.fullfilled = "N"
        }
        else{
             self.fullfilled = "Y"
        }
    }
    //Find User current location
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
    
    //Fullfill need, if Post having image then upload image first than save data otherwise save data directly
    @IBAction func postAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: nil, message: "Do you really want to post.".localized(), preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes".localized(), style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
            if self.cameraFlag {
                
                self.saveImageMethodCall()
            }else{
                
                self.postMethodCall(imageName: "")
            }
        })
        
        let noAction = UIAlertAction(title: "No".localized(), style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in

        })
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func appDistance (){
        
        let urlString = Constant.BASE_URL + Constant.app_distance
        let url:NSURL = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let userId = UserDefaults.standard.value(forKey: "User_ID") as? String ?? "0"
        let paramString = ""
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
      
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
             //   ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    //  self.outletCoverView.isHidden = true
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                    ANLoader.hide()
                }
                return
            }
             if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj)
                let distanceVal = jsonObj?.value(forKey: "distancevalue") as! NSArray
                for item in distanceVal{
                    let distance_name = (item as! AnyObject).value(forKey: "distance_name") as! String
                    let distance_unit = (item as! AnyObject).value(forKey: "distance_unit") as! String
                    let distance_value = (item as! AnyObject).value(forKey: "distance_value") as! String
                   
                    if(distance_name == "Fulfill Distance"){
                        self.distance =  self.nullToNil(value: distance_value as AnyObject) as! String
                    }
                    else{
                       
                    }
                }
            }
        }
        task.resume()
    }
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }

    //If app user 500 feet near to deed then only he/she can fullfill need.
    //Save data to server
    func postMethodCall(imageName: String){
       
        print(self.currentLatLong)
        print(tagerLatLong)
        let distanceInMeters = self.currentLatLong.distance(from: tagerLatLong)
        let distanceInFeet = distanceInMeters * 3.280839895
        print(self.distance)
        
      
        if distanceInFeet<=Double(self.distance) ?? 500{
                let discription = outletDescription.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                if discription.count == 0 {
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast("Enter Description".localized())
                    return
                }
                
                //self.outletCoverView.isHidden = false
                ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
                
                let urlString = Constant.BASE_URL + Constant.fulfilled_need
                
                let url:NSURL = NSURL(string: urlString)!
                
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = 60.0
                let session = URLSession(configuration: sessionConfig)
                
                
                let request = NSMutableURLRequest(url: url as URL)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
                request.httpMethod = "POST"
                
                let paramString = String(format: "User_ID=%@&Tagged_ID=%@&Fulfilled_Photo_Path=%@&Description=%@&need=%@&is_partial=%@&fulfilled_count=%@",userId,self.deedId,imageName,outletDescription.text!,need,self.fullfilled,self.benifitedQty.text!)
                print(paramString)
                request.httpBody = paramString.data(using: String.Encoding.utf8)
                
                let task = session.dataTask(with: request as URLRequest) {
                    (
                    
                    data, response, error) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        
                     ANLoader.hide()
                    }
                    
                    guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                        
                        DispatchQueue.main.async{
                            
                            //  self.outletCoverView.isHidden = true
                            self.view.hideAllToasts()
                            self.navigationController?.view.makeToast(Validation.ERROR.localized())
                            ANLoader.hide()
                        }
                        return
                    }
                    
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                        
                        if let checkstatus = jsonObj!.value(forKey: "checkstatus") as? NSArray {
                            
                            let status = String(format: "%@",(checkstatus[0] as AnyObject).value(forKey:"status") as! String)
                            if status.isEqual("1"){
                                
                              
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    // your code here
                                    
                                    let Total_credits = String(format: "%@",(checkstatus[0] as AnyObject).value(forKey:"Total_credits") as! String)
                                    let credits_earned = String(format: "%@",(checkstatus[0] as AnyObject).value(forKey:"credits_earned") as! String)
                                    let alertTitle = String(format: "You have tagged %@ need",self.need)
                                    let alertMessage = String(format: "You have earned %@ point(s) and Your total point(s) are %@",credits_earned,Total_credits)
                                    
                                    //  self.outletCoverView.isHidden = true
                                    let actionDic : [String: () -> Void] = [ "Tell Your Friends" : { (
                                        print("tapped YES")
                                        ) }, "NO" : { (
                                            print("tapped NO")
                                            ) }]
                                    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: alertTitle)
                                    attributedString.setColorForText(self.need, with: UIColor.orange)
                                    
                                    //attributedString.setColorForText(textForAttribute: "over", withColor: UIColor.orange)
                                    //attributedString.setColorForText(textForAttribute: "flow", withColor: UIColor.red)
                                    //label.font = UIFont.boldSystemFont(ofSize: 40)
                                    //label.attributedText = attributedString
                                    let text = "points by fulfilling".localized()
                                    let text1 = "need".localized()
                                    let text2 = "Your total points are".localized()
                                   ANLoader.hide()
                                    let objViewController = self.storyboard?.instantiateViewController(withIdentifier: "SuccessPopupViewController") as! SuccessPopupViewController
                                    objViewController.wonPoints = credits_earned
                                    objViewController.needName = self.need
                                    objViewController.totalWonPoints = Total_credits
                                    objViewController.viewFrom = "fulfilldeed"
                                    self.navigationController?.pushViewController(objViewController, animated: true)
                                 //   self.showCustomAlertWith(message: credits_earned, descMsg: "\(text) \(self.need) \(text1)", totalEarnedMsg: "\(text2) \(Total_credits)", itemimage: UIImage (named: "certificate"), actions: actionDic)
                                    // self.alterView(Total_credits: Total_credits, credits_earned: credits_earned, alertTitle: alertTitle, alertMessage: alertMessage)
                                }
                            }
                            else if status.isEqual("0"){
                                
                                self.view.hideAllToasts()
                                self.navigationController?.view.makeToast(Validation.ERROR.localized())
                                ANLoader.hide()
                            }
                        }
                    }
                }
                task.resume()
            }
            else{
                
                DispatchQueue.main.async {
                    let text = "You need to be within".localized()
                    let text1 = "feet area of the needy person".localized()
                    let alertController = UIAlertController(title: nil, message: "\(text) 500 \(text1)", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok".localized(), style: .default, handler:
                    {
                        (alert: UIAlertAction!) -> Void in
                        
                    })
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
    }
    
    //Show alter with user points and can he/she share can also share to other friends
    func alterView(Total_credits: String,credits_earned: String,alertTitle: String,alertMessage: String) {
        
        // create the alert
        let alert = UIAlertController(title: alertTitle , message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (actionSheetController) -> Void in
            
            DispatchQueue.main.async {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.destructive, handler: { (actionSheetController) -> Void in

            //set up activity view controller
            let textToShare = [ Constant.GAD_SHARE_TEXT ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop ]
            
            activityViewController.completionWithItemsHandler = {
                (activity, success, items, error) in
                
                DispatchQueue.main.async {
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home") 
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            }
            
            if Device.IS_IPHONE {
                
                self.present(activityViewController, animated: true, completion: nil)
            }
            else {
                
                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                
                self.present(activityViewController, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
  
    @IBAction func fullfiledSwitchBtn(_ sender: UISwitch) {
        if(sender.isOn){
            fullfilled = "N"
           //tellDescriptionLbl.text = "Tell people what is remaining"
            tellDescriptionLbl.text = "Tell people about your gift"
        }
        else{
             tellDescriptionLbl.text = "Tell people what is remaining"
             // tellDescriptionLbl.text = "Tell people about your gift"
            fullfilled = "Y"
        }
    }
    //Save image to server
    func saveImageMethodCall(){
        
        let discription = outletDescription.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if discription.count == 0 {
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Enter Description".localized())
            return
        }
        
      //  self.outletCoverView.isHidden = false
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.saveimg_ful
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"

        let charset = NSMutableCharacterSet.alphanumeric()
        let paramString = String(format: "name=test.png&image=%@",self.imageBase64.addingPercentEncoding(withAllowedCharacters: charset as CharacterSet)!)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            ANLoader.hide()
            
            guard let imageName = String(data: data!, encoding: .utf8) else{
                
                //self.outletCoverView.isHidden = true
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast("Some error occured, While image uploading.".localized())
                return
            }
            
            self.postMethodCall(imageName: imageName)
        }
        task.resume()
    }
    
    // MARK: Image Picker
    @IBAction func cameraAction(_ sender: Any) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func photoLibAction(_ sender: Any) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.outletDeedPic.image = editedImage;
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.outletDeedPic.image = originalImage;
        }
        picker.dismiss(animated: true)
        
        cameraFlag = true
        self.imageBase64 = GlobalClass.sharedInstance.encodeToBase64String(image:self.outletDeedPic.image?.resizeWithWidth(width: 700))!
    }
}
