//
//  EditDeedViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 18/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    A User should be able to edit a live, unfulfilled deed that anybody has tagged.
 •    On ‘Details of Deed’ screen there should be an Edit option.
 •    After clicking on the Edit option, the User should be directed to the Edit Deed page which will be similar to Tag a Deed page, but it will have pre-populated data.
 •    All the fields are editable.
 •    After successfully editing a deed, a success message should be shown and the user should be redirected to the Deeds Details page of that specific deed.
 */

import UIKit
import Foundation
import ActionSheetPicker_3_0
import Toast_Swift
import GooglePlaces
import ANLoader
import  Localize_Swift

class EditDeedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,GMSAutocompleteViewControllerDelegate{
    
    @IBOutlet  var outletDeedPic: UIImageView!
    @IBOutlet  var outletCategory: UITextField!
    @IBOutlet  var outletLocation: UILabel!
    @IBOutlet  var outletValidity: UISlider!
    @IBOutlet  var outletDescription: UITextView!
    @IBOutlet  var outletHours: UILabel!
    @IBOutlet  var outletSwitch: UISwitch!
    @IBOutlet  var outletIconPic: UIImageView!
    @IBOutlet  var outletContainerView: UIView!
    @IBOutlet  var outletContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var outletCoverView: UIView!
    let defaults = UserDefaults.standard
    var userId = ""
    let imagePicker = UIImagePickerController()
    var cameraFlag : Bool = false
    var validity = ""
    var subType = ""
    var desc = ""
    var ownerId = ""
    var charactorURL = ""
    var geoPoint = ""
    var addressString = ""
    var containerStatus = ""
    var needMappingID = ""
    var needTitle = ""
    var deedImage = ""
    var deedId = ""
    var imageBase64 = ""
    var categoryArr = NSMutableArray()
    var categoryListArr = NSMutableArray()
    var currentVC: UIViewController!
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    var height : CGFloat = 0.0
    var width : CGFloat = 0.0
    var categoryStr = ""

    @IBOutlet weak var uploadPicLbl: UILabel!
    @IBOutlet weak var browseBtn: UIButton!
    @IBOutlet weak var snapBtn: UIButton!
    @IBOutlet weak var selectLocationLbl: UILabel!
    @IBOutlet weak var deedValidityLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var postBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.automaticallyAdjustsScrollViewInsets = false

        self.updateUI()
        
        outletSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        imagePicker.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
 
        self.outletContainerView.isHidden = true
        self.outletContainerViewHeight.constant = 0.0
        self.outletContainerViewHeight.constant = 0.0
    }
    func setText()
    {
        self.uploadPicLbl.text = "Upload Picture".localized();
        self.selectLocationLbl.text = "Select Location".localized();
        self.outletCategory.placeholder = "Select category".localized();
        self.deedValidityLbl.text = "Deed Validity (1 to 48)".localized();
        //self.hrOutlet.text = "OR LOGIN WITH".localized();
        self.descriptionLbl.text = "Description".localized();
        //self.outletDescription.placeholder = "Description".localized();
        self.postBtn.setTitle("Post".localized(using: "Localizable"), for: UIControlState.normal)
        self.snapBtn.setTitle("Snap".localized(using: "Localizable"), for: UIControlState.normal)
        self.browseBtn.setTitle("Browse".localized(using: "Localizable"), for: UIControlState.normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        userId = defaults.value(forKey: "User_ID") as! String
        
        self.downloadCategoryData()
        let network = NetworkManager.sharedInstance
        network.reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.view.hideAllToasts()
                self.view.makeToast(Validation.ERROR)
            }
        }
        
        network.reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.downloadCategoryData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ANLoader.hide()
    }
    
    //Check if image selected then upload image then save data, if not then save data directly
    @IBAction func postAction(_ sender: Any) {
        
        if cameraFlag {
            
            self.saveImageMethodCall()
        }else{
            
            if !self.deedImage.isEqual(""){
                
                let deedImage = self.deedImage.components(separatedBy: "/");
                let imageName = deedImage.last!.components(separatedBy: ".");
                self.postMethodCall(imageName: imageName.first!)
                return;
            }
            self.postMethodCall(imageName: "")
        }
    }
    
    //Validaty slider
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        let currentValue = Int(sender.value)
        outletHours.text = "\(currentValue) hr(s)"
    }
    
    //Container check flag
    @IBAction func switchAction(_ sender: Any) {
        
        if outletSwitch.isOn {
            
            self.containerStatus = "1"
        } else {
            
            self.containerStatus = "0"
        }
    }
    
    //Update data already saved at server
    func updateUI(){
        
        let deedImage = String(format: "%@",self.deedImage)
        let charactorURL = String(format: "%@", self.charactorURL)
        self.outletIconPic.sd_setImage(with: URL(string: charactorURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
        self.outletDeedPic.sd_setImage(with: URL(string: deedImage), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
        self.outletCategory.text = self.needTitle
        self.outletLocation.text = self.addressString
        self.outletValidity.setValue(Float((self.validity as NSString).doubleValue), animated: true)
        self.outletDescription.text = self.desc
        self.outletHours.text = String(format:"%@hr(s)",self.validity)
        
        if ((self.outletCategory.text?.isEqual("Water"))! || (self.outletCategory.text?.isEqual("Food"))!){
            
            DispatchQueue.main.async {
                
                self.outletContainerView.isHidden = false
                self.outletContainerViewHeight.constant = 75.0
                self.outletContainerViewHeight.constant = 75.0
                
                if self.containerStatus.isEqual("1"){
                    
                    self.outletSwitch.setOn(true, animated: true)
                }
                else{
                    
                    self.outletSwitch.setOn(false, animated: true)
                }
            }
        }
        else{
            
            DispatchQueue.main.async {
                
                self.outletContainerView.isHidden = true
                self.outletContainerViewHeight.constant = 0.0
                self.outletContainerViewHeight.constant = 0.0
            }
        }
    }
    
    //Save image to server
    func saveImageMethodCall(){
        
        if self.needMappingID.count == 0{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Select Category")
            return
        }
        if self.needTitle.count == 0 {
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Select Category")
            return
        }
        let discription = outletDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if discription.count == 0 {
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Enter Description")
            return
        }
        
        if addressString.count == 0 {
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Select Address")
            return
        }
        
        self.outletCoverView.isHidden = false
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.saveimg
        
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let imageName = String(data: data!, encoding: .utf8) else{
                
                DispatchQueue.main.async{
                    
                    self.outletCoverView.isHidden = true
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast("Some error occured, While image uploading.")
                }
                return
            }
            
            self.postMethodCall(imageName: imageName)
        }
        task.resume()
    }
    
    //save data to server
    func postMethodCall(imageName: String){
        
        if self.needMappingID.count == 0{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Select Category")
            return
        }
        if self.needTitle.count == 0 {
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Select Category")
            return
        }
        let discription = outletDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if discription.count == 0 {
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Enter Description")
            return
        }
        
        if addressString.count == 0 {
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Select Address")
            return
        }
        
        self.outletCoverView.isHidden = false
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.edit_deed
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"

        let paramString = String(format: "userId=%@&deedId=%@&NeedMapping_ID=%@&Geopoint=%@&Tagged_Photo_Path=%@&Tagged_Title=%@&Description=%@&Address=%@&validity=%d&container=%@", userId,deedId,self.needMappingID,geoPoint,imageName,self.needTitle,discription,addressString,
            (outletHours.text! as NSString).integerValue,self.containerStatus)
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.outletCoverView.isHidden = true
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR)
                }
                return
            }

            let convertedStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(convertedStr as Any)
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                
                let status = String(format:"%d", GlobalClass.sharedInstance.nullToNil(value: (jsonObj as AnyObject).value(forKey: "status")! as AnyObject) as! Int);
                if status.isEqual("1"){
                    
                    DispatchQueue.main.async{
                        
                        self.outletCoverView.isHidden = true
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast("Edited Successfully.")
                    }
                    self.navigationController?.popViewController(animated: true)
                }
                else if status.isEqual("0"){
                    
                    DispatchQueue.main.async{
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast(Validation.ERROR)
                    }
                }
            }
        }
        task.resume()
    }
    
    //Select category
    @IBAction func selectCategory(_ sender: Any) {
        
        ActionSheetStringPicker.show(withTitle: "Select Category",
                                     rows: self.categoryListArr as! [Any] ,
                                     initialSelection: 0,
                                     doneBlock: {
                                        picker, indexe, values in
                                        
                                        self.outletCategory.text = values as? String
                                        
                                        let item = self.categoryArr[indexe]
                                        self.needTitle = (item as AnyObject).value(forKey:"Need_Name") as! String
                                        self.needMappingID = (item as AnyObject).value(forKey:"NeedMapping_ID") as! String
                                        
                                        DispatchQueue.main.async {
                                            
                                            let iconURL = String(format: "%@%@", Constant.BASE_URL ,(item as AnyObject).value(forKey:"Character_Path") as! String)
                                            self.outletIconPic.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
                                        }
                                        
                                        if ((self.outletCategory.text?.isEqual("Water"))! || (self.outletCategory.text?.isEqual("Food"))!){
                                            
                                            if Device.IS_IPHONE {
                                                
                                                self.outletContainerViewHeight.constant = 65.0
                                                self.outletContainerViewHeight.constant = 65.0
                                            }
                                            else {
                                                
                                                self.outletContainerViewHeight.constant = 85.0
                                                self.outletContainerViewHeight.constant = 85.0
                                            }
                                            self.outletContainerView.isHidden = false
                                        }
                                        else{
                                            
                                            self.outletContainerView.isHidden = true
                                            self.outletContainerViewHeight.constant = 0.0
                                            self.outletContainerViewHeight.constant = 0.0
                                        }
                                        return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    // Mark: Autocomplete
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    // Mark: Google Autocomplete
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        self.addressString = place.formattedAddress!
        self.outletLocation.text = self.addressString
        
        geoPoint = String(format:"%f,%f", place.coordinate.latitude, place.coordinate.longitude)
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: Image Picker
    @IBAction func cameraAction(_ sender: Any) {
        
        cameraFlag = true
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func photoLibAction(_ sender: Any) {
        
        cameraFlag = true
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
        self.imageBase64 = GlobalClass.sharedInstance.encodeToBase64String(image:self.outletDeedPic.image!)!
    }
    
    //Download category data
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
                    self.navigationController?.view.makeToast(Validation.ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                self.categoryListArr.removeAllObjects();
                self.categoryArr.removeAllObjects();
                
                if let needtype = jsonObj!.value(forKey: "needtype") as? NSArray {
                    
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
                }
            }
            
        }
        task.resume()
    }
}
