//
//  SliderViewController.swift
//  MMDrawController
//
//  Created by Millman YANG on 2017/3/30.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//
//import CoreData
import CoreLocation
import ANLoader
import MapKit
import CoreData
import UIKit
import MMDrawController
import Firebase
import Localize_Swift
import FirebaseStorage
import FirebaseDatabase
import Firebase
extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}
var titleArr = [""]
let imgArr = ["home_icon","tag_a_deed_icon","group_icon","inspire_icon","resources_icon_1","about_app","notification_icon","settings_icon","Address_book","logout_icon-1"]
class SliderViewController: UIViewController,CLLocationManagerDelegate {
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    @IBOutlet weak var versionOutlet: UILabel!
    @IBOutlet weak var outletViewProfile: UIButton!
    @IBOutlet weak var versionView: UIView!
    // Firebase services
    var database = FIRDatabase.database()
    var storage = FIRStorage.storage()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var versionText: UILabel!
    @IBOutlet  var outletName: UILabel!
    @IBOutlet weak var outletEmail: UILabel!
    let defaults = UserDefaults.standard
    var serviceCallFlag : Bool = true
    var userId = ""
    var geo = ""
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var imgAvater:UIImageView!
    @IBOutlet weak var outletIcon: UIImageView!
    @IBOutlet weak var countTxt: UILabel!
    var groupArr = NSMutableArray()
    var groupListArr = NSMutableArray()
    var notificationCount : Int = 0
    override func viewDidAppear(_ animated: Bool) {
        let lng = UserDefaults.standard.value(forKey: "language") as? String
        //print(lng)
        titleArr =  ["Home".localized(),"Tag A Deed".localized(),"Groups".localized(),"Inspire Community".localized(),"Resources".localized(),"Dashboard".localized(),"Notifications".localized(),"Setting".localized(),"Emergency Contacts".localized(),"Logout".localized()]
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent("Options"+".plist")
        
        if let filePath = Bundle.main.path(forResource: "Options", ofType: "plist"),
            let dataDictionary = NSDictionary(contentsOfFile: filePath){
            
            var output:AnyObject = false as AnyObject
            output = dataDictionary.object(forKey: "firstcontact")! as AnyObject
            //print(output as! String)
            if(output as! String  == "0")
            {
                //print("Primary Number is not Set for SOS")
            }
            else{
                // sosLbl.isHidden = true
                tabBarController?.tabBar.items?[3].badgeValue = nil
                
            }
        }
        
        var output:AnyObject = false as AnyObject
        if let dict = NSMutableDictionary(contentsOfFile: path){
            output = dict.object(forKey: "firstcontact")! as AnyObject
            //print(output)
            if(output as! String == "0")
            {
                
                tabBarController?.tabBar.items?[3].badgeValue = "1"
                //print("Primary Number is not Set for SOS")
            }
            else{
                
                tabBarController?.tabBar.items?[3].badgeValue = nil
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionView.addTopBorder(UIColor.black, height: 0.4)
        //  self.outletName.addBottomBorder(UIColor.white, height: 0.5)
        userId = defaults.value(forKey: "User_ID") as? String ?? "0"
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        self.setText()
        self.tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.black
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        // tableView.backgroundView = UIImageView(image: UIImage(named: "splash"))
        // Do any additional setup after loading the view.
        
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "1.0"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "1.0"
        let versionAndBuildNumber = "Ver #\(versionNumber) ( Build #\(buildNumber) )"
        versionText.text = ("\(versionNumber)" as! String)
      
        
        //print()
    }
    
    @IBAction func editProfileBtnPress(_ sender: UIButton) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "profile") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setText()
     
        self.tableView.reloadData()
        DispatchQueue.main.async {
            //            self.tableView.reloadData()
            
            self.downloadProfileImg()
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
                //print(currentLocation.coordinate.latitude)
                //print(currentLocation.coordinate.longitude)
                self.geo = String(format: "%f,%f", currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)
            }
            DispatchQueue.main.async {
                // self.downloadData()
            }
        }
    }
    @IBAction func termsBtnPress(_ sender: UIButton) {
        GlobalClass.sharedInstance.menuIndex = "10"
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WebView") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setup()
    }
    @objc func setText(){
        self.versionOutlet.text = "Gift a Deed version :".localized()
        self.outletViewProfile.setTitle("View profile".localized(), for: .normal)
        let lname = UserDefaults.standard.value(forKey: "Lname") as? String
        let Lname = lname!.localized()
        let fname = UserDefaults.standard.value(forKey: "Fname") as? String
        let Fname = fname!.localized()
        //Email
        let email = UserDefaults.standard.value(forKey: "Email") as? String
        let Email = email!.localized()
        
        self.outletName.text = String(format:"%@ %@",Fname,Lname).localized()
        self.outletEmail.text = Email
    }
    func setup() {
        self.imgAvater.clipsToBounds = true
        self.imgAvater.layer.borderWidth=0.5
        self.imgAvater.layer.borderColor = UIColor.black.cgColor
        self.imgAvater.layer.cornerRadius = imgAvater.frame.height/2
    }
    func downloadOwnGroupData (){
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.owned_groups
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@",userId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    //self.view.hideAllToasts()
                    //self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                
                self.groupListArr.removeAllObjects();
                self.groupArr.removeAllObjects();
                
                for item in jsonObj! {
                    
                    do {
                        
                        try self.groupListArr.add((item as AnyObject).value(forKey:"group_name") as! String)
                        
                        let groupItem = item as? NSDictionary
                        try self.groupArr.add(groupItem!)
                        
                    } catch {
                        // Error Handling
                        //print("Some error occured.")
                    }
                    
                }
              
                
            }
            
        }
        task.resume()
    }
    
    func downloadProfileImg(){
        let dbRef = database.reference().child("usersDev/profile")
         //usersDev/profile test //users/profile production
        dbRef.observeSingleEvent(of:.value) { (snapshot) in
            if !snapshot.exists() { return }
            
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                //print(data)
                let object = data.value as? [String:AnyObject]
                let id = object?["userid"]
                //print(id,self.userId)
                if (id?.isEqual(self.userId))!{
                    let downloadUrl = object?["photourl"]
                    //print(downloadUrl!)
                    UserDefaults.standard.set(downloadUrl, forKey: "userimg") //setObject
                    
                    let storageRef = self.storage.reference(forURL: downloadUrl as! String)
                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
                    storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        // Create a UIImage, add it to the array
                        let pic = UIImage(data: data!)
                        self.imgAvater.layer.cornerRadius =  self.imgAvater.frame.size.width / 2
                        self.imgAvater.clipsToBounds = true
                        self.imgAvater.layer.borderWidth = 0.5
                        self.imgAvater.layer.borderColor = UIColor.white.cgColor
                        self.imgAvater.image = pic
                    }
                }
                else{
                    
                    //print("Default Image")
                }
            }
        }
    }
    
    //Logout server to clear device token
    func logoutService(){
        
        //   ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.logout
        let url:NSURL = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let diviceToken = GlobalClass.sharedInstance.nullToNil(value: FIRInstanceID.instanceID().token() as AnyObject) as! String
        
        let paramString = String(format: "user_id=%@&device_id=%@",userId,diviceToken)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            if let data = data {
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    
                    guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            
                            ANLoader.hide()
                        }
                        
                        DispatchQueue.main.async {
                            
                            self.navigationController?.view.hideAllToasts()
                            self.view.makeToast("Something went wrong, Please try again.".localized())
                        }
                        
                        return
                    }
                    
                    let status = jsonObj?.value(forKey:"status") as? Int
                    if status==1{
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            
                            ANLoader.hide()
                        }
                        
                        DispatchQueue.global(qos:.userInteractive).async {
                            
                            self.deleteEntity()
                            GlobalClass.sharedInstance.deInitClass()
                            GlobalClass.sharedInstance.clearLocalData()
                            UserDefaults.standard.removeObject(forKey: "back")
                            self.resetDefaults()
                            DispatchQueue.main.async {
                                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                                
                            }
                        }
                    }
                }
            } else if error != nil {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    // ANLoader.hide()
                }
                DispatchQueue.main.async {
                    
                    self.navigationController?.view.hideAllToasts()
                    self.view.makeToast("Something went wrong, Please try again.".localized())
                }
                return
            } else {
                
                // no data and no error... what happened???
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    // ANLoader.hide()
                }
                DispatchQueue.main.async {
                    
                    self.navigationController?.view.hideAllToasts()
                    self.view.makeToast("Something went wrong, Please try again.".localized())
                }
                return
            }
        }
        task.resume()
    }
    
    //    //MARK:- Delete Core data all data
    //    func deleteEntity() {
    //
    //      //  self.deleteAllData(entity: "Notifications")
    //    }
    //
    //    func deleteAllData(entity: String)
    //    {
    //        let context = appDelegate.persistentContainer.viewContext
    //        // Create Fetch Request
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    //
    //        // Create Batch Delete Request
    //        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    //
    //        do {
    //            try context.execute(batchDeleteRequest)
    //
    //        } catch {
    //            // Error Handling
    //        }
    //    }
    
}

extension SliderViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let d = self.drawer() {
            d.showLeftSlider(isShow: false)
            if indexPath.row == 0 {
                d.setMain(identifier: "Home", config: { (vc) in
                    if let nav = vc as? UINavigationController {
                        nav.viewControllers.first?.title = "Home"
                    }
                })
            }
            if indexPath.row == 1 {
                d.setMain(identifier: "TagAdeed", config: { (vc) in
                    if let nav = vc as? UINavigationController {
                        //   UserDefaults.standard.set(true, forKey: "Tag A Deed")
                        UserDefaults.standard.set("menu", forKey: "Tag A Deed")
                        nav.viewControllers.first?.title = "Tag A Deed"
                    }
                })
            }
            if indexPath.row == 2 {
                d.setMain(identifier: "group", config: { (vc) in
                    if let nav = vc as? UINavigationController {
                        nav.viewControllers.first?.title = "Groups"
                    }
                })
            }
            if indexPath.row == 3 {
                d.setMain(identifier: "sendbird", config: { (vc) in
                    if let nav = vc as? UINavigationController {
                        nav.viewControllers.first?.title = "Inspire Community"
                    }
                })
            }
            if indexPath.row == 4 {

                    d.setMain(identifier: "resource", config: { (vc) in
                        if let nav = vc as? UINavigationController {
                            
                            nav.viewControllers.first?.title = "Resources"
                        }
                    })
             
            }
            if indexPath.row == 5 {
                d.setMain(identifier: "AboutUsSegue", config: { (vc) in
                    if let nav = vc as? UINavigationController {
                        nav.viewControllers.first?.title = "Dashboard"
                    }
                })
            }
            if indexPath.row == 6 {
                d.setMain(identifier: "Notification", config: { (vc) in
                    if let nav = vc as? UINavigationController {
                        //                        nav.viewControllers.first?.title = "SOS"
                    }
                })
            }
            if indexPath.row == 7 {
                d.setMain(identifier: "SettingSeque", config: { (vc) in
                    if let nav = vc as? UINavigationController {
                        nav.viewControllers.first?.title = "Setting"
                    }
                })
            }
            if indexPath.row == 8 {
                d.setMain(identifier: "sos", config: { (vc) in
                    if let nav = vc as? UINavigationController {
                        UserDefaults.standard.set("menu", forKey: "Emergency Contactemer")
                        nav.viewControllers.first?.title = "Emergency Contact's"
                    }
                })
            }
            if indexPath.row==9{
                
                DispatchQueue.main.async {
                    
                    if Device.IS_IPHONE {
                        
                        let optionMenu = UIAlertController(title: nil, message: "Do you really want to logout?".localized(), preferredStyle: .actionSheet)
                        
                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default, handler:
                        {
                            (alert: UIAlertAction!) -> Void in
                            
                            self.logoutService()
                        })
                        
                        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:
                        {
                            (alert: UIAlertAction!) -> Void in
                        })
                        
                        optionMenu.addAction(okAction)
                        optionMenu.addAction(cancelAction)
                        
                        self.present(optionMenu, animated: true, completion: nil)
                    }
                    else {
                        
                        let alertController = UIAlertController(title: nil, message: "Do you really want to logout?".localized(), preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "Ok".localized(), style: .default, handler:
                        {
                            (alert: UIAlertAction!) -> Void in
                            
                            self.logoutService()
                        })
                        
                        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler:
                        {
                            (alert: UIAlertAction!) -> Void in
                        })
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(okAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            
        }
    }
    //MARK:- Delete Core data all data
    func deleteEntity() {
        
        self.deleteAllData(entity: "Notifications")
    }
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    func deleteAllData(entity: String)
    {
        let context = appDelegate.persistentContainer.viewContext
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
        } catch {
            // Error Handling
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    //MARK:- Download notification count data
    func downloadData(){
        
        // let geo = ("\(currentLatLong.coordinate.latitude),\(currentLatLong.coordinate.longitude)")
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.notification_count
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "userId=%@&lat_long=%@", userId,geo)
        //print(paramString)
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
                //print(jsonObj!)
                
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
                    
                    self.notificationCount = Int((jsonObj?.value(forKey:"nt_count") as? String)!)!
                    //print(self.notificationCount)
                    self.tableView.reloadData()
                    ANLoader.hide()
                }
            }
        }
        
        task.resume()
    }
}

extension SliderViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(self.notificationCount)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") ,
            let label = cell.viewWithTag(100) as? UILabel{
            label.text = titleArr[indexPath.row].localized()
            cell.layoutMargins = UIEdgeInsets.zero
            
            let img = cell.viewWithTag(101) as? UIImageView
            img?.image = UIImage (named: imgArr[indexPath.row])?.maskWithColor(color: UIColor.darkGray)
            if(label.text == "Notifications".localized()){
                let label1 = cell.viewWithTag(102) as? UILabel
                if(UserDefaults.standard.string(forKey: "count") == "0"){
                    label1?.alpha = 0
                }
                else
                {
                    label1?.alpha = 1
                    label1!.layer.masksToBounds = true
                    label1!.layer.cornerRadius = 5
                    //                    label1!.layer.borderWidth = 5.0
                    //                   label1!.layer.borderColor = UIColor.orange.cgColor
                    //print( UserDefaults.standard.string(forKey: "count"))
                    label1!.text =  UserDefaults.standard.string(forKey: "count")
                }
                
            }
            else{
                let label1 = cell.viewWithTag(102) as? UILabel
                label1?.alpha = 0
            }
            
            
            //            if(cell.isSelected){
            //                cell.backgroundColor = UIColor.red
            //            }else{
            //                cell.backgroundColor = UIColor.clear
            //            }
            return cell
        }
        
        return UITableViewCell()
    }
}
