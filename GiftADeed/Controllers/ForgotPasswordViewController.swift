//
//  ForgotPasswordViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 03/05/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    Upon clicking Forgot Password (Button), a popup should appear with the following message – “Enter registered email”. There should be a text box to enter the email address. There should be a Submit (Button) and Cancel (Button) below that. On clicking Cancel, the popup should close. On clicking Submit, an email with the Current Password will be sent to the registered email address,and a toast message should appear with the following message – “Check your email for password”.
 •
 •    If the User has not completed the registration process by setting the password using the Registration Completion Link, but still tries to use the Forgot Password option using the same email id, then the following popup message should be shown “A Registration Completion Link has already been sent to <Email Id>. Please set your password using that link.” There will be a Resend Link button on the popup. On clicking the Resend Link button, an email with the Registration Completion Link will be sent again to the Users email id.
 •    If the User has been using Social Media to use the app and has never used the app login before, but still tries to use the forgot password option using the same email id, then the following happens – A random password with the required validations is generated at the backend and stored in the database. This password is then sent to the User through email on the email id. A toast message will appear with the following message - “Check your email for password”.
*/
import EFInternetIndicator
import UIKit
import ANLoader
import Localize_Swift

class ForgotPasswordViewController: UIViewController,InternetStatusIndicable {
   var internetConnectionIndicator:InternetViewIndicator?

    @IBOutlet weak var forgotPasswordLbl: UILabel!
    @IBOutlet var outletEmail: FloatLabelTextField!
    @IBOutlet var outletForgotView: UIView!
  
    @IBOutlet weak var cancelBTn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        setText()
        
self.navigationController?.setNavigationBarHidden(true, animated: true)
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            ANLoader.hide()
        }
    }
    @objc func setText(){
        outletEmail.placeholder = "Email".localized();
        forgotPasswordLbl.text = "Forgot Password?".localized();
        submitBtn.setTitle("Submit".localized(using: "Localizable"), for: UIControlState.normal)
        cancelBTn.setTitle("Cancel".localized(using: "Localizable"), for: UIControlState.normal)
    }
    //MARK:- Forgot password API call
    @IBAction func submitAction(_ sender: Any) {
        
        self.view.endEditing(true)
        let email = outletEmail.text

        if Validation.sharedInstance.isValidEmail(Email: email!){
            
        }else{
            
            self.outletForgotView.hideAllToasts()
            self.outletForgotView.makeToast(Validation.validLoginEmail)
            return
        }
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.forgot_password
        
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
                    
                    self.outletForgotView.hideAllToasts()
                    self.outletForgotView.makeToast(Validation.ERROR.localized())
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
                    
                if let infoArray = jsonObj!.value(forKey: "checkstatus") as? NSArray {
                    
                    for info in infoArray{
                        
                        let infoDict = info as? NSDictionary
                        let statusVal = (infoDict!["status"] as! NSString).doubleValue
                        
                        if(statusVal==1){
                            DispatchQueue.main.async{
                                self.outletForgotView.hideAllToasts()
                                self.outletForgotView.makeToast(Validation.checkPass)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                            }
                            return
                        }
                        else if(statusVal==2){

                            DispatchQueue.main.async{
//                                      let message = String(format:"A Registration Completion Link has been sent to %@. You can set your password using that link.Please check your promotions,social,spam or junk mails folders.Depending on your email preference settings,email from admin@giftadeed.com may end up in diffrent folders.",email!)
                                let msg1 = "A Registration Completion Link has been sent to".localized()
                                let msg2 = "You can set your password using that link.Please check your promotions,social,spam or junk mails folders.Depending on your email preference settings,email from admin@giftadeed.com may end up in diffrent folders.".localized()
                                
                                let message = String(format:"\(msg1) %@. \(msg2)",email!)
                                self.outletForgotView.hideAllToasts()
                                //A registration completion link has been sent to " + email + ". Please set your password using that link.
                                // Create the alert controller
                                //"A registration completion link has been sent to \(email!). Please set your password using that link."
                                let alertController = UIAlertController(title: "Verify Email".localized(), message:message , preferredStyle: .alert)
                                
                                // Create the actions
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    NSLog("OK Pressed")
                                    alertController.dismiss(animated: true, completion: nil)
                                }
                               self.outletEmail.text = ""
                                // Add the actions
                                alertController.addAction(okAction)
                               
                                // Present the controller
                                self.present(alertController, animated: true, completion: nil)
                                self.outletForgotView.makeToast("Check your email for password.".localized())
                                return
                            }

                        }
                     
                        else{
                            
                            DispatchQueue.main.async{
                           
                                self.outletForgotView.hideAllToasts()
                                self.outletForgotView.makeToast("Email id not found,User not registered with GAD.".localized())
                                return
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    //Cancel button Action
    @IBAction func cancelAction(_ sender: Any) {
        DispatchQueue.main.async {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
//self.navigationController?.popViewController(animated: true)
    }
}
