//
//  MenuViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 04/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
/*
 Widgets can be used instead of a list to represent all the options. The UI of the widgets needs to be approved by the client. The Navigation Bar will have the following options -
 •    GAD logo and below it the logged in User’s Name (not clickable)(User Name to be displayed as <First Name><.><First letter of Last Name>)
 •    My Profile
 •    Home (Tagged Deeds/Landing Page)
 •    My Tags
 •    My Fulfilled Tags
 •    Tag A Deed
 •    Top 10 Taggers
 •    Top 10 Tag Fulfillers
 •    Tag counter
 •    Dashboard
 •    About App
 •    Advisory Board
 •    Terms And Conditions
 •    Privacy Policy
 •    Cookies Policy
 •    End-User Licence Agreement
 •    Disclaimer
 •    Help
 •    Contact Us
 •    Notifications
 •    Logout
 */
import EFInternetIndicator
import UIKit
import CoreLocation
import MapKit
import CoreData
import ANLoader
import Firebase
import Localize_Swift
import FirebaseStorage
import FirebaseDatabase
import Firebase


class MenusViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate,InternetStatusIndicable{
   var internetConnectionIndicator:InternetViewIndicator?
    // Firebase services
    var database = FIRDatabase.database()
    var storage = FIRStorage.storage()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet  var outletName: UILabel!
    let defaults = UserDefaults.standard
    
    var serviceCallFlag : Bool = true
    
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet  var menuCollectionView: UICollectionView!
    var menuNameArr : NSMutableArray = []
    var menuImageArr : NSMutableArray = []
    
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    var lat_long = ""
    
    var userId = ""
    
    var notificationCount : Int = 0
    
    @IBOutlet weak var menuNavLbl: UINavigationItem!
    @IBOutlet weak var menuLbl: UILabel!
    @IBOutlet weak var dashboardLbl: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
  self.setText()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        userId = defaults.value(forKey: "User_ID") as! String
        self.findCurrentLocation()
        
        
        
        menuNameArr = ["HOME","MY TAGS","MY FULFILLED TAGS","TAG A DEED","About APP","LOGOUT"]
        //This are the app icons which are present at assets file
        menuImageArr = ["home","mytags","myfullfilledtags","tagadeed","aboutus","logout"]
    }
    @IBAction func editBtnPress(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "url")
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "avtar") as! AvtaarImgViewController
        
        self.addChildViewController(popvc)
        
        popvc.view.frame = self.view.frame
        popvc.view.backgroundColor = UIColor.groupTableViewBackground
        self.view.addSubview(popvc.view)
        self.view.alpha = 0.65
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        popvc.didMove(toParentViewController: self)
    }
    func downloadProfileImg(){
        let dbRef = database.reference().child("myFiles")
        dbRef.observeSingleEvent(of:.value) { (snapshot) in
            if !snapshot.exists() { return }
            
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                print(data)
                let object = data.value as? [String:AnyObject]
                let id = object?["id"]
                print(id,self.userId)
                if (id?.isEqual(self.userId))!{
                    let downloadUrl = object?["url"]
                    print(downloadUrl!)
                    let storageRef = self.storage.reference(forURL: downloadUrl as! String)
                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
                    storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        // Create a UIImage, add it to the array
                        let pic = UIImage(data: data!)
                        self.profileImg.layer.cornerRadius =  self.profileImg.frame.size.width / 2
                        self.profileImg.clipsToBounds = true
                        self.profileImg.layer.borderWidth = 0.5
                        self.profileImg.layer.borderColor = UIColor.white.cgColor
                        self.profileImg.image = pic
                    }
                }
                else{
                    print("Default Image")
                }
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        ANLoader.hide()
        DispatchQueue.main.async {
            
            self.title = "Back"
        }
    }
    @objc func setText(){
    
      
   // self.outletName.text  = "".localized()

        self.menuNavLbl.title = "Menu".localized()
        menuNameArr = ["".localized()]
        dashboardLbl.setTitle("DashBoard".localized(using: "Localizable"), for: UIControlState.normal)
        let lname = UserDefaults.standard.value(forKey: "Lname") as! String
        let Lname = lname.localized()
        let fname = UserDefaults.standard.value(forKey: "Fname") as! String
        let Fname = fname.localized()
        if Lname.count != 0 {
            
            let index = Lname.index(Lname.startIndex, offsetBy: 0)
            self.outletName.text = String(format:"%@. %@",Fname, String(Lname[index])).localized()
        }
        else{
            
            self.outletName.text = String(format:"%@",Fname).localized()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            
           
            
            self.downloadProfileImg()
         
        }
    }

    //To find user current location and initialise location manager
    func findCurrentLocation(){
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locManager = CLLocationManager()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }
    }
    
    //MARK:- Delegate methods for LOcation manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        if serviceCallFlag{
            
            let location = locations.last! as CLLocation
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            serviceCallFlag = false;
            lat_long = String(format :"%f,%f",latitude,longitude)
            locManager.stopUpdatingLocation()
            self.downloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    //MARK:- Navigate to Profile screen
//    @IBAction func myProfileAction(_ sender: Any) {
//        
//        let myProfile = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
//        self.navigationController?.pushViewController(myProfile, animated: true)
//    }
    
    //MARK:- Toggle to Menu screen and previous screen, it will check what will be the previous screen accordingly it will change screen
    @IBAction func menuAction(_ sender: Any) {

        if Int(GlobalClass.sharedInstance.menuIndex)==0 {
            
            DispatchQueue.main.async {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
            
        } else if Int(GlobalClass.sharedInstance.menuIndex)==1{
            
            DispatchQueue.main.async {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "myTags") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
            
        } else if Int(GlobalClass.sharedInstance.menuIndex)==2{
            
            DispatchQueue.main.async {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "myFulfilledTags") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
            
        } else if Int(GlobalClass.sharedInstance.menuIndex)==3{
            
            DispatchQueue.main.async {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tagADeed") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
            
      }
     
        else if Int(GlobalClass.sharedInstance.menuIndex)==4{
            
            DispatchQueue.main.async {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "aboutUs") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
            
        }
     
    }
    
    //MARK: - Table delegate and datasource methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return menuNameArr.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MenuCollectionViewCell
        
        cell.layer.cornerRadius=4.0
        cell.layer.borderWidth=1.0
        cell.layer.borderColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1).cgColor
        
        cell.outletMenuIcon.image=UIImage.init(named: menuImageArr[indexPath.row] as! String)
        cell.outletMenuName.text=(menuNameArr[indexPath.row] as! String).localized()
        
        if indexPath.row==16{
            
            cell.outletNotificationCount.isHidden = false
            
            if( self.notificationCount <= 0){
                
                cell.outletNotificationCount.isHidden = true
            }
            else{
                
                cell.outletNotificationCount.layer.masksToBounds = true
                cell.outletNotificationCount.layer.cornerRadius = cell.outletNotificationCount.bounds.size.height/2
                cell.outletNotificationCount.isHidden = false
                cell.outletNotificationCount.text=String(format: "%d", self.notificationCount)
            }
        }
        else{
            
            cell.outletNotificationCount.isHidden = true
        }
        
        return cell;
    }

    //Set menu icon and sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let screenRect = UIScreen.main.bounds
        var screenWidth : Double
        var cellWidth : Double
        
        if Device.IS_IPHONE {
            
            screenWidth = Double(screenRect.size.width-30);
            cellWidth = screenWidth / 3.0;
        }
        else {
            
            screenWidth = Double(screenRect.size.width-40);
            cellWidth = screenWidth / 4.0;
        }
        let size = CGSize(width: cellWidth, height: cellWidth+15)
        
        return size;
    }
    
    //Cell selection to change Root view (Navigate to respective screen)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row==0 {
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "0"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==1 {
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "1"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "myTags") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==2 {
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "2"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "myFulfilledTags") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==3 {
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "3"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tagADeed") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }

        else if indexPath.row==4{
            
            DispatchQueue.main.async {
                
            GlobalClass.sharedInstance.menuIndex = "4"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "aboutUs") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }

        else if indexPath.row==5{
            
            DispatchQueue.main.async {
                
                if Device.IS_IPHONE {
                    
                    let optionMenu = UIAlertController(title: nil, message: "Do you really want to logout?", preferredStyle: .actionSheet)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler:
                    {
                        (alert: UIAlertAction!) -> Void in
                        
                        self.logoutService()
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                    {
                        (alert: UIAlertAction!) -> Void in
                    })
                    
                    optionMenu.addAction(okAction)
                    optionMenu.addAction(cancelAction)
                    
                    self.present(optionMenu, animated: true, completion: nil)
                }
                else {
                    
                    let alertController = UIAlertController(title: nil, message: "Do you really want to logout?", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler:
                    {
                        (alert: UIAlertAction!) -> Void in
                        
                        self.logoutService()
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
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
    
    //Logout server to clear device token
    func logoutService(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
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
                            
                            DispatchQueue.main.async {
                                
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                            }
                        }
                    }
                }
            } else if let error = error {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
                DispatchQueue.main.async {
                    
                    self.navigationController?.view.hideAllToasts()
                    self.view.makeToast("Something went wrong, Please try again.".localized())
                }
                return
            } else {
                
                // no data and no error... what happened???
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
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

    //MARK:- Delete Core data all data
    func deleteEntity() {
        
        self.deleteAllData(entity: "Notifications")
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
    
    //MARK:- Download notification count data
    func downloadData(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.notification_count
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "userId=%@&lat_long=%@", userId,lat_long)
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
                    
                    self.menuCollectionView.dataSource = self
                    self.menuCollectionView.delegate = self
                    
                    self.notificationCount = Int((jsonObj?.value(forKey:"nt_count") as? String)!)!
                    self.menuCollectionView.reloadData()
                }
            }
        }
        
        task.resume()
    }
}
