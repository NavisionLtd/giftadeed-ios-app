//
//  CommonWebViewStaticViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 09/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    Clicking this option should direct the user to the Terms and Conditions page of the app.
 •    In terms and conditions, there should be a note about Photo policy (obscene photos), and a note about the Age of the user as well.
 •    Clicking this option should direct the user to the Privacy Policy page of the app.
 •    Clicking this option should direct the user to the Cookies Policy page of the app.
 •    Clicking this option should direct the user to the End-User Licence Agreement page of the app.
 •    Clicking this option should direct the user to the Disclaimer page of the app.
 */
import UIKit
import Localize_Swift
import EFInternetIndicator
class CommonWebViewStaticViewController: UIViewController,InternetStatusIndicable {
    var internetConnectionIndicator:InternetViewIndicator?
    

    @IBOutlet  var outletWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
self.startMonitoringInternet()
        // Do any additional setup after loading the view.
        
        self.loadWebview()
    }
   
    @IBAction func menuBarAction(_ sender: Any) {
       
        DispatchQueue.main.async {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "aboutUs") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = viewController
     //   GlobalClass.sharedInstance.openMenu()
            
        
        }
    }
    
    //These view is common for all static web pages screen depends on flag will load web page
    func loadWebview() {
        
        if Int(GlobalClass.sharedInstance.menuIndex)==8{
            
            self.title = "About Us".localized()
          //  let url = Bundle.main.url(forResource: "AboutApp", withExtension:"html")
            
              let url = URL (string: "https://giftadeed.com/pages/about_app_mob.html")
            let requestObj = URLRequest(url: url!)
            
            outletWebView.loadRequest(requestObj)
            
        } else if Int(GlobalClass.sharedInstance.menuIndex)==10{
            
            self.title = "Terms And Conditions".localized()
            let url = URL (string: " https://giftadeed.com/pages/Terms_and_condition.html")//Bundle.main.url(forResource: "Terms_and_condition", withExtension:"html")
           
            let requestObj = URLRequest(url: url!)
            outletWebView.loadRequest(requestObj)
            
        } else if Int(GlobalClass.sharedInstance.menuIndex)==11{
            
            self.title = "Privacy Policy"
           // let url = Bundle.main.url(forResource: "PrivacyPolicy", withExtension:"html")
            let url = URL (string: "https://giftadeed.com/pages/privacy_policy_app.html")
            let requestObj = URLRequest(url: url!)
            outletWebView.loadRequest(requestObj)
            
        } else if Int(GlobalClass.sharedInstance.menuIndex)==12{
            
            self.title = "Cookies Policy".localized()
            let url = URL (string: "https://giftadeed.com/pages/CookiesPolicy.html") //Bundle.main.url(forResource: "CookiesPolicy", withExtension:"html")
            
            let requestObj = URLRequest(url: url!)
            outletWebView.loadRequest(requestObj)
           
        } else if Int(GlobalClass.sharedInstance.menuIndex)==13{
            
            self.title = "End User Agreement".localized()
            let url = URL (string: "https://giftadeed.com/pages/EndUserAgreement.html")//Bundle.main.url(forResource: "EndUserAgreement", withExtension:"html")
           // https://giftadeed.com/pages/EndUserAgreement.html
            let requestObj = URLRequest(url: url!)
            outletWebView.loadRequest(requestObj)
            
        } else if Int(GlobalClass.sharedInstance.menuIndex)==14{
            
            self.title = "Disclaimer".localized()
            let url = URL (string: "https://giftadeed.com/pages/Disclaimer.html")//Bundle.main.url(forResource: "Disclaimer", withExtension:"html")
            
            let requestObj = URLRequest(url: url!)
            outletWebView.loadRequest(requestObj)
        }
    }
}
    

