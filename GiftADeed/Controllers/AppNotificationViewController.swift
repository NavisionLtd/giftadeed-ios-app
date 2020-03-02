//
//  AppNotificationViewController.swift
//  GiftADeed
//
//  Created by KTS  on 10/07/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import MMDrawController
import ANLoader
import ListPlaceholder
import Localize_Swift
import EFInternetIndicator
struct notify {
    var date = ""
    var time = ""
    var nt_type = ""
    var tag_type = ""
    var Geopoint = ""
    var Need_Name = ""
    var tag_id = ""
    var seen = ""
    var distance_in_kms = ""
}
class AppNotificationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,InternetStatusIndicable {
   
    var internetConnectionIndicator:InternetViewIndicator?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.notificationArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AppNotificationTableViewCell
        let value = notificationArr[indexPath.row]
        print(value.seen)
        if(value.seen == "0"){//not read
            cell.name?.font =  UIFont(name:"Avenir Next Bold", size: 14.0)
            if(value.nt_type == "fulfill"){
                let text = "Your tag for"
                let text1 = "has been fulfilled."
                cell.name!.textColor = UIColor.darkGray
                cell.name!.text =  String(format: "\(text.localized()) %@ \(text1.localized())", (value.Need_Name).localized())
            }
            else{
                let text = "There was a tag for"
                let text1 = "near you."
                cell.name!.textColor = UIColor.darkGray
                cell.name!.text = String(format: "\(text.localized()) %@ \(text1.localized())", (value.Need_Name).localized())
            }
            
        }
        else{
            cell.name?.font =  UIFont(name:"Avenir Next Regular", size: 13.0)
            if(value.nt_type == "fulfill"){
                let text = "Your tag for"
                let text1 = "has been fulfilled."
                cell.name!.textColor = UIColor.gray
                cell.name!.text =  String(format: "\(text.localized()) %@ \(text1.localized())", (value.Need_Name))
            }
            else{
                let text = "There was a tag for"
                let text1 = "near you."
                cell.name!.textColor = UIColor.gray
                cell.name!.text = String(format: "\(text.localized()) %@ \(text1.localized())", (value.Need_Name))
            }
        }
        
       cell.date?.text = value.date
       
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = notificationArr[indexPath.row]
        if(value.nt_type == "fulfill"){
            self.view.makeToast("Tag is already fulfilled".localized())
        }
        else{
            let tagger = self.storyboard?.instantiateViewController(withIdentifier: "TaggerDetailsViewController") as! TaggerDetailsViewController
            print(value.tag_id)
            tagger.deedId = String(format: "%@",value.tag_id)
            self.navigationController?.pushViewController(tagger, animated: true)
        }
       
    }
    //MARK:- Download notification count data
    func downloadNotificationData(){
        DispatchQueue.main.async {
            self.userId = UserDefaults.standard.value(forKey: "User_ID") as! String
            // Ask for Authorisation from the User.
            self.locManager.requestAlwaysAuthorization()
            
            // For use in foreground
            self.locManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                self.locManager.delegate = self
                self.locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locManager.startUpdatingLocation()
            }
            self.locManager.requestWhenInUseAuthorization()
            
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                guard let currentLocation = self.locManager.location else {
                    return
                }
                print(currentLocation.coordinate.latitude)
                print(currentLocation.coordinate.longitude)
                
                let geo = String(format: "%f,%f", (currentLocation.coordinate.latitude),(currentLocation.coordinate.longitude))
                print(geo)
                ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
                
                let urlString = Constant.BASE_URL + Constant.notification_count
                
                let url:NSURL = NSURL(string: urlString)!
                
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = 60.0
                let session = URLSession(configuration: sessionConfig)
                
                let request = NSMutableURLRequest(url: url as URL)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
                request.httpMethod = "POST"
                
                let paramString = String(format: "userId=%@&lat_long=%@", self.userId,geo)
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
                            
                            self.navigationController?.view.hideAllToasts()
                            self.navigationController?.view.makeToast(Validation.ERROR.localized())
                        }
                        return
                    }
                    
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                        print(jsonObj!)
                        
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
                            
                            //                    self.menuCollectionView.dataSource = self
                            //                    self.menuCollectionView.delegate = self
                            //
                            
                            let notificationCount = Int((jsonObj?.value(forKey:"nt_count") as? String)!)!
                            UserDefaults.standard.set(notificationCount, forKey: "count")
                            ANLoader.hide()
                        }
                    }
                }
                
                task.resume()
            }
        }
        
    }
    let defaults = UserDefaults.standard
    var userId = ""

     var notificationArr = [notify]()
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    @IBOutlet weak var notificationTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        userId = defaults.value(forKey: "User_ID") as! String
        self.downloadData()
         self.navigationBarButton()
        let notificationStatus = defaults.value(forKey: "NOTIFICATIONSTATUS")
        if ((notificationStatus as AnyObject).isEqual("FALSE")){
            
            notificationBtn.setImage(UIImage(named: "notificationoff"), for: .normal)
        }
        else{
            
            notificationBtn.setImage(UIImage(named: "notification"), for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        if let drawer = self.drawer() ,
            let manager = drawer.getManager(direction: .left){
            let value = !manager.isShow
            drawer.showLeftSlider(isShow: value)
        }
    }
    
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
        notificationBtn.addTarget(self, action: #selector(AppNotificationViewController.notificationAction), for: .touchUpInside)
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
        self.navigationItem.title = "Notifications".localized()
        filterBtnItem.isEnabled = true
        if GlobalClass.sharedInstance.notifilterStatus {
            self.notificationArr.removeAll()
            //if filter apply then show the notifications
            print(GlobalClass.sharedInstance.notifilterDistanceVal)
            print(GlobalClass.sharedInstance.notifilterTimeVal)
            print(GlobalClass.sharedInstance.notifilterCategoryValue )
            
         self.downloadData()
            
        }
        
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
    func downloadData(){
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
                    self.navigationController?.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj!)
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
                        let geoPoints = (item as AnyObject).value(forKey: "Geopoint") as! String
                        let Need_Name = (item as AnyObject).value(forKey: "Need_Name") as! String
                        let date = (item as AnyObject).value(forKey: "date") as! String
                        let distance_in_kms = (item as AnyObject).value(forKey: "distance_in_kms") as? String
                        let nt_type = (item as AnyObject).value(forKey: "nt_type") as! String
                        let seen = (item as AnyObject).value(forKey: "seen") as! String
                        let tag_id = (item as AnyObject).value(forKey: "tag_id") as! String
                        let tag_type = (item as AnyObject).value(forKey: "tag_type") as! String
                        let time = (item as AnyObject).value(forKey: "time") as! String
                        let model = notify(date: date, time: time, nt_type: nt_type, tag_type: tag_type, Geopoint: geoPoints, Need_Name: Need_Name, tag_id: tag_id, seen: seen, distance_in_kms: distance_in_kms ?? "0")
                        //To find current date
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let currentDate = Date()
                        //record date coming from API
                        let notificationDate = dateFormatter.date(from: date)
                        let diffBtndays = GlobalClass.sharedInstance.daysBetweenDates(startDate: currentDate, endDate:notificationDate!)
                        print(GlobalClass.sharedInstance.notifilterCategoryValue)
                        print("\(GlobalClass.sharedInstance.notifilterDistanceVal),\(distance_in_kms)")
                        print(GlobalClass.sharedInstance.notifilterTimeVal)
                        let latlong = geoPoints.components(separatedBy: ",")
                        let lat    = (latlong[0] as NSString).doubleValue
                        let long = (latlong[1] as NSString).doubleValue
                       
                        let locationOne = CLLocation(latitude: self.currentLatLong.coordinate.latitude, longitude: self.currentLatLong.coordinate.longitude)
                        let locationTwo = CLLocation(latitude: lat,longitude: long)
                       let distanceInMeters = Double(locationOne.distance(from: locationTwo))
                       let distanceInKM = distanceInMeters/1000.0
                        
                        print("\(distanceInKM)")
                     
                        let diffInDays = Calendar.current.dateComponents([.day], from: notificationDate!, to: currentDate).day
                      //  let diffInDays = Calendar.current.dateComponents([.day], from: notificationDate, to: currentDate!).day
                          print("\(diffInDays)\(GlobalClass.sharedInstance.notifilterTimeVal)")
                       
                        if(GlobalClass.sharedInstance.notifilterDistanceVal == 10){
                            if(GlobalClass.sharedInstance.notifilterTimeVal == 10 || GlobalClass.sharedInstance.notifilterTimeVal == 7){
                                if(GlobalClass.sharedInstance.notifilterCategoryValue == "All" || GlobalClass.sharedInstance.notifilterCategoryValue == ""){
                                     self.notificationArr.append(model)
                                }
                                else if(GlobalClass.sharedInstance.notifilterCategoryValue == Need_Name){
                                    self.notificationArr.append(model)
                                }
                            }
                            else if(diffInDays! <= GlobalClass.sharedInstance.notifilterTimeVal){
                                 self.notificationArr.append(model)
                            }
                        }
                        else if(Int(distanceInKM) <= GlobalClass.sharedInstance.notifilterDistanceVal){
                            if(diffInDays! <= GlobalClass.sharedInstance.notifilterTimeVal){
                                if(GlobalClass.sharedInstance.notifilterCategoryValue == Need_Name){
                                    self.notificationArr.append(model)
                                }
                                else if(GlobalClass.sharedInstance.notifilterCategoryValue == "All"){
                                    self.notificationArr.append(model)
                                }
                            }
                            else if(GlobalClass.sharedInstance.notifilterTimeVal == 10 || GlobalClass.sharedInstance.notifilterTimeVal == 7){
                                self.notificationArr.append(model)
                            }
                           
                        }
                        
                    }
                    
                    DispatchQueue.main.async{
                        self.notificationTblView.showLoader()
                        self.notificationTblView.reloadData()
                          self.downloadNotificationData()
                         Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(AppNotificationViewController.removeLoader), userInfo: nil, repeats: false)
                    }
                }
            }
        }
        task.resume()
    }
    @objc func removeLoader()
    {
        self.notificationTblView.hideLoader()
    }
}
