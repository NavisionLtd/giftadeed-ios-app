//  HomeViewController.swift
//  GiftADeed
//
//  Created by navin on 04/04/18.
//  phase 3 = priority 1 . sr no.5. Home screen SRS : version 31
//  Copyright © 2018 GiftADeed. All rights reserved.
//
/*
 •    This screen will be divided into two tabs – one for a Map View of the tagged deeds and other List View display of the tagged deeds as shown in the above image. There will be a Hamburger button for Navigation bar (Drawer) at the left of Tagged Deeds heading, and Tag A Deed button (Camera Symbol) to the right.
 •    Next to the Camera Symbol, there is a Filters button (Settings button). On clicking on Filter, the User is redirected to the Filters Page. In the content window, there is Apply Filters heading. Below that there is Radius option. Below that there is Select Category option. Below that there is Apply button. For Radius selection, there will be a Seek Bar with minimum value of 10km and maximum value of 100km. When the selection marker/dot is pressed/held the instantaneous value of the radius is shown in a Red balloon on top. Above the seek bar, the selected radius is shown as a numerical value. Below the Radius there is Select Category option. The User can select the category of deeds that he/she wishes to see. On clicking Select Category, a popup will open with the following single select options - All, Food, Cloth, Shelter, Water. At the bottom of the popup there is Cancel option. On the Filters page, there is an Apply button at the button, pressing which will apply the selected filters.
 •    Below the Tagged Deeds heading, there will be two options – Map View and List View. The user can toggle between the Map View and List View.
 •    The Map View will be the landing page after successful log in, and it is the default selected option for Tagged Deeds.
 •    By default, the current location of the user is shown with red marker on the map. Depending on the Filters (Search conditions), the tags are shown on the map. By default, the Search Conditions are Radius-10km and Select Category-All. For example, a deed that has been tagged for medical assistance will show a “+” (medicine symbol) or a deed that has been tagged for hungry persons will be displayed as a food icon.
 •    List view will show a list of tagged deeds (only unfulfilled)in ascending order of distance (i.e. nearest first). For an unfulfilled deed, a user will be presented with an option to Give/Donate by clicking on a button. Every deed can be seen in detail by tapping list item.No. of Views and no. of Endorsements is required for all the deeds. This will be shown in the Tagged Deeds Details Page, Tag List View, My Fulfilled Tags, and My Tags. Only unique Views will be counted i.e. one User will be counted only once.
 •    To see the details of a Deed, the Deed has to be clicked once in the List View. As far as Map View is concerned, when the marker for a Deed is clicked once, a popup with the Deed type symbol will appear over the marker. On clicking this popup, the User will be directed to the Deed Details page.
 •    Map View Disclaimer – The Map view should have an ‘i’ icon at the top left of the screen. On clicking it, a message should be displayed 'Distances displayed may not be accurate'.
 */
import SwiftMessages
import EFInternetIndicator
import ListPlaceholder
import FirebaseStorage
import Firebase
import FirebaseDatabase
import Localize_Swift
import Foundation
import UIKit
import GoogleMaps
import SDWebImage
import CoreLocation
import Firebase
import ANLoader
import MMDrawController
import SQLite
struct sosList {
    var id : String
    var geoPoints : String
    var path : String
    var address : String
}
struct pDeedList {
    var tag_id : String
    var sub_types : String
    var need_name : String
    var icon_path : String
}
struct resourceList {
    var resourseid : String
    var resoursegeoPoints : String
    var resourseMarker : String
    var resourseName : String
    var address : String
}
//Struct for downloading deeds
struct deed_list:Codable {
    var Tagged_ID:String
    var Tagged_Title:String
    var Address:String
    var Geopoint:String
    var Tagged_Photo_Path:String
    var Tagged_Datetime:String
    var is_permanent:String
    var Icon_Path:String
    var Character_Path:String
    var Need_Name:String
    var cat_type:String
    var all_groups:String
    var user_grp_ids:String
    var from_group:String
    var Views:String
    var Endorse:String
}
extension UserDefaults {
    func set(location:CLLocation, forKey key: String){
        let locationLat = NSNumber(value:location.coordinate.latitude)
        let locationLon = NSNumber(value:location.coordinate.longitude)
        self.set(["lat": locationLat, "lon": locationLon], forKey:key)
    }
    func location(forKey key: String) -> CLLocation?
    {
        if let locationDictionary = self.object(forKey: key) as? Dictionary<String,NSNumber> {
            let locationLat = locationDictionary["lat"]!.doubleValue
            let locationLon = locationDictionary["lon"]!.doubleValue
            return CLLocation(latitude: locationLat, longitude: locationLon)
        }
        return nil
    }
}
class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate,GMSMapViewDelegate,CellSubclassDelegate,InternetStatusIndicable {
   
    @IBOutlet weak var menuTaggedDeedLbl: UINavigationItem!
    @IBOutlet  var outletSegment: UISegmentedControl!
    @IBOutlet weak var segmentTutorialBtn: UIButton!
    @IBOutlet  var outletTableView: UITableView!
    @IBOutlet  var outletMapView: GMSMapView!
    @IBOutlet  var outletListView: UIView!
    @IBOutlet  var outletCountLabel: UILabel!
    @IBOutlet  var outletNoRecord: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var sosLbl: UILabel!
    var refreshControl = UIRefreshControl()
    var internetConnectionIndicator:InternetViewIndicator?
    var userId = ""
    var markerFlag :Bool = false
    var sosFlag :Bool = false
    let currentLocationVal : NSMutableDictionary = NSMutableDictionary()
    var detailsFlag :Bool = false
    var currentLatLong = CLLocation()
    var locManager = CLLocationManager()
    var loadFlag : Bool = true
    var address = ""
    // Firebase services
    var database = FIRDatabase.database()
    var storage = FIRStorage.storage()
    var permanant_icon = ""
    var sosAddress = ""
    var geoPoints = ""
    var groupArr = NSMutableArray()
    var groupListArr = NSMutableArray()
    var alert = UIAlertController()
    var deviceToken = ""
    var deiviceStatus :Int?
    var arrayTableViewData = [pDeedList]()
    //permanant deed marker table
    var tableViewSortBy: UITableView = UITableView()
    var popover: DXPopover = DXPopover()
    var tappedMarker = GMSMarker()
    var sosArray = [sosList]()
    var resourceArray = [resourceList]()
    let customInfoWindow = Bundle.main.loadNibNamed("MarkerInfoView", owner: self, options: nil)![0] as! MarkerInfoView
    let filter = UIButton(type: .custom)
    let tagDeed = UIButton(type: .custom)
    let tagDeedTutorialBtn = UIButton(type: .custom)
    var sortedTaggerListArr = NSMutableArray()
    var taggerListArr = NSMutableArray()
    let defaults = UserDefaults.standard
    private var myTableView: UITableView!
    private let myArray: NSMutableArray = []
    private let myArrayImg: NSMutableArray = []
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalClass.sharedInstance.openDb()
        GlobalClass.sharedInstance.createAudianceTable()
        let deleteData = Constant.audianceTable.delete()
        do {
            try Constant.database.run(deleteData)
        } catch {
            ////print(error)
        }
        UserDefaults.standard.set("backToHome", forKey: "backFromAbout")
        UserDefaults.standard.set("backToHome", forKey: "back")
         //permanant deed marker table load
        self.tableViewSortBy = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        self.tableViewSortBy.delegate = self
        self.tableViewSortBy.dataSource = self
        self.view.addSubview(self.tableViewSortBy)
        
        UserDefaults.standard.removeObject(forKey: "Key")
       //nav bar title localized() convert into local language
        self.navigationItem.title = "Tagged Deeds".localized()
        //setting mapview delegate to access delegate methods
        outletMapView.delegate = self
        
        //Get FCM token
        let refreshedToken = GlobalClass.sharedInstance.nullToNil(value: FIRInstanceID.instanceID().token() as AnyObject)
        UserDefaults.standard.setValue(refreshedToken, forKey: "FCMTOEKN")
        deviceToken = UserDefaults.standard.value(forKey: "FCMTOEKN") as! String
        outletMapView.settings.indoorPicker = true
        self.navigationBarButton()
        // acessing function  to store categoty images from API
        self.createFolder()
        
        //Set loginFlag to TRUE means User is get loged in and alway opens with Home Screen which we checked in App delegate class
        defaults.set("TRUE", forKey: "loginFlag")
        //To adjust top white space
        self.automaticallyAdjustsScrollViewInsets = false
        
        DispatchQueue.main.async{
            //List count set border and color
            self.outletCountLabel.layer.borderWidth = 1.0
            self.outletCountLabel.layer.cornerRadius = 2
            self.outletCountLabel.layer.borderColor = UIColor.orange.cgColor//UIColor(red:1.00, green:0.45, blue:0.00, alpha:1.0).cgColor
            //Set delegate to table view
            self.outletTableView.delegate = self
            self.outletTableView.dataSource = self
        }
       
    }
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.taggerListArr.removeAllObjects()
        self.downloadData()
        
    }
    // obj-c method for localize language
    @objc func setText(){
        self.outletSegment.setTitle("MAP".localized(), forSegmentAt: 0)
        self.outletSegment.setTitle("LIST".localized(), forSegmentAt: 1)
        listLabel.text = "Deed found near you.".localized()
        outletNoRecord.text = "No Records Found".localized()
    }
    // function Create folder to store categoty images from API
    func createFolder(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        let imagesDirectoryPath = documentDirectorPath.appendingFormat("/DownloadedImages")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath , withIntermediateDirectories: true, attributes: nil)
            }catch{
                //print("Something went wrong while creating a new folder")
            }
        }
    }
    
    // MARK:- Set All Markers with marging base image and URL image
    func showMarker(position: CLLocationCoordinate2D, title: String, taggerID: String, imageTagURL: URL,Address:String){
        let marker = GMSMarker()
        let mCustomData = CustomData(starRating: Address)
        marker.position = position
        marker.title = title
        marker.snippet = taggerID
        marker.userData = mCustomData
        let rect = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        let image1 = UIImage(contentsOfFile: imageTagURL.path)
        print(image1 as Any);
        if(image1 == nil){
            
        }
        else{
            let image = self.resizeImage(image: image1!, targetSize: rect)
            marker.icon = image
        }
        marker.map = outletMapView
    }
    // MARK:- resize marker image
    func resizeImage(image: UIImage, targetSize: CGRect) -> UIImage {
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
    
    // MARK:- Show current location marker on map
    func showCurrentLocationMarker(position: CLLocationCoordinate2D, title: String, taggerID: String, imageTag: String){
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        marker.snippet = taggerID
        marker.map = outletMapView
    }
//    //Marge base image and URL image which we stored in Bundle folder
//    func imageByMergingImages(topImage: UIImage, scaleForTop: CGFloat = 1.0) -> UIImage {
//        let size = topImage.size
//        let container = CGRect(x: 0, y: 0, width: 40, height: 49)
//        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
//        UIGraphicsGetCurrentContext()!.interpolationQuality = .high
//        topImage.draw(in: container)
//        let topWidth = size.width / scaleForTop
//        let topHeight = size.height / scaleForTop
//        let topX = (size.width / 2.0) - (topWidth / 2.0)
//        let topY = (size.height / 2.0) - (topHeight / 2.0)
//        topImage.draw(in: CGRect(x: topX, y: topY, width: topWidth, height: topHeight-5), blendMode: .normal, alpha: 1.0)
//        return UIGraphicsGetImageFromCurrentImageContext()!
//    }
//
    /* handles Info Window long press */
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        //print("didLongPressInfoWindowOf")
    }
    // MARK:- reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        customInfoWindow.removeFromSuperview()
        tappedMarker = marker
        UserDefaults.standard.set(marker.snippet, forKey: "marker") //setObject
        UserDefaults.standard.set(marker.title, forKey: "markertitle")
        if((marker.userData as? CustomData)?.starRating == nil || (marker.userData as? CustomData)?.starRating == ""){
            customInfoWindow.layer.borderWidth = 0.5
            customInfoWindow.layer.borderColor = UIColor.orange.cgColor//UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
            customInfoWindow.center = mapView.projection.point(for: marker.position)
        }else{
            UserDefaults.standard.set((marker.userData as! CustomData).starRating, forKey: "markerAddress")
            let lat = marker.position.latitude
            let long = marker.position.longitude
            let geo = String(format:"%.7f,%.7f", lat,long)//("\(lat),\(long)")
            UserDefaults.standard.set(geo, forKey: "markerGeo")//setObject
            customInfoWindow.layer.borderWidth = 0.5
            customInfoWindow.layer.borderColor = UIColor.orange.cgColor//UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
            customInfoWindow.center = mapView.projection.point(for: marker.position)
        }
        let arr = marker.title!.components(separatedBy: ":")
        var firstPart = ""
        var secondPart = ""
        if(arr.count>1){
            firstPart    = arr[0]
            secondPart = arr[1]
        }
        else{
            firstPart    = arr[0]
        }
        let title = ("\(firstPart)  \(marker.snippet ?? "0")")
        customInfoWindow.nameLabel.text = title
        if((marker.userData) != nil){
            if(secondPart == "P"){
                self.downloadPListMarker(geo:marker.position)
                let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
                popOverVC.geo = String(format:"%.7f,%.7f", marker.position.latitude,marker.position.longitude)
                self.addChildViewController(popOverVC)
                popOverVC.view.frame = self.view.frame
                self.view.addSubview(popOverVC.view)
                popOverVC.didMove(toParentViewController: self)
            }
            else{
                if(secondPart == "R") || (secondPart == "S")
                {
                    customInfoWindow.addressConstraint.constant = 61
                    customInfoWindow.addressLbl.text = (marker.userData as! CustomData).starRating
                    customInfoWindow.placePhoto.image = marker.icon
                    customInfoWindow.closeBtn.addTarget(self, action: #selector(self.closeBtnPress(_:)), for: .touchUpInside)
                    customInfoWindow.btn2.addTarget(self, action: #selector(self.showDetailsBtnPress(_:)), for: .touchUpInside)
                    self.view.addSubview(customInfoWindow)
                }
                else{
                    customInfoWindow.addressConstraint.constant = 61
                    customInfoWindow.addressLbl.text = (marker.userData as! CustomData).starRating
                    customInfoWindow.placePhoto.image = marker.icon
                    customInfoWindow.closeBtn.addTarget(self, action: #selector(self.closeBtnPress(_:)), for: .touchUpInside)
                    customInfoWindow.btn2.addTarget(self, action: #selector(self.showDetailsBtnPress(_:)), for: .touchUpInside)
                    self.view.addSubview(customInfoWindow)
                }
              
            }
        }
        else{
            //print("no")
        }
        return false
    }
    //MARK:- Close the custom information window open when marker tapped
    @objc func closeBtnPress(_ sender:UIButton){
        customInfoWindow.removeFromSuperview()
    }
//    //The target function
//    @objc func pressButton(_ sender: UIButton){ //<- needs `@objc`
//        //print("\(sender)")
//        let str = String(sender.tag)
//        self.outletMapView.makeToast(str)
//
//    }//The target function
    //Mark:- go to details button of tag from custom window
    @objc func showDetailsBtnPress(_ sender: UIButton){ //<- needs `@objc`
        let marker = UserDefaults.standard.string(forKey: "marker")
        let markertitle = UserDefaults.standard.string(forKey: "markertitle")
        let arr = markertitle!.components(separatedBy: ":")
        let firstPart    = arr[0]
        if Int(marker!) != 0{
            if(markertitle == "SOS:S")
            {
                let tagger = self.storyboard?.instantiateViewController(withIdentifier: "SosDetailsViewController") as! SosDetailsViewController
                tagger.sos_id = marker!
                self.navigationController?.pushViewController(tagger, animated: true)
            }
            else if((markertitle?.contains(":R"))!){
                let tagger = self.storyboard?.instantiateViewController(withIdentifier: "ResourceDetailViewController") as! ResourceDetailViewController
                tagger.resource_id = marker!
                self.navigationController?.pushViewController(tagger, animated: true)
            }
            else if((markertitle?.contains(":T"))!){
                let tagger = self.storyboard?.instantiateViewController(withIdentifier: "TaggerDetailsViewController") as! TaggerDetailsViewController
                tagger.deedId = marker!
                self.navigationController?.pushViewController(tagger, animated: true)
            }
        }
        else{
            self.outletMapView.hideAllToasts()
            self.outletMapView.makeToast("Your current location".localized())
        }
    }
   
    //empty the default infowindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    // let the custom infowindow follows the camera
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        customInfoWindow.center = mapView.projection.point(for: tappedMarker.position)
    }
    
    // take care of the close event
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        customInfoWindow.removeFromSuperview()
    }
    // MARK:- End Set Marker
    // MARK:- Get current location and update location to server
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
    
    //MARK:- Update user current location with server
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
    
    //MARK:- Check user permission for location
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            outletMapView.isMyLocationEnabled = true
        }
    }
    
    //MARK:- Get user location in Background and Active state and marker on map
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
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude,
                                              longitude: currentLocation.coordinate.longitude,
                                              zoom: 45,
                                              bearing: 0,
                                              viewingAngle: 0)
        outletMapView.camera = camera
        outletMapView.animate(toViewingAngle: 0)
        
        let latlongStr = String(format: "%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude)
        self.geoPoints = latlongStr
        
        //print(self.geoPoints)
        self.defaults.set(latlongStr, forKey: "CURRENTLOCATION")
        
        //let item : NSMutableDictionary = NSMutableDictionary()
        currentLocationVal.setValue("Current", forKey: "Tagged_Title")
        currentLocationVal.setValue(latlongStr, forKey: "Geopoint")
        currentLocationVal.setValue("", forKey: "Character_Path")
        currentLocationVal.setValue("0", forKey: "Tagged_ID")
        
        self.showCurrentLocationMarker(position: camera.target, title: "Current", taggerID: "0", imageTag: "")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Error while updating location " + error.localizedDescription)
    }
    // MARK:- End
    
    //MARK:- Add filter button on navigation bar
    func navigationBarButton(){
        filter.setImage(UIImage(named: "filter"), for: .normal)
        if Device.IS_IPHONE {
            
            filter.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        else {
            
            filter.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        }
        filter.addTarget(self, action: #selector(HomeViewController.filterAction), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: filter)
        
        tagDeed.setImage(UIImage(named: "cameraHome"), for: .normal)
        if Device.IS_IPHONE {
            
            tagDeed.frame = CGRect(x: 0, y: 0, width: 40, height: 35)
        }
        else {
            
            tagDeed.frame = CGRect(x: 0, y: 0, width: 60, height: 50)
        }
        tagDeed.addTarget(self, action: #selector(HomeViewController.cameraAction), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: tagDeed)
        self.navigationItem.setRightBarButtonItems([item1,item2], animated: true)
    }
    
    //Navigation bar button action: Filter
    @objc func filterAction() {
        
        filter.isUserInteractionEnabled = false
        
        let filterView = self.storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        self.navigationController?.pushViewController(filterView, animated: true)
    }
    
    //Navigation bar button action: Camera
    @objc func cameraAction(){
        
        //  GlobalClass.sharedInstance.menuIndex = "3"
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tagADeed") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ANLoader.hide()
        DispatchQueue.main.async {
          
        }
    }
    //Mark:- close window when page redirect from any controller to home view/map view
    @objc func closeMarkerView(notfication: NSNotification) {
        customInfoWindow.removeFromSuperview()
    }
   
    override func viewWillAppear(_ animated: Bool) {
         self.tabBarController?.tabBar.isHidden = false
        customInfoWindow.removeFromSuperview()
        //start monitering internet
         self.startMonitoringInternet()
        //download notification count data
          self.downloadNotificationData()
        //localize function call
         self.setText()
     //broadcast notification to close an custom info window
        NotificationCenter.default.addObserver(self, selector: #selector(closeMarkerView(notfication:)), name: .postNotifi, object: nil)
        
        DispatchQueue.main.async {
        //set name of tabbars
            self.tabBarController?.tabBar.items![1].title = "Tag A Deed".localized()
            self.tabBarController?.tabBar.items![0].title = "Home".localized()
            self.tabBarController?.tabBar.items![2].title = "Fulfilled tags".localized()
            self.tabBarController?.tabBar.items![3].title = "SOS".localized()
            self.navigationItem.title = "Tagged Deeds".localized()
            UserDefaults.standard.set("Home", forKey: "BackPress")
            self.loadFlag = true
            //   self.title = "Tagged Deeds"
            self.filter.isUserInteractionEnabled = true
            self.outletMapView.clear()
            self.findCurrentLocation()
            self.taggerListArr.removeAllObjects()
            self.outletTableView.reloadData()
            self.userId = UserDefaults.standard.value(forKey: "User_ID") as! String
            self.downloadData()
            self.downloadSosMarker()

            self.outletSegment.tintColor = UIColor.orange
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            self.refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
            self.tableViewSortBy.addSubview(self.refreshControl) // not required when using UITableViewController
        }
       
        let network = NetworkManager.sharedInstance
        network.reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.outletMapView.hideAllToasts()
                self.outletMapView.makeToast(Validation.ERROR.localized())
            }
        }
        
        network.reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.downloadData()
            }
        }
    }
    

    
    //MARK:- Menu button action
    @IBAction func menuBarAction(_ sender: Any)
    {
        if let drawer = self.drawer() ,
            let manager = drawer.getManager(direction: .left){
            let value = !manager.isShow
        drawer.isShowMask = true
            drawer.draggable = true
            drawer.showLeftSlider(isShow: value)
        }
    }
    
    //MARK:- Segment Action
    @IBAction func segmentAction(_ sender: Any) {
        if(outletSegment.selectedSegmentIndex==0) {
            outletListView.isHidden = true
            outletMapView.isHidden = false
         
        }
        else if(outletSegment.selectedSegmentIndex==1) {
            self.outletMapView.hideAllToasts()
            outletListView.isHidden = false
            outletMapView.isHidden = true
             
        }
    }
    
    //MARK: - TableView datasource dategate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(tableView == self.tableViewSortBy){
            return 2}
        else{
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(tableView == self.tableViewSortBy){
            if(section == 0){
                return 1
            }
            else{
                return self.arrayTableViewData.count
            }
        }
        else{
            if(taggerListArr.count == 0){
                return 0
            }
            else{
                return taggerListArr.count
            }
        }
    }
//MARK:- load cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.tableViewSortBy){
            let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell") as UITableViewCell
            if(indexPath.section == 0){
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                let marker = UserDefaults.standard.string(forKey: "markerAddress")
                cell.textLabel!.font = UIFont(name:"Avenir Medium", size:10)
                cell.textLabel!.numberOfLines = 0
                cell.textLabel!.text = marker
            }
            else{
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                cell.accessoryType = .detailDisclosureButton
                cell.tintColor = UIColor.orange
                let values = self.arrayTableViewData[indexPath.row]
                cell.textLabel!.font = UIFont(name:"Avenir", size:12)
                cell.textLabel!.text = ("\(values.need_name) - \(values.tag_id)")
                cell.detailTextLabel!.text = values.sub_types
                cell.detailTextLabel!.numberOfLines = 0
                let img = ("\(Constant.BASE_URL)/\(values.icon_path)")
                cell.imageView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                let itemSize = CGSize.init(width: 25, height: 25)
                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
                cell.imageView!.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
                let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
                cell.imageView?.image!.draw(in: imageRect)
                cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
                UIGraphicsEndImageContext();
                
                
            }
            return cell
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? HomeTableViewCell!
            cell?!.layer.cornerRadius=2
            
            let model = self.taggerListArr[indexPath.row] as! ModelHome
            
            cell?!.outletNeedLabel.text = String(format: "%@", model.Need_Name!)
            cell?!.taggedId.text = String(format: "%@", model.Tagged_ID!)
            cell?!.outletAddressLabel.text = String(format: "%@", model.Address!)
            
            let Tagged_Datetime = GlobalClass.sharedInstance.converDateFormate(dateString: model.Tagged_Datetime!)
            cell?!.outletDateLabel.text = String(format: "%@",Tagged_Datetime)
            
            cell?!.outletViewsLabel.text = String(format: "%@", model.Views!)
            cell?!.outletEndorseLabel.text = String(format: "%@", model.Endorse!)
            
            let iconURL = String(format: "%@%@", Constant.BASE_URL , model.Tagged_Photo_Path!)
            print(iconURL);
            var charactorURL = ""
            if(model.cat_type == "C"){
                                         charactorURL = String(format: "%@%@", Constant.Custom_BASE_URL ,model.Character_Path!)
                                      }
                                      else{
                                          charactorURL = String(format: "%@%@", Constant.BASE_URL ,model.Character_Path!)
                                      }
           
       //     let charactorURL = String(charactorURLstring.filter { !" \n\t\r".contains($0) })
            print("charecter",charactorURL);
            cell?!.outletIconImg.sd_setImage(with: URL(string: iconURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
            cell?!.outletIconImg.clipsToBounds = true
            cell?!.outletIconImg.layer.borderWidth=0.5
            cell?!.outletIconImg.layer.borderColor = UIColor.black.cgColor
            //cell?!.outletIconImg.layer.cornerRadius =  cell?!.outletIconImg.frame.height/2
            cell?!.outletCharacterImg.sd_setImage(with: URL(string: charactorURL), placeholderImage: UIImage(named: "Tag_A_Deed_Placeholder"))
            
            cell?!.outletKMAwayLabel.text = String(format: "Location : %@ km(s) away", model.Distance!)
            cell?!.outletGiftNowLabel .setTitle("See More".localized(), for: UIControlState.normal)
            //   cell?!.outletGiftNowLabel.backgroundColor = .clear
            cell?!.outletGiftNowLabel.layer.cornerRadius = 5
            cell?!.outletGiftNowLabel.layer.borderWidth = 0.5
            cell?!.outletGiftNowLabel.layer.borderColor = UIColor.black.cgColor
            cell?!.delegate = self
            return cell!!
        }
    }
    //MARK:- handle deatls show more button event in tableview
    func detailButtonTapped(name: String) {
        //print(name)

        let tagger = self.storyboard?.instantiateViewController(withIdentifier: "TaggerDetailsViewController") as! TaggerDetailsViewController
        //print(name)
     tagger.deedId = String(format: "%@", name)
        self.navigationController?.pushViewController(tagger, animated: true)
    }
    
     //MARK:- method to define height of row in tableview
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(tableView == self.tableViewSortBy){
            return HT/9.9
        }
        else{
            return UITableViewAutomaticDimension
        }
    }
     //MARK:- define estimated height of row for showing dynamic data and according to this resize cell height
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.tableViewSortBy){
            return 200
        }
        else{
            return UITableViewAutomaticDimension
        }
    }
     //MARK:- define height for header section in tableview
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView == self.tableViewSortBy){
            return HT/12.9
        }
        else{
            return 5
        }
    }
    
    //Mark:- download permannat list
    func downloadPListMarker(geo : CLLocationCoordinate2D){
        //print(geo.latitude)//18.5535633,73.802788
        let  geoPoint = ("\(geo.latitude),\(geo.longitude)")//String(format:"%f,%f", geo.latitude,geo.longitude)
        //print(geoPoint)
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized().localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.permanent_deed_list
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@&geopoints=%@",userId,geoPoint)
        //print(paramString)
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                //print(jsonObj!)
                
                for values in jsonObj!{
                    let tag_id = (values as AnyObject).value(forKey: "tag_id") as! String
                    let need_name = (values as AnyObject).value(forKey: "need_name") as! String
                    let sub_types = (values as AnyObject).value(forKey: "sub_types") as! String
                    let icon_path = (values as AnyObject).value(forKey: "icon_path") as! String
                    let pdeed = pDeedList(tag_id: tag_id, sub_types: sub_types, need_name: need_name, icon_path: icon_path)
                    //print(pdeed)
                    self.arrayTableViewData.append(pdeed)
                    
                    //print(self.arrayTableViewData)
                }
                DispatchQueue.main.async{
                    self.tableViewSortBy.reloadData()
                    self.tableViewSortBy.showLoader()
                    Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(HomeViewController.removeLoader), userInfo: nil, repeats: false)
                }
            }
            
        }
        
        task.resume()
        
    }
     //MARK:-  remove loader from view
    @objc func removeLoader()
    {
        self.tableViewSortBy.hideLoader()
    }
    //Mark:- download sos marker from API
    func downloadSosMarker(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized().localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.sos_list
        
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
                    
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                let sosLists = jsonObj?.value(forKey: "sos_list") as? NSArray
                let sosMarker = jsonObj?.value(forKey: "marker_path") as! String
                for values in sosLists!{
                    let sosId = (values as AnyObject).value(forKey: "id") as! String
                    let sosGeo = (values as AnyObject).value(forKey: "geopoints") as! String
                      let address = (values as AnyObject).value(forKey: "address") as! String
                    let sos = sosList(id: sosId , geoPoints: sosGeo, path: sosMarker, address: address)
                    //print(sos)
                    self.sosArray.append(sos)
                }
                DispatchQueue.main.async{
                    self.loadSosViewMapView()
                }
            }
            
        }
        
        task.resume()
        
    }
    //Mark:- Load Sos marker location from server data
    func loadSosViewMapView() {
        
        DispatchQueue.main.async{
            
            for i in 0..<self.sosArray.count {
                self.sosFlag = true
                let model = self.sosArray[i]
                
                var charactorURL =  ""
                let title = String(format: "%@", "SOS" )
                
                charactorURL = String(format: "%@%@", Constant.BASE_URL ,model.path)
                
                let documentDirectorPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                
                let imagesDirectoryPath = documentDirectorPath.appendingFormat("/DownloadedImages")
                
                let url = NSURL(fileURLWithPath: imagesDirectoryPath)
                
                let imageName = (charactorURL as NSString).lastPathComponent
                
                if let pathComponent = url.appendingPathComponent(imageName) {
                    
                    let filePath = pathComponent.path
                    let fileManager = FileManager.default
                    
                    if fileManager.fileExists(atPath: filePath) {
                        //print("FILE AVAILABLE")
                    } else {
                        let result = charactorURL.components(separatedBy: .whitespacesAndNewlines).joined()
                        let data1 = try? Data(contentsOf: URL(string: result)!)
                        
                        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("/DownloadedImages").appendingPathComponent(imageName)
                        
                        do {
                            try data1?.write(to: fileURL, options: .atomic)
                        } catch {
                            //print(error)
                        }
                    }
                } else {
                    //print("FILE PATH NOT AVAILABLE")
                }
                
                let imagePathComponent = url.appendingPathComponent(imageName)
                if(model.geoPoints == ""){}
                else{
                    let latlongStr = String(format: "%@", (model.geoPoints))
                    let latlong = latlongStr.components(separatedBy: ",")
                    let lat    = (latlong[0] as NSString).doubleValue
                    let long = (latlong[1] as NSString).doubleValue
                    let marker = GMSMarker()
                    marker.snippet = String(format: "%@", (model.id))
                    marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    // self.getAddressForLatLng(latitude: lat, longitude: long)
                    self.showMarker(position: marker.position, title:  ("\(title):\("S")"), taggerID: marker.snippet!, imageTagURL: imagePathComponent!,Address:model.address)
                }
            }
        }
    }
    
    //Mark:- check if user has an own group then only show resources on map
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
                DispatchQueue.main.async{
                    if(self.groupArr.count > 0)
                    {
                        self.downloadResourceMarker()
                    }
                    else{
                       
                        return
                    }
                    
                }
                
            }
            
        }
        task.resume()
    }
    
    // Mark:- Load resources marker location from server data
    func loadResourcesViewMapView() {
        
        DispatchQueue.main.async{
            
            for i in 0..<self.resourceArray.count {
                self.sosFlag = true
                let model = self.resourceArray[i]
                
                var charactorURL =  ""
                let title = String(format: "%@:%@", model.resourseName,"R")
                
                charactorURL = String(format: "%@%@", Constant.BASE_URL ,model.resourseMarker)
                
                let documentDirectorPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                
                let imagesDirectoryPath = documentDirectorPath.appendingFormat("/DownloadedImages")
                
                let url = NSURL(fileURLWithPath: imagesDirectoryPath)
                
                let imageName = (charactorURL as NSString).lastPathComponent
                
                if let pathComponent = url.appendingPathComponent(imageName) {
                    
                    let filePath = pathComponent.path
                    let fileManager = FileManager.default
                    
                    if fileManager.fileExists(atPath: filePath) {
                        //print("FILE AVAILABLE")
                    } else {
                        let result = charactorURL.components(separatedBy: .whitespacesAndNewlines).joined()
                        let data1 = try? Data(contentsOf: URL(string: result)!)
                        
                        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("/DownloadedImages").appendingPathComponent(imageName)
                        
                        do {
                            try data1?.write(to: fileURL, options: .atomic)
                        } catch {
                            //print(error)
                        }
                    }
                } else {
                    //print("FILE PATH NOT AVAILABLE")
                }
                
                let imagePathComponent = url.appendingPathComponent(imageName)
                if(model.resoursegeoPoints == ""){}
                else{
                    let latlongStr = String(format: "%@", (model.resoursegeoPoints))
                    let latlong = latlongStr.components(separatedBy: ",")
                    let lat    = (latlong[0] as NSString).doubleValue
                    let long = (latlong[1] as NSString).doubleValue
                    let marker = GMSMarker()
                    marker.snippet = String(format: "%@", (model.resourseid))
                    marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    // self.getAddressForLatLng(latitude: lat, longitude: long)
                    self.showMarker(position: marker.position, title: title, taggerID: marker.snippet!, imageTagURL: imagePathComponent!,Address:model.address)
                }
            }
        }
    }
    //Mark:- download resouce data from server
    func downloadResourceMarker(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized().localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.list_resources
        
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
                    
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            //{resource_list: [{id, resource_name, geopoint}], marker}
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                //print(jsonObj)
                let resourceLists = jsonObj?.value(forKey: "resource_list") as? NSArray
                let resourceMarker = jsonObj?.value(forKey: "marker") as! String
                
                for values in resourceLists!{
                    let resourceId = (values as AnyObject).value(forKey: "id") as! String
                    let resourceGeo = (values as AnyObject).value(forKey: "geopoint") as! String
                    let resource_name = (values as AnyObject).value(forKey: "resource_name") as! String
                    let address = (values as AnyObject).value(forKey: "address") as! String
                    let resource = resourceList(resourseid: resourceId, resoursegeoPoints: resourceGeo, resourseMarker: resourceMarker, resourseName: resource_name, address: address)
                    //print(resource)
                    self.resourceArray.append(resource)
                }
                DispatchQueue.main.async{
                    self.loadResourcesViewMapView()
                }
            }
            
        }
        
        task.resume()
        
    }

    //MARK:- Download tagger list marker and show data list in tableview
    func downloadData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.tagger_list
       // print(urlString)
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@", userId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async {
                    
                    if(self.outletSegment.selectedSegmentIndex==0) {
                        
                        self.outletMapView.hideAllToasts()
                        self.outletMapView.makeToast(Validation.ERROR.localized())
                    }
                    else if(self.outletSegment.selectedSegmentIndex==1) {
                        
                        self.outletMapView.hideAllToasts()
                        self.outletListView.makeToast(Validation.ERROR.localized())
                    }
                }
                return
            }
           
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                //print(jsonObj as Any)
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
                
                self.deiviceStatus = jsonObj!.value(forKey: "userDeviceTy") as? Int
                self.permanant_icon = (jsonObj!.value(forKey: "p_marker") as? String)!
                
                if let taggedlist = jsonObj!.value(forKey: "deed_list") as? NSArray {
                    
                    self.taggerListArr.removeAllObjects();
                    
                    for item in taggedlist {
                        
                        let taggedItem = item as? NSDictionary
                        let latlongStr = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Geopoint") as! String)
                        let latlong = latlongStr.components(separatedBy: ",")
                        if(latlong.count == 1){
                            //error msg show and skip marker
                            //print("data is not proper")
                        }
                        else{
                            //show marker
                            let lat    = (latlong[0] as NSString).doubleValue
                            let long = (latlong[1] as NSString).doubleValue
                            let tagerLatLong = CLLocation(latitude: lat, longitude: long)
                            let distanceInMeters = Double(self.currentLatLong.distance(from: tagerLatLong))
                            let Tagged_ID = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_ID") as! String)
                            let Tagged_Title = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_Title") as! String)
                            let Address = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Address") as! String)
                            let PAddress = String(format: "%@", (taggedItem as AnyObject).value(forKey:"is_permanent") as! String)
                            let Geopoint = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Geopoint") as! String)
                            let urlString_Tagged_Photo_Path = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_Photo_Path") as! String)
                            let Tagged_Photo_Path =  urlString_Tagged_Photo_Path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed);
                            let Tagged_Datetime = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Tagged_Datetime") as! String)
                            let urlString = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Icon_Path") as! String)
                            let Icon_Path = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                            print(Icon_Path)
                            let cat_type = String(format: "%@", (taggedItem as AnyObject).value(forKey:"cat_type") as! String)
                          
                            let Character_PathString = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Character_Path") as? String ?? "value")
                            let Character_Path = Character_PathString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                            let Need_Name = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Need_Name") as! String)
                            let Views = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Views") as! String)
                            let Endorse = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Endorse") as! String)
                            
                            let distanceInKM = distanceInMeters/1000.0
                            let model = ModelHome.init(Tagged_ID: Tagged_ID, Tagged_Title: Tagged_Title, Address: Address, PAddress: PAddress, Geopoint: Geopoint, Tagged_Photo_Path: Tagged_Photo_Path!, Tagged_Datetime: Tagged_Datetime, Icon_Path: Icon_Path!, Character_Path: Character_Path!, Need_Name: Need_Name, Views: Views, Endorse: Endorse, Distance: String(format:"%0.2f",distanceInKM),cat_type: cat_type)
                            
                            let flag = self.defaults.value(forKey: "FILTERSTATUS") as? Bool
                            if flag ?? false {
                                
                                let filterRadiusValInKM = self.defaults.value(forKey: "DEED_RADIUS") as! Double
                                
                                if distanceInKM <= filterRadiusValInKM{
                                    
                                    let category = String(format: "%@", (taggedItem as AnyObject).value(forKey:"Need_Name") as! String)
                                    let group = String(format: "%@", (taggedItem as AnyObject).value(forKey:"user_grp_ids") as! String)
                                    let all_groups = String(format: "%@", (taggedItem as AnyObject).value(forKey:"all_groups") as! String)
                                    let filterCategoryVal = self.defaults.value(forKey: "CATEGORY") as! String
                                    let filterGroupVal = self.defaults.value(forKey: "GROUP") as! String
                                    
                                    
                                    do {
                                
                                        if ((filterCategoryVal.isEqual(category) && filterGroupVal.isEqual("All")) || (filterCategoryVal.isEqual("All") && filterGroupVal.isEqual("All")))
                                        {
                                            try self.taggerListArr.add(model!)
                                        }
                                        else if ((filterCategoryVal.isEqual(category) && (!filterGroupVal.isEqual("All"))) || (filterCategoryVal.isEqual("All") && (!filterGroupVal.isEqual("All")))){
                                            
                                            //print(filterGroupVal)
                                            if(filterGroupVal.isEqual(group) || (all_groups.isEqual("Y"))){
                                                self.taggerListArr.add(model!)
                                            }
                                            else{
                                               if (filterGroupVal.isEqual(group) && (all_groups.isEqual("N"))){
                                                     self.taggerListArr.add(model!)
                                                }
                                            }
                                        }
                                        
                                    } catch {
                                        // Error Handling
                                        //print("Some error occured.")
                                    }
                                    
                                }
                                else{
                                    
                                    //print("More Distance")
                                }
                            }
                            else{
                                
                                if distanceInKM <= GlobalClass.sharedInstance.filterRadiusVal{
                                    
                                    do {
                                        
                                        try self.taggerListArr.add(model!)
                                        
                                    } catch {
                                        // Error Handling
                                        //print("Some error occured.")
                                    }
                                    
                                }
                                else{
                                    
                                    //print("More Distance")
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async{
                        self.refreshControl.endRefreshing()
                        self.updateUI()
                        self.loadViewMapView()
                        self.downloadOwnGroupData()
                    }
                }
            }
            
        }
        task.resume()
    }
    
    //Load marker location from server data
    func loadViewMapView() {
        
        DispatchQueue.main.async{
            
            for i in 0..<self.taggerListArr.count {
                self.sosFlag = false
                let model = self.taggerListArr[i] as? ModelHome
                let flag = model?.PAddress!
                var charactorURL =  ""
                let title = String(format: "%@", (model?.Need_Name)! )
                if(flag == "Y"){
                    if(model?.cat_type == "C"){
                        charactorURL = String(format: "%@%@", Constant.Custom_BASE_URL ,(model?.Icon_Path)!)
                    }
                    else{
                        charactorURL = String(format: "%@%@", Constant.BASE_URL ,self.permanant_icon)
                        //print(charactorURL)
                    }
                    
                }
                else{
                    
                    if(model?.cat_type == "C"){
                        charactorURL = String(format: "%@%@", Constant.Custom_BASE_URL ,(model?.Icon_Path)!)
                    }
                    else{
                        charactorURL = String(format: "%@%@", Constant.BASE_URL ,(model?.Icon_Path)!)
                        //print(charactorURL)
                    }
                    
                }
                
                let documentDirectorPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                
                let imagesDirectoryPath = documentDirectorPath.appendingFormat("/DownloadedImages")
                
                let url = NSURL(fileURLWithPath: imagesDirectoryPath)
                
                let imageName = (charactorURL as NSString).lastPathComponent
                
                if let pathComponent = url.appendingPathComponent(imageName) {
                    
                    let filePath = pathComponent.path
                    let fileManager = FileManager.default
                    
                    if fileManager.fileExists(atPath: filePath) {
                        //print("FILE AVAILABLE")
                    } else {
                        let result = charactorURL.components(separatedBy: .whitespacesAndNewlines).joined()
                        let data1 = try? Data(contentsOf: URL(string: result)!)
                        
                        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("/DownloadedImages").appendingPathComponent(imageName)
                        
                        do {
                            try data1?.write(to: fileURL, options: .atomic)
                        } catch {
                            //print(error)
                        }
                    }
                } else {
                    //print("FILE PATH NOT AVAILABLE")
                }
                
                let imagePathComponent = url.appendingPathComponent(imageName)
                
                let latlongStr = String(format: "%@", (model?.Geopoint)!)
                let latlong = latlongStr.components(separatedBy: ",")
                let lat    = (latlong[0] as NSString).doubleValue
                let long = (latlong[1] as NSString).doubleValue
                //                let lat = Double(latlong[0])
                //                let lon = Double(latlong[1])
                
                let coordinates = CLLocationCoordinate2D(latitude:lat
                    , longitude:long)
                
                let marker = GMSMarker()
                marker.snippet = String(format: "%@", (model?.Tagged_ID)!)
                marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                //print(marker.position)
                //print(flag as Any)
                if(flag == "Y")
                {
                    self.showMarker(position: marker.position, title: ("\(title):\("P")"), taggerID: marker.snippet!, imageTagURL: imagePathComponent!,Address: (model?.Address)!)
                    
                }
                else{
                    self.showMarker(position: marker.position, title:  ("\(title):\("T")"), taggerID: marker.snippet!, imageTagURL: imagePathComponent!,Address: (model?.Address)!)
                }
                
            }
        }
    }
    
    //MARK:- Sort Tagger list by Distance
    func updateUI() {
        
        self.outletCountLabel.text=String(format: "  %d  ", self.taggerListArr.count)
        if(self.taggerListArr.count > 1){
             listLabel.text = "Deed(s) found near you.".localized()
            
        }
        else{
             listLabel.text = "Deed found near you.".localized()
        }
        let sortedArray = taggerListArr.sortedArray {
            (obj1, obj2) -> ComparisonResult in
            
            let p1 = obj1 as! ModelHome
            let p2 = obj2 as! ModelHome
            
            let result = p1.Distance!.compare(p2.Distance!)
            return result
        }
        
        taggerListArr.removeAllObjects()
        taggerListArr = NSMutableArray(array: sortedArray)
        
        if self.deiviceStatus == 0{
            
            self.updateDevicetype()
        }
        
        if self.taggerListArr.count == 0{
            
            DispatchQueue.main.async{
                
                self.outletNoRecord.isHidden = false
            }
        }
        else{
            
            outletNoRecord.isHidden = true
        }
        outletTableView.reloadData()
    }
    
    //MARK:- Update device type
    func updateDevicetype() {
        
        let urlString = Constant.BASE_URL + Constant.update_device_type
        let url:NSURL = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@",userId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request as URLRequest)
        task.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            customInfoWindow.removeFromSuperview()
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
                //print(currentLocation.coordinate.latitude)
                //print(currentLocation.coordinate.longitude)
                
                let geo = String(format: "%f,%f", (currentLocation.coordinate.latitude),(currentLocation.coordinate.longitude))
                //print(geo)
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
}
