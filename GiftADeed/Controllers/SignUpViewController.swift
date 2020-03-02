//
//  SignUpViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 04/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

//GiftADeed(318,0x1943a000) malloc: *** error for object 0x166b0730: double free
//*** set a breakpoint in malloc_error_break to debug

/*
 •    The registration process is divided into 2 stages.
 •    In the first stage of registration, the User needs to enter his First Name, Last Name, Email ID, and country.
 •    The user should be able to enter First Name. This is a mandatory field.
 •    The user should be able to enter Last Name. This is not a mandatory field.
 •    The user should be able to enter Email ID. At the time of focus moving away from this field, the system should check if the email address entered by the user already exists. If it does, then appropriate message should be displayed in a pop up and user should not be able to register unless a unique email address is entered. This is a mandatory field.
 •    The user should be able to select a Country they reside in. This is a mandatory field.
 •    The User must agree to the Terms and Conditions by checking the checkbox. Upon clicking on Terms and Conditions, the User must be directed to the Terms and Conditions page.
 •    The user should be able to click the “Sign up” button.
 •    Clicking the Sign Up buttonwill send a Complete Your Registration email to the email address entered. This is the second stage of registration. A popup will be displayed with the following message “A Registration Completion Link has been sent to <Email Id>. Please set your password using that link.” In phase 2, there will be a Resend Link button on the popup. On clicking the Resend Link button, an email with the Registration Completion Link will be sent again to the Users email id.
 •    The email will contain a link to complete the registration process (i.e. set password).
 •    On clicking the link, the User will be directed to a new browser instance (i.e new tab) from where he/she can continue with the registration process. The new page will contain the password entry and confirm password.
 •
 •    The user should be able to enter a password. This is a mandatory field. Password should be minimum 8 characters and maximum 20 characters. Should contain at least one number, one special character out of !@#$%^&*()and one alphabet (a-z, A-Z). There should be in ‘i’ button at the right, which when clicked upon will show the password rules/validations in a popup.
 •    The User should be able to confirm the password entered above. This is a mandatory field.
 •    Below that there will be ‘Activate Your Account’ button. After clicking ‘Activate Your Account’, a new page will open with the following message – “Your account has been successfully created. You can start using the app. Your profile is public, if you want to make it private, please go to My Profile”.
 •    After an Account has been successfully created, the User should get a mail regarding the same.
*/

import Localize_Swift
import UIKit
import ActionSheetPicker_3_0
import ANLoader
import EFInternetIndicator
class SignUpViewController: UIViewController,UITextFieldDelegate,InternetStatusIndicable {
   var internetConnectionIndicator:InternetViewIndicator?
  let availableLanguages = Localize.availableLanguages()
    var setLanguage = ""
    @IBOutlet var outletFirstNameTxt: UITextField!
    @IBOutlet var outletLastNameTxt: UITextField!
    @IBOutlet var outletEmailTxt: UITextField!
    @IBOutlet var outletCountryTxt: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signLbl: UILabel!
    @IBOutlet weak var haveAccountLbl: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var andLbl: UILabel!
    var countryDataArr = NSMutableArray()
    var countryNameArr = NSMutableArray()
    var countryID = ""
    var autoCompleteCharacterCount = 0
    let regularFont = UIFont.systemFont(ofSize: 16)
    let boldFont = UIFont.boldSystemFont(ofSize: 16)
    @IBOutlet weak var loginLink: FRHyperLabel!
    @IBOutlet weak var privacyLink: FRHyperLabel!
    @IBOutlet weak var termsLbl: FRHyperLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
      setText()
        self.startMonitoringInternet()
          signUpBtn.layer.cornerRadius = 5
        
        self.outletEmailTxt.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                           attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                    self.outletFirstNameTxt.attributedPlaceholder = NSAttributedString(string: "First Name",
                                                                                   attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
             self.outletLastNameTxt.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
             self.outletCountryTxt.attributedPlaceholder = NSAttributedString(string: "Country",
                                                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
             
        
        // self.signLbl.addBottomBorder(UIColor.white, height: 1)
    outletFirstNameTxt.addBottomBorder(UIColor.orange, height: 1)
        outletLastNameTxt.addBottomBorder(UIColor.orange, height: 1)
        outletEmailTxt.addBottomBorder(UIColor.orange, height: 1)
        outletCountryTxt.addBottomBorder(UIColor.orange, height: 1)
        outletFirstNameTxt.delegate = self
        outletEmailTxt.delegate = self
        //here we give link to part of label .
        // full text is "By logging in, you agree to our Terms and Conditions" and we have to give link to "Terms and Conditions"
        //we can do using following snippet
        //Depending on text we are redirecting to linked page
        //Step 1: Define a normal attributed string for non-link texts
        let string = "By Signing up, you agree to our Terms and Conditions"
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
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            }
        }
        //Step 3: Add link substrings
        termsLbl.setLinksForSubstrings(["Terms and Conditions"], withLinkHandler: handler)
        //End of snippet for "Terms and Conditions"
        
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
                    UserDefaults.standard.set("privacy", forKey: "view") //setObject
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            }
        }
        //Step 3: Add link substrings
        privacyLink.setLinksForSubstrings(["Privacy Policy."], withLinkHandler: handler4)
        //End of snippet "and privacy policy."
        
        
        //here we give link to part of label .
        //full text is "Not registered yet? Sign Up" and we have to give link to "Sign Up"
        //we can do using following snippet
        //Depending on text we are redirecting to linked page
        //Step 1: Define a normal attributed string for non-link texts
        let string1 = "Already have an account? Login"
        let attributes1 = [NSAttributedStringKey.foregroundColor: UIColor.white,
                           NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 13.0)!]
        loginLink.attributedText = NSAttributedString(string: string1, attributes: attributes1)
        //Step 2: Define a selection handler block
        let handler1 = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            //print(substring!)
            if(substring! == "Login"){
                DispatchQueue.main.async {
//                    let terms = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//                    self.navigationController?.pushViewController(terms, animated: true)
                                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            }
            
        }
        //Step 3: Add link substrings
        loginLink.setLinksForSubstrings(["Login"], withLinkHandler: handler1)
        //End of snippet for "Sign Up"
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     

// Call observer to detct change in language
       
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)
   
        DispatchQueue.main.async {
            
            self.downloadCountryData();
        }
        
        let network = NetworkManager.sharedInstance
        network.reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.view.hideAllToasts()
                self.view.makeToast(Validation.ERROR.localized())
            }
        }
        
        network.reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.downloadCountryData();
            }
        }
    }
    @objc func setText(){
    
        outletEmailTxt.placeholder = "Email".localized();
        outletFirstNameTxt.placeholder = "First Name".localized();
         outletLastNameTxt.placeholder = "Last Name".localized();
         outletCountryTxt.placeholder = "Country".localized();
        signLbl.text = "Sign up".localized();
         signUpBtn.setTitle("Sign up".localized(using: "Localizable"), for: UIControlState.normal)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            ANLoader.hide()
        }
    }
    
    //MARK: - text field dategate methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //To check email Id already exit or not, this method will call after user editing end
        if outletEmailTxt == textField{
            
            DispatchQueue.main.async {
               
                self.view.endEditing(true)
                self.checkEmailAlready()
            }
        }
        
        //To validate first name, this method will call after user editing end
        if outletFirstNameTxt == textField{
            
            if Validation.sharedInstance.isNameValid(Name: outletFirstNameTxt.text!){
                
            }else{
                
                DispatchQueue.main.async {
                    
                    self.view.endEditing(true)
//                    self.outletSignUpView.hideAllToasts()
//                    self.outletSignUpView.makeToast(Validation.validFirstName)
                }
            }
        }
    }
  
    
    //Select Country
    @IBAction func selectCountry(_ sender: UIButton) {
        
        if self.countryNameArr.count == 0{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast(Validation.NETWORK_ERROR.localized())
            return
        }
        let greenColor = sender.backgroundColor
       
        let greenAppearance = YBTextPickerAppearanceManager.init(
            pickerTitle         : "Select Country".localized(),
            titleFont           : boldFont,
            titleTextColor      : .white,
           titleBackground     : greenColor,
            searchBarFont       : regularFont,
            searchBarPlaceholder: "Search Country".localized(),
            closeButtonTitle    : "Cancel".localized(),
            closeButtonColor    : .darkGray,
            closeButtonFont     : regularFont,
            doneButtonTitle     : "Okay".localized(),
            doneButtonColor     : greenColor,
            doneButtonFont      : boldFont,
            checkMarkPosition   : .Left,
            itemCheckedImage    : UIImage(named:"green_ic_checked"),
            itemUncheckedImage  : UIImage(named:"green_ic_unchecked"),
            itemColor           : .black,
            itemFont            : regularFont
            
        )
        
        let countries = ["India", "Bangladesh", "Sri-Lanka", "Japan", "United States", "United Kingdom", "United Arab Emirates", "Egypt", "France", "Russia", "Poland", "Australia", "New Zealand", "Saudi Arabia", "South Africa", "Somalia", "Turkey", "Ukraine"]
        let picker = YBTextPicker.init(with: self.countryNameArr as! [String], appearance: greenAppearance,
                                       onCompletion: { (selectedIndexes, selectedValues) in
                                        //print("\(selectedIndexes)\(selectedValues)")
                                        if selectedValues.count > 0{
                                           //print(self.countryNameArr)
                                            var values = [String]()
                                            for index in selectedIndexes{
                                        
                                                values.append(self.countryNameArr[index] as! String)
                                            }
                                            
                                        //    self.btnCountyPicker.setTitle(values.joined(separator: ", "), for: .normal)
                                            self.outletCountryTxt.text = values.joined(separator:",")
                                        let item = selectedIndexes[0]
                                            self.countryID = String(item)
                                            //print(self.countryID)
                                        }else{
                                          //  self.btnCountyPicker.setTitle("Select Countries", for: .normal)
                                            self.outletCountryTxt.text = "Select Country".localized()
                                        }
        },
                                       onCancel: {
                                        //print("Cancelled")
        }
        )
        
//        if let title = btnCountyPicker.title(for: .normal){
//            if title.contains(","){
//                picker.preSelectedValues = title.components(separatedBy: ", ")
//            }
//        }
        picker.allowMultipleSelection = false
        
        picker.show(withAnimation: .Fade)
//        ActionSheetStringPicker.show(withTitle: "Select Country", rows: self.countryNameArr as! [String] , initialSelection: 0, doneBlock: {
//            picker, indexe, values in
//
//            self.outletCountryTxt.text = values as? String
//            let item = self.countryDataArr[indexe]
//            self.countryID = (item as AnyObject).value(forKey:"Cntry_ID") as! String
//            return
//        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //Check email already present on server
    func checkEmailAlready (){

        let email = outletEmailTxt.text
        if Validation.sharedInstance.isValidEmail(Email: email!){
            
        }else{
            
            DispatchQueue.main.async {
                
                self.view.endEditing(true)
                self.view.hideAllToasts()
                self.view.makeToast(Validation.validLoginEmail.localized())
                return
            }
        }
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.email_check
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "Email=%@", email!)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    //self.outletSignUpView.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.NETWORK_ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let infoArray = jsonObj!.value(forKey: "checkstatus") as? NSArray {
                    
                    for heroe in infoArray{
                        
                        let infoDict = heroe as? NSDictionary
                        let statusVal = (infoDict!["status"] as! NSString).doubleValue
                 
                        if statusVal == 1{
                            
                            DispatchQueue.main.async {
                                
                                self.view.endEditing(true)
                                self.outletEmailTxt.text = ""
                                self.view.hideAllToasts()
                                self.navigationController?.view.makeToast(Validation.validEmailAlreadyRegister)
                                return
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //Sign up method
    func signUpMethod(){
        
        let firstName = outletFirstNameTxt.text
        let lastName = outletLastNameTxt.text
        let email = outletEmailTxt.text

        if Validation.sharedInstance.isNameValid(Name: firstName!){
            
        }else{
            
            self.view.hideAllToasts()
            self.view.makeToast(Validation.validFirstName.localized())
            return
        }
        
        if lastName!.count != 0{
            
            if Validation.sharedInstance.isLastNAmeValid(Name: lastName!){
                
            }else{
                
                self.view.hideAllToasts()
                self.view.makeToast(Validation.validLastName.localized())
                return
            }
        }
        
        if Validation.sharedInstance.isValidEmail(Email: email!){
            
        }else{
            
            self.view.hideAllToasts()
            self.view.makeToast(Validation.validLoginEmail.localized())
            return
        }
        
        if self.outletCountryTxt.text?.count == 0{
            
            self.view.hideAllToasts()
            self.view.makeToast(Validation.validCountry.localized())
            return
        }
        
        if self.countryID.count == 0{
            
            self.view.hideAllToasts()
            self.view.makeToast(Validation.validCountry.localized())
            return
        }
        
//        if self.switchFlag.isEqual("0"){
//            
//            self.outletSignUpView.hideAllToasts()
//            self.outletSignUpView.makeToast(Validation.validSignUpTermsCondition)
//            return
//        }
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        
        DispatchQueue.main.async {
            
        }
        let urlString = Constant.BASE_URL + Constant.app_signup
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "Fname=%@&Lname=%@&Email=%@&Country_ID=%@&Device_Type=IOS", firstName!, lastName!, email!, self.countryID)
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
                
                if let infoArray = jsonObj!.value(forKey: "checkstatus") as? NSArray {
                    
                    for heroe in infoArray{
                        
                        let infoDict = heroe as? NSDictionary
                        let statusVal = (infoDict!["status"] as! NSString).doubleValue
                        
                        //Status  1 is for successfully register and it will goes to login screen
                        if(statusVal==1){
                            
                             DispatchQueue.main.async {
                                let msg1 = "A Registration Completion Link has been sent to".localized()
                                let msg2 = "You can set your password using that link.Please check your promotions,social,spam or junk mails folders.Depending on your email preference settings,email from admin@giftadeed.com may end up in diffrent folders.".localized()
                                let message = String(format:"\(msg1) %@. \(msg2)",email!)
                                
                                let optionMenu = UIAlertController(title: "Sign up successful!".localized(), message: message, preferredStyle: .alert)
                                
                                let okAction = UIAlertAction(title: "Ok".localized(), style: .default, handler:
                                {
                                    (alert: UIAlertAction!) -> Void in
                                    self.outletEmailTxt.text = ""
                                    self.outletLastNameTxt.text = ""
                                    self.outletCountryTxt.text = ""
                                    self.outletFirstNameTxt.text = ""
                                    DispatchQueue.main.async {
                                        
                                     self.navigationController?.popToRootViewController(animated: true)
                                    }
                                })
                                optionMenu.addAction(okAction)
                            self.present(optionMenu, animated: true, completion: nil)
                            }
                        }
                        else{
                            
                            self.view.hideAllToasts()
                            self.view.makeToast(Validation.ERROR.localized())
                        }
                    }
                }
            }
            else{
                
                //print("Test")
            }
        }
        task.resume()
    }
    
    //Sign up action
    @IBAction func signUpAction(_ sender: Any) {
        
        self.view.endEditing(true)
        self.signUpMethod()
    }

    //Navigate to Login Screen
    @IBAction func loginAction(_ sender: Any) {
   self.navigationController?.popViewController(animated: true)
//        DispatchQueue.main.async {
//
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
//            UIApplication.shared.keyWindow?.rootViewController = viewController
//        }
    }
    
    //Navigate to Terms And Condition Screen
    @IBAction func termsAndConditionAction(_ sender: Any) {
        let terms = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as! TermsAndConditionsViewController
        terms.screenType = "terms"
        self.navigationController?.pushViewController(terms, animated: true)
    }
    
    //Navigate to Privacy Policy Screen
    @IBAction func privacyPolicy(_ sender: Any) {
        let terms = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as! TermsAndConditionsViewController
        self.navigationController?.pushViewController(terms, animated: true)
    }

    //MARK:- Download Country data
    func downloadCountryData (){
        
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
                    self.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                //print(jsonObj!)
                if let taggedlist = jsonObj!.value(forKey: "countrydata") as? NSArray {
                    
                    self.countryNameArr.removeAllObjects()
                    self.countryDataArr.removeAllObjects()
                    
                   
                    for item in taggedlist {
                        
                        do {
                            
                            let countryItem = item as? NSDictionary
                           
                            try self.countryNameArr.add((item as! NSDictionary).value(forKey:"Cntry_Name") as! String)
                         
                            try self.countryDataArr.add(countryItem!)
                            
                        } catch {
                            // Error Handling
                            //print("Some error occured.")
                        }
                        //print(self.countryNameArr)
                    }
                }
            }
            
        }
        task.resume()
    }
}
