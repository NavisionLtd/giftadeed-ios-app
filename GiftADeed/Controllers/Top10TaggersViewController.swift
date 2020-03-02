//
//  Top10TaggersViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 06/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    This screen will display a list of top 10 users with the highest deed tagging points in the app user’s city (this information is captured at the time of registration) who have tagged the needy persons.
 •    The heading on the content area is 'List of top 10 taggers in your city'.
 •    For “Anonymous” users, their name will not be displayed. Only the word Anonymous will be shown in place of their name.For all other users, their name will be displayed as <First Name><.><First letter of Last Name>.
 •    The entries will have the following data - Tagger Name, in front of that the words ‘Tagged Deeds Score', in front of that the Tagged points of that tag fulfiller. The points of the tagger are the points earned by the tagger due to tagging. These are not the overall points. The list is arranged in the descending order of the points i.e. tagger with highest tagged points at the top.
 */
import  EFInternetIndicator
import UIKit
import ANLoader
import Localize_Swift
class Top10TaggersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,InternetStatusIndicable {
   
    
     var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var taggedNeedScoreLbl: UILabel!
    @IBOutlet weak var menuTopTenTitle: UINavigationItem!
    @IBOutlet weak var topListbl: UILabel!
    @IBOutlet  var outletNoRecord: UILabel!
    @IBOutlet  var outletTableView: UITableView!
    var top10TaggerArr = NSMutableArray()
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
func setText()
{
    menuTopTenTitle.title = "Top 10 Taggers".localized()
    topListbl.text = "List of top 10 taggers in your city".localized()
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
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "aboutUs")
            UIApplication.shared.keyWindow?.rootViewController = viewController
           
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return top10TaggerArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? Top10TableViewCell?
        cell??.layer.cornerRadius=2
  
        let model = self.top10TaggerArr[indexPath.section] as! ModelTop10Taggers
        
        var fullName = ""
        
        let Lname = model.Last_Name
        if Lname.count != 0 {
            
            let index = Lname.index(Lname.startIndex, offsetBy: 0)
            fullName = String(format:"%@. %@",model.First_Name, String(Lname[index]))
        }
        else{
            
            fullName = String(format: "%@", model.First_Name)
        }
        cell??.outletScoreLbl.text = "Tagged Needs Score".localized()
        cell??.outletNameLabel.text = fullName
        cell??.outletSRNoLabel.text = String(format: "%d", indexPath.section+1)
        cell??.outletPointsLabel.text = String(format: "  %@  ", model.Total_Credit_Point)
        
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
    
    //MARK:- Download Top Taggers data
    func downloadData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.top_taggers
        
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
                
                if let taggedlist = jsonObj!.value(forKey: "RESULT") as? NSArray {
                    
                    for item in taggedlist {
                        
                        let taggedItem = item as? NSDictionary
   
                        let First_Name = String(format: "%@", (taggedItem as AnyObject).value(forKey:"First_Name") as! String)
                        let Last_Name = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Last_Name") as! String)
                        let Total_Credit_Point = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Total_Credit_Point") as! String)

                        let model = ModelTop10Taggers.init(First_Name: First_Name, Last_Name: Last_Name, Total_Credit_Point: Total_Credit_Point)
                        
                        do {
                            
                            try self.top10TaggerArr.add(model!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }
                    
                    if self.top10TaggerArr.count == 0{
                        
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
    
    //Sort data by Credite points and Reload tableview
    func updateUI() {
        
        let sortedArray = top10TaggerArr.sortedArray {
            (obj1, obj2) -> ComparisonResult in
            
            let p1 = obj1 as! ModelTop10Taggers
            let p2 = obj2 as! ModelTop10Taggers

            let result = p1.Total_Credit_Point.compare(p2.Total_Credit_Point, options: .numeric)
            return result
        }
        
        top10TaggerArr.removeAllObjects()
        top10TaggerArr = NSMutableArray(array: sortedArray)
        top10TaggerArr =  NSMutableArray(array: top10TaggerArr.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
        outletTableView.reloadData()
    }
}
