//
//  AboutUsViewController.swift
//  GiftADeed
//
//  Created by Darshan on 8/1/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
import EFInternetIndicator
import UIKit
import CoreData
import ANLoader
import Firebase
import CoreLocation
import MMDrawController
class AboutUsViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,InternetStatusIndicable {
   var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var menuTagAdeedTitle: UINavigationItem!
    @IBOutlet  var menuCollectionView: UICollectionView!
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var menuNameArr : NSMutableArray = []
    var menuImageArr : NSMutableArray = []
     var notificationCount : Int = 0
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    var lat_long = ""
     let defaults = UserDefaults.standard
    var userId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
             userId = defaults.value(forKey: "User_ID") as! String
       
        menuNameArr = ["MY TAGS".localized(),"MY FULFILLED TAGS".localized(),"TOP 10 TAGGERS".localized(),"TOP 10 FULFILLERS".localized(),"TAG COUNTER".localized(),"DASHBOARD".localized(),"ABOUT US".localized(),"TERMS AND CONDITIONS".localized(),"PRIVACY POLICY".localized(),"COOKIES POLICY".localized(),"END-USER AGREEMENT".localized(),"DISCLAMER".localized(),"FAQs".localized(),"CONTACT US".localized()]
       setText()
        //        //This are the app icons which are present at assets file
            menuImageArr = ["mytags","myfullfilledtags","top10taggers".localized(),"top10tagsfullfilled","tagcounter","dashboard","aboutus","tandc","privacypolicy","policy","enduser","disclimer","help","contactus"]
        // Do any additional setup after loading the view.
        // self.downloadData()
    }

    @objc func setText(){
    
        self.menuTagAdeedTitle.title = "About App".localized()
     
      
    }
    @IBAction func menuBarAction(_ sender: Any) {

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
        UIApplication.shared.keyWindow?.rootViewController = viewController
//        if let drawer = self.drawer() ,
//            let manager = drawer.getManager(direction: .left){
//            let value = !manager.isShow
//            drawer.isShowMask = true
//            drawer.showLeftSlider(isShow: value)
//        }
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
        cell.outletMenuName.text=(menuNameArr[indexPath.row] as! String)
        
        if indexPath.row==11{
            
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
                
                // GlobalClass.sharedInstance.menuIndex = "4"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "myTags") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        if indexPath.row==1 {
            
            DispatchQueue.main.async {
                UserDefaults.standard.set("myFulfilledTags", forKey: "backFromAbout")
                // GlobalClass.sharedInstance.menuIndex = "4"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "myFulfilledTags") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        if indexPath.row==2 {
            
            DispatchQueue.main.async {
                
               // GlobalClass.sharedInstance.menuIndex = "4"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "top10Taggers") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==3 {
            
            DispatchQueue.main.async {
                
               // GlobalClass.sharedInstance.menuIndex = "5"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "top10fulfillers") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==4 {
            
            DispatchQueue.main.async {
                
               // GlobalClass.sharedInstance.menuIndex = "6"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tagCounter") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==5{
            
            DispatchQueue.main.async {
                
              //  GlobalClass.sharedInstance.menuIndex = "7"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "dashboard") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==6{
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "8"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WebView") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==7{
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "10"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WebView") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==8{
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "11"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WebView") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==9{
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "12"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WebView") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
      
        else if indexPath.row==10{
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "13"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WebView") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==11{
            
            DispatchQueue.main.async {
                
                GlobalClass.sharedInstance.menuIndex = "14"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WebView") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        if indexPath.row==12{
            
            DispatchQueue.main.async {
                
              //  GlobalClass.sharedInstance.menuIndex = "15"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "help") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
        else if indexPath.row==13{
            
            DispatchQueue.main.async {
                
           //     GlobalClass.sharedInstance.menuIndex = "16"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "contactUs") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        }
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
                     ANLoader.hide()
                }
            }
        }
        
        task.resume()
    }
}
