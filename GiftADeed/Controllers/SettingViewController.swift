//
//  SettingViewController.swift
//  GiftADeed
//
//  Created by Darshan on 8/2/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
// let query = Constant.settingTable.select(Constant.sett_id)
//.filter(Constant.set_status == "y")
//

import UIKit
import Localize_Swift
import ANLoader
import SQLite
import MMDrawController
import EFInternetIndicator
extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CellNotificationSubclassDelegate,InternetStatusIndicable{
   
     var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var radius: UILabel!
    @IBOutlet weak var reciveNotificationLbl: UILabel!
    func selectedGroup(name: String, id: String, settingBtn: UISwitch, cell: SettingTableViewCell) {
        guard let indexPath = self.settingTable.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        
        //  Do whatever you need to do with the indexPath
        
        print("Button tapped on row \(indexPath.section)")
      //    print("\(id)\(name)\(settingBtn.isOn)")
        
     //   print("\(self.selectedGropu)\(self.selectedCategory)")
        if(indexPath.section == 0){
            if(settingBtn.isOn == true){
                //Add group into array
                self.selectedGropu.add(id)
            }
            else{
                //remove group from array
                  self.selectedGropu.remove(id)
            }
        }
        else{
            if(settingBtn.isOn == true){
                //Add category into array
                  self.selectedCategory.add(id)
            }
            else{
                //remove category from array
                  self.selectedCategory.remove(id)
            }
        }
        print("\(self.selectedGropu)\(self.selectedCategory)")
    }
    
   
    //tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    //array loop
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return groupListArray.count
        }
        else{
            return  self.categoryArray.count
        }
    }
    //tableview cell called multiple times
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingTableViewCell
        cell.delegate = self
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
      
        if(indexPath.section == 0){
            let values = groupListArray[indexPath.row]
            cell.settingName.text = values.group_name
            cell.gropId.text =  values.group_id
            if(cell.settingBtn.isOn == true)
            {
                self.selectedGropu.add(values.group_id)
            }
           
        }
        else{
             let values = categoryArray[indexPath.row]
             cell.settingName.text =  values.category_name
             cell.gropId.text =  values.category_id
            if(cell.settingBtn.isOn == true)
            {
                self.selectedCategory.add(values.category_id)
            }
           
        }
         print("\(self.selectedGropu)\(self.selectedCategory)")
 
        return cell
    }
    //height of header in tableview sectiion
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    //title of tableview section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height-10)
        if(section == 0){
        label.text = "Group wise notification's".localized()
        }
          else{
              label.text = "Category wise notification's".localized()
        }
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.orange
        headerView.addSubview(label)
        
        return headerView
    }
    //variables
    var flag : Bool = false
    var selectedCategory = NSMutableArray()
    var selectedGropu = NSMutableArray()
    var globalNotification : Bool = false
    var globalNotifications = ""
    @IBOutlet weak var globalNotificationSwitch: UISwitch!
    @IBOutlet weak var radiusValue: UILabel!
    @IBOutlet weak var notificationSettingBtn: UILabel!
    @IBOutlet weak var appSettingLbl: UILabel!
    var groupListArray = [GroupList]()
    var categoryArray = [CategoryList]()
    var categoryList = NSMutableArray()
    var userId = ""
    @IBOutlet weak var settingTable: UITableView!
    var actionSheet: UIAlertController!
    let availableLanguages = Localize.availableLanguages()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
         GlobalClass.sharedInstance.openDb()
        //underline labels and buttons and call the api
        self.selectLangageBtn.addBottomBorder(UIColor.black, height: 0.5)
        self.appSettingLbl.addBottomBorder(UIColor.black, height: 0.5)
        self.notificationSettingBtn.addBottomBorder(UIColor.black, height: 0.5)
        self.categoryList = ["Food","Cloth","Shelter","Water","Health"]
         userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        self.grupListApiCall()
        self.downloadCategoryData()
        setText()
    }
    override func viewWillAppear(_ animated: Bool) {
      
    }
     //MARK:- Download group list owned and joined
    //call api to get all groups associated to logeedin user
    func grupListApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.showGroupList
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@",userId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    //if network error or server error show this toast msg
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR)
                }
                return
            }
            //actual parsing of data
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                for values in jsonObj!{
                    let group_id = (values as AnyObject).value(forKey: "group_id")
                    let group_logo = (values as AnyObject).value(forKey: "group_logo")
                    let group_name = (values as AnyObject).value(forKey: "group_name")
                    let groups = GroupList(group_name: group_name as! String, group_imageURL: group_logo as! String, group_id: group_id as! String)
                    print(groups)
                    //save parse data in struct and apend that struct values in array
                   self.groupListArray.append(groups)
                  
                     GlobalClass.sharedInstance.createSettingTbl()
                    let insertUser = Constant.settingTable.insert(Constant.set_name <- group_name as! String, Constant.sett_id <- group_id as! String,Constant.set_status <- "n")
                    
                    do {
                        try Constant.database.run(insertUser)
                        print("INSERTED USER")
                    }
                    catch {
                    }
                }
                
            }
            DispatchQueue.main.async{
               print(self.groupListArray)
                //reload the tableview every time on dat receive from api
//                self.refreshControl.endRefreshing()
                self.settingTable.reloadData()
            }
        }
        
        task.resume()
    }
   //Get category
    func downloadCategoryData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.need_type
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.navigationController?.view.makeToast(Validation.ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj)
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast("GlobalClass.sharedInstance.blockStatus = true")
                    }
                    return
                }
                
                if let needtype = jsonObj!.value(forKey: "g_need") as? NSArray {
                
                    for item in needtype {
                        
                        do {
                            let need_name = (item as AnyObject).value(forKey: "Need_Name") as! String
                            let NeedMapping_ID = (item as AnyObject).value(forKey: "NeedMapping_ID") as! String
  let model = CategoryList(category_name: need_name, category_id: NeedMapping_ID)
                            self.categoryArray.append(model)
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }
               
                }
                if let needtype1 = jsonObj!.value(forKey: "c_need") as? NSArray {
                    
                 
                    
                    for item in needtype1 {
                        
                        do {
                            let need_name = (item as AnyObject).value(forKey: "Need_Name") as! String
                            let NeedMapping_ID = (item as AnyObject).value(forKey: "NeedMapping_ID") as! String
                            let model1 = CategoryList(category_name: need_name, category_id: NeedMapping_ID)
                            self.categoryArray.append(model1)
                          
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }
                }
                DispatchQueue.main.async {
                    self.settingTable.reloadData()
                }
            }
        }
        task.resume()
    }
//iboutlets connected to storyboard
    @IBOutlet weak var selectLangageBtn: UIButton!
    @IBOutlet weak var menuSettingTitle: UINavigationItem!
    @IBAction func menuBtnPress(_ sender: UIBarButtonItem) {
        
        DispatchQueue.main.async {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
    func setText(){
        menuSettingTitle.title = "Setting".localized()
    }
    @IBAction func sliderValuePress(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        self.radiusValue.text = "\(currentValue) km"
    }
    @IBAction func globleNotificationBtnPress(_ sender: UISwitch) {
           GlobalClass.sharedInstance.createSettingTbl()
        if(sender.isOn){
            //Set flag = Y
          self.globalNotifications = "Y"
           
//            let insertUser = Constant.settingTable.insert(Constant.set_name <- "Global" , Constant.sett_id <- "0" ,Constant.set_status <- "y")
//
//            do {
//                try Constant.database.run(insertUser)
//                print("INSERTED USER")
//            }
//            catch {
//            }
            
        }else{
             //Set flag = N
              self.globalNotifications = "N"
//            let insertUser = Constant.settingTable.insert(Constant.set_name <- "Global" , Constant.sett_id <- "0" ,Constant.set_status <- "n")
//
//            do {
//                try Constant.database.run(insertUser)
//                print("INSERTED USER")
//            }
//            catch {
//            }
        }
       
    }
    //open language pickers
    @IBAction func selectLanguageBtnPress(_ sender: UIButton) {
        actionSheet = UIAlertController(title: nil, message: "Switch Language", preferredStyle: UIAlertControllerStyle.actionSheet)
        for language in availableLanguages {
            let displayName = Localize.displayNameForLanguage(language)
            let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
               
                print(language)
                UserDefaults.standard.set(language, forKey: "language")
            })
            actionSheet.addAction(languageAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnPress(_ sender: UIButton) {
       
        let language = UserDefaults.standard.value(forKey: "language") as! String
          Localize.setCurrentLanguage(language)
        
        
    }
    func saveSetting(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)

        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.app_setting
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        var paramString = ""

        paramString = String(format: "user_id=%@&receive_notification=%@&radius=%@&allowed_group_ids=%@&allowed_category_ids=%@",userId,self.globalNotifications,self.radiusValue.text!,"","")
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            //[{user_id, name, email, joined: 0/1}]
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async {
                    
                }
                return
            }
            
          
            
            
        }
        task.resume()
}
}
  
