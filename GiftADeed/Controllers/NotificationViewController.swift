//
//  NotificationViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 09/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 •    In the Navigation Bar (Menu), the unread notification count will be shown on the Notifications label. Every time the User clicks on the Navigation bar, the Notifications API will be called, and the unread notification count will be calculated based on the Users current GPS location, tags in the vicinity, and notification date. The unread notification count is cumulative, and goes on increasing till the user visits the notification page, and/or till the notifications get deleted after 7 days.
 •    On clicking the Notifications label, the User will be directed to the Notifications page.
 •    The User can see all the notifications from here.
 •    By default, all the notifications will be displayed. They will be displayed in the descending order of date (i.e. newest first).
 •    There will be an option for the User to select the filter based on which notifications will be filtered - Distance, Time and Type of deed. On clicking the Filter button, the Filter selection window will expand below the filter button, with the Filter selection options. The selection ranges will be (1km – 10km: slider), (1 day – 7 days: slider), and (Singledeed selected - All deeds selected: Single select). The default selected filters will be 10km, 7 days, and All deeds selected. The Tags which fulfil the selected criteria will be shownon the Notification screen.
 •    When the User navigates to another page, and comes back to the Notifications page, all the notifications will be shown again. The User will have to again click on the Filters and apply them.
 •    Mute notifications option is also there. When notifications are muted, the push notifications will be disabled in the status bar.
 •    Notifications will be shown when a User’s tagged deed is fulfilled (by others or by the User himself/herself); and when there is a new/edited tag in the selected vicinity of the User (10 km).
 •    Notifications will be stored on the database, as well as the local handsetfor a maximum period of 7 days i.e. the notifications will get deleted after 7 days, irrespective whether the user has read them or not. The locally saved notifications will also get deleted when the app is uninstalled/removed from the phone, or when the User logs out.
 •    The notifications will be shown as follows –
 •    When there is a New Tag - There was a tag for <Deed Type> near you.
 •    When there is an Edited Tag - There was a tag for <Deed Type> near you.
 •    When the user’s tag is fulfilled - Your tag for <Deed Type> has been fulfilled.
 */

import UIKit
import CoreData
import CoreLocation
import ANLoader
import Localize_Swift
//import MMDrawController
import ListPlaceholder
class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate  {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    @IBOutlet weak var menuNotificationsTitle: UINavigationItem!
    @IBOutlet  var outletNoRecord: UILabel!
    @IBOutlet  var outletTableView: UITableView!
    var notificationArr = NSMutableArray()
    var notificationGroupArr = NSMutableArray()
    
    var globalNotificationArr = NSMutableArray()
    
    let defaults = UserDefaults.standard
    var userId = ""
    
    let notificationBtn = UIButton(type: .custom)
    let filterBtn = UIButton(type: .custom)
    
    var filterBtnItem = UIBarButtonItem()
    var notificationBtnItem = UIBarButtonItem()
    
    func navigationBarButton(){
        
        notificationBtn.setImage(UIImage(named: "notification"), for: .normal)
        if Device.IS_IPHONE {
            
            notificationBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        else {
            
            notificationBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        }
        notificationBtn.addTarget(self, action: #selector(NotificationViewController.notificationAction), for: .touchUpInside)
        notificationBtnItem = UIBarButtonItem(customView: notificationBtn)
        
        filterBtn.setImage(UIImage(named: "filterNotification"), for: .normal)
        if Device.IS_IPHONE {
            
            filterBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        }
        else {
            
            filterBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
        }
        filterBtn.addTarget(self, action: #selector(NotificationViewController.filterAction), for: .touchUpInside)
        filterBtnItem = UIBarButtonItem(customView: filterBtn)
        
        self.navigationItem.setRightBarButtonItems([notificationBtnItem,filterBtnItem], animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ANLoader.hide()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
setText()
        
        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationBarButton()
        
        outletTableView.delegate = self
        outletTableView.dataSource = self
        
        userId = defaults.value(forKey: "User_ID") as! String
        self.downloadData()

        let notificationStatus = defaults.value(forKey: "NOTIFICATIONSTATUS")
        if ((notificationStatus as AnyObject).isEqual("FALSE")){
            
            notificationBtn.setImage(UIImage(named: "notificationoff"), for: .normal)
        }
        else{
            
            notificationBtn.setImage(UIImage(named: "notification"), for: .normal)
        }
    }

    func setText(){
        menuNotificationsTitle.title = "Notifications".localized()
        outletNoRecord.text = "No records found".localized()
    }
    @objc func notificationAction() {
        
        let notificationStatus = defaults.value(forKey: "NOTIFICATIONSTATUS")
        if ((notificationStatus as AnyObject).isEqual("FALSE")){
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("ON".localized())
            defaults.set("TRUE", forKey: "NOTIFICATIONSTATUS")
            notificationBtn.setImage(UIImage(named: "notification"), for: .normal)
            UIApplication.shared.registerForRemoteNotifications()
        }
        else{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("OFF".localized())
            defaults.set("FALSE", forKey: "NOTIFICATIONSTATUS")
            notificationBtn.setImage(UIImage(named: "notificationoff"), for: .normal)
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        filterBtnItem.isEnabled = true
        
        if GlobalClass.sharedInstance.notifilterStatus {
            
            self.notificationArr.removeAllObjects()
            self.fetchRecords()
        //outletTableView.reloadData()
           
        }
    }
    @objc func removeLoader()
    {
        self.outletTableView.hideLoader()
    }
    override func viewDidDisappear(_ animated: Bool) {
        GlobalClass.sharedInstance.notifilterStatus = false
    }
    
    //Filter action
    @objc func filterAction() {

        filterBtnItem.isEnabled = false
        let filterView = self.storyboard?.instantiateViewController(withIdentifier: "NotificationFilterViewController")
            as! NotificationFilterViewController
        self.navigationController?.pushViewController(filterView, animated: true)
    }
    
    @IBAction func menuBarAction(_ sender: Any) {
        if let drawer = self.drawer() ,
            let manager = drawer.getManager(direction: .left){
            let value = !manager.isShow
            drawer.showLeftSlider(isShow: value)
        }
//        DispatchQueue.main.async {
//
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "aboutUs") as! UINavigationController
//            UIApplication.shared.keyWindow?.rootViewController = viewController
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print(notificationGroupArr.count)
        return notificationGroupArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let notificationInfo = notificationGroupArr[section] as! NSDictionary
        let arr = notificationInfo["NotificationInfo"] as! NSArray
        print(arr.count)
        return arr.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let notificationInfo = notificationGroupArr[section] as! NSDictionary
        let dateString = notificationInfo["Date"] as! String

        var resultString = ""
        if dateString.isEqual("Today"){
            
            resultString = "Today"
        }
        else{
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
            let showDate = inputFormatter.date(from: dateString)
            inputFormatter.dateFormat = "dd-MM-yyyy"
            resultString = inputFormatter.string(from: showDate!)
        }
        return resultString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? NotificationTableViewCell
        cell?.layer.cornerRadius=2
 
        let notificationInfoDic = notificationGroupArr[indexPath.section] as! NSDictionary
        let notificationInfoArr = notificationInfoDic["NotificationInfo"] as! NSArray
        
        let model = notificationInfoArr[indexPath.row] as? ModelNotification
        
     if(model?.nt_seen == "0")
     {
        cell?.outletMessageLabel.textColor = UIColor(red:0.81, green:0.66, blue:0.245, alpha:1.0)
     //   cell?.outletMessageLabel.backgroundColor = UIColor.green
        cell?.outletMessageLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        
    }
     else{
        
        }
        if (model?.nt_type.isEqual("fulfill"))!{
        
            cell?.outletMessageLabel.textColor = UIColor(red:0.49, green:0.80, blue:0.53, alpha:1.0)
            cell?.outletMessageLabel.text = String(format: "Your tag for %@ has been fulfilled.", (model?.Need_Name)!)
        }
        else{
        
            cell?.outletMessageLabel.textColor = UIColor(red:0.94, green:0.53, blue:0.82, alpha:1.0)
            cell?.outletMessageLabel.text = String(format: "There was a tag for %@ near you.", (model?.Need_Name)!)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }

    //MARK:- Download data for notification
    //Download data for notification and notifications are less then 7 days then not get notifications other get notification save it in core data
    func downloadData (){
        currentLatLong = locManager.location!
        let geo = ("\(currentLatLong.coordinate.latitude),\(currentLatLong.coordinate.longitude)")
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.app_notify
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "userId=%@&geopoints=%@",userId,geo)
        print(paramString)
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
                        
                        GlobalClass.sharedInstance.blockStatus = true
                    }
                    return
                }
                
                if let notificationslist = jsonObj!.value(forKey: "notifications") as? NSArray {
                    
                    for item in notificationslist {
                        
                        let notifyItem = item as? NSDictionary
                        let context = self.appDelegate.persistentContainer.viewContext
                        let entity = NSEntityDescription.entity(forEntityName: "Notifications", in: context)
                        let newUser = NSManagedObject(entity: entity!, insertInto: context)
                        newUser.setValue((notifyItem as AnyObject).value(forKey:"date") as! String, forKey: "date")
                        newUser.setValue((notifyItem as AnyObject).value(forKey:"time") as! String, forKey: "time")
                        newUser.setValue((notifyItem as AnyObject).value(forKey:"nt_type") as! String, forKey: "nt_type")
                        newUser.setValue((notifyItem as AnyObject).value(forKey:"tag_type") as! String, forKey: "tag_type")
                        newUser.setValue((notifyItem as AnyObject).value(forKey:"Geopoint") as! String, forKey: "geopoint")
                        newUser.setValue((notifyItem as AnyObject).value(forKey:"Need_Name") as! String, forKey: "need_Name")
                         newUser.setValue((notifyItem as AnyObject).value(forKey:"seen") as! String, forKey: "nt_seen")
                        do {
                            
                            try context.save()
                            print("Saved")
                        } catch {
                            print("Failed saving")
                        }
                    }
                    
                    DispatchQueue.main.async{
                            
                         self.fetchRecords()
                    }
                }
            }
        }
        task.resume()
    }
    
    //Find current location
    func findCurrentLocation(){
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locManager = CLLocationManager()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let currentLocation = locManager.location!
        
        locManager.stopMonitoringSignificantLocationChanges()
        locManager.stopUpdatingLocation()
        
        currentLatLong = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return components.day!
    }

    //Fetch record from core data and check if notification are less then 7 days and Distance from current location and filter radius data, then only get notification from core data other wise delete notification core data
    func fetchRecords(){
        
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        
        request.returnsObjectsAsFaults = false
        do {
            
            self.notificationArr.removeAllObjects()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let currentDate = Date()
            
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {

                let date = dateFormatter.date(from: data.value(forKey: "date") as! String)
                
                if GlobalClass.sharedInstance.notifilterStatus {
                    
                    let latlongStr = String(format: "%@", data.value(forKey: "geopoint") as! String)
                    let latlong = latlongStr.components(separatedBy: ",")
                    let lat    = (latlong[0] as NSString).doubleValue
                    let long = (latlong[1] as NSString).doubleValue
                    print(data.value(forKey: "nt_seen") as? String)
                    let tagerLatLong = CLLocation(latitude: lat, longitude: long)
                    let distanceInMeters : Int = Int(currentLatLong.distance(from: tagerLatLong))
                    
                    var diffBtndays = GlobalClass.sharedInstance.daysBetweenDates(startDate: currentDate, endDate: date!)
                    if diffBtndays < 0{
                        
                        diffBtndays = diffBtndays * -1
                    }
                    
                    if distanceInMeters >= GlobalClass.sharedInstance.notifilterDistanceVal || diffBtndays >= GlobalClass.sharedInstance.notifilterTimeVal{

                        if diffBtndays < 7 {
                            
                            let needName = data.value(forKey: "need_Name") as! String
                            if GlobalClass.sharedInstance.notifilterCategoryValue.isEqual("All"){
                                   print(data.value(forKey: "nt_seen") as? String)
                                let notificationModel = ModelNotification.init(date: data.value(forKey: "date") as! String, time: data.value(forKey: "time") as! String, nt_type: data.value(forKey: "nt_type") as! String, tag_type: data.value(forKey: "tag_type") as! String, Geopoint: data.value(forKey: "geopoint") as! String, Need_Name: data.value(forKey: "need_Name") as! String, numberDays:diffBtndays, nt_seen:  data.value(forKey: "nt_seen") as! String)
                                
                                do {
                                    
                                    try self.notificationArr.add(notificationModel as Any)
                                    
                                } catch {
                                    // Error Handling
                                    print("Some error occured.")
                                }
                                
                            }
                            else  if GlobalClass.sharedInstance.notifilterCategoryValue.isEqual(needName) {
                                
                                let notificationModel = ModelNotification.init(date: data.value(forKey: "date") as! String, time: data.value(forKey: "time") as! String, nt_type: data.value(forKey: "nt_type") as! String, tag_type: data.value(forKey: "tag_type") as! String, Geopoint: data.value(forKey: "geopoint") as! String, Need_Name: data.value(forKey: "need_Name") as! String, numberDays:diffBtndays, nt_seen: data.value(forKey: "nt_seen") as! String)
                                
                                do {
                                    
                                    try self.notificationArr.add(notificationModel as Any)
                                    
                                } catch {
                                    // Error Handling
                                    print("Some error occured.")
                                }
                                
                            }
                        }
                        else{
                            
                            let context = appDelegate.persistentContainer.viewContext
                            context.delete(data)
                            do {
                                
                                try context.save()
                            } catch {
                                print("Failed saving")
                            }
                        }
                    }
                }
                else{
                       print(data.value(forKey: "nt_seen") as? String)
                    let NumOfDays: Int = GlobalClass.sharedInstance.daysBetweenDates(startDate: date!, endDate: currentDate)
                    if NumOfDays < 7 {
                        
                        let notificationModel = ModelNotification.init(date: data.value(forKey: "date") as! String, time: data.value(forKey: "time") as! String, nt_type: data.value(forKey: "nt_type") as! String, tag_type: data.value(forKey: "tag_type") as! String, Geopoint: data.value(forKey: "geopoint") as! String, Need_Name: data.value(forKey: "need_Name") as! String,numberDays:NumOfDays, nt_seen: data.value(forKey: "nt_seen") as! String)
                        
                        do {
                            
                            try self.notificationArr.add(notificationModel as Any)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                        
                        let sortedArray = self.notificationArr.sortedArray {
                            (obj1, obj2) -> ComparisonResult in
                            
                            let p1 = obj1 as! ModelNotification
                            let p2 = obj2 as! ModelNotification
                            
                            let result = p1.date.compare(p2.date)
                            return result
                        }
                        
                        self.notificationArr.removeAllObjects()
                        self.notificationArr = NSMutableArray(array: sortedArray)
                        self.notificationArr =  NSMutableArray(array: self.notificationArr.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
                    }
                    else{
                        
                        let context = appDelegate.persistentContainer.viewContext
                        context.delete(data)
                        do {
                            
                            try context.save()
                        } catch {
                            print("Failed saving")
                        }
                    }
                }
            }
            
            self.groupNotificationValues()
            
        } catch {
            
            print("Failed")
        }
    }

    //Group notification data by date
    func groupNotificationValues(){
        
        notificationGroupArr.removeAllObjects()
        
        let zeroNotificationArr = NSMutableArray()
        let oneNotificationArr = NSMutableArray()
        let twoNotificationArr = NSMutableArray()
        let threeNotificationArr = NSMutableArray()
        let fourNotificationArr = NSMutableArray()
        let fiveNotificationArr = NSMutableArray()
        let sixNotificationArr = NSMutableArray()
        let sevenNotificationArr = NSMutableArray()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let zeroDic = NSMutableDictionary()
        //var zeroDate = ""
        let oneDic = NSMutableDictionary()
        var oneDate = ""
        let twoDic = NSMutableDictionary()
        var twoDate = ""
        let threeDic = NSMutableDictionary()
        var threeDate = ""
        let fourDic = NSMutableDictionary()
        var fourDate = ""
        let fifthDic = NSMutableDictionary()
        var fifthDate = ""
        let sixthDic = NSMutableDictionary()
        var sixthDate = ""
        let seventhDic = NSMutableDictionary()
        var seventhDate = ""
        
        for i in 0..<self.notificationArr.count {
            
            let model = notificationArr[i] as! ModelNotification

            if model.numberDays <= 0{
                
                do {
                    
                    try zeroNotificationArr.add(model)
                    
                } catch {
                    // Error Handling
                    print("Some error occured.")
                }
                
            }
            else if model.numberDays == 1{
                
                do {
                    
                    oneDate = String(format:"%@",formatter.date(from: model.date)! as CVarArg)
                    try oneNotificationArr.add(model)
                    
                } catch {
                    // Error Handling
                    print("Some error occured.")
                }
                
            }
            else if model.numberDays == 2{
                
                do {
                    
                    twoDate = String(format:"%@",formatter.date(from: model.date)! as CVarArg)
                    try twoNotificationArr.add(model)
                    
                } catch {
                    // Error Handling
                    print("Some error occured.")
                }
                
            }
            else  if model.numberDays == 3{
                
                do {
                    
                    threeDate = String(format:"%@",formatter.date(from: model.date)! as CVarArg)
                    try threeNotificationArr.add(model)
                    
                } catch {
                    // Error Handling
                    print("Some error occured.")
                }
                
            }
            else if model.numberDays == 4{
                
                do {
                    
                    fourDate = String(format:"%@",formatter.date(from: model.date)! as CVarArg)
                    try fourNotificationArr.add(model)
                    
                } catch {
                    // Error Handling
                    print("Some error occured.")
                }
                
            }
            else if model.numberDays == 5{
                
                do {
                    
                    fifthDate = String(format:"%@",formatter.date(from: model.date)! as CVarArg)
                    try fiveNotificationArr.add(model)
                    
                } catch {
                    // Error Handling
                    print("Some error occured.")
                }
                
            }
            else if model.numberDays == 6{
                
                do {
                    
                    sixthDate = String(format:"%@",formatter.date(from: model.date)! as CVarArg)
                    try sixNotificationArr.add(model)
                    
                } catch {
                    // Error Handling
                    print("Some error occured.")
                }
                
            }
            else if model.numberDays == 7{
                
                do {
                    
                    seventhDate = String(format:"%@",formatter.date(from: model.date)! as CVarArg)
                    try sevenNotificationArr.add(model)
                    
                } catch {
                    // Error Handling
                    print("Some error occured.")
                }
                
            }
        }
        if(zeroNotificationArr.count>0){
            
            do {
                
                zeroDic.setValue("Today", forKey: "Date")
                try zeroDic.setObject(zeroNotificationArr, forKey: "NotificationInfo" as NSCopying)
                try notificationGroupArr.add(zeroDic)
                
            } catch {
                // Error Handling
                print("Some error occured.")
            }
            
        }
        
        if(oneNotificationArr.count>0){
            
            do {
                
                oneDic.setValue(oneDate, forKey: "Date")
                try oneDic.setObject(oneNotificationArr, forKey: "NotificationInfo" as NSCopying)
                try notificationGroupArr.add(oneDic)
                
            } catch {
                // Error Handling
                print("Some error occured.")
            }
            
        }
        
        if(twoNotificationArr.count>0){
            
            do {
                
                twoDic.setValue(twoDate, forKey: "Date")
                try twoDic.setObject(twoNotificationArr, forKey: "NotificationInfo" as NSCopying)
                try notificationGroupArr.add(twoDic)
                
            } catch {
                // Error Handling
                print("Some error occured.")
            }
            
        }
        
        if(threeNotificationArr.count>0){
            
            do {
                
                threeDic.setValue(threeDate, forKey: "Date")
                try threeDic.setObject(threeNotificationArr, forKey: "NotificationInfo" as NSCopying)
                try notificationGroupArr.add(threeDic)
                
            } catch {
                // Error Handling
                print("Some error occured.")
            }

        }
        
        if(fourNotificationArr.count>0){
            
            do {
                
                fourDic.setValue(fourDate, forKey: "Date")
                try fourDic.setObject(fourNotificationArr, forKey: "NotificationInfo" as NSCopying)
                try notificationGroupArr.add(fourDic)
                
            } catch {
                // Error Handling
                print("Some error occured.")
            }
            
        }
        
        if(fiveNotificationArr.count>0){
            
            do {
                
                fifthDic.setValue(fifthDate, forKey: "Date")
                try fifthDic.setObject(fiveNotificationArr, forKey: "NotificationInfo" as NSCopying)
                try notificationGroupArr.add(fifthDic)
                
            } catch {
                // Error Handling
                print("Some error occured.")
            }

        }
        
        if(sixNotificationArr.count>0){
            
            do {
                
                sixthDic.setValue(sixthDate, forKey: "Date")
                try sixthDic.setObject(sixNotificationArr, forKey: "NotificationInfo" as NSCopying)
                try notificationGroupArr.add(sixthDic)
                
            } catch {
                // Error Handling
                print("Some error occured.")
            }

        }
        
        if(sevenNotificationArr.count>0){
            
            do {
                
                seventhDic.setValue(seventhDate, forKey: "Date")
                try seventhDic.setObject(sevenNotificationArr, forKey: "NotificationInfo" as NSCopying)
                try notificationGroupArr.add(seventhDic)
                
            } catch {
                // Error Handling
                print("Some error occured.")
            }

        }

        if notificationGroupArr.count != 0 {
            
            DispatchQueue.main.async{
                
                self.outletNoRecord.isHidden = true
                self.updateUI()
            }
        }
        else{
            
            DispatchQueue.main.async{
                
                self.outletNoRecord.isHidden = false
            }
        }
    }
    
    //Update table view
    func updateUI() {
        self.outletTableView.showLoader()
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(NotificationViewController.removeLoader), userInfo: nil, repeats: false)
        outletTableView.reloadData()
    }
}
