
//
//  TagCounterViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 06/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

/*
 •    There will be a tag counter option.
 •    Here the User will see the number of tagged deeds and number of deeds fulfilled by all the app users on that specific day. (Based on server time)
 */
import EFInternetIndicator
import UIKit
import ANLoader
import Localize_Swift
class TagCounterViewController: UIViewController,InternetStatusIndicable {
    var internetConnectionIndicator:InternetViewIndicator?
    

    @IBOutlet weak var todaysFulfilledDeedslbl: UILabel!
    @IBOutlet weak var todaysTaggedDeedLbl: UILabel!
    @IBOutlet weak var menuTagCounterTitle: UINavigationItem!
    @IBOutlet  var outletTaggedDeed: UILabel!
    @IBOutlet  var outletFulfilledDeed: UILabel!
    @IBOutlet weak var taggerDeedsCountForADay: UILabel!
    
    let defaults = UserDefaults.standard
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        setText()
        // Do any additional setup after loading the view.
    }
func setText()
{
    menuTagCounterTitle.title = "Tag Counter".localized()
    taggerDeedsCountForADay.text = "Tagged Deeds & Fulfilled Deeds for day".localized()
    todaysTaggedDeedLbl.text = "Today's Tagged Deeds".localized()
    todaysFulfilledDeedslbl.text = "Today's Fulfilled Deeds".localized()
    }
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    //MARK:- Download Tag counter data and update UI
    func downloadData(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.tag_counter
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "userId=%@", userId)
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
                
                DispatchQueue.main.async{
                    
                    self.outletTaggedDeed.text = jsonObj?.value(forKey:"tagged") as? String
                    self.outletFulfilledDeed.text = jsonObj?.value(forKey:"fulfilled") as? String
                }
            }
        }
        
        task.resume()
    }

}
