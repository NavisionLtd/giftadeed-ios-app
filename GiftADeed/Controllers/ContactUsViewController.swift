//
//  ContactUsViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 09/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    This page will have the contact details of the Admin/App owner.
 •    The page will have the following contents : “You can contact us on – admin@navisionltd.com or you can directly send a message to the admin using the following text box.” There will be a text box with aSend button below it. Clicking on admin@navisionltd.com will open the email app of the phone with the ‘To’ field prepopulated as “admin@navisionltd.com”, and Subject prepopulated as “Contacting Gift-a-Deed”.
 •    On the Contact Us page, the Users can type a message (max. 500 chars) in the message box which will send an internal message to the admin (which can be seen from admin panel), and it will also send an email to admin@navisionltd.com with the respective message. After successfully sending a message, a success message will be shown.
 •    For the Time being, the following Email template can be used - Subject line - <User First Name and Last Name> has sent a message.  Email body - <User First Name and Last Name> , <(User email, User ID)> has sent the following message using the Contact Us form in the Gift-a-Deed app on <Server Date>, at <Server Time HH:MM AM/PM>-  <Actual message content>
 */
import UIKit
import ANLoader
import Localize_Swift
import EFInternetIndicator
class ContactUsViewController: UIViewController,UITextFieldDelegate,InternetStatusIndicable {
    var internetConnectionIndicator:InternetViewIndicator?
    

    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var contactUsDircetLbl: UILabel!
    @IBOutlet weak var orLbl: UILabel!
    @IBOutlet weak var mailIdLbl: UILabel!
    @IBOutlet weak var contactUsLbl: UILabel!
    @IBOutlet weak var menuContactTitle: UINavigationItem!
    @IBOutlet var outletContactUsView: UIView!
    @IBOutlet  var outletContactTxt: UITextView!
    let defaults = UserDefaults.standard
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
setText()
        
        // Do any additional setup after loading the view.
        userId = defaults.value(forKey: "User_ID") as! String

    }
    func setText(){
        menuContactTitle.title = "Contact Us".localized()
        contactUsLbl.text = "You can contact us on -".localized()
        mailIdLbl.text = "admin@navisionltd.com".localized()
   orLbl.text = "OR".localized()
        contactUsDircetLbl.text = "Contact us directly".localized()
        self.sendBtn .setTitle("SEND".localized(), for:UIControlState.normal)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ANLoader.hide()
    }
    
    @IBAction func menuBarAction(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "aboutUs") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }

    //MARK:- Send contact us message to admin
    @IBAction func sendAction(_ sender: Any) {
        
        outletContactTxt.resignFirstResponder()
        
        let message = outletContactTxt.text
        
        if message!.count == 0 {
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Enter Message".localized())
            return
        }
        
        outletContactTxt.text = ""
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.contact_us
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "userId=%@&message=%@", userId, message!)
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
                        
                        GlobalClass.sharedInstance.blockStatus = true
                    }
                    return
                }
                
                let status = jsonObj?.value(forKey:"status") as? Int
                
                if status==1{
                    
                    DispatchQueue.main.async{
                        
                        self.outletContactUsView.hideAllToasts()
                        self.outletContactUsView.makeToast("Message sent successfully".localized())
                    }
                }
            }
            
        }
        task.resume()
    }
}
