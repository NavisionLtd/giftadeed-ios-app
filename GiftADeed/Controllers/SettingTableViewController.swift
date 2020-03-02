//
//  SettingTableViewController.swift
//  GiftADeed
//
//  Created by KTS  on 11/07/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import Localize_Swift
import ANLoader
import SQLite
import EFInternetIndicator
import MMDrawController
//struct variable to hold json values for groups
struct GroupList {
    let group_name : String
    let group_imageURL : String
    let group_id : String
}
struct CategoryList
{
    let category_name : String
    let category_id : String
}
struct recrived_setting {
    let receive_notification : String
    let radius : String
    let allowed_group_ids : String
    let allowed_category_ids : String
}
extension RangeReplaceableCollection where Element: Hashable {
    var orderedSet: Self {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
    mutating func removeDuplicates() {
        var set = Set<Element>()
        removeAll { !set.insert($0).inserted }
    }
}

class SettingTableViewController: UITableViewController,CellNotificationSubclassDelegate,InternetStatusIndicable {
     var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var radiusViewToggle: UIView!
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    //array loop
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return groupListArray.count
        }
        else{
            return  self.categoryArray.count
        }
    }
 
    //tableview cell called multiple times
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingTableViewCell
        cell.delegate = self
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    
    if UserDefaults.standard.bool(forKey: "flag"){
        // set all values
        cell.isUserInteractionEnabled = false
     cell.notificationViewToggle.isHidden = false
//        if(self.globalNotifications == "Y"){
//
//        }
        
        self.radiusValue.text = "35 Metres"
          self.radius = "35"
        
        if(indexPath.section == 0){
               cell.alpha = 0.1
            let values = groupListArray[indexPath.row]
            cell.settingName.text = values.group_name
            cell.gropId.text =  values.group_id
            if(cell.settingBtn.isOn == true)
            {
                self.selectedGropu.add(values.group_id)
            }
            else{
                self.selectedGropu.remove(values.group_id)
            }
            
        }
        else{
               cell.alpha = 0.1
            let values = categoryArray[indexPath.row]
            cell.settingName.text =  values.category_name
            cell.gropId.text =  values.category_id
            if(cell.settingBtn.isOn == true)
            {
                self.selectedCategory.add(values.category_id)
            }
            else{
                self.selectedGropu.remove(values.category_id)
            }
            
        }
        print("\(self.selectedGropu)\(self.selectedCategory)")
       // cell.isHidden = true
    }else{
        
        cell.alpha = 1.0
         cell.isUserInteractionEnabled = true
        cell.notificationViewToggle.isHidden = true
        
        // set all values
        if(indexPath.section == 0){

            if(receivedSetting.count > 0){
                let values = groupListArray[indexPath.row]
                let recids = receivedSetting[0]
                cell.settingName.text = values.group_name
                print(recids.allowed_group_ids)
                
                  var pointsArr = recids.allowed_group_ids.components(separatedBy: ",")
                
                if(pointsArr.contains(values.group_id)){
                      cell.gropId.text =  values.group_id
                    cell.settingBtn.isOn = true
                }else{
                      cell.gropId.text =  values.group_id
                    cell.settingBtn.isOn = false
                }
              
                if(cell.settingBtn.isOn == true)
                {
                    self.selectedGropu.add(values.group_id)
                }
            }
            else{
                let values = groupListArray[indexPath.row]
                cell.settingName.text = values.group_name
                cell.gropId.text =  values.group_id
                if(cell.settingBtn.isOn == true)
                {
                    self.selectedGropu.add(values.group_id)
                }
                else{
                    self.selectedGropu.remove(values.group_id)
                }
            }
            
        }
        else{

            if(receivedSetting.count > 0){
                let values = categoryArray[indexPath.row]
                let recids = receivedSetting[0]
                cell.settingName.text = values.category_name
                var cateGoryIdArray = NSMutableArray()
                cateGoryIdArray.add(recids.allowed_category_ids)
                print("\(recids.allowed_category_ids)\(values.category_id),\(cateGoryIdArray)")
                
                var pointsArr = recids.allowed_category_ids.components(separatedBy: ",")
                
//                let index = find(value: values.category_id, in: pointsArr)
//                print(index)
               
                if(pointsArr.contains(values.category_id)){
                    cell.gropId.text =  values.category_id
                    cell.settingBtn.isOn = true
                }else{
                    cell.gropId.text =  values.category_id
                    cell.settingBtn.isOn = false
                }
                
                if(cell.settingBtn.isOn == true)
                {
                    self.selectedCategory.add(values.category_id)
                }
                else{
                    self.selectedGropu.remove(values.category_id)
                }
            }
            else{
                let values = categoryArray[indexPath.row]
                cell.settingName.text = values.category_name
                cell.gropId.text =  values.category_id
                if(cell.settingBtn.isOn == true)
                {
                    self.selectedCategory.add(values.category_id)
                }
                else{
                    self.selectedGropu.remove(values.category_id)
                }
            }
        }
        print("\(self.selectedGropu)\(self.selectedCategory)")
    }

        return cell
    }
    func find(value searchValue: String, in array: [String]) -> Int?
    {
        for (index, value) in array.enumerated()
        {
            if value == searchValue {
                return index
            }
        }
        
        return nil
    }
    //height of header in tableview sectiion
   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    //title of tableview section
   override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height-10)
    
    if(self.globalNotifications == "Y")
    {
        if(self.groupListArray.count == 0)
        {
            if(section == 1){
                label.text = "Category wise notification's".localized()
            }
            
        }
        else{
            if(section == 0){
                label.text = "Group wise notification's".localized()
            }
            else{
                label.text = "Category wise notification's".localized()
            }
        }
    }
    else{
        
        
       
            if(section == 0){
                label.text = ""
            }
            else{
                label.text = ""
        }
    
    }
  
    
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.orange
        headerView.addSubview(label)
        
        return headerView
    }
   
    @IBOutlet weak var receiveNotificationLbl: UILabel!
    @IBOutlet weak var notificationSettingLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    //variables
    @IBOutlet weak var radiusSlider: UISlider!
    var radius = ""
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
    var receivedSetting = [recrived_setting]()
    var categoryList = NSMutableArray()
    var userId = ""
    @IBOutlet weak var settingTable: UITableView!
    var actionSheet: UIAlertController!
    let availableLanguages = Localize.availableLanguages()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        self.settingTable.tableFooterView = UIView()
        GlobalClass.sharedInstance.openDb()
        //underline labels and buttons and call the api
//        self.selectLangageBtn.addBottomBorder(UIColor.black, height: 0.5)
//        self.appSettingLbl.addBottomBorder(UIColor.black, height: 0.5)
//        self.notificationSettingBtn.addBottomBorder(UIColor.black, height: 0.5)
        self.categoryList = ["Food","Cloth","Shelter","Water","Health"]
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        self.fetchSavedRecords()
        self.grupListApiCall()
        self.downloadCategoryData()
     self.radiusViewToggle.isHidden = true
        
   
        setText()
    }
    override func viewWillAppear(_ animated: Bool) {
     self.navigationItem.title = "Setting".localized()
        self.appSettingLbl.text = "Application Setting's".localized()
        self.notificationSettingLbl.text = "Notification Setting's".localized()
        self.radiusLbl.text = "Radius".localized()
        self.saveBtn.setTitle("Save".localized(), for: .normal)
        self.receiveNotificationLbl.text = "Receive Notification's".localized()
//        self.value = Float(defaults.value(forKey: "DEED_RADIUS") as! Int)
//        self.outlletRadiusValue.text = String(format: "%d Metres(%d Kms)",(defaults.value(forKey: "DEED_RADIUS") as! Int),(defaults.value(forKey: "DEED_RADIUS") as! Int)/1000)
        self.radiusValue.text = "35 Metres"
        
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
                    self.view.makeToast(Validation.ERROR.localized())
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
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
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
                        self.navigationController?.view.makeToast("\(GlobalClass.sharedInstance.blockStatus = true)")
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
    @IBOutlet weak var radiusLbl: UILabel!
    //iboutlets connected to storyboard
    @IBOutlet weak var selectLangageBtn: UIButton!
    @IBOutlet weak var menuSettingTitle: UINavigationItem!
    @IBAction func menuBtnPress(_ sender: UIBarButtonItem) {
        
        DispatchQueue.main.async {
//
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
//            UIApplication.shared.keyWindow?.rootViewController = viewController
            DispatchQueue.main.async {
                if let drawer = self.drawer() ,
                    let manager = drawer.getManager(direction: .left){
                    let value = !manager.isShow
                    drawer.isShowMask = true
                    drawer.showLeftSlider(isShow: value)
                }
            }}
    }
    func setText(){
    //    menuSettingTitle.title = "Setting".localized()
    }
    @IBAction func sliderValuePress(_ sender: UISlider) {
        let currentValue = Int(sender.value)
         radius = "\(currentValue/1000)"
        print(radius)
        if(currentValue > 1000){
             self.radiusValue.text = String(format: "%d Metres(%d Kms)",currentValue,currentValue/1000)
        }
        else{
             self.radiusValue.text = "\(currentValue) Metres"
        }
       
        
    }
    @IBAction func globleNotificationBtnPress(_ sender: UISwitch) {
        GlobalClass.sharedInstance.createSettingTbl()
        //defaults.set(Int(CGFloat((self.radiusValue.text! as NSString).doubleValue)), forKey: "DEED_RADIUS")
        if(sender.isOn){
            //Set flag = Y
               self.settingTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            self.globalNotifications = "Y"
             UserDefaults.standard.set(false, forKey: "flag")
             self.radiusViewToggle.isHidden = true
            self.radiusSlider.isUserInteractionEnabled = true
            self.selectedGropu.removeAllObjects()
            self.selectedCategory.removeAllObjects()
          self.settingTable.reloadData()
            
        }else{
            //Set flag = N
             self.settingTable.tableFooterView = UIView()
            self.settingTable.separatorStyle = UITableViewCellSeparatorStyle.none
            self.globalNotifications = "N"
            self.selectedGropu.removeAllObjects()
            self.selectedCategory.removeAllObjects()
             self.radiusViewToggle.isHidden = false
              self.radiusSlider.isUserInteractionEnabled = false
             UserDefaults.standard.set(true, forKey: "flag")
        self.settingTable.reloadData()
        }
//        self.settingTable.reloadData()
    }
    //open language pickers
    @IBAction func selectLanguageBtnPress(_ sender: UIButton) {
        actionSheet = UIAlertController(title: nil, message: "Switch Language", preferredStyle: UIAlertControllerStyle.actionSheet)
        for language in availableLanguages {
            let displayName = Localize.displayNameForLanguage(language)
            let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                 self.selectLangageBtn.setTitle(displayName, for: .normal)
                 UserDefaults.standard.set(language, forKey: "language")

            })
           
            actionSheet.addAction(languageAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
      //  self.present(actionSheet, animated: true, completion: nil)
        if Device.IS_IPHONE {
            self.present(actionSheet, animated: true, completion: nil)
        }
        else{
            actionSheet.popoverPresentationController!.sourceView = self.view
            actionSheet.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width/2 , y: self.view.bounds.size.height/7, width: 1.0, height: 1.0)
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveBtnPress(_ sender: UIButton) {
        
        let language = UserDefaults.standard.value(forKey: "language") as? String
        Localize.setCurrentLanguage(language ?? ".en")
        UserDefaults.standard.set("settingchange", forKey: "setting")
       
        saveSetting()
       
    }
    func removeDuplicateInts(values: [Int]) -> [Int] {
        // Convert array into a set to get unique values.
        let uniques = Set<Int>(values)
        // Convert set back into an Array of Ints.
        let result = Array<Int>(uniques)
        return result
    }

    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }
    @IBAction func saveBrButtonPress(_ sender: Any) {
        let language = UserDefaults.standard.value(forKey: "language") as? String
        Localize.setCurrentLanguage(language ?? ".en")
        UserDefaults.standard.set("settingchange", forKey: "setting")
        
        saveSetting()
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
   
        let groupArray : NSArray = removeDuplicates(array: self.selectedGropu as! [String]) as NSArray
        let selectedgroup = groupArray.componentsJoined(by: ",")
       
        let catArray : NSArray = removeDuplicates(array: self.selectedCategory as! [String]) as NSArray
        let selectedCat = catArray.componentsJoined(by: ",")
     
       
        print(self.globalNotifications)
        print(self.radiusValue.text!)
        
        if(self.globalNotificationSwitch.isOn){
            self.globalNotifications = "Y"
            self.radiusViewToggle.isHidden = true
           // self.notificationViewToggle.isHidden = false
            
        }
        else{
             self.globalNotifications = "N"
            self.radiusViewToggle.isHidden = false
           // self.notificationViewToggle.isHidden = true
        }
        if(self.radiusViewToggle.isHidden == false)
        {
              paramString = String(format: "user_id=%@&receive_notification=%@&radius=%d",userId,self.globalNotifications,1)
        }
        else{
            if(radius == "" || radius == "0" ){
                 paramString = String(format: "user_id=%@&receive_notification=%@&radius=%@&allowed_group_ids=%@&allowed_category_ids=%@",userId,self.globalNotifications,"35",selectedgroup,selectedCat)
            }
            else{
                 paramString = String(format: "user_id=%@&receive_notification=%@&radius=%@&allowed_group_ids=%@&allowed_category_ids=%@",userId,self.globalNotifications,radius,selectedgroup,selectedCat)
            }
            
        }
      print(paramString)
        
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj)
                let status = jsonObj?.value(forKey: "status") as! Int
                if(status == 1){
                    print("Setting has been changed")
                       DispatchQueue.main.async {
                        self.view.makeToast("Setting has been changed".localized(), position: .center)
                      
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                    }
                }
                else{
                       DispatchQueue.main.async {
                    self.view.makeToast("Something went wrong Try again later!")
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func fetchSavedRecords(){
    ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
    
    ANLoader.showLoading("Loading", disableUI: true)
    
    let urlString = Constant.BASE_URL + Constant.getSetting
    
    let url:NSURL = NSURL(string: urlString)!
    
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 60.0
    let session = URLSession(configuration: sessionConfig)
    
    let request = NSMutableURLRequest(url: url as URL)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
    request.httpMethod = "POST"
    var paramString = ""
    
    paramString = String(format: "user_id=%@",userId)
    
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
        if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
            print(jsonObj)
            var user_id =  ""
            var allowed_category_ids = ""
            var receive_notification = ""
            var radius = ""
            var allowed_group_ids = ""
            var status = jsonObj?.value(forKey: "status") as! Int
            if(status == 1){
                let app_setting = jsonObj?.value(forKey: "application_settings") as! NSArray
                for item in app_setting{
                      user_id = (item as AnyObject).value(forKey: "user_id") as! String
                      receive_notification = (item as AnyObject).value(forKey: "receive_notification") as! String
                      radius = (item as AnyObject).value(forKey: "radius") as! String
                      allowed_category_ids = (item as AnyObject).value(forKey: "allowed_category_ids") as! String
                      allowed_group_ids = (item as AnyObject).value(forKey: "allowed_group_ids") as! String
                      let model = recrived_setting(receive_notification: receive_notification, radius: radius, allowed_group_ids: allowed_group_ids, allowed_category_ids:allowed_category_ids )
                    self.receivedSetting.append(model)
                }
                DispatchQueue.main.async {
                    let lng = UserDefaults.standard.value(forKey: "language") as? String
                    let save = UserDefaults.standard.value(forKey: "setting") as? String
                    if(save == "settingchange"){
                        print("Setting has been changed")
                        print(self.receivedSetting)
                        for value in self.receivedSetting{
                            if(lng == "hi"){
                                 self.selectLangageBtn.setTitle("हिंदी", for:.normal)
                            }
                            else if(lng == "en"){
                                self.selectLangageBtn.setTitle("English", for:.normal)
                            }
                            else if(lng == "pt-BR"){
                                self.selectLangageBtn.setTitle("Portuguese Brazil", for:.normal)
                            }
                            else{
                                 self.selectLangageBtn.setTitle("Chinese", for:.normal)
                            }
                            let globalNotify = value.receive_notification
                            if(globalNotify == "Y"){
                          self.settingTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                                     UserDefaults.standard.set(false, forKey: "flag")
                               self.globalNotifications = "Y"
                                self.globalNotificationSwitch.isOn = true
                               
                            self.radiusViewToggle.isHidden = true
                                self.radius = "\(value.radius)"
                                print(value.radius)
var myRadiusInFloatValue = Float(value.radius)
                                var myRadiusInInt = Int(myRadiusInFloatValue!)
                                print(myRadiusInInt)
                                //radius come in km format
                                   self.radiusSlider.isUserInteractionEnabled = true
                                if(myRadiusInInt * 1000 > 1000){
                                    self.radiusValue.text = ("\(myRadiusInInt * 1000)Metres(\(myRadiusInInt) kms)")
                                    
                                 
                                    print(Float(value.radius)!)
                                    self.radiusSlider.setValue(Float(value.radius)! * 1000, animated: true)
                                    
                                }
                                else{
                                    self.radiusValue.text = ("\(myRadiusInInt)Metres")
                                    
                                    
                                    print(Float(value.radius)!)
                                    self.radiusSlider.setValue(Float(value.radius)!, animated: true)
                                }
                                
                               self.settingTable.reloadData()
                             
                            }else{
                                 self.radiusViewToggle.isHidden = false
                             self.globalNotifications = "N"
                              
                             self.settingTable.separatorStyle = UITableViewCellSeparatorStyle.none
                                UserDefaults.standard.set(true, forKey: "flag")
                                self.radiusValue.text = "\("0") Metres"
                                self.globalNotificationSwitch.isOn = false
                                self.radiusSlider.isUserInteractionEnabled = false
                            }
                      
                        self.settingTable.reloadData()
                        }
                    }
                    else{
// decide either radius show from filter or default
                        
                        print(UserDefaults.standard.string(forKey: "DEED_RADIUS")!)
                        self.settingTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                     //   self.radiusValue.text = ("\(String(describing: UserDefaults.standard.string(forKey: "DEED_RADIUS")!))Metres(\(String(describing: UserDefaults.standard.string(forKey: "DEED_RADIUS")!)) kms)")
                        self.radiusSlider.value = Float(UserDefaults.standard.string(forKey: "DEED_RADIUS")!) ?? 0
                            print("Setting is default")
                        self.radiusValue.text = "35 Metres"
                           self.globalNotifications = "Y"
                            self.radius = "35"
//                            self.radiusSlider.value = Float(self.radius)!
                            self.globalNotificationSwitch.isOn = true
                         self.radiusViewToggle.isHidden = true
                            self.selectLangageBtn.setTitle("English", for: .normal)
                    }
                }
            }
        }
    
    
    }
    task.resume()
    }
    
}
