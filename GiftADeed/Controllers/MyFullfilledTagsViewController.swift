//
//  MyFullfilledTagsViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 06/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

/*
 •    On clicking this option, the User is directed to the My Fulfilled Tags page.
 •    Here the tags fulfilled by the User are shown.
 •    If there are no tags, then a message line is shown in the content screen which reads 'Hey, looks like you haven't fulfilled any deed yet.'
 •    If the User has fulfilled any tags, then the list of all such fulfilled tags will be shown.
 •    The tags will be shown in descending order of fulfilment i.e. latest first. In each tag, the photo will be shown at the left. Next to that the deed type is written. Next to that, the date of fulfilment is written in format 17-Aug-2017. Below the Deed Type, the address of the deed is displayed. Below the address, No. of Endorsements, and No. of Views are shown. In front of that, the picture of the deed type is shown.
 •    No. of Views and no. of Endorsements is required for all the deeds. This will be shown in the Tagged Deeds Details Page, Tag List View, My Fulfilled Tags, and My Tags. Only unique Views will be counted i.e. one User will be counted only once.
 */
import  EFInternetIndicator
import UIKit
import ANLoader
import Localize_Swift
class MyFullfilledTagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,InternetStatusIndicable {
   
     var internetConnectionIndicator:InternetViewIndicator?

    @IBOutlet weak var menuFullFillText: UINavigationItem!
    @IBOutlet weak var fullFilledTagLabl: UILabel!
    @IBOutlet  var outletNoRecord: UILabel!
    @IBOutlet  var outletTableView: UITableView!
    let defaults = UserDefaults.standard
    var userId = ""
    var myFulFilledTagsArr = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
setText()
        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        outletTableView.delegate = self
        outletTableView.dataSource = self
    }
    func setText(){
          self.menuFullFillText.title = "My Fulfilled Tags".localized()
        self.outletNoRecord.text = "Hey, looks like you haven't fulfilled any deed yet.".localized()
      self.fullFilledTagLabl.text = "List of My Fulfilled Tags".localized()
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
       let back =  UserDefaults.standard.string(forKey: "backFromAbout")
        if(back == "myFulfilledTags"){
        DispatchQueue.main.async {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "aboutUs") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = viewController
            //   GlobalClass.sharedInstance.openMenu()
            
            
        }
        }
        else{
        DispatchQueue.main.async {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
            UIApplication.shared.keyWindow?.rootViewController = viewController        }
    }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.myFulFilledTagsArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? HomeTableViewCell!
        cell?!.layer.cornerRadius=2
        
        let model = self.myFulFilledTagsArr[indexPath.section] as! ModelMyFullFill
        
        cell?!.outletNeedLabel.text = model.Need_Name?.localized()
        cell?!.outletAddressLabel.text = model.Address
        let Tagged_Datetime = GlobalClass.sharedInstance.converDateFormate(dateString:(model.FullFilled_Datetime)!)
        cell?!.outletDateLabel.text = String(format: "%@",Tagged_Datetime)
        cell?!.outletViewsLabel.text = String(format: "%@", model.Views!)
        cell?!.outletEndorseLabel.text = String(format: "%@", model.Endorse!)
        
        let iconURL = String(format: "%@%@", Constant.BASE_URL , model.FullFilled_Photo_Path!)
        let charactorURL = String(format: "%@%@", Constant.BASE_URL ,model.Character_Path!)
        
        cell?!.outletIconImg.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
        cell?!.outletCharacterImg.sd_setImage(with: URL(string: charactorURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
        
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

    //Download my fullfill data
    func downloadData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.MyfullFillTags
        
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
                
                if let taggedlist = jsonObj!.value(forKey: "Taggedlist") as? NSArray {
                    
                    for item in taggedlist {
                        
                        let taggedItem = item as? NSDictionary

                        let Tagged_Title = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_Title") as! String)
                        let Address = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Address") as! String)
                       
                        let fulfilled_photo = String(format: "%@", (taggedItem as AnyObject).value(forKey:"FullFilled_Photo_Path") as! String)
                        let FullFilled_Photo_Path = fulfilled_photo.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                        let FullFilled_Datetime = String(format: "%@", (taggedItem as AnyObject).value(forKey:"FullFilled_Datetime") as! String)
                        let FullFilled_Points = String(format: "%@", (taggedItem as AnyObject).value(forKey:"FullFilled_Points") as! String)
                        
                        let charecterImg = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Character_Path") as! String)
                        let Character_Path = charecterImg.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                        let NeedMapping_ID = String(format: "%@", (taggedItem as AnyObject).value(forKey:"NeedMapping_ID") as! String)
                        let Need_Name = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Need_Name") as! String)
                        let Endorse = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Endorse") as! String)
                        let Views = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Views") as! String)
                        
                        let model = ModelMyFullFill.init(Tagged_Title: Tagged_Title, Address: Address, FullFilled_Photo_Path: FullFilled_Photo_Path, FullFilled_Datetime: FullFilled_Datetime, FullFilled_Points: FullFilled_Points, NeedMapping_ID: NeedMapping_ID, Character_Path: Character_Path, Need_Name: Need_Name, Views: Views, Endorse: Endorse)
                        
                        do {
                            
                            try self.myFulFilledTagsArr.add(model!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }
                    
                    if taggedlist.count == 0{
                        
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
    
    //Sort records by date update UI
    func updateUI() {
        
        let sortedArray = myFulFilledTagsArr.sortedArray {
            (obj1, obj2) -> ComparisonResult in
            
            let p1 = obj1 as! ModelMyFullFill
            let p2 = obj2 as! ModelMyFullFill
            
            let result = p1.FullFilled_Datetime!.compare(p2.FullFilled_Datetime!)
            return result
        }
        
        myFulFilledTagsArr.removeAllObjects()
        myFulFilledTagsArr = NSMutableArray(array: sortedArray)
        myFulFilledTagsArr =  NSMutableArray(array: myFulFilledTagsArr.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
        outletTableView.reloadData()
    }
}
