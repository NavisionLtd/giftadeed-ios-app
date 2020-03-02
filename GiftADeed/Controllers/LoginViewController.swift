//
//  ViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 04/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.

/*
 •    The User can either login using his/her registered email and password, or by using his/her Facebook, Google or LinkedIn credentials. If the user has already been registered earlier and not logged out of the system during the last use of the app, clicking the App icon in the App gallery will directly take the user to the landing page. The landing page is the Map view.
 •    If the user is a first time user (not yet registered) of the app or have clicked “Sign Out” during the last use of the app, he/she should see the log-in screen.
 •    User should be able to enter his registered email address (used at the time of Registration/Sign Up).
 •    User should be able to enter his registered password (used at the time of Registration/Sign Up).
 •    If email address and/or password entered does not match with the system’s data, an appropriate pop-up should be displayed.
 •    If email address and/or password entered matches with the system’s data, user should be taken to the landing screen.
 •    If the User has not completed the registration process by setting the password using the Registration Completion Link, but still tries to Login using that email id, then the following popup message should be shown “A Registration Completion Link has already been sent to <Email Id>. Please set your password using that link.” There will be a Resend Link button on the popup. On clicking the Resend Link button, an email with the Registration Completion Link will be sent again to the Users email id.
 •    If the User has been using Social Media to use the app and has never used the app login before, but still tries to Login using that email id and any password, then the following message should be shown “Wrong Password”. The User will need to use the Forgot Password option in this case.
 •    If the user has registered with the system previously, but is unable to recollect the password, “Forgot password?” link should be provided.
 •    There is also an option ‘Not registered Yet? Sign Up’. Upon clicking Sign Up, the User will be directed to the Sign Up page.
 •    Google login special case - In case of Google login, the list of all the Google accounts that are currently synced with the handset are shown. If the User’s desired account is not in the Synced Account list of the device, the User will first need to use the ‘Add another account’ option on the Google login screen. After the User enters the correct credentials of the required Google account, the account will get added in the synced Google accounts list of that device. The User will be directed to the Google login screen again, and then the User can select the desired Google account from the list to login.
 •    If a banned user tries to login, then a toast message will be shown to the User “Your account has been blocked”.
 */
import SQLite
import AuthenticationServices
import SwiftMessages
//import EFInternetIndicator
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Google
import GoogleSignIn
import LinkedinSwift
import ActionSheetPicker_3_0
import Toast_Swift
import Firebase
import CoreLocation
import Firebase
import ANLoader
import Localize_Swift
import Messages
import ContactsUI
import Contacts
import MessageUI
//this extension is used to change partial color of text
extension NSMutableAttributedString{
    func setColorForText1(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    // ASAuthorizationControllerDelegate function for authorization failed
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        print(error.localizedDescription)
        
    }
    
    // ASAuthorizationControllerDelegate function for successful authorization
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Create an account as per your requirement
            
            let appleId = appleIDCredential.user ?? "0"
            
            let appleUserFirstName = appleIDCredential.fullName?.givenName ?? ""
            
            let appleUserLastName = appleIDCredential.fullName?.familyName ?? ""
            
            let appleUserEmail = appleIDCredential.email ?? ""
            
            //Write your code
            print(appleId)
            //  print(appleUserFirstName!)
            print(appleUserLastName)
            print(appleUserEmail)
               self.defaults.set(appleId, forKey: "appleId")
            
            //Create login records in sqlite and save apple information on first login time
            GlobalClass.sharedInstance.openDb()
            GlobalClass.sharedInstance.createAppleLoginTable()
            let insertUser = Constant.AppleLoginTable.insert(Constant.appleid <- appleId, Constant.firstname <- appleUserFirstName, Constant.lastname <- appleUserLastName,Constant.email <- appleUserEmail)
                                  do {
                                      try Constant.database.run(insertUser)
                                      print("INSERTED USER")
                                  } catch {
                                      print(error)
                                  }
            //fetch apple login information from sqlite and send to API so data is save everytime
            
            do {
                  let users = try Constant.database.prepare(Constant.AppleLoginTable)
                  for user in users {
                        var name = user[Constant.firstname]
                        var lname = user[Constant.lastname]
                        var email = user[Constant.email]
 DispatchQueue.main.async {
                
                self.socialLogin(Fname: name, Lname: lname, Email: email, Login_Type: "li")
            }
                      
                  }
              } catch {
                  //print(error)
              }
            
            
           
        
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            
            let appleUsername = passwordCredential.user
            
            let applePassword = passwordCredential.password
            
            //Write your code
            
            print(appleUsername)
            print(applePassword)
            
        }
        
    }
    
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    //For present window
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return self.view.window!
        
    }
    
}

//main class with delegates defined
class LoginViewController: UIViewController , GIDSignInUIDelegate, GIDSignInDelegate,CLLocationManagerDelegate,MFMessageComposeViewControllerDelegate,UITextFieldDelegate {
    @IBOutlet weak var loginLogo: UIImageView!
    
     //var internetConnectionIndicator:InternetViewIndicator?
    //this function responsible to send a text msg in SOS functionality
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SOSs")
        self.present(nextViewController, animated:true, completion:nil)
        //we are setting value of backpress in userdefault to identify the controller/navigation where comes from
        UserDefaults.standard.set("BackPress", forKey: "Key") //setObject
    }
    //FRhyperlabel library is used for partial label link like terms and privacy link in whole text
    @IBOutlet weak var termsLbl: FRHyperLabel!
    @IBOutlet weak var privacyLink: FRHyperLabel!
    @IBOutlet weak var forgotPasswordLink: FRHyperLabel!
    @IBOutlet weak var signUpLink: FRHyperLabel!
    var thirdNo = ""
    var secondNo = ""
    var firstNo = ""
    var callFlag = false
    var messageFlag = false
    var addressLocation = ""
    @IBOutlet weak var sosLbl: UILabel!
   
    //MARK: - Properties
    var switchFlag = ""
    let defaults = UserDefaults.standard
    var togglePwd : Bool!
    var fname = "",lname = "",email = "",countryId = ""
    var locManager = CLLocationManager()
    var latitude = "" , longitude = ""
    let locationManager = CLLocationManager()
    @IBOutlet  var outletEmailTxt: UITextField!
    @IBOutlet  var outletPaswordTxt: UITextField!
    @IBOutlet  var outletChangePwdBtn: UIButton!
    //Outlets for localization
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var orLoginWith: UILabel!
    @IBOutlet weak var sosBtn: UIButton!
    @IBOutlet weak var loginLbl: UILabel!
  //Social login helper variables
    let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    var plistHelepr = PlistManagment()
    let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: Constant.linkedinClientID, clientSecret: Constant.linkedinClientSecret, state: "DLKDJF46ikMMZADfdfds", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: "http://www.kshantechsoft.com/"))
    var actionSheet: UIAlertController!
    let availableLanguages = Localize.availableLanguages()
    
    override func viewDidAppear(_ animated: Bool) {
       // 
        loginBtn.layer.cornerRadius = 5
        sosBtn.backgroundColor = .clear
        sosBtn.layer.cornerRadius = self.sosBtn.frame.height/2
        sosBtn.layer.borderColor = UIColor.white.cgColor
        outletPaswordTxt.delegate = self
        //get user current location
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        //End of location declaration
        
        //To get SOS contact information from PLIST file first as we have to validate if number is present or not.
        let firstContact = plistHelepr.readPlist(namePlist: "Options", key: "firstcontact") as? String
        let secondContact = plistHelepr.readPlist(namePlist: "Options", key: "secondcontact") as? String
        let first = firstContact!.trimmingCharacters(in: .whitespaces)
        let second = secondContact!.trimmingCharacters(in: .whitespaces)
        //Here we are validating if number is present or not in plist
        if(first.count > 1){
            //print("Number present")
        }
        else{
            //print("Number not prsent")
            
        }
      
        //here we give link to part of label .
        // full text is "By logging in, you agree to our Terms and Conditions" and we have to give link to "Terms and Conditions"
        //we can do using following snippet
          //Depending on text we are redirecting to linked page
        //Step 1: Define a normal attributed string for non-link texts
        let string = "By logging in, you agree to our Terms and Conditions"
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                           NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 13.0)!]
        termsLbl.attributedText = NSAttributedString(string: string, attributes: attributes)
        //Step 2: Define a selection handler block
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            let controller = UIAlertController(title: substring, message: nil, preferredStyle: UIAlertControllerStyle.alert)
            controller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
          //  self.present(controller, animated: true, completion: nil)
            //print(substring!)
           
            if(substring! == "Terms and Conditions"){
                 DispatchQueue.main.async {

                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "terms")
                    UserDefaults.standard.set("terms", forKey: "view") //setObject
                      UserDefaults.standard.set("login", forKey: "back")
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            }
        }
        //Step 3: Add link substrings
        termsLbl.setLinksForSubstrings(["Terms and Conditions"], withLinkHandler: handler)
        //End of snippet for "Terms and Conditions"
        
        //here we give link to part of label .
        //full text is "Not registered yet? Sign Up" and we have to give link to "Sign Up"
        //we can do using following snippet
        //Depending on text we are redirecting to linked page
        //Step 1: Define a normal attributed string for non-link texts
        let string1 = "Not registered yet? Sign Up"
        let attributes1 = [NSAttributedStringKey.foregroundColor: UIColor.white,
                          NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 13.0)!]
        signUpLink.attributedText = NSAttributedString(string: string1, attributes: attributes1)
        //Step 2: Define a selection handler block
        let handler1 = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            //print(substring!)
            if(substring! == "Sign Up"){
                DispatchQueue.main.async {
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "signUp")
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            }
            
        }
        //Step 3: Add link substrings
        signUpLink.setLinksForSubstrings(["Sign Up"], withLinkHandler: handler1)
         //End of snippet for "Sign Up"
        
        //here we give link to part of label .
        //full text is "Forgot Password?"
        //we can do using following snippet
        //Depending on text we are redirecting to linked page
        //Step 1: Define a normal attributed string for non-link texts if any.
        let string2 = "Forgot Password?"
        //print(string2)
        let attributes2 = [NSAttributedStringKey.foregroundColor: UIColor.white,
                           NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 13.0)!]
        forgotPasswordLink.attributedText = NSAttributedString(string: string2, attributes: attributes2)
        //Step 2: Define a selection handler block
        let handler2 = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            if(substring! == "Forgot Password?"){
                DispatchQueue.main.async {
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "forgot")
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
              
            }
        }
        //Step 3: Add link substrings
        forgotPasswordLink.setLinksForSubstrings(["Forgot Password?","पासवर्ड भूल गए?"], withLinkHandler: handler2)
        //End of snippet "Forgot password"
        
        //here we give link to part of label .
        //full text is "and Privacy Policy."
        //we can do using following snippet
        //Depending on text we are redirecting to linked page
        //Step 1: Define a normal attributed string for non-link texts
        let string4 = "and Privacy Policy."
        let attributes4 = [NSAttributedStringKey.foregroundColor: UIColor.white,
                          NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 13.0)!]
        privacyLink.attributedText = NSAttributedString(string: string4, attributes: attributes4)
        //Step 2: Define a selection handler block
        let handler4 = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            let controller = UIAlertController(title: substring, message: nil, preferredStyle: UIAlertControllerStyle.alert)
            controller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            //  self.present(controller, animated: true, completion: nil)
            //print(substring!)
            if(substring! == "Privacy Policy."){
                DispatchQueue.main.async {
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "terms")
                    //  viewController.screenType = "privacy"
                     UserDefaults.standard.set("login", forKey: "back")
                    UserDefaults.standard.set("privacy", forKey: "view") //setObject
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            }
        }
        //Step 3: Add link substrings
        privacyLink.setLinksForSubstrings(["Privacy Policy."], withLinkHandler: handler4)
//End of snippet "and privacy policy."
    }
    //toggle between show hide password button first time/input time
    @objc func passwordFieldDidChange(_ textField: UITextField) {
        if(outletPaswordTxt.text?.count == 0){outletChangePwdBtn.isHidden = true}else{outletChangePwdBtn.isHidden = false}
        
    }
    //MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
//self.startMonitoringInternet()
    
        //to add bottom border
       // self.loginLbl.addBottomBorder(UIColor.white, height: 1)
        self.outletEmailTxt.addBottomBorder(UIColor.orange, height: 1)
        self.outletPaswordTxt.addBottomBorder(UIColor.orange, height: 1)
        //declare delegates to textfeild
        self.outletEmailTxt.delegate = self
        self.outletPaswordTxt.delegate = self
        //self.outletEmailTxt.becomeFirstResponder()
        //declare placeholder and define color of placholder
        self.outletEmailTxt.attributedPlaceholder = NSAttributedString(string: "Email",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        self.outletPaswordTxt.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        self.outletEmailTxt.attributedPlaceholder = NSAttributedString(string: "ईमेल",
                                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        self.outletPaswordTxt.attributedPlaceholder = NSAttributedString(string: "पासवर्ड",
                                                                         attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        //detect text change in password textfeild
        outletPaswordTxt.addTarget(self, action: #selector(passwordFieldDidChange(_:)), for: .editingChanged)
        //end detection
        //first time hide the password show button
          outletChangePwdBtn.isHidden = true
        //check network avilability
        let network = NetworkManager.sharedInstance
        // if avilable then execute code in normal way
        // if network is not avilable then show proper toast message
        network.reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.view.hideAllToasts()
                self.view.makeToast(Validation.ERROR.localized())
                ////print("nbuibubu")
           //    self.loginLogo.image = UIImage(named: "2")
            }
        }
        //End of network detection
        //error object
        var error : NSError?
        togglePwd = true
        //setting the error
        GGLContext.sharedInstance().configureWithError(&error)
        //if any error stop execution and ////print error
        if error != nil{
            //print(error ?? "google error")
            return
        }
        //Get user current location
        self.findCurrentLocation()
        //adding the delegates for G+ signin
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    //This button will show diffrent types of local language in application
    //for iPhone it shows picker which is default in iOS
    //it shows chinese/english/hindi language
    @IBAction func changeBtnPress(_ sender: UIButton) {
        actionSheet = UIAlertController(title: nil, message: "Select Language", preferredStyle: UIAlertControllerStyle.actionSheet)
        for language in availableLanguages {
            let displayName = Localize.displayNameForLanguage(language)
            let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
               Localize.setCurrentLanguage(language)
                //print(language)
                UserDefaults.standard.set(language, forKey: "language")
                 UserDefaults.standard.set("settingchange", forKey: "setting")
            })
            actionSheet.addAction(languageAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        //For iphone and ipad we have to show picker in diffrant manner otherwise app will crash
        //so we are deciding either device is iphone or ipad
        //depending on code will execute and shows the picker
        if Device.IS_IPHONE {
            self.present(actionSheet, animated: true, completion: nil)
        }
        else{
            actionSheet.popoverPresentationController!.sourceView = self.view
            actionSheet.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width/2 , y: self.view.bounds.size.height/7, width: 1.0, height: 1.0)
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    // to go inside SOS functionality from login page
    // again we are setting some session value for back to validate the navigation.
    // if sos button is pressed from login screen then it will back to login page from sos screen when back button press
    @IBAction func SosBtnPress(_ sender: Any) {
        //we are using this to run snippet on background thread
        DispatchQueue.main.async {
               UserDefaults.standard.set("login", forKey: "BackPress")
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SOSs")
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
       
        super.viewWillAppear(animated)
  
        //to call localization we are using settext function
     self.setText()
   // notificationcenter receive the broadcast msg if any language is changes from application login/setting menu
        //whatever language is selected depend on that language it fire settext()
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    //using this we can get an user device token received from FCM
        self.getDeviceToken()
        //on every launch time we are chking the user status if user has account or his/her account has been blovked
        if GlobalClass.sharedInstance.blockStatus{
            self.view.hideAllToasts()
            self.view.makeToast("Your account has been blocked.".localized())
        }
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    // MARK: Localized Text
    @objc func setText(){
        loginLbl.text = "Login".localized();
        orLoginWith.text = "OR LOGIN WITH".localized();
        outletEmailTxt.placeholder = "Email".localized();
        outletPaswordTxt.placeholder = "Password".localized();
        loginBtn.setTitle("Login".localized(using: "Localizable"), for: UIControlState.normal)
      //  termsLbl.text = "By logging in, you agree to our Terms and Conditions".localized()
       // privacyLink.text = "and Privacy Policy.".localized()
        //signUpLink.text = "Not registered yet? Sign up".localized()
      //  forgotPasswordLink.text = "Forgot Password?"
    }
    //when we are redirect to new vew or view disappear from screen
    //following block execute
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        ANLoader.hide()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    //MARK: - Social login common method to Save user data on server
    func socialLogin(Fname : String, Lname : String, Email : String, Login_Type : String){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized().localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.social_signup
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString  = String(format: "Fname=%@&Lname=%@&Email=%@&Device_ID=%@&Login_Type=%@&Device_Type=IOS", Fname, Lname, Email,self.getDeviceToken(),Login_Type)
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
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj)
                if let jsonDict = jsonObj {
                    if let checkstatus = jsonDict["checkstatus"] as? NSDictionary {
                        if let status = checkstatus["status"] as? String {
                            if(status.isEqual("1")){
                                if let count = checkstatus["count"] as? String {
                                    let User_ID = checkstatus["user_id"] as? Int
                                    self.defaults.set("Social", forKey: "Login_Type")
                                    self.defaults.set(Fname, forKey: "Fname")
                                    self.defaults.set(Lname, forKey: "Lname")
                                    self.defaults.set(String(format:"%d",User_ID!), forKey: "User_ID")
                                    self.defaults.set(Email, forKey: "Email")
                                    self.defaults.set(10.0, forKey: "DEED_RADIUS")
                                    self.defaults.set(false, forKey: "FILTERSTATUS")
                                    if(count.isEqual("0")){
                                        DispatchQueue.main.async {
                                            self.defaults.set("Public", forKey: "PRIVACY")
                                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "FirstLoginViewController")
                                            self.defaults.set("social", forKey: "FISRTSCREEN")
                                            UIApplication.shared.keyWindow?.rootViewController = viewController
                                        }
                                    }
                                    else{
                                        DispatchQueue.main.async {
                                            self.defaults.set(checkstatus.value(forKey:"Privacy") as! String, forKey: "PRIVACY")
                                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
                                            UIApplication.shared.keyWindow?.rootViewController = viewController
                                        }
                                    }
                                    self.updateLocation(latitude: self.latitude, longitude: self.longitude);
                                }
                            }
                            else{
                                self.view.hideAllToasts()
                                self.view.makeToast(Validation.ERROR.localized())
                                return
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //This is view
     @available(iOS 13.0, *)
    @IBAction func AppleLoginBtnPress(_ sender: ASAuthorizationAppleIDButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
              
              let request = appleIDProvider.createRequest()
              
              request.requestedScopes = [.fullName, .email]
              
              let authorizationController = ASAuthorizationController(authorizationRequests: [request])
              
              authorizationController.delegate = self
              
              authorizationController.presentationContextProvider = self
              
              authorizationController.performRequests()
    }
    //This is button now alpha is 0 i.e hidden
    @available(iOS 13.0, *)
    @IBAction func appleLoginAction(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    //MARK: - FB login
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        fbLoginManager.logOut()
        let cookies = HTTPCookieStorage.shared
        let facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
        for cookie in facebookCookies! {
            cookies.deleteCookie(cookie )
        }
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    
    //Get user data from Facebook
    func getFBUserData(){
        
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works //print the user data
                    
                    self.fname = ((result as AnyObject).value(forKey: "first_name") as? String)!
                    self.lname = ((result as AnyObject).value(forKey: "last_name") as? String)!
                    self.email = ((result as AnyObject).value(forKey: "email") as? String)!
                    
                    self.fbLoginManager.logOut()
                    
                    DispatchQueue.main.async {
                        
                        self.socialLogin(Fname: self.fname, Lname: self.lname, Email: self.email, Login_Type: "fb")
                    }
                }
            })
        }
    }
    //MARK: - End FB login
    
    //MARK: - Google Plus login
    @IBAction func googlePlusAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    //Get user data from Google plus
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let fullName = user.profile.name.components(separatedBy: " ")
            self.fname = fullName[0]
            self.lname = fullName[1]
            self.email = user.profile.email
            DispatchQueue.main.async {
                self.socialLogin(Fname: self.fname, Lname: self.lname, Email: self.email, Login_Type: "gp")
            }
            
        } else {
            //print("\(error.localizedDescription)")
        }
    }
    //MARK: - End Google Plus login
    
    //MARK: - Linkedin login
    @IBAction func linkedAction(_ sender: UIButton) {
        linkedinHelper.authorizeSuccess({ [unowned self] (lsToken) -> Void in
            self.linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url,picture-urls::(original),positions,date-of-birth,phone-numbers,location)?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
                self.fname = response.jsonObject["firstName"]! as! String
                self.lname = response.jsonObject["lastName"]! as! String
                self.email = response.jsonObject["emailAddress"]! as! String
                DispatchQueue.main.async {
                    self.socialLogin(Fname: self.fname, Lname: self.lname, Email: self.email, Login_Type: "li")
                }
            }) {(error) -> Void in
                //print("Encounter error: \(error.localizedDescription)")
            }
            
            }, error: {(error) -> Void in
                
                //print("Encounter error: \(error.localizedDescription)")
        }, cancel: {() -> Void in
            
            //print("User Cancelled!")
        })
    }
    //MARK: - End Linkedin login
    
    //MARK: - Find Current location
    func findCurrentLocation(){
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locManager = CLLocationManager()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locManager.startUpdatingLocation()
        }
    }
    
    //MARK: - CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        guard locations.last != nil else {
            
            return
        }
        
        let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        latitude = String(format:"%f",locationValue.latitude)
        longitude = String(format:"%f",locationValue.longitude)
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        addressLocation =  String(format:"%f,%f", locValue.latitude,locValue.longitude)
        //print(addressLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Error while updating location " + error.localizedDescription)
    }
    
    //Update User current location to server
    func updateLocation(latitude : String, longitude : String) {
        
        let radiusVal = String(format:"%d",defaults.value(forKey: "DEED_RADIUS") as! Int)
        
        let urlString = Constant.BASE_URL + Constant.update_location
        let url:NSURL = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        
        let paramString = String(format: "user_id=%@&device_id=%@&lat=%@&lng=%@&radius=%@",userId,self.getDeviceToken(),latitude,longitude,radiusVal)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request as URLRequest)
        task.resume()
    }
    
    
    @IBAction func passwordToggleBtnPress(_ sender: UIButton) {
        //print(togglePwd)
        if (outletPaswordTxt.text?.isEmpty)!{
            return;
        }
        if(togglePwd == true) {
            // outletChangePwdBtn.setTitle( "Hide" , for: .normal )
            outletChangePwdBtn.setImage(UIImage(named:"show_pass"), for: .normal)
            outletPaswordTxt.isSecureTextEntry = false
            togglePwd = false
        } else {
            outletChangePwdBtn.setImage(UIImage(named:"Hide_pass"), for: .normal)
            // outletChangePwdBtn.setTitle( "Show" , for: .normal )
            outletPaswordTxt.isSecureTextEntry = true
            togglePwd = true
        }
    }
    
  
    
    //Get device token
    func getDeviceToken()->String{
        
        let refreshedToken = GlobalClass.sharedInstance.nullToNil(value: FIRInstanceID.instanceID().token() as AnyObject)
        UserDefaults.standard.setValue(refreshedToken, forKey: "FCMTOEKN")
        return refreshedToken as! String
    }
    
    //App Login Action
    @IBAction func loginAction(_ sender: UIButton) {
        
        self.view.endEditing(true)
        let email = outletEmailTxt.text
        let password = outletPaswordTxt.text
        
        if Validation.sharedInstance.isValidEmail(Email: email!){
            
        }else{
            
            self.view.hideAllToasts()
            self.view.makeToast(Validation.validLoginEmail.localized())
            return
        }
        
        if password?.count != 0 {
            
            
        }else{
            
            self.view.hideAllToasts()
            self.view.makeToast("Please enter password".localized())
            return
        }
        
        outletEmailTxt.text = ""
        outletPaswordTxt.text = ""
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized().localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.login
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let paramString = String(format: "Email=%@&Password=%@&Device_Type=IOS&Device_ID=%@",email!,password!.addingPercentEncoding(withAllowedCharacters: charset as CharacterSet)!, self.getDeviceToken())
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            
            
            
            if let data = data {
                
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
                
                DispatchQueue.main.async{
                    
                    self.outletEmailTxt.text = email!
                    self.outletPaswordTxt.text = password!
                }
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    
                    if let infoArray = jsonObj!.value(forKey: "checkstatus") as? NSArray {
                        
                        for user in infoArray{
                            
                            let infoDict = user as? NSDictionary
                            let statusVal = (infoDict!["status"] as! NSString).doubleValue
                            
                            if(statusVal==1){
                                
                                let count = infoDict?.value(forKey:"count") as! String
                                
                                self.defaults.set("App", forKey: "Login_Type")
                                self.defaults.set(infoDict?.value(forKey:"Fname") as! String, forKey: "Fname")
                                self.defaults.set(infoDict?.value(forKey:"Lname") as! String, forKey: "Lname")
                                self.defaults.set(infoDict?.value(forKey:"User_ID") as! String, forKey: "User_ID")
                                self.defaults.set(infoDict?.value(forKey:"Country_ID") as! String, forKey: "Country_ID")
                                self.defaults.set(infoDict?.value(forKey:"Privacy") as! String, forKey: "PRIVACY")
                                self.defaults.set(email!, forKey: "Email")
                                self.defaults.set(10.0, forKey: "DEED_RADIUS")
                                self.defaults.set(false, forKey: "FILTERSTATUS")
                                
                                if count.isEqual("0") {
                                    
                                    DispatchQueue.main.async {
                                        
                                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "FirstLoginViewController")
                                        self.defaults.set("normal", forKey: "FISRTSCREEN")
                                        UIApplication.shared.keyWindow?.rootViewController = viewController
                                    }
                                }else{
                                    
                                    DispatchQueue.main.async {
                                        
                                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
                                        UIApplication.shared.keyWindow?.rootViewController = viewController
                                    }
                                }
                                
                                self.updateLocation(latitude: self.latitude, longitude: self.longitude);
                            }
                            else if(statusVal==2){
                                
                                DispatchQueue.main.async{
                      
                                    let msg1 = "A Registration Completion Link has been sent to".localized()
                                    let msg2 = "You can set your password using that link.Please check your promotions,social,spam or junk mails folders.Depending on your email preference settings,email from admin@giftadeed.com may end up in diffrent folders.".localized()
                                    
                                    let message = String(format:"\(msg1) %@. \(msg2)",email!)
                                   
                                    let optionMenu = UIAlertController(title: "", message: message, preferredStyle: .alert)
                                    
                                    let okAction = UIAlertAction(title: "Ok".localized(), style: .default, handler:
                                    {
                                        (alert: UIAlertAction!) -> Void in
                                        
                                    })
                                    
                                    let resendAction = UIAlertAction(title: "Resend link".localized(), style: .destructive, handler:
                                    {
                                        (alert: UIAlertAction!) -> Void in
                                        
                                        self.resend_link(email: email!)
                                    })
                                    
                                    optionMenu.addAction(okAction)
                                    optionMenu.addAction(resendAction)
                                    self.present(optionMenu, animated: true, completion: nil)
                                }
                            }
                            else if(statusVal==3){
                                
                                DispatchQueue.main.async {
                                    
                                    self.view.hideAllToasts()
                                    self.view.makeToast("Your account has been terminated. Contact organisation admin".localized())
                                    return
                                }
                            }
                            else if(statusVal==4){
                                
                                DispatchQueue.main.async {
                                    
                                    self.view.hideAllToasts()
                                    self.view.makeToast("Wrong Password".localized())
                                    return
                                }
                            }
                            else if(statusVal==0){
                                
                                DispatchQueue.main.async {
                                    
                                    self.view.hideAllToasts()
                                    self.view.makeToast(Validation.validRegisterEmail.localized())
                                    return
                                }
                            }
                            else {
                                
                                DispatchQueue.main.async {
                                    
                                    self.view.hideAllToasts()
                                    self.view.makeToast(Validation.validUser.localized())
                                    return
                                }
                            }
                        }
                    }
                }
                
            } else if let error = error {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
                DispatchQueue.main.async {
                    
                    self.navigationController?.view.hideAllToasts()
                    self.view.makeToast("Something went wrong, Please try again.".localized())
                }
                return
            } else {
                
                // no data and no error... what happened???
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
                DispatchQueue.main.async {
                    
                    self.navigationController?.view.hideAllToasts()
                    self.view.makeToast("Something went wrong, Please try again.".localized())
                }
                return
            }
        }
        
        task.resume()
    }
    
    //Resend app verification link to Users mail
    func resend_link( email : String){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized().localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.resend_link
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "email=%@", email)
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let statusVal = (jsonObj!["status"] as! NSString).doubleValue
                if(statusVal==1){
                    
                    DispatchQueue.main.async {
                        
                        self.view.hideAllToasts()
                        self.view.makeToast(Validation.checkPass.localized())
                        return
                    }
                }
                else{
                    
                    DispatchQueue.main.async {
                        
                        self.view.hideAllToasts()
                        self.view.makeToast(Validation.ERROR.localized())
                        return
                    }
                }
            }
            else{
                
                DispatchQueue.main.async {
                    
                    self.view.makeToast(Validation.NETWORK_ERROR.localized())
                    return
                }
            }
        }
        task.resume()
    }
}
