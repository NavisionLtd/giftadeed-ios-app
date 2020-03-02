//
//  SosImageUploadViewController.swift
//  GiftADeed
//
//  Created by Darshan on 11/19/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
import FirebaseStorage
import UIKit
import Photos
import Firebase
import FirebaseDatabase
import ANLoader
import SQLite
import CoreLocation
import Localize_Swift
import EFInternetIndicator
struct types{
    var name: String
    var id : String
}
class SosImageUploadViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,InternetStatusIndicable{
   var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var clickPicBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    var typeArray: [types]? = []
     var selectedRows = NSMutableIndexSet()
    var sos_id = 0
    var selectedSosName = NSMutableArray()
    var selectedSosId = NSMutableArray()
    @IBOutlet weak var setCurrentLocationBtn: UIButton!
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(self.typeArray!.count == 0){
            return 0
        }
        else{
        return self.typeArray!.count
        }
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SosImageTableViewCell
        var text: String
        var text1: String = ""
        var accessory = UITableViewCell.AccessoryType.none
        cell.tintColor = UIColor.clear
        print(selectedRows.count)
       
            let value = self.typeArray![indexPath.row]
            text = value.name
             text1 = value.id
            if selectedRows.contains(indexPath.row) {
                accessory = .checkmark
                cell.tintColor = UIColor.blue
            }
        
        cell.emergencyType!.text = text
      //   cell.id!.text = text1
        cell.accessoryType = accessory
        return cell
    }
    @IBAction func setCurrentLocationBtnPress(_ sender: UIButton) {
         self.findCurrentLocation()
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as! SosImageTableViewCell
   
            self.selectedRows.contains(indexPath.row) ? self.selectedRows.remove(indexPath.row) : self.selectedRows.add(indexPath.row)
            
            if(self.selectedRows.contains(indexPath.row)){
                //get cell name of selected index
                print(cell.emergencyType.text as Any)
                let sosTypeName = cell.emergencyType.text
                //if selected index is equal to index in table then change status to y for that row
                let user = Constant.sosTypeTable.filter(Constant.sosname == sosTypeName!)
                let updateUser = user.update(Constant.sosstatus <- "y")
                do {
                    try Constant.database.run(updateUser)
                } catch {
                    print(error)
                }
                //end
            }
            else{
                //if selected index is equal to index in table then change status to n for that row
                  let sosTypeName = cell.emergencyType.text
                let user = Constant.sosTypeTable.filter(Constant.sosname == sosTypeName!)
                let updateUser = user.update(Constant.sosstatus <- "n")
                do {
                    try Constant.database.run(updateUser)
                } catch {
                    print(error)
                }
                //end
            }
            let rows = [IndexPath(row: 0, section: 0), indexPath]
            
            tableView.reloadRows(at: rows, with: .none)
        
        return nil
    }
    func downloadSosType(){
        // create type table and save types using coloumns
        // insert types everry times when user hit this page
        GlobalClass.sharedInstance.openDb()
        GlobalClass.sharedInstance.createSosTypeTable()
        //initialy set status to n for all rows
        let updateUser = Constant.sosTypeTable.update(Constant.sosstatus <- "n")
        do {
            try Constant.database.run(updateUser)
        } catch {
            print(error)
        }
        //end
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.sos_type
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "%@","")
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
          
                for item in jsonObj! {
            let name = (item as AnyObject).value(forKey: "emergency_name")
            let id = (item as AnyObject).value(forKey: "id")
                    let model = types(name: name as! String, id: id as! String)
                    self.typeArray?.append(model)
                    //insert values to DB
                    
                    let insertUser = Constant.sosTypeTable.insert(Constant.sosname <- name as! String, Constant.sosid <- id as! String,Constant.sosstatus <- "n")
                    
                    do {
                        try Constant.database.run(insertUser)
                        print("INSERTED USER")
                    } catch {
                        print(error)
                    }
                    //End
            }
             DispatchQueue.main.async{
                self.sosShareImgTableView.reloadData()
                }
        }
        }
        task.resume()
    }
    var backPress = ""
    @IBOutlet weak var sosShareImgTableView: UITableView!
    @IBOutlet weak var currentLocation: UILabel!
    var fire = ""
    var flood = ""
    var earthQuake = ""
    var accident = ""
    var locManager = CLLocationManager()
    @IBOutlet weak var sosImgView: UIView!
    @IBOutlet weak var downloadedImg: UIImageView!
    // Firebase services
    var database = FIRDatabase.database()
    var storage = FIRStorage.storage()
        let imagePicker = UIImagePickerController()
    var emergencyType = ""
 var emergencyTypeArray = ""
    var latitude : CLLocationDegrees = 0.0
    var longitude : CLLocationDegrees = 0.0
     var latitudeLongitude = ""
    var userId = ""
    var addressString = ""
    var geoPoint = ""
      var currentLatLong = CLLocation()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
          self.findCurrentLocation()
         navigationController?.setNavigationBarHidden(true, animated: true)
        userId = UserDefaults.standard.value(forKey: "User_ID") as? String ?? "0"
imagePicker.delegate = self
        self.sosShareImgTableView.allowsMultipleSelection = true
        self.sosShareImgTableView.allowsMultipleSelectionDuringEditing = true
        self.downloadSosType()
    print(self.latitudeLongitude)
        print(self.latitude,self.longitude)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
     @objc func setText(){
    self.clickPicBtn.setTitle("Click Photo".localized(), for: .normal)
    self.setCurrentLocationBtn.setTitle("Set current location".localized(), for: .normal)
        self.doneBtn.setTitle("Done".localized(), for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.findCurrentLocation()
        self.setText()
        setCurrentLocationBtn.setBorder()
        let network = NetworkManager.sharedInstance
        network.reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.view.hideAllToasts()
                self.view.makeToast(Validation.ERROR.localized())
            }
        }
        network.reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if self.geoPoint != ""{
                    let latLong = self.geoPoint.components(separatedBy: ",")
                    self.getAddressForLatLng(latitude: String(format:"%@",latLong[0]), longitude: String(format:"%@",latLong[1]))
                }
               // self.downloadSosType()
            }
        }
         let latLong = self.geoPoint.components(separatedBy: ",")
        // self.getAddressForLatLng(latitude: String(format:"%@",latLong[0]), longitude: String(format:"%@",latLong[1]))
        
    }
    //Find user current location
    func findCurrentLocation(){
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locManager = CLLocationManager()
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }
    }
    
    //Get user address from user current location (lat, long)
    func getAddressForLatLng(latitude: String, longitude: String) {
        
        let url = NSURL(string: "\(Constant.GOOGLE_PLACES_BASE_URL)latlng=\(latitude),\(longitude)&key=\(Constant.GooglePlacesApp_ID)")
        
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url! as URL)
        
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
            {
                
                if let result = jsonObj!["results"] as? NSArray {
                    
                    DispatchQueue.main.async {
                        
                        let address = (result[0] as AnyObject)["formatted_address"] as? String
                        self.addressString = address!
                        self.currentLocation.text = self.addressString
                  
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        var currentLocation = locations.last! as CLLocation
        
        currentLocation = locManager.location!
        currentLatLong = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        geoPoint = String(format:"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        
        self.getAddressForLatLng(latitude: String(format:"%f",currentLocation.coordinate.latitude), longitude: String(format:"%f",currentLocation.coordinate.longitude))
        
        self.locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }

    @IBAction func closeBtnPress(_ sender: UIButton) {
self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var sosImageView: UIImageView!
    
    @IBAction func uploadBtnPress(_ sender: UIButton) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
           self.openCamera()
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                   self.openCamera()
                }
            })
            print("It is not determined until now")
            
        case .restricted:
            print("User do not have access to photo album.")
            
        case .denied:
            print("User has denied the permission.")
        }
        }
  

func askForChooeseImageType() {
    let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
        self.openCamera()
    }))
    
    alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
        self.openGallary()
    }))
    
    
    
    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
}
    
    func openCamera()
    {
        UserDefaults.standard.removeObject(forKey: "url")
        navigationItem.rightBarButtonItem?.isEnabled = false
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        navigationItem.rightBarButtonItem?.isEnabled = false
        UserDefaults.standard.removeObject(forKey: "url")
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: - imagePickerView delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
           // let kUserDefault = UserDefaults.standard
          let userName =      UIDevice.current.name
            self.sosImageView.image = pickedImage
            //            PostServiceFireBase.create(for: pickedImage)
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHH:mm"
            let currentDateTimeString = formatter.string(from: currentDateTime)
            
//            let filePath = "1"// change path as per your requirement
//
//            PostServiceFireBase.create(for: pickedImage, path: filePath) { (downloadURL) in
//                guard let downloadURL = downloadURL else {
//                    print("Download url not found")
//                    //   Toast(text: "Failed to upload image").show()
//                    print("Failed to upload image")
//                    return
//                }
//                let array = ["url": downloadURL,"Type": self.emergencyTypeArray,"Location": self.latitudeLongitude
//                    ] as [String : Any]
//                let dbRef = self.database.reference().child("SOS/"+userName)
//                dbRef.setValue(array)
//
//
//                let urlString = downloadURL
//                print("image url for download image :: \(urlString)")
//
//                DispatchQueue.global(qos: .background).async {
//                    print("This is run on the background queue")
//
//                    DispatchQueue.main.async {
//                     //   self.downloadProfileImg()
//                        print("This is run on the main queue, after the previous code in outer block")
//                    }
//                }
//
//            }
        }
        dismiss(animated: true, completion: nil)
    }

    func downloadProfileImg(){
        navigationItem.rightBarButtonItem?.isEnabled = true
        let dbRef = database.reference().child("SOS")
        dbRef.observeSingleEvent(of:.value) { (snapshot) in
            if !snapshot.exists() { return }
            
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                print(data)
                let object = data.value as? [String:AnyObject]
                    let downloadUrl = object?["url"]
                    print(downloadUrl!)
                    let storageRef = self.storage.reference(forURL: downloadUrl as! String)
                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
                    storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        // Create a UIImage, add it to the array
                        let pic = UIImage(data: data!)
                        self.downloadedImg.layer.cornerRadius =  self.downloadedImg.frame.size.width / 2
                        self.downloadedImg.clipsToBounds = true
                        self.downloadedImg.layer.borderWidth = 0.5
                        self.downloadedImg.layer.borderColor = UIColor.black.cgColor
                        self.downloadedImg.image = pic
                }
            }
        }
        
    }
    
    @IBAction func fireBtnPress(_ sender: UIButton) {
       sender.isSelected = !sender.isSelected
        if(sender.isSelected){
            print("selected value\(String(describing: sender.titleLabel?.text))")
           // let type = sender.titleLabel?.text
            fire = (sender.titleLabel?.text)!
        }
        else{
            fire = ""
    }
    }
    @IBAction func floodButtonPress(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if(sender.isSelected){
            print("selected value\(String(describing: sender.titleLabel?.text))")
            // let type = sender.titleLabel?.text
            flood = (sender.titleLabel?.text)!
        }
        else{
            flood = " "
        }
    }
    @IBAction func earthQuakeBtnPress(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if(sender.isSelected){
            print("selected value\(String(describing: sender.titleLabel?.text))")
            // let type = sender.titleLabel?.text
            earthQuake = (sender.titleLabel?.text)!
        }
        else{
            earthQuake = ""
        }
    }
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
  
    //Get device token
    func getDeviceToken()->String{
        
        let refreshedToken = GlobalClass.sharedInstance.nullToNil(value: FIRInstanceID.instanceID().token() as AnyObject)
        UserDefaults.standard.setValue(refreshedToken, forKey: "FCMTOEKN")
        return refreshedToken as! String
    }
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

    func createSosApiCall(sosName:String){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.create_sos
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        var paramString = ""
        if(userId == "")
        {
            paramString = String(format: "user_id=%@&device_id=%@&geopoints=%@&address=%@&sos_types=%@&device_type=%@","",self.getDeviceToken(),self.geoPoint,self.currentLocation.text!,sosName,2)
        }
        else{
            paramString = String(format: "user_id=%@&device_id=%@&geopoints=%@&address=%@&sos_types=%@",userId,self.getDeviceToken(),self.geoPoint,self.currentLocation.text!,sosName)
        }
       print(paramString)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                DispatchQueue.main.async{
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj as Any)
                self.sos_id = jsonObj?.value(forKey: "sos_id") as! Int
                if(self.sos_id != nil){

                    var currentTime = self.getCurrentMillis()
                     let storageRef = self.storage.reference().child("uploadsDev/\(self.sos_id)\(currentTime).jpg")
                        let path =  storageRef.fullPath
                    PostServiceFireBase.create(for: self.sosImageView.image!, path:path ) { (downloadURL) in
                        guard let downloadURL = downloadURL else {
                            print("Download url not found")
                            //   Toast(text: "Failed to upload image").show()
                            print("Failed to upload image")
                            return
                        }
                        let array = ["sosid":String(self.sos_id),"sosurl": downloadURL
                            ] as [String : Any]
                        let dbRef = self.database.reference().child("\("SOSDev")/\(String(self.sos_id))")
                        //"SOSDev/"+String(self.sos_id)
                        dbRef.setValue(array)
                       // print(array)
                        
                        let urlString = downloadURL
                        print("image url for download image :: \(urlString)")
                        DispatchQueue.main.async {
                        self.sosImgView.makeToast("SOS created Successfully".localized())
                          
                            
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            
                            ANLoader.hide()
                            
                        }
                        DispatchQueue.global(qos: .background).async {
                            print("This is run on the background queue")
                            
                            DispatchQueue.main.async {
                                //   self.downloadProfileImg()
                              self.backPress =  UserDefaults.standard.value(forKey: "BackPress") as! String
                                print(self.backPress)
                                if(self.backPress == "login"){
                                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                                    UIApplication.shared.keyWindow?.rootViewController = viewController
                                }
                                else{
                                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
                                    UIApplication.shared.keyWindow?.rootViewController = viewController}
                                print("This is run on the main queue, after the previous code in outer block")
                            }
                        }
                        
                    }
                    
                }
                else{
           self.sosImgView.makeToast("SOS created Successfully".localized())
                }
            }
            DispatchQueue.main.async{
             
            }
        }
        
        task.resume()
    }
    @IBAction func uploadPhotoOnfirebase(_ sender: UIButton) {
       
        //retrive data for selected sostype
        GlobalClass.sharedInstance.openDb()
        do {
            let users = try Constant.database.prepare(Constant.sosTypeTable)
            for user in users {
                print("userId: \(user[Constant.sid]), name: \(user[Constant.sosname]), nameid: \(user[Constant.sosid]), nameStatus: \(user[Constant.sosstatus])")
                let status = user[Constant.sosstatus]
                var id = ""
                var name = ""
                if(status == "y"){
                    name = user[Constant.sosname]
                    id = user[Constant.sosid]
                    selectedSosName.add(name)
                    selectedSosId.add(id)
                }else{
                    
                }
                print("\(selectedSosName)\(selectedSosId)")
                
            }
        } catch {
            print(error)
        }
        var sosTypeName = selectedSosId.componentsJoined(by: ",")
        //End
        createSosApiCall(sosName: sosTypeName)

    }
    
}
