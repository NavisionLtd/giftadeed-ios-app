//
//  MyTagsViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 06/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    Here all the tags posted by the User will be shown under 'List of my tags'.
 •    If there are no tags, then a message line will be shown in the content screen which reads 'Hey, looks like you haven't tagged any deed yet. Click here to get started'. On clicking ‘Click here’, the user must be directed to Tag a Deed.
 •    If the User has already tagged certain deeds, then they must be shown here in a list form with the heading 'List of my tags'. On the left, the photo of the deed must be shown. On the right, the Category of the deed should be written. Next to that, the date of tagging should be written. Below the Category, the address/location of the deed should bewritten in text form.Below the address, No. of Endorsements, and No. of Views are shown.  In front of that, the deed category symbol should be shown. Below the category symbol, the status of the deed should be shown i.e. whether fulfilled or unfulfilled.
 •    No. of Views and no. of Endorsements is required for all the deeds. This will be shown in the Tagged Deeds Details Page, Tag List View, My Fulfilled Tags, and My Tags. Only unique Views will be counted i.e. one User will be counted only once.
 •    On clicking on a tag, nothing happens.
 •    The tags are displayed in descending order of creation i.e. latest tags are displayed first. Whenever a deed is tagged, the User gets a push notification.
 */

import UIKit
import ANLoader
import Localize_Swift
import EFInternetIndicator
class MyTagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate ,InternetStatusIndicable{
   
    
 var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var listOfMyTagsLbl: UILabel!
    @IBOutlet weak var mentMyTagsLbl: UINavigationItem!
    @IBOutlet  var outletNoRecord: UILabel!
    @IBOutlet weak var outletClickHere: UIButton!
    @IBOutlet  var outletTableView: UITableView!
    let defaults = UserDefaults.standard
    var userId = ""
    var myTagsArr = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
self.setText()
        self.startMonitoringInternet()
        // Do any additional setup after loading the view.
        outletTableView.delegate = self
        outletTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
    }
    @objc func setText(){
        
        self.mentMyTagsLbl.title = "MY TAGS".localized()
        self.listOfMyTagsLbl.text = "List of my tags".localized()
         self.outletNoRecord.text = "Hey, looks like you haven't tagged any deed yet.".localized()
      outletClickHere.setTitle("Click here to get started.".localized(using: "Localizable"), for: UIControlState.normal)
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
            //   GlobalClass.sharedInstance.openMenu()
            
            
        }
//        DispatchQueue.main.async {
//
//            GlobalClass.sharedInstance.openMenu();
//        }
    }
    
    //If there user not having any tags then only these button will visible otherwise not.
    //Button tap to navigate tag a deed screen
    @IBAction func getStartedAction(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tagADeed") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.myTagsArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? HomeTableViewCell!
        cell?!.layer.cornerRadius=2
        
        let item = self.myTagsArr[indexPath.section] as? NSDictionary
        
        cell?!.outletNeedLabel.text = String(format: "%@", (item as AnyObject).value(forKey:"Need_Name") as! String).localized()
        cell?!.outletAddressLabel.text = String(format: "%@", (item as AnyObject).value(forKey:"Address") as! String)
        
        let Tagged_Datetime = GlobalClass.sharedInstance.converDateFormate(dateString:(item as AnyObject).value(forKey:"Tagged_Datetime") as! String)
        cell?!.outletDateLabel.text = String(format: "%@",Tagged_Datetime)

        cell?!.outletViewsLabel.text = String(format: "%@", (item as AnyObject).value(forKey:"Views") as! String)
        cell?!.outletEndorseLabel.text = String(format: "%@", (item as AnyObject).value(forKey:"Endorse") as! String)

       

        let tagType = String(format: "%@", (item as AnyObject).value(forKey:"Category_Type") as! String)
        if(tagType == "D"){
            
            let iconString =  (item as AnyObject).value(forKey:"Tagged_Photo_Path") as! String
            let iconUrl = iconString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let iconURL = String(format: "%@%@", Constant.BASE_URL ,iconUrl )
            cell?!.outletIconImg.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
            
            
            
            let charecterIconString = (item as AnyObject).value(forKey:"Character_Path") as! String
            let charecterUrl = charecterIconString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let charactorURL = String(format: "%@%@", Constant.BASE_URL , charecterUrl)
            cell?!.outletCharacterImg.sd_setImage(with: URL(string: charactorURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
        }
        else{
        let iconString =  (item as AnyObject).value(forKey:"Tagged_Photo_Path") as! String
        let iconUrl = iconString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
             let iconURL = String(format: "%@%@", Constant.Custom_BASE_URL ,iconUrl )
//            let iconURL = String(format: "%@%@", Constant.Custom_BASE_URL , (item as AnyObject).value(forKey:"Tagged_Photo_Path") as! String)
            cell?!.outletIconImg.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
            
//            let charactorURL = String(format: "%@%@", Constant.Custom_BASE_URL , (item as AnyObject).value(forKey:"Character_Path") as! String)
            
            let charecterIconString = (item as AnyObject).value(forKey:"Character_Path") as! String
                      let charecterUrl = charecterIconString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
              let charactorURL = String(format: "%@%@", Constant.BASE_URL , charecterUrl)
            cell?!.outletCharacterImg.sd_setImage(with: URL(string: charactorURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
        }
        let tagStatus = String(format: "%@", (item as AnyObject).value(forKey:"TagStatus") as! String)
        if (tagStatus.caseInsensitiveCompare("yes") == ComparisonResult.orderedSame){

            cell?!.outletTagStatusLabel.textColor = UIColor.red;
            cell?!.outletTagStatusLabel.text="Unfulfilled".localized();
        }
        else{

            cell?!.outletTagStatusLabel.textColor = UIColor(red:0.51, green:0.78, blue:0.48, alpha:1.0);
            cell?!.outletTagStatusLabel.text="Fulfilled".localized();
    }
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
    
    //Dowload all tags
    func downloadData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.MyTags
        
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
                
                self.view.hideAllToasts()
                self.navigationController?.view.makeToast(Validation.ERROR.localized())
                
                DispatchQueue.main.async{
                    
                    self.outletNoRecord.isHidden = false
                    self.outletNoRecord.text = "Some error occured"
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let taggedlist = jsonObj!.value(forKey: "Taggedlist") as? NSArray {
                    
                    for item in taggedlist {
                        
                        do {
                            
                            let taggedItem = item as? NSDictionary
                            try self.myTagsArr.add(taggedItem!)
                           
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }
                    
                    if self.myTagsArr.count == 0{
                        
                        DispatchQueue.main.async{
                            
                            self.outletClickHere.isHidden = false
                            self.outletNoRecord.isHidden = false
                        }
                    }
                    else{
                        
                        DispatchQueue.main.async{
                            
                            self.outletClickHere.isHidden = true
                            self.outletNoRecord.isHidden = true
                            self.updateUI()
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //Reload table view
    func updateUI() {
        
        outletTableView.reloadData()
    }
}
