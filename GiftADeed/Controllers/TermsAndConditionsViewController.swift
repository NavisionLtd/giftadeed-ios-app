//
//  TermsAndConditionsViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 05/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
//import WebKit
import EFInternetIndicator
class TermsAndConditionsViewController: UIViewController,InternetStatusIndicable {
    var internetConnectionIndicator:InternetViewIndicator?
    

    var screenType = ""
    var back = ""
   @IBOutlet  var outletWebView: UIWebView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        // Do any additional setup after loading the view.
        screenType =  UserDefaults.standard.string(forKey: "view")!
        //If user came from Terms and condition load Terms_and_condition file otherwise PrivacyPolicy from login screen and signup screen
        if screenType.isEqual("terms"){
            
            self.title = "Terms and Conditions"
            self.navigationController?.navigationBar.tintColor = UIColor.white;
            let url = Bundle.main.url(forResource: "Terms_and_condition", withExtension:"html")
            let requestObj = URLRequest(url: url!)
            outletWebView.loadRequest(requestObj)
        }
        else{
            
            self.title = "Privacy Policy"
            self.navigationController?.navigationBar.tintColor = UIColor.white;
          let url = URL (string: "https://giftadeed.com/pages/privacy_policy_app.html")
            let requestObj = URLRequest(url: url!)
            outletWebView.loadRequest(requestObj)
        }
    }
    @IBAction func backBtnPress(_ sender: Any) {
        back =  UserDefaults.standard.string(forKey: "back") ?? "0"
          if back.isEqual("login"){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "login") 
        UIApplication.shared.keyWindow?.rootViewController = viewController
        }
          else{
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "signUp")
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
}
