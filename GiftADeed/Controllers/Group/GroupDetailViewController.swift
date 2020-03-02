//
//  GroupDetailViewController.swift
//  GiftADeed
//
//  Created by Darshan on 2/16/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import Firebase
import SDWebImage
import SnapKit
import PopOverMenu
import EzPopup
import SendBirdSDK
import ListPlaceholder
import Localize_Swift

class GroupDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate, UIAdaptivePresentationControllerDelegate,CellSeeMoreSubclassDelegate {
    func buttonTapped(name: String) {
        let tagger = self.storyboard?.instantiateViewController(withIdentifier: "TaggerDetailsViewController") as! TaggerDetailsViewController
        print(name)
        tagger.deedId = String(format: "%@", name)
        self.navigationController?.pushViewController(tagger, animated: true)
    }
    //sendbird
    fileprivate var channels: [SBDGroupChannel] = []
    fileprivate var myGroupChannelListQuery: SBDGroupChannelListQuery?
    let customAlertVC = CustomAlertViewController.instantiate()
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var groupDeeds: UITableView!
    weak var headerImageView: UIView?
    var group_id = ""
    var userId = ""
    var group_img_url = ""
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    var loadFlag : Bool = true
    var deviceToken = ""
    let currentLocationVal : NSMutableDictionary = NSMutableDictionary()
    let defaults = UserDefaults.standard
    var taggerListArr = NSMutableArray()
    let imageView = UIImageView()
    var groupTitle = ""
    var menuArray: [String] = [""]
    var menuOption = ""
    override func viewWillAppear(_ animated: Bool) {
         self.navigationItem.title = groupTitle
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.findCurrentLocation()
        findAdminOrUserApiCall()
        getGroupTagListApiCall()
        self.navigationItem.title = groupTitle
        //Get FCM token
        let refreshedToken = GlobalClass.sharedInstance.nullToNil(value: FIRInstanceID.instanceID().token() as AnyObject)
        UserDefaults.standard.setValue(refreshedToken, forKey: "FCMTOEKN")
        deviceToken = UserDefaults.standard.value(forKey: "FCMTOEKN") as! String
        //get userid to create group and send data to API
       // userId = defaults.value(forKey: "User_ID") as! String
        //get userid to show group list
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        //register cell
        groupDeeds.register(UINib(nibName: "GroupTagListTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        //create view as header view
        
        let imgURL = String(format: "%@%@", Constant.BASE_URL , group_img_url)
        print(group_img_url)
        
        imageView.sd_setImage(with: URL(string: imgURL), placeholderImage:nil)
        if(group_img_url == ""){
         imageView.image = UIImage(named: "ic_launcher-1")
            
//           imageView.image =  self.resizeImage(image: UIImage(named: "ic_launcher-1")!, targetSize: CGSize(width: 50, height: 50))
//            imageView.image = nil
            imageView.contentMode = .scaleAspectFit
            //setup blur vibrant view
            imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: 1).enable()
            headerImageView = imageView
            groupDeeds.parallaxHeader.view = imageView
            groupDeeds.parallaxHeader.height = 200
            groupDeeds.parallaxHeader.minimumHeight = 40
            groupDeeds.parallaxHeader.mode = .center
            
            groupDeeds.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
                //update alpha of blur view on top of image view
                parallaxHeader.view.blurView.alpha = 1 - parallaxHeader.progress
            }
            
        }else{
            imageView.image = UIImage(named: "member")
            imageView.contentMode = .scaleAspectFill
            //setup blur vibrant view
            imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: 1).enable()
            headerImageView = imageView
            groupDeeds.parallaxHeader.view = imageView
            groupDeeds.parallaxHeader.height = 200
            groupDeeds.parallaxHeader.minimumHeight = 40
            groupDeeds.parallaxHeader.mode = .centerFill

            groupDeeds.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
                //update alpha of blur view on top of image view
                parallaxHeader.view.blurView.alpha = 1 - parallaxHeader.progress
            }
        }

        // Do any additional setup after loading the view.
        //Sendbirds
           let  name = UserDefaults.standard.value(forKey: "Fname") as! String
        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery?.limit = 10
        ANLoader.showLoading()
        //   memberId = UserDefaults.standard.string(forKey: "memberid") ?? "0"
        //   let name = UserDefaults.standard.string(forKey: "first_Name")
        self.loadChannels()
        SBDMain.connect(withUserId: self.userId, completionHandler: { (user, error) in
            if error == nil {
                SBDMain.updateCurrentUserInfo(withNickname: name, profileUrl: nil, completionHandler: { (error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true, completion: nil)
                        })
                        return
                    }
                })
            }
            else {
                let alert = UIAlertController(title: "Error", message: String(format: "%lld-%@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(closeAction)
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
        })
       
        let query = SBDGroupChannel.createMyGroupChannelListQuery()
        query?.includeEmptyChannel = false
        query?.loadNextPage(completionHandler: { (channels, error) in
            guard error == nil else {   // Error.
                return
            }
            print(channels as Any)
            print(channels?.count as Any)
            //  self.chanelNameArray.add(channels as Any)
            // ...
        })
        //end
        
    }
    fileprivate func loadChannels() {
        if self.myGroupChannelListQuery?.isLoading() == true {
            return
        }
        
        if self.myGroupChannelListQuery?.hasNext == false {
            return
        }
        
        self.myGroupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                //                if self.refreshControl?.isRefreshing == true {
                //                    self.refreshControl?.endRefreshing()
                //                }
                
                return
            }
            
            if channels == nil || channels!.count == 0 {
                return
            }
            
            for item in channels! {
                let channel = item as SBDGroupChannel
                self.channels.append(channel)
                
            }
            
            DispatchQueue.main.async(execute: {
                print(self.channels)
                
                ANLoader.hide()
            })
        })
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    @IBAction func additionalDetailsBtnPress(_ sender: UIBarButtonItem) {
      //  let titles = ["Menu1", "Menu2", "Menu3"]
        print(menuOption)
        if(menuOption == "Member"){
            //show only two menu option
            //show four options
            let popOverViewController = PopOverViewController.instantiate()
            popOverViewController.setTitles(self.menuArray)
            popOverViewController.popoverPresentationController?.barButtonItem = sender
            popOverViewController.preferredContentSize = CGSize(width: 200, height:100)
            popOverViewController.presentationController?.delegate = self
            popOverViewController.completionHandler = { selectRow in
                switch (selectRow) {
                case 0:
                    //push  group info view
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "GroupInfoViewController") as! GroupInfoViewController
                    viewController.group_id = self.group_id
                    self.navigationController!.pushViewController(viewController, animated: true)
                    break
                case 1:
                    //push group exit view
                    // Create the alert controller
                    let alertController = UIAlertController(title: "Exit group", message: "Do you really want to Exit from  group?", preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                        self.exitGroupApiCall()
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        alertController.dismiss(animated: true, completion: nil)
                        NSLog("Cancel Pressed")
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                    break
               
                default:
                    break
                }
                
            };
            present(popOverViewController, animated: true, completion: nil)
        }
        else if(menuOption == "Admin"){
            //show four options
            let popOverViewController = PopOverViewController.instantiate()
            popOverViewController.setTitles(self.menuArray)
            popOverViewController.popoverPresentationController?.barButtonItem = sender
            popOverViewController.preferredContentSize = CGSize(width: 200, height:200)
            popOverViewController.presentationController?.delegate = self
            popOverViewController.completionHandler = { selectRow in
                switch (selectRow) {
                case 0:
                    //push add group member view
                    print("ZERO")
                    guard let customAlertVC = self.customAlertVC else { return }
                    let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 300, popupHeight: 200)
                    popupVC.cornerRadius = 5
                    
                    customAlertVC.group_id = self.group_id
                    customAlertVC.group_name = self.groupTitle
                    customAlertVC.channels = self.channels
                    // self.navigationController?.setNavigationBarHidden(true, animated: false)
                    self.present(popupVC, animated: true, completion: nil)
                    // self.navigationController?.pushViewController(popupVC, animated: false)
                    break
                case 1:
                    //push group member list view
                    let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "GroupMemberListViewController") as? GroupMemberListViewController
                  
                    memberViewController!.group_id = self.group_id
                    memberViewController!.group_name = self.groupTitle
                    memberViewController!.channels = self.channels
                    self.navigationController?.pushViewController(memberViewController!, animated: true)
                    print("ONE")
                    break
                case 2:
                    //push edit group view
                    let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as? CreateGroupViewController
                    memberViewController!.group_id = self.group_id
                    memberViewController!.group_name = self.groupTitle
                    memberViewController!.channels = self.channels
                    self.navigationController?.pushViewController(memberViewController!, animated: true)
                    print("two")
                    
                    break
                case 3:
                    //push exit group view
                    //Admin member
                    // Create the alert controller
                    let alertController = UIAlertController(title: "Exit group".localized(), message: "Do you really want to Exit from  group?".localized(), preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                        self.exitGroupApiCall()
                    }
                    let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        alertController.dismiss(animated: true, completion: nil)
                        NSLog("Cancel Pressed")
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                    break
                default:
                    break
                }
                
            };
            present(popOverViewController, animated: true, completion: nil)
        }
        else if(menuOption == "Creator")
        {
            //show four options which differ from admin
            let popOverViewController = PopOverViewController.instantiate()
            popOverViewController.setTitles(self.menuArray)
            popOverViewController.popoverPresentationController?.barButtonItem = sender
            popOverViewController.preferredContentSize = CGSize(width: 200, height:200)
            popOverViewController.presentationController?.delegate = self
            popOverViewController.completionHandler = { selectRow in
                switch (selectRow) {
                case 0:
                    //push add group member view
                    print("ZERO")
                    guard let customAlertVC = self.customAlertVC else { return }
                    let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 300, popupHeight: 200)
                    popupVC.cornerRadius = 5
                    customAlertVC.group_id = self.group_id
                     customAlertVC.group_name = self.groupTitle
                     customAlertVC.channels = self.channels
                    // self.navigationController?.setNavigationBarHidden(true, animated: false)
                    self.present(popupVC, animated: true, completion: nil)
                    // self.navigationController?.pushViewController(popupVC, animated: false)
                    break
                case 1:
                    //push group member list view
                    let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "GroupMemberListViewController") as? GroupMemberListViewController
                    memberViewController!.group_id = self.group_id
                    memberViewController!.group_name = self.groupTitle
                    memberViewController!.channels = self.channels
                    self.navigationController?.pushViewController(memberViewController!, animated: true)
                    print("ONE")
                    break
                case 2:
                    //push edit group view
                    let memberViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as? CreateGroupViewController
                    memberViewController!.group_id = self.group_id
                    memberViewController!.group_name = self.groupTitle
                    memberViewController!.channels = self.channels
                    self.navigationController?.pushViewController(memberViewController!, animated: true)
                    print("two")
                    
                    break
                case 3:
                    //push delete group view
                    //genral member
                    // Create the alert controller
                    let alertController = UIAlertController(title: "Delete group".localized(), message: "Do you really want to delete group?".localized(), preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                        self.deleteGroupApiCall()
                    }
                    let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        alertController.dismiss(animated: true, completion: nil)
                        NSLog("Cancel Pressed")
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                    break
                default:
                    break
                }
                
            };
            present(popOverViewController, animated: true, completion: nil)
        }
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    //MARK: table view data source/delegate
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if self.taggerListArr.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No records found".localized()
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
             return self.taggerListArr.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GroupTagListTableViewCell
        
        let model = self.taggerListArr[indexPath.row] as! ModelHome
        print(model.Need_Name)
        cell.deedName.text = model.Need_Name!
        cell.deedTaggerId.text = model.Tagged_ID!
        cell.deedAddress.text = model.Address
        cell.deedDate.text = model.Tagged_Datetime
        cell.deedLocationKm.text = String(format: "%@ km(s) away", model.Distance!)
        cell.deedEndorse.text = model.Endorse
        cell.deedView.text = model.Views
        let img_url = model.Tagged_Photo_Path
        let icon_url = model.Character_Path
        //image/tagged_image
        let imgURL = String(format: "%@%@", Constant.BASE_URL , img_url!)
         let iconURL = String(format: "%@%@", Constant.BASE_URL , icon_url!)
        print(imgURL)
        cell.seeMoreBt.layer.cornerRadius = 5
        cell.seeMoreBt.layer.borderWidth = 0.5
        cell.seeMoreBt.layer.borderColor = UIColor.black.cgColor
        cell.seeMoreBt.setTitle("See More".localized(), for: .normal)
        cell.delegate = self
        cell.deedImg.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "default"))
        cell.deedIcon.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "default"))
            return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    //Find user current location
    func findCurrentLocation(){
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locManager = CLLocationManager()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locManager.distanceFilter = 500.0
            locManager.requestAlwaysAuthorization()
            locManager.startUpdatingLocation()
        }
    }
    
    //Update user current location with server
    func updateLocation(latitude : String, longitude : String) {
        
        let defaults = UserDefaults.standard
        let loginFlag = defaults.value(forKey: "loginFlag")
        
        if ((loginFlag as AnyObject).isEqual("TRUE")) {
            
            let radiusVal = String(format:"%d",defaults.value(forKey: "DEED_RADIUS") as! Int)
            
            let urlString = Constant.BASE_URL + Constant.update_location
            let url:NSURL = NSURL(string: urlString)!
            
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            
            let paramString = String(format: "user_id=%@&device_id=%@&lat=%@&lng=%@&radius=%@",userId,deviceToken,latitude,longitude,radiusVal)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            
            let task = session.dataTask(with: request as URLRequest)
            task.resume()
        }
        else{
            
            locManager.stopMonitoringSignificantLocationChanges()
            locManager.stopUpdatingLocation()
            locManager.stopMonitoringVisits()
        }
    }
    
    //Check user permission for location
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            //   outletMapView.isMyLocationEnabled = true
        }
    }
    
    //Get user location in Background and Active state and marker on map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let currentLocation = locManager.location!
        guard locations.last != nil else {
            
            return
        }
        
        if UIApplication.shared.applicationState == .active {
            
            let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
            self.updateLocation(latitude: String(format:"%f",locationValue.latitude), longitude: String(format:"%f",locationValue.longitude))
        } else {
            
            let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
            self.updateLocation(latitude: String(format:"%f",locationValue.latitude), longitude: String(format:"%f",locationValue.longitude))
        }
        
        if loadFlag {
            
            loadFlag = false
        }
        else{
            
            return
        }
        
        currentLatLong = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        
        let latlongStr = String(format: "%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)
        
        self.defaults.set(latlongStr, forKey: "CURRENTLOCATION")
        
        //let item : NSMutableDictionary = NSMutableDictionary()
        currentLocationVal.setValue("Current", forKey: "Tagged_Title")
        currentLocationVal.setValue(latlongStr, forKey: "Geopoint")
        currentLocationVal.setValue("", forKey: "Character_Path")
        currentLocationVal.setValue("0", forKey: "Tagged_ID")
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    //exit from group Api call
    func exitGroupApiCall(){
        //user_id(int), group_id(int)
        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.".localized())
            }
        }
        else{
            
            ANLoader.showLoading("Loading", disableUI: true)
            
            let urlString = Constant.BASE_URL + Constant.exitGroup
            
            let url:NSURL = NSURL(string: urlString)!
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            
            let paramString = String(format: "user_id=%@&group_id=%@",userId,group_id)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request as URLRequest) {
                (
                
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
                    print(jsonObj as Any)
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        DispatchQueue.main.async{
                            
                            //Sendbird edit channel
                            var channel: SBDGroupChannel
                            //   self.channels.removeAll()
                            for item in self.channels {
                                channel = item as SBDGroupChannel
                                self.channels.append(channel)
                                print(self.channels)
                                print(channel.name)
                                print(channel.channelUrl)
                                let fullName   = "\(self.groupTitle) - GRP\(self.group_id)"
                                print("\(channel.name)\(fullName)")
                                if(channel.name == fullName){
                                    print("chanel is present")
                                    self.channels.removeAll()
                                    self.channels.append(channel)
                                    print(self.channels)
                                    print("\(channel.name)")
                                    print(channel.channelUrl)
                                    let session = URLSession.shared
                                    
                                    let url = "https://api-2B2DA376-91B5-4604-9279-C0533F130126.sendbird.com/v3/group_channels/\(channel.channelUrl)/leave"
                                    print(url)
                                    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                                    request.addValue("cf709ee2fa69a3823f90bdc98647c0d2e850d3cf", forHTTPHeaderField: "Api-Token")
                                    request.httpMethod = "PUT"
                                    let newname = "\(self.groupTitle) - GRP\(self.group_id)"
                                    print(newname)
                                    
                               
                                    var array = [self.group_id]
                                    var params = NSMutableDictionary()
                                    params.setValue(array, forKey:"user_ids")
                                    print(params)
                                    do{
                                        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
                                        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                                            if let response = response {
                                                let nsHTTPResponse = response as! HTTPURLResponse
                                                let statusCode = nsHTTPResponse.statusCode
                                                print ("status code = \(statusCode)")
                                            }
                                            if let error = error {
                                                print ("\(error)")
                                            }
                                            if let data = data {
                                                do{
                                                    let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                                                    print(jsonData)
                                                    //   print (" deviceId= \(deviceId), mobileDeviceId= \(mobileDeviceId), deviceType= \(deviceType)")
                                                }catch _ {
                                                    print ("the response is not well JSON formatted")
                                                }
                                            }
                                        })
                                        task.resume()
                                    }catch _ {
                                        print ("Oops something happened buddy")
                                    }
                                    
                                    
                                }else{
                                    print("chanel isNot present")
                                }
                            }
                            
                            //sendbird end
                            
                            self.view.makeToast("You have successfully left from group".localized(),duration: 1.0)
                            let d = self.drawer()
                            d!.setMain(identifier: "group", config: { (vc) in
                                if let nav = vc as? UINavigationController {
                                    //  nav.viewControllers.first?.title = "Home"
                                    UserDefaults.standard.set(false, forKey: "creategroup")
                                    
                                }
                            })
                            ANLoader.hide()
                            self.view.hideAllToasts()
                        }
                        
                    }
                    else{
                        DispatchQueue.main.async{
                            ANLoader.hide()
                            self.view.hideAllToasts()
                            self.view.makeToast("Something went wrong ! Please try again.".localized())
                        }
                    }
                }

            }
            task.resume()
        }
      
    }
    //delete group api call group_id(int), user_id(int)
    func deleteGroupApiCall(){
        if(self.channels.count == 0){
            DispatchQueue.main.async{
                ANLoader.hide()
                self.view.hideAllToasts()
                self.view.makeToast("Chatting group channel retrive fail ! Please try again.".localized())
            }
        }
        else{
            //user_id(int), group_id(int)
            ANLoader.showLoading("Loading", disableUI: true)
            
            let urlString = Constant.BASE_URL + Constant.deleteGroup
            
            let url:NSURL = NSURL(string: urlString)!
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            
            let paramString = String(format: "user_id=%@&group_id=%@",userId,group_id)
            print(paramString)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request as URLRequest) {
                (
                
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
                    print(jsonObj as Any)
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        DispatchQueue.main.async{
                            //start sendbird
                            var channel: SBDGroupChannel
                            //   self.channels.removeAll()
                            for item in self.channels {
                                channel = item as SBDGroupChannel
                                self.channels.append(channel)
                                print(self.channels)
                                print(channel.name)
                                print(channel.channelUrl)
                                let fullName   = "\(self.groupTitle) - GRP\(self.group_id)"
                                print("\(channel.name)\(fullName)")
                                if(channel.name == fullName){
                                    print("chanel is present")
                                    self.channels.removeAll()
                                    self.channels.append(channel)
                                    print(self.channels)
                                    print("\(channel.name)")
                                    print(channel.channelUrl)
                                    let session = URLSession.shared
                                    
                                    let url = "https://api-2B2DA376-91B5-4604-9279-C0533F130126.sendbird.com/v3/group_channels/\(channel.channelUrl)"
                                    print(url)
                                    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                                    request.addValue("cf709ee2fa69a3823f90bdc98647c0d2e850d3cf", forHTTPHeaderField: "Api-Token")
                                    request.httpMethod = "DELETE"
                                    let newname = "\(self.groupTitle) - GRP\(self.group_id)"
                                    print(newname)
                                    let params:[String: AnyObject] = ["name" : newname as AnyObject]
                                    do{
                                        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
                                        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                                            if let response = response {
                                                let nsHTTPResponse = response as! HTTPURLResponse
                                                let statusCode = nsHTTPResponse.statusCode
                                                print ("status code = \(statusCode)")
                                            }
                                            if let error = error {
                                                print ("\(error)")
                                            }
                                            if let data = data {
                                                do{
                                                    let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                                                    print(jsonData)
                                                    //   print (" deviceId= \(deviceId), mobileDeviceId= \(mobileDeviceId), deviceType= \(deviceType)")
                                                }catch _ {
                                                    print ("the response is not well JSON formatted")
                                                }
                                            }
                                        })
                                        task.resume()
                                    }catch _ {
                                        print ("Oops something happened buddy")
                                    }
                                    
                                    
                                }else{
                                    print("chanel isNot present")
                                }
                            }
                            //end sendbird
                            self.view.makeToast("Group deleted Successfully".localized(),duration: 1.0)
                            let d = self.drawer()
                            d!.setMain(identifier: "group", config: { (vc) in
                                if let nav = vc as? UINavigationController {
                                    //  nav.viewControllers.first?.title = "Home"
                                    UserDefaults.standard.set(false, forKey: "creategroup")
                                    
                                }
                            })
                            ANLoader.hide()
                            self.view.hideAllToasts()
                        }
                        
                    }
                    else{
                        DispatchQueue.main.async{
                            ANLoader.hide()
                            self.view.hideAllToasts()
                            self.view.makeToast("Something went wrong ! Please try again.".localized())
                        }
                    }
                }
            }
            task.resume()
        }
       
    }
    // MARK:- End
    func getGroupTagListApiCall(){
        //user_id(int), group_id(int)
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.groupTagList
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        //get userid to show group list
       
        let paramString = String(format: "user_id=%@&group_id=%@",userId,group_id)
        print(paramString)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
     
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async {
                    
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                print(jsonObj as Any)
                if(jsonObj?.count == 0){
                    DispatchQueue.main.async{
                        ANLoader.hide()
                        self.groupDeeds.separatorStyle = .none
                        self.view.makeToast("There is no deed in this group".localized(),duration: 2.0)
                    }
                }else{
                for item in jsonObj! {
                      self.groupDeeds.separatorStyle = .singleLine
                    self.view.hideAllToasts()
                    let taggedItem = item as? NSDictionary
                    
                    let latlongStr = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Geopoint") as! String)
                    let latlong = latlongStr.components(separatedBy: ",")
                    let lat    = (latlong[0] as NSString).doubleValue
                    let long = (latlong[1] as NSString).doubleValue
                    
                    let tagerLatLong = CLLocation(latitude: lat, longitude: long)
                    let distanceInMeters = Double(self.currentLatLong.distance(from: tagerLatLong))
                    
                    let Tagged_ID = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_ID") as! String)
                    let Tagged_Title = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_Title") as! String)
                    print(Tagged_Title)
                   // let Tagged_ID = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_ID") as! String)
                    let Address = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Address") as! String)
                    let Geopoint = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Geopoint") as! String)
                    let Tagged_Photo_Path = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_Photo_Path") as! String)
                    let Tagged_Datetime = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_Datetime") as! String)
                    let Icon_Path = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Icon_Path") as! String)
                    let Character_Path = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Character_Path") as? String ?? "value")
                    let Need_Name = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Need_Name") as! String)
                    let Views = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Views") as! String)
                    let Endorse = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Endorse") as! String)
                    let distanceInKM = distanceInMeters/1000.0
                    let model = ModelHome.init(Tagged_ID: Tagged_ID, Tagged_Title: Tagged_Title, Address: Address, PAddress: "", Geopoint: Geopoint, Tagged_Photo_Path: Tagged_Photo_Path, Tagged_Datetime: Tagged_Datetime, Icon_Path: Icon_Path, Character_Path:
                        Character_Path, Need_Name: Need_Name, Views: Views, Endorse: Endorse, Distance: String(format:"%0.2f",distanceInKM), cat_type: "C")
              
                    self.taggerListArr.add(model!)
                    
                }
                }
            }
            
            DispatchQueue.main.async{
                // Label for vibrant text
                if(self.group_img_url == ""){}
                else{

                let vibrantLabel = UILabel()
                vibrantLabel.text = "Active Tags \(self.taggerListArr.count)"
                vibrantLabel.font = UIFont.systemFont(ofSize: 10.0)
                vibrantLabel.sizeToFit()
                vibrantLabel.textAlignment = .center

                self.imageView.blurView.vibrancyContentView?.addSubview(vibrantLabel)
                //  self.groupDeeds.addSubview(vibrantLabel)
                //add constraints using SnapKit library
                vibrantLabel.snp.makeConstraints { make in
                    make.edges.equalToSuperview()

                }
                }
                self.groupDeeds.reloadData()
               // self.groupDeeds.showLoader()
              //  Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GroupDetailViewController.removeLoader), userInfo: nil, repeats: false)
            }
            
            
        }
        task.resume()
    }
    @objc func removeLoader()
    {
        self.groupDeeds.hideLoader()
    }
    func findAdminOrUserApiCall()
    {
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.groupInfo
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@&group_id=%@",userId,group_id)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async {
                    
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                print(jsonObj as Any)
                 for item in jsonObj! {
                let creator_id = (item as AnyObject).value(forKey: "creator_id") as! String
                let admin_ids = (item as AnyObject).value(forKey: "admin_ids") as! String
                if(creator_id == self.userId){
                    //Its creator show creator menu
                  
                    self.menuArray = ["Add Members".localized(),"View member list".localized(),"Edit group".localized(),"Delete group".localized()]
                    self.menuOption = "Creator"
                  
                }
                else if (admin_ids == self.userId){
                    //Its Admin show Admin menu
                     self.menuArray = ["Add Members".localized(),"View member list".localized(),"Edit group".localized(),"Exit group".localized()]
                    self.menuOption = "Admin"
                }
                else {
                    //Its member show member menu
                    self.menuOption = "Member".localized()
                     self.menuArray = ["Group info".localized(),"Exit group".localized()]
                   
                }
                }

            }
            
            DispatchQueue.main.async{
            }
            
            
        }
        task.resume()
    }
}
