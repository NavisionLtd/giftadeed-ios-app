//
//  DashBoardViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 06/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    Each User should have a Dashboard.
 •    It will have the following options –
 •    Your last good deed was on <Date e.g. 15th Feb 2018>
 •    Your total number of Tags are <Numerical value>
 •    Your total number of Fulfilments are <Numerical value>
 •    Your percentage of Successful tags is <Numerical value up to 2 decimal places>
 •    Your Gift-A-Deed score is <Numerical value>
 •    Percentage of successful tags can be calculated in the following way –
 •    Let the total number of Deeds tagged by the User be x.
 •    Let the total number of Deeds that have been fulfilled out of x be y.
 •    The percentage of successful tags for that User will be ((y/x) * 100).
 •    On the Dashboard, the stats of the User can also include the last time the User did a Good deed using the app i.e. Tag a Deed or Fulfil a Deed.
 •    Share app option will be there as well.
 */

import UIKit
import ANLoader
import Localize_Swift
class DashBoardViewController: UIViewController {
   
    

    @IBOutlet  var outletLastGoodDeed: UILabel!
    @IBOutlet  var outletTotalNoTags: UILabel!
    @IBOutlet  var outletTotalNoFulfilments: UILabel!
    @IBOutlet  var outletPercentageOfSuccessTag: UILabel!
    @IBOutlet  var outletGiftADeedScore: UILabel!
    
    @IBOutlet weak var menuDashboardTitle: UINavigationItem!
    @IBOutlet weak var lastGoodDeedLbl: UILabel!
    @IBOutlet weak var totalFulfillmentsLbl: UILabel!
    @IBOutlet weak var totalNoofTagsLbl: UILabel!
    @IBOutlet weak var percentageOfTagsLbl: UILabel!
    @IBOutlet weak var scoreLbls: UILabel!
    let defaults = UserDefaults.standard
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
setText()
        
        // Do any additional setup after loading the view.
    }

    func setText(){
        menuDashboardTitle.title = "Dashboard".localized()
        lastGoodDeedLbl.text = "Your last good deed was on".localized()
        totalNoofTagsLbl.text = "Your total number of Tags are".localized()
        totalFulfillmentsLbl.text = "Your total no of Fulfillments are".localized()
        percentageOfTagsLbl.text = "Your percentage of successful tags are".localized()
        scoreLbls.text = "Your Gift a Deed score is".localized()
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
    
    //MARK:- Download dashboard data and update UI.
    func downloadData(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.dashboard
        
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
                    
                    let percentage:String = String(format:"%.2f", (jsonObj?.value(forKey:"tagSuccessPercent") as? Double)!)
                    
                    self.outletLastGoodDeed.text = jsonObj?.value(forKey:"lastDeedDate") as? String
                    self.outletTotalNoTags.text = jsonObj?.value(forKey:"totTags") as? String
                    self.outletTotalNoFulfilments.text = jsonObj?.value(forKey:"totFulfills") as? String
                    self.outletPercentageOfSuccessTag.text = String(format: "%@%%",percentage)
                    self.outletGiftADeedScore.text = jsonObj?.value(forKey:"totPoints") as? String
                }
            }
        }
        
        task.resume()
    }

}
