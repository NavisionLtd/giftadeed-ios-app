//
//  MyProfileViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 13/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    This screen will display all the information user entered at the time of registering the app or during the last modification done by the User.
 •    Here, the user will have an option to make their profile “Anonymous” or “Public”.
 •    The password can be changed from here.During social media login, Change Password option will not be visible. Change password functionality is available only during regular app login.
 •    The heading of the page is My Profile. On the right there is an Edit button. Initially all the options are shown in non-editable form.
 •    There is a smiley below My profile heading on the display page. Below that there is User First Name and Last Name. Below that there is My Credits - <Points of User>. Next to points, there is Share symbol (button). On clicking Share symbol, sharing options are opened. Sharing is available during Edit as well as during View only. The user should be able to share the total points. The Share message should be as follows: Hey! I am using ‘Gift-A-Deed’ charity mobile app. You can download it from: https://play.google.com/store/apps/details?id=giftadeed.kshantechsoft.com.giftadeed After clicking on the app link, the user should be taken to the Gift-A-Deed play store page.
 •    On clicking Edit, the following User information can be edited - First Name, Last Name, Country,State, City, andChange Password (Password is prepopulated. Visible and Invisible symbol available at the right. Only a single Change Password option is there. There is no option for Current Password, New Password, Confirm Password etc), Privacy (Anonymous or Public radio buttons).If the User selects Anonymous, then the name will be shown as Anonymous in – Tagged by in Tagged Deeds Details page, Comments, in Tagged Deeds Details page, Top 10 Taggers, and Top 10 Tag Fulfillers.
 •    Apart from email id, all other fields are editable.
 •    During Edit, the Edit button becomes Save button. After clicking on Save button, the User is redirected to Home page and a Toast Message is shown 'Profile Updated successfully' while the home page is loaded.
 */
import EFInternetIndicator
import SQLite3
import UIKit
import ActionSheetPicker_3_0
import ANLoader
import Localize_Swift
import FirebaseStorage
//import UIKit
import Photos
import AudioToolbox
import Firebase
import FirebaseDatabase

class MyProfileViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate,InternetStatusIndicable{
    var internetConnectionIndicator:InternetViewIndicator?
    
    // Firebase services
    var database = FIRDatabase.database()
    var storage = FIRStorage.storage()
   var receivedAvtaar = ""
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var menuProfileTitle: UINavigationItem!
    @IBOutlet var outletProfilePic: UIImageView!
    @IBOutlet var outletName: UILabel!
    @IBOutlet var outletCreditScore: UILabel!
 
    @IBOutlet  var outletFirstName: UITextField!
    @IBOutlet  var outletLastName: UITextField!
    @IBOutlet  var outletEmail: UITextField!
    @IBOutlet  var outletCountry: UITextField!
    @IBOutlet  var outletState: UITextField!
    @IBOutlet  var outletCity: UITextField!
    @IBOutlet  var outletChangePassword: UITextField!
    @IBOutlet  var outletChangePwdBtn: UIButton!
    @IBOutlet var outletLinePassword: UIImageView!
    @IBOutlet var outletPasswordHeight: NSLayoutConstraint!
    @IBOutlet var outletPrivacyView: UIView!
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet  var outletCountryBtn: UIButton!
    @IBOutlet  var outletStateBtn: UIButton!
    @IBOutlet  var outletCityPwdBtn: UIButton!
    
   
    @IBOutlet  var outletPublic: ISRadioButton!
    @IBOutlet  var outletAnonymous: ISRadioButton!
    
    @IBOutlet weak var uploadBtn: UIButton!
    //@IBOutlet weak var uploadImgBtn: UIButton!
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var privacyLbl: UITextField!
    var countryDataArr = NSMutableArray()
    var countryNameArr = NSMutableArray()
    var stateDataArr   = NSMutableArray()
    var stateNameArr   = NSMutableArray()
    var cityDataArr    = NSMutableArray()
    var cityNameArr    = NSMutableArray()
    @IBOutlet weak var privacyDetailsLbl: UILabel!
    @IBOutlet weak var primaryDetails: UILabel!
    @IBOutlet weak var otherDetails: UILabel!
    
    var Fname  = "", Lname  = "", Email  = "", Mobile  = "", Address  = "",countryId = "",stateId = "",cityId = "", Gender  = "", Privacy  = "", Password  = ""
    
    @IBAction func shareBtnPress(_ sender: UIBarButtonItem) {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let textToShare = [ Constant.GAD_SHARE_TEXT,img! ] as [Any]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
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
    @IBAction func editBtnPress(_ sender: UIBarButtonItem) {
         self.outletChangePwdBtn.isHidden = false
         self.uploadBtn.isHidden = false
        self.outletCity.isEnabled = true
        self.outletState.isEnabled = true
        self.outletCountry.isEnabled = true
        self.outletCountryBtn.isEnabled = true
        self.outletStateBtn.isEnabled = true
        self.outletCityPwdBtn.isEnabled = true
        self.outletFirstName.isEnabled = true
        self.outletLastName.isEnabled = true
        self.outletEmail.isEnabled = true
        self.outletChangePassword.isEnabled = true
        self.privacyLbl.isEnabled = true
        self.privacySwitch.isEnabled = true
       //  editBtn.action = #selector(buttonClicked(sender:))
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(buttonClicked(sender:)))
        
    }
    @objc func buttonClicked(sender: UIBarButtonItem) {
            self.updateProfile()
    }
    @IBOutlet weak var editBackgroundView: UIView!
    var editStatus : Bool!
    var downloadStatus : Bool!
    var togglePwd : Bool!
    
    let defaults = UserDefaults.standard
    var userId = ""
    
    @IBAction func uploadAvtaarBtnPress(_ sender: UIButton) {
        let storageRef = self.storage.reference().child("liveAvtaars/"+"35")
        let path =  storageRef.fullPath
       
        let pickedImage = UIImage (named: "avtaar35")
        PostServiceFireBase.create(for: pickedImage!, path: path) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                print("Download url not found")
                //   Toast(text: "Failed to upload image").show()
                print("Failed to upload image")
                return
            }
            let array = ["email":self.outletEmail.text!,
                         "id":self.userId,
                         "name": self.outletName.text! as String,
                         "url": downloadURL
                ] as [String : Any]
            let dbRef = self.database.reference().child("liveAvtaars/"+"35")
            dbRef.setValue(array)
            
            
            let urlString = downloadURL
            print("image url for download image :: \(urlString)")
            
      
        }
    }
    @IBAction func uploadBtnPress(_ sender: UIButton) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
            self.askForChooeseImageType()
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                    self.askForChooeseImageType()
                }
            })
            print("It is not determined until now")
            
        case .restricted:
            print("User do not have access to photo album.")
            
        case .denied:
            print("User has denied the permission.")
        }
    }
    func askForChooeseImageType() {
        let alert = UIAlertController(title: "Choose Image".localized(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".localized(), style: .default, handler: { _ in
            DispatchQueue.main.async {
            self.openCamera()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery".localized(), style: .default, handler: { _ in
            DispatchQueue.main.async {
            self.openGallary()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Avtaar".localized(), style: .default, handler: { _ in
              DispatchQueue.main.async {
            self.openAvtaar()
            }
        }))
          DispatchQueue.main.async {
        alert.addAction(UIAlertAction.init(title: "Cancel".localized(), style: .cancel, handler: nil))
        if Device.IS_IPHONE {
            self.present(alert, animated: true, completion: nil)
        }
        else{
            alert.popoverPresentationController!.sourceView = self.view
            alert.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width/2 , y: self.view.bounds.size.height/7, width: 1.0, height: 1.0)
            self.present(alert, animated: true, completion: nil)
        }
        }
    }
    func openAvtaar(){
        UserDefaults.standard.removeObject(forKey: "url")
        navigationItem.rightBarButtonItem?.isEnabled = false
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "avtar") as! AvtaarImgViewController
        self.addChildViewController(popvc)
        popvc.view.frame = self.view.frame
        popvc.view.backgroundColor = UIColor.groupTableViewBackground
        self.view.addSubview(popvc.view)
      //  self.view.alpha = 0.65
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        popvc.didMove(toParentViewController: self)
    }
    func openCamera()
    {
          DispatchQueue.main.async {
        UserDefaults.standard.removeObject(forKey: "url")
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
          
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        }
    }
    
    func openGallary()
    {
        navigationItem.rightBarButtonItem?.isEnabled = false
        UserDefaults.standard.removeObject(forKey: "url")
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
  
    //MARK: - imagePickerView delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let kUserDefault = UserDefaults.standard
            let email = kUserDefault.string(forKey:"email")
            self.outletProfilePic.image = pickedImage
            //            PostServiceFireBase.create(for: pickedImage)
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHH:mm"
            let currentDateTimeString = formatter.string(from: currentDateTime)
            
            let filePath = self.userId// change path as per your requirement
            
            PostServiceFireBase.create(for: pickedImage, path: filePath) { (downloadURL) in
                guard let downloadURL = downloadURL else {
                    print("Download url not found")
                 //   Toast(text: "Failed to upload image").show()
                    print("Failed to upload image")
                    return
                }
                let array = ["email":self.outletEmail.text,
                             "userid":self.userId,
                             "name": self.outletName.text! as String,
                              "photourl": downloadURL
                    ] as [String : Any]
                let dbRef = self.database.reference().child("FirbaseBranch"+self.userId)
              
                dbRef.setValue(array)
              
                
                let urlString = downloadURL
                print("image url for download image :: \(urlString)")
                
                DispatchQueue.global(qos: .background).async {
                    print("This is run on the background queue")
                    
                    DispatchQueue.main.async {
                         self.downloadProfileImg()
                        print("This is run on the main queue, after the previous code in outer block")
                    }
                }
               
            }
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func menuBtnPress(_ sender: UIBarButtonItem) {

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }


    func downloadProfileImg(){
       navigationItem.rightBarButtonItem?.isEnabled = true
        let dbRef = database.reference().child("FirbaseBranch")
       
        dbRef.observeSingleEvent(of:.value) { (snapshot) in
            if !snapshot.exists() { return }
         
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                 print(data)
                let object = data.value as? [String:AnyObject]
                let id = object?["userid"]
               print(id,self.userId)
                if (id?.isEqual(self.userId))!{
                    let downloadUrl = object?["photourl"]
                     print(downloadUrl!)
                    let storageRef = self.storage.reference(forURL: downloadUrl as! String)
                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
                    storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        // Create a UIImage, add it to the array
                        let pic = UIImage(data: data!)
//                    let storageRef = self.storage.reference(forURL: downloadUrl as! String)
//                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
//                    storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
//                        // Create a UIImage, add it to the array
                 
                        self.outletProfilePic.layer.borderWidth = 1.0
                        self.outletProfilePic.layer.masksToBounds = false
                        self.outletProfilePic.layer.borderColor = UIColor.black.cgColor
                      //  self.outletProfilePic.layer.cornerRadius = self.outletProfilePic.frame.size.width/2
                        self.outletProfilePic.clipsToBounds = true
                          self.outletProfilePic.image = pic
                    }
                }
                else{
                    
                    print("Default Image")
                }
            }
        }
      
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
 self.navigationItem.title = "My Profile".localized()
setText()
      
outletFirstName.setBottomBorder()
        outletLastName.setBottomBorder()
        outletEmail.setBottomBorder()
        outletChangePassword.setBottomBorder()
        outletCountry.setBottomBorder()
        outletState.setBottomBorder()
        outletCity.setBottomBorder()
      //  self.outletProfilePic.clipsToBounds = true
      //  self.outletProfilePic.layer.borderWidth=0.2
     //   self.outletProfilePic.layer.borderColor = UIColor.black.cgColor
      //  self.outletProfilePic.layer.cornerRadius = outletProfilePic.frame.height/2
        
        let radius: CGFloat = self.outletProfilePic.frame.width / 2.0 //change it to .height if you need spread for height
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 2.1 * radius, height: self.outletProfilePic.frame.height))
        //Change 2.1 to amount of spread you need and for height replace the code for height
        
        self.outletProfilePic.layer.cornerRadius = outletProfilePic.frame.height/2
        
        self.outletProfilePic.layer.masksToBounds =  false
        self.outletProfilePic.layer.shadowPath = shadowPath.cgPath
        privacyLbl.addBottomBorder(UIColor.black, height: 0.5)
            imagePicker.delegate = self
        //first time disable user interaction with UI
        self.outletCity.isEnabled = false
        self.outletState.isEnabled = false
        self.outletCountry.isEnabled = false
        self.outletCountryBtn.isEnabled = false
        self.outletStateBtn.isEnabled = false
        self.outletCityPwdBtn.isEnabled = false
        self.outletFirstName.isEnabled = false
        self.outletLastName.isEnabled = false
        self.outletEmail.isEnabled = false
        self.outletChangePassword.isEnabled = false
        self.privacyLbl.isEnabled = false
        self.privacySwitch.isEnabled = false
        self.uploadBtn.isHidden = true
        self.outletChangePwdBtn.isHidden = true
    }
    func setText()
    {
          self.privacyDetailsLbl.text = "Privacy Details".localized()
        self.primaryDetails.text = "Primary Details".localized()
        self.otherDetails.text = "Other Details".localized()
        outletName.text = "".localized()
        outletCreditScore.text = "My Credits".localized()
        outletFirstName.placeholder = "First Name".localized()
        outletLastName.placeholder = "Last Name".localized()
        outletEmail.placeholder = "Email".localized()
        outletChangePassword.placeholder = "Password".localized()
        outletCountry.placeholder = "Country".localized()
        privacyLbl.placeholder = "Privacy".localized()
        outletState.placeholder = "State".localized()
        outletCity.placeholder = "City".localized()
        editBtn.title = "Edit".localized()
        uploadBtn.setTitle("Edit Profile Photo".localized(), for: .normal)
        menuProfileTitle.title = "My Profile".localized()
        menuProfileTitle.title = "My Profile".localized()
    //     uploadImgBtn.setTitle("Edit".localized(), for: UIControlState.normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           downloadProfileImg()
        // Hide the navigation bar on the this view controller
        userId = defaults.value(forKey: "User_ID") as! String
    self.downloadData()

        let network = NetworkManager.sharedInstance
        network.reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast(Validation.ERROR.localized())
            }
        }
        
        network.reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
           
               self.downloadData();
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ANLoader.hide()
    }
    
 
    @objc func editAction(){
        
        self.view.endEditing(true)
     //   self.editStatus = true
        print(editStatus)
          DispatchQueue.main.async{
            if self.editStatus == nil{
            
            self.updateProfile()
        }
        else{
            
                self.editStatus = true
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(self.editAction))
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            
            self.isEnable()
        }
        }
    }
    
    //Enable all fields
    func isEnable(){
        
//    }
//
//    //Enable all fields
//    func isEnable(){
//
//        DispatchQueue.main.async {
//          //  self.uploadImgBtn.isUserInteractionEnabled = true;
//            self.outletCountryBtn.isUserInteractionEnabled = true
//            self.outletStateBtn.isUserInteractionEnabled = true
//            self.outletCityPwdBtn.isUserInteractionEnabled = true
//            self.outletFirstName.isUserInteractionEnabled = true
//            self.outletLastName.isUserInteractionEnabled = true
//            self.outletEmail.isUserInteractionEnabled = true
    }
    
    //Desible all fields
    func isDisable(){
        
//    }
//
//    //Desible all fields
//    func isDisable(){
//
//        DispatchQueue.main.async {
//            //self.uploadImgBtn.isHidden = true
//            self.editBackgroundView.isHidden = true
//           // self.uploadImgBtn.isUserInteractionEnabled = false;
//            self.outletPrivacyView.isHidden = false
//            self.outletCountryBtn.isUserInteractionEnabled = false
//            self.outletStateBtn.isUserInteractionEnabled = false
//            self.outletCityPwdBtn.isUserInteractionEnabled = false
    }
    
    //Radios buttons privacy
    @IBAction func radioButtonAction(_ isRadioButton:ISRadioButton){
        
        self.Privacy = isRadioButton.titleLabel!.text ?? ""
    }
    
    @IBAction func switchBtnPress(_ sender: UISwitch) {
        if(sender.isOn){
            self.privacyLbl.text =  "Public"
        }
        else{
            self.privacyLbl.text =  "Anonymous"
        }
    }
    //Update edited fields profile to server
    func updateProfile(){
       // UIApplication.shared.beginIgnoringInteractionEvents()
        self.Fname  = self.outletFirstName.text!
        self.Lname  = self.outletLastName.text!
        self.Email  = self.outletEmail.text!
        let password =  self.outletChangePassword.text ?? ""
        
        if Validation.sharedInstance.isNameValid(Name: self.Fname){
            
        }else{
            
            DispatchQueue.main.async{
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(self.editAction))
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast(Validation.validFirstName.localized())
            }
            return
        }
        
        if self.Fname.count>=3 && self.Fname.count<=15 {
            
            
        }
        else{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("First name must be 3 to 15 charectors.".localized())
            return
        }
        
        if self.Lname.count != 0{
            
            if Validation.sharedInstance.isLastNAmeValid(Name: self.Lname){
                
            }else{
                
                DispatchQueue.main.async{
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(self.editAction))
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.validLastName.localized())
                }
                return
            }
        }
        
        if Validation.sharedInstance.isValidEmail(Email: self.Email ){
            
        }else{
            
            DispatchQueue.main.async{
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(self.editAction))
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast(Validation.validLoginEmail.localized())
            }
            return
        }

        if self.countryId.count == 0{
            
            DispatchQueue.main.async{
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(self.editAction))
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast(Validation.validCountry.localized())
            }
            return
        }
        
        if self.stateId.count == 0{
            
            DispatchQueue.main.async{
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(self.editAction))
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast(Validation.validState.localized())
            }
            return
        }
        
        if self.cityId.count == 0{
            
            DispatchQueue.main.async{
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(self.editAction))
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast(Validation.validCity.localized())
            }
            return
        }
        
        if self.Password.count != 0{
            
            if Validation.sharedInstance.isPwdLenth(Password: password){
                
                if Validation.sharedInstance.isPasswordValid(Password: password){
                    
                }else{
                    
                    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(editAction))
                    navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                    DispatchQueue.main.async{
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast(Validation.validPassword.localized())
                    }
                    return
                }
            }
            else{
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.validPassword.localized())
                }
                return
            }
        }

        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.update_userprofile
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"

        let charset = NSMutableCharacterSet.alphanumeric()
        let paramString = String(format:"User_ID=%@&Fname=%@&Lname=%@&Country_ID=%@&State_ID=%@&City_ID=%@&Privacy=%@&Password=%@",self.userId,self.Fname,self.Lname,self.countryId,self.stateId,self.cityId,self.privacyLbl.text!,password.addingPercentEncoding(withAllowedCharacters: charset as CharacterSet)!)
        
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
                      
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast("\(GlobalClass.sharedInstance.blockStatus = true)")
                    }
                    return
                }
                
                if let checkstatus = jsonObj!.value(forKey: "checkstatus") as? NSArray {
                    
                    let status  = ((checkstatus[0] as AnyObject).value(forKey: "status") as? String)!
                    if status.isEqual("1"){
                        
                        self.editStatus = false
                //    self.isDisable()
                      
                        UserDefaults.standard.set("App", forKey: "Login_Type")
                        UserDefaults.standard.set(self.Fname, forKey: "Fname")
                        UserDefaults.standard.set(self.Lname, forKey: "Lname")
                        UserDefaults.standard.set(self.userId, forKey: "User_ID")
                        UserDefaults.standard.set(self.countryId, forKey: "Country_ID")
                        
                        DispatchQueue.main.async {
                            
                            let optionMenu = UIAlertController(title: nil, message: "Profile Updated Successfully.".localized(), preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "Ok", style: .default, handler:
                            {
                                (alert: UIAlertAction!) -> Void in
                                
//
//                            let okAction = UIAlertAction(title: "Ok", style: .default, handler:
//                            {
                            })
                            optionMenu.addAction(okAction)
                            self.present(optionMenu, animated: true, completion: nil)
                            self.outletCity.isEnabled = false
                            self.outletState.isEnabled = false
                            self.outletCountry.isEnabled = false
                            self.outletCountryBtn.isEnabled = false
                            self.outletStateBtn.isEnabled = false
                            self.outletCityPwdBtn.isEnabled = false
                            self.outletFirstName.isEnabled = false
                            self.outletLastName.isEnabled = false
                            self.outletEmail.isEnabled = false
                            self.outletChangePassword.isEnabled = false
                            self.privacyLbl.isEnabled = false
                            self.privacySwitch.isEnabled = false
                             self.uploadBtn.isHidden = true
                            self.outletChangePwdBtn.isHidden = true
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit".localized(), style: .plain, target: self, action:
                                #selector(self.editAction))
                            
                            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                        
                         //   UIBarButtonItem.appearance().tintColor = UIColor.magenta
                        }
                    }
                    else {
                        
                        DispatchQueue.main.async {
                            
                            self.view.hideAllToasts()
                            self.navigationController?.view.makeToast("Some error occured.".localized())
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //Toggele password fields like visible and invisible fields
    @IBAction func hideShowPwdBtnPress(_ sender: UIButton) {
        if(togglePwd == true) {
            
            outletChangePwdBtn.setTitle( "Hide" , for: .normal )
            outletChangePassword.isSecureTextEntry = false
            togglePwd = false
        } else {
            
            outletChangePwdBtn.setTitle( "Show" , for: .normal )
            outletChangePassword.isSecureTextEntry = true
            togglePwd = true
        }
    }
    @IBAction func pwdTaggleAction(sender: AnyObject) {
        
        if(togglePwd == true) {
            
            outletChangePwdBtn.setTitle( "Hide" , for: .normal )
            outletChangePassword.isSecureTextEntry = false
            togglePwd = false
        } else {
           
            outletChangePwdBtn.setTitle( "Show" , for: .normal )
            outletChangePassword.isSecureTextEntry = true
            togglePwd = true
        }
    }
    
    //share points to other friends.
   
    
    @IBAction func selectCountry(_ sender: Any) {
        
        if self.countryNameArr.count==0{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("No data found".localized())
            return
        }
        
        ActionSheetStringPicker.show(withTitle: "Select Country".localized(), rows: (self.countryNameArr as! [Any]) , initialSelection: 0, doneBlock: {
            picker, indexe, values in
            let country = values as! String
            self.downloadStatus = false
            self.outletCountry.text = country.localized()
            let item = self.countryDataArr[indexe]
            self.countryId = (item as AnyObject).value(forKey:"Cntry_ID") as! String
           
            self.outletState.text = "Select State".localized()
            self.outletCity.text = "Select City".localized()
            
            self.stateId = ""
            self.stateNameArr.removeAllObjects()
            self.stateDataArr.removeAllObjects()
            self.cityId = ""
            self.cityDataArr.removeAllObjects()
            self.cityNameArr.removeAllObjects()
           
            self.downloadStateData()
            return
       }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //Select state
    @IBAction func selectState(_ sender: Any) {
        
        if self.countryId.isEqual(""){
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Select Country".localized())
            return
        }
        
        if self.stateNameArr.count==0{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("No data found".localized())
            return
        }
        
        ActionSheetStringPicker.show(withTitle: "Select State".localized(), rows: self.stateNameArr as! [Any] , initialSelection: 0, doneBlock: {
            picker, indexe, values in
            
            self.downloadStatus = false
            self.outletState.text = values as? String
            let item = self.stateDataArr[indexe]
            self.stateId = (item as AnyObject).value(forKey:"State_ID") as! String
            
            self.outletCity.text = "Select City".localized()
            
            self.cityId = ""
            self.cityDataArr.removeAllObjects()
            self.cityNameArr.removeAllObjects()
            
            self.downloadCityData()
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //Selct city
    @IBAction func selectCity(_ sender: Any) {
        
        if self.stateId.isEqual(""){
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Select City".localized())
            return
        }
        
        if self.cityNameArr.count==0{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("No data found".localized())
            return
        }
        
        ActionSheetStringPicker.show(withTitle: "Select City".localized(), rows: self.cityNameArr as! [Any] , initialSelection: 0, doneBlock: {
            picker, indexe, values in
            
            self.downloadStatus = false
            self.outletCity.text = values as? String
            let item = self.cityDataArr[indexe]
            self.cityId = (item as AnyObject).value(forKey:"City_ID") as! String
            return
       }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //Download data of User profile and update UI
    func downloadData(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        downloadStatus = true
        let urlString = Constant.BASE_URL + Constant.fetch_userprofile
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "User_ID=%@", userId)
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
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
print(jsonObj)
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast("\(GlobalClass.sharedInstance.blockStatus = true)")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if let profiledata = jsonObj!.value(forKey: "profiledata") as? NSArray {
                        
                        let userInfo = profiledata[0]
                        
                        self.Fname = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Fname")! as AnyObject) as! String
                        self.Lname  = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Lname")! as AnyObject) as! String
                        self.Email  = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Email")! as AnyObject) as! String
                        print(self.Email)
                        self.Address  = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Address")! as AnyObject) as! String
                        self.Gender  =  GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Gender")! as AnyObject) as! String
                        self.Password  = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Password")! as AnyObject) as! String
                        self.Privacy  = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Privacy")! as AnyObject) as! String
                        
                        self.defaults.set(self.Privacy, forKey: "PRIVACY")
                        
                        if self.Password.isEqual(""){
                            
                         /*   self.outletPasswordHeight.constant = 0.0
                            self.outletLinePassword.isHidden = true
                            self.outletChangePwdBtn.isHidden = true
                            self.outletChangePassword.isHidden = true*/
                        }
                        else{
                            
                            if Device.IS_IPHONE {
                                
                              //  self.outletPasswordHeight.constant = 50.0
                            }
                            else{
                                
                               // self.outletPasswordHeight.constant = 35.0
                            }
                            
                        //    self.outletLinePassword.isHidden   = false
                        //    self.outletChangePwdBtn.isHidden   = false
                         //   self.outletChangePassword.isHidden = false
                        }
                        
                        DispatchQueue.main.async {
                            
                            if self.Privacy.isEqual("Public"){
                                self.privacyLbl.text = "Public"
                                self.privacySwitch.isOn = true
                          //      self.outletPublic.isSelected = true
                               // self.outletAnonymous.isSelected = false
                            }
                            else if self.Privacy.isEqual("Anonymous"){
                                self.privacyLbl.text = "Anonymous"
                                self.privacySwitch.isOn = false
                           //     self.outletPublic.isSelected = false
                               // self.outletAnonymous.isSelected = true
                            }
                            else{
                                 self.privacyLbl.text = "Public"
                                self.privacySwitch.isOn = true
                             //   self.outletPublic.isSelected = true
                            //    self.outletAnonymous.isSelected = false
                            }
                        }
                        
                        self.countryId = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Country_ID")! as AnyObject) as! String
                        self.stateId = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "State_ID")! as AnyObject) as! String
                        self.cityId = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "City_ID")! as AnyObject) as! String
                        self.Mobile  = GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Mobile")! as AnyObject) as! String
    
                        self.outletName.text = self.Fname + " " + self.Lname
                        self.outletFirstName.text = self.Fname
                        self.outletLastName.text = self.Lname
                        self.outletEmail.text = self.Email
                        self.outletChangePassword.text = self.Password
                        let msg = "My Credits".localized()
                        self.outletCreditScore.text = String(format:"\(msg)  %d", GlobalClass.sharedInstance.nullToNil(value: (userInfo as AnyObject).value(forKey: "Total_Points")! as AnyObject) as! Int);
                        
                        self.downloadCountryData()
                    }
                }
            }
        }
        
        task.resume()
    }
    
    //Download country data
    func downloadCountryData(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.country_list
        
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
                
                if let taggedlist = jsonObj!.value(forKey: "countrydata") as? NSArray {
                    
                    self.countryNameArr.removeAllObjects()
                    self.countryDataArr.removeAllObjects()
                    
                    for item in taggedlist {
                        
                        let countryItem = item as? NSDictionary
                        
                        do {
                            
                            try self.countryNameArr.add((countryItem as AnyObject).value(forKey:"Cntry_Name") as! String)
                            try self.countryDataArr.add(countryItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                        
                        if self.downloadStatus{
                            
                            let countryID = (countryItem as AnyObject).value(forKey:"Cntry_ID") as! String
                            if countryID.isEqual(self.countryId){
                                
                                DispatchQueue.main.async {
                                    
                                    self.countryId = ((countryItem as AnyObject).value(forKey:"Cntry_ID") as? String)!
                                    self.outletCountry.text = (countryItem as AnyObject).value(forKey:"Cntry_Name") as? String
                                 //   self.outletCountryBtn.setTitle((countryItem as AnyObject).value(forKey:"Cntry_Name") as? String, for: .normal)
                                    self.downloadStateData()
                                }
                            }
                        }
                    }
                }
            }
            
        }
        task.resume()
    }
    
    //Download state data
    func downloadStateData(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.state_list
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "Cntry_ID=%@", self.countryId)
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
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let statelist = jsonObj!.value(forKey: "statedata") as? NSArray {
                    
                    for item in statelist {
                        
                        let stateItem = item as? NSDictionary
                        
                        do {
                            
                            try self.stateNameArr.add((stateItem as AnyObject).value(forKey:"State_Name") as! String)
                            try self.stateDataArr.add(stateItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                        
                        if self.downloadStatus{
                            
                            let stateID = (stateItem as AnyObject).value(forKey:"State_ID") as! String
                            if stateID.isEqual(self.stateId){
                                
                                DispatchQueue.main.async {
                                    
                                    self.stateId = ((stateItem as AnyObject).value(forKey:"State_ID") as? String)!
                                  self.outletState.text = (stateItem as AnyObject).value(forKey:"State_Name") as? String
                                 //   self.outletStateBtn.setTitle((stateItem as AnyObject).value(forKey:"State_Name") as? String, for: .normal)
                                    self.downloadCityData()
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //Download city data
    func downloadCityData(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.city_list
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "State_ID=%@", self.stateId)
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
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let citylist = jsonObj!.value(forKey: "citydata") as? NSArray {
                    
                    for item in citylist {
                        
                        let cityItem = item as? NSDictionary
                        
                        do {
                            
                            try self.cityNameArr.add((cityItem as AnyObject).value(forKey:"City_Name") as! String)
                            try self.cityDataArr.add(cityItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                        
                        if self.downloadStatus{
                            
                            let cityID = (cityItem as AnyObject).value(forKey:"City_ID") as! String
                            if cityID.isEqual(self.cityId){
                                
                                DispatchQueue.main.async {
                                    
                                    self.cityId = ((cityItem as AnyObject).value(forKey:"City_ID") as? String)!
                                 self.outletCity.text = (cityItem as AnyObject).value(forKey:"City_Name") as? String
                                  //  self.outletCityPwdBtn.setTitle((cityItem as AnyObject).value(forKey:"City_Name") as? String, for: .normal)
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
}
