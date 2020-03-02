//
//  Top10FullersViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 06/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    This screen will display a list of top 10 users with highest deed fulfilment points in the app user’s city (this information is captured at the time of registration). The list is arranged in descending order of points i.e. tag fulfiller with highest tag fulfilled points at the top.
 •    The heading on the content area is 'Top 10 Tag Fulfillers'.
 •    For “Anonymous” users, their name will not be displayed. Only the word Anonymous will be shown in place of their name.For all other users, their name will be displayed as <First Name><.><First letter of Last Name>.
 •    Based on the deed fulfilment points earned by the deed fulfillers, they will be assigned a title like Titanium, Platinum, Gold, Silver, Bronze. These titles will be managed from the Web Admin interface.
 •    The entries will have the following data - Tagger Name, in front of that the words 'Fulfilled Deeds Score', in front of that theFulfillment points of that tag fulfiller. The points of the tag fulfiller are the points earned by the tag fulfiller due to fulfilling the deeds. These are not the overall points.
 •    Below the Fulfilled Needs Score, the title and smiley is shown based on the points earned/title. Each title has a different smiley.
 */
import EFInternetIndicator
import UIKit
import ANLoader
import Localize_Swift

class Top10FullersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,InternetStatusIndicable  {
   
    
 var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var fulFillNeedScoreLbl: UILabel!
    @IBOutlet weak var menuTopTenTagFullerTitle: UINavigationItem!
    @IBOutlet weak var topTenListLabel: UILabel!
    @IBOutlet  var outletNoRecord: UILabel!
    @IBOutlet  var outletTableView: UITableView!
    var top10FullFillterArr = NSMutableArray()
    let defaults = UserDefaults.standard
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
setText()
        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        outletTableView.delegate = self
        outletTableView.dataSource = self
    }
    func setText(){
     
        menuTopTenTagFullerTitle.title = "Top 10 Tag Fulfillers".localized()
        
        topTenListLabel.text = "List of top 10 tag fulfillers in your city".localized()
        outletNoRecord.text = "No records found".localized()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return top10FullFillterArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? Top10TableViewCell!
        cell?!.layer.cornerRadius=2
        
        let item = self.top10FullFillterArr[indexPath.section] as? NSDictionary
        
        let Fname = String(format: "%@", (item as AnyObject).value(forKey:"First_Name") as! String)
        let Lname = String(format: "%@", (item as AnyObject).value(forKey:"Last_Name") as! String)
        var fullName = ""
        
        if Lname.count != 0 {
            
            let index = Lname.index(Lname.startIndex, offsetBy: 0)
            fullName = String(format: "%@. %@", Fname, String(Lname[index]))
        }
        else{
            
            fullName = String(format: "%@", Fname)
        }
           cell?!.outletScoreLbl.text = "Fulfilled Needs Score".localized()
        cell?!.outletNameLabel.text = fullName
        cell?!.outletSRNoLabel.text = String(format: "%d", indexPath.section+1)
        cell?!.outletPointsLabel.text = String(format: "  %@  ", (item as AnyObject).value(forKey:"Total_Fullfiller_Points") as! String)
        
        cell?!.outletRankLabel.text = String(format: "%@", (item as AnyObject).value(forKey:"FullFillerRank") as! String)

        let iconURL = String(format: "%@%@", Constant.BASE_URL , (item as AnyObject).value(forKey:"Url_fullfillerRank") as! String)
        cell?!.outletRankImg.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "default"))
   
        return cell!!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 5
    }
    
    //MARK:- Download Top ten fullfiller data
    func downloadData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.top_ten_fullfiller
        
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
                    self.outletNoRecord.isHidden = false
                    self.outletNoRecord.text = "Some error occured"
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
                
                if let taggedlist = jsonObj!.value(forKey: "RESULTFFILLER") as? NSArray {
                    
                    for item in taggedlist {
                        
                        let taggedItem = item as? NSDictionary
                        
                        do {
                            
                            try self.top10FullFillterArr.add(taggedItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }
                    
                    if self.top10FullFillterArr.count == 0{
                        
                        DispatchQueue.main.async{
                            
                            self.outletNoRecord.isHidden = false
                        }
                    }
                    else{
                        
                        DispatchQueue.main.async{
                            
                            self.outletNoRecord.isHidden = true
                            self.updateUI()
                        }
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func updateUI() {
        
        outletTableView.reloadData()
    }
}
