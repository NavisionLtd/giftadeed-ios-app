//
//  CreateResourceViewController.swift
//  GiftADeed
//
//  Created by Darshan on 2/27/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//
import Localize_Swift
import UIKit
import ANLoader
import ActionSheetPicker_3_0
import SQLite
import CoreLocation
import GooglePlaces
import MMDrawController

class CreateResourceViewController: UIViewController, CLLocationManagerDelegate ,GMSAutocompleteViewControllerDelegate {
    @IBOutlet weak var createResBtn: UIButton!
    @IBOutlet weak var selectLocationLbl: UILabel!
    @IBOutlet weak var selectAudiance: UITextField!
    @IBOutlet weak var selectPreferenceText: UITextField!
    @IBOutlet weak var selectCategory: UITextField!
    @IBOutlet weak var selectedGroupText: UITextField!
    @IBOutlet weak var selectedAddressText: UILabel!
    @IBOutlet weak var resourceName: UITextField!
    @IBOutlet weak var resourceDescription: FloatLabelTextField!
    @IBOutlet weak var preferenceTextHeightConstraint: NSLayoutConstraint!
    var res_idforedit = ""
    var categoryListArray: [resCategory]? = []
    var groupArr = NSMutableArray()
    var groupListArr = NSMutableArray()
    var userId = ""
    //For group
    var needGroupMappingID = ""
    var needGroupTitle = ""
    //for category
    var selectedCategoryRows = NSMutableIndexSet()
    var selectedCategotyNameArray = NSMutableArray()
    var selectedCategotyIdArray = NSMutableArray()
    var selectedCategoryId = ""
    var selectedCategoryName = ""
    var selectedNormalCategory = NSMutableArray()
    var selectedNormalCategoryId = ""
    var selectedCustomCategory = NSMutableArray()
    var selectedCustomCategoryId = ""
    //for preference
    var selectedPreferenceRows = NSMutableIndexSet()
    var selectedPreferenceNameArray = NSMutableArray()
    var selectedPreferenceIdArray = NSMutableArray()
    var selectedPreferenceId = ""
    var selectedPreferenceName = ""
    //for Audiance
    var selectedAudianceRows = NSMutableIndexSet()
    var selectedAudianceNameArray = NSMutableArray()
    var selectedAudianceIdArray = NSMutableArray()
    var selectedAudianceId = ""
    var selectedAudianceName = ""
    var allAudiance = ""
    @IBOutlet weak var selectAudianceBtn: UIButton!
    @IBOutlet weak var selectCategoryBtn: UIButton!
    @IBOutlet weak var selectGroupBtn: UIButton!
    @IBOutlet weak var selectPreferenceBtn: UIButton!
    @IBOutlet weak var selectAddressBtn: UIButton!
    var addressString = ""
    var geoPoint = ""
    var locManager = CLLocationManager()
    var currentLatLong = CLLocation()
    var res_name = ""
    var res_description = ""
    var flag:Bool =  false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
       
        self.navigationController?.navigationBar.topItem?.title = " "
        GlobalClass.sharedInstance.openDb()
         self.findCurrentLocation()
        selectGroupBtn.addBottomBorder(UIColor.black, height: 1.0)
        selectCategoryBtn.addBottomBorder(UIColor.black, height: 1.0)
        selectPreferenceBtn.addBottomBorder(UIColor.black, height: 1.0)
        selectedAddressText.addBottomBorder(UIColor.black, height: 1.0)
        resourceName.addBottomBorder(UIColor.black, height: 1.0)
        resourceDescription.addBottomBorder(UIColor.black, height: 1.0)
        selectAudiance.addBottomBorder(UIColor.black, height: 1.0)
         userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        downloadOwnGroupData()
        setText()
        if(flag){
            //Set res detail to each outlet
            //Its edit functionality so change create resource btn to save resource btn
            self.createResBtn.setTitle("Edit Resource".localized(), for: .normal)
            self.resourceName.text = self.res_name
            self.resourceDescription.text = self.res_description
            self.selectedGroupText.text = self.needGroupTitle
            print(self.categoryListArray!)
            selectedCategotyNameArray.removeAllObjects()
            selectedCategotyIdArray.removeAllObjects()
            selectedPreferenceNameArray.removeAllObjects()
            selectedPreferenceIdArray.removeAllObjects()
            for values in categoryListArray!{
                print(values.subcategory_id)
                self.selectedPreferenceIdArray.add(values.subcategory_id)
                self.selectedPreferenceNameArray.add(values.subcategory_name)
                self.selectedCategotyNameArray.add(values.category_name)
                self.selectedCategotyIdArray.add(values.category_id)
                //Get group_cat index from api and update indexset
                var array : [Int] = []
                var clubIndex = values.category_id as! String
                let pointsArr = clubIndex.components(separatedBy: ",")
                print(pointsArr.count)
                for i in pointsArr{
                    print(i)
                    let number = Int(i)
                    
                    array.append(number!-1)
                    print(array)
                }
                for index in array {
                    self.selectedCategoryRows.add(index)
                }
                //end of group_cat indexset
              
            }
            
            selectedCategoryId = selectedCategotyIdArray.componentsJoined(by: ",")
            selectedPreferenceId = selectedPreferenceIdArray.componentsJoined(by: ",")
            selectedPreferenceName = selectedPreferenceNameArray.componentsJoined(by: ",")
            selectedCategoryName = selectedCategotyNameArray.componentsJoined(by: ",")
            
            let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let components = selectedPreferenceName.components(separatedBy: ",")
            let words = components.filter { !$0.isEmpty }
            
            print(words.count)  // 18
            
            if(self.selectedCategotyNameArray.count > 1){
                self.selectCategory.text = ("\(self.selectedCategotyNameArray[0]) & \(self.selectedCategotyNameArray.count - 1) Other(s)")
            }
            else{
                self.selectCategory.text = (self.selectedCategotyNameArray[0] as! String)
            }
    
            if(self.selectedPreferenceNameArray.count > 1){
               let str = selectedPreferenceNameArray.componentsJoined(by: ",")
               print(str.count)
                if let first = str.components(separatedBy: ",").first {
                    // Do something with the first component.
                    self.selectPreferenceText.text = ("\(first) & \(words.count - 1) Other(s)")
                }
                
            }
            else{
                self.selectPreferenceText.text = (selectedPreferenceNameArray[0] as! String)
            }
            
            self.selectedAddressText.text = self.addressString
            if(self.allAudiance == "Y"){
                self.selectAudiance.text = "All Audiance"
            }
            else{
                 self.selectAudiance.text = self.selectedAudianceName
            }
           self.navigationController?.title = "Edit Resource".localized()
        }
        else{
            //continue with create_resources and set first value
            //as default value for each and every dropdown
             self.navigationController?.title = "Create Resource".localized()
             self.createResBtn.setTitle("Create Resource".localized(), for: .normal)
            
        }
    }
    func setText(){
        self.selectedGroupText.placeholder = "Select your group".localized()
        self.selectCategory.placeholder = "Select resource category".localized()
        self.selectPreferenceText.placeholder = "Select resource preference".localized()
         self.resourceName.placeholder = "Select Resource name".localized()
        self.resourceDescription.placeholder = "Resource description".localized()
        self.selectAudiance.placeholder = "Select Resource audience".localized()
        self.createResBtn.setTitle("Create Resource".localized(), for: .normal)
        self.selectLocationLbl.text = "Select Location".localized()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        if(flag){
             self.navigationItem.title = "Edit Resource".localized()
        }
        else{
            
            self.navigationItem.title = "Create Resource".localized()
        }
        
    }
    func didUpdateCategory(){
        var selectedTypeArray = NSMutableArray()
        selectedCategotyNameArray.removeAllObjects()
        selectedCategotyIdArray.removeAllObjects()
        selectedNormalCategory.removeAllObjects()
        selectedCustomCategory.removeAllObjects()
        let selectedStatus = NSMutableArray()
         // let selectedType = NSMutableArray()
        do {
            let users = try Constant.database.prepare(Constant.categoryTable)
            for user in users {
                print("id: \(user[Constant.cid]), needName: \(user[Constant.catname]), needId: \(user[Constant.catid]), needStatus: \(user[Constant.catstatus])")
                let name = user[Constant.catname]
                let id = user[Constant.catid]
                let status = user[Constant.catstatus]
                let type = user[Constant.cattype]
                if(status == "y"){
                    if(type == "C"){
                      selectedTypeArray.add(type)
                       self.selectAudiance.text = needGroupTitle
                       // self.selectedAudianceIdArray.add(needGroupMappingID)
                        self.selectedAudianceId = needGroupMappingID
                        self.selectAudianceBtn.isEnabled = false
                        self.selectPreferenceBtn.isHidden = true
                        self.selectPreferenceText.isHidden = true
                        self.preferenceTextHeightConstraint.constant = 0
                        self.selectedCustomCategory.add(id)
                    }else{
                         selectedTypeArray.remove(type)
                         self.preferenceTextHeightConstraint.constant = 35
                         self.selectAudianceBtn.isEnabled = true
                         self.selectPreferenceBtn.isHidden = false
                         self.selectPreferenceText.isHidden = false
                         self.selectedNormalCategory.add(id)
                    }
                    if(selectedNormalCategory.count > 0){
                        self.selectPreferenceBtn.isHidden = false
                        self.selectPreferenceText.isHidden = false
                        self.preferenceTextHeightConstraint.constant = 35
                    }
                    else{
                        self.selectPreferenceBtn.isHidden = true
                        self.selectPreferenceText.isHidden = true
                        self.preferenceTextHeightConstraint.constant = 0
                    }
                    selectedCategotyNameArray.add(name)
                    selectedCategotyIdArray.add(id)
                    selectedStatus.add("y")
                }
                else{
                    self.selectedCustomCategory.remove(id)
                    self.selectedNormalCategory.remove(id)
                    selectedCategotyNameArray.remove(name)
                    selectedCategotyIdArray.remove(id)
                    selectedStatus.add("n")
                }
              
                print(selectedTypeArray)
            }
            print("\(self.selectedCustomCategory)\(self.selectedNormalCategory)")
           selectedNormalCategoryId = self.selectedNormalCategory.componentsJoined(by: ",")
           selectedCustomCategoryId = self.selectedCustomCategory.componentsJoined(by: ",")
            let catName = selectedCategotyNameArray.componentsJoined(by: ",")
            let catid = selectedCategotyIdArray.componentsJoined(by: ",")
          
            selectedCategoryId = selectedCategotyIdArray.componentsJoined(by: ",")
            print("Selected categories are \(selectedCategoryId)")
            print(selectedCategotyNameArray.count)
            if(selectedCategotyNameArray.count == 1)
            {
                let title = ("\(catName)")
                self.selectCategory.text = title
            }
            else  if(selectedCategotyNameArray.count > 1){
                let title = ("\(selectedCategotyNameArray[0]) & \(selectedCategotyNameArray.count - 1) Other(s)")
                self.selectCategory.text = title
            }
            else{
                 self.selectCategory.text = ""
                 self.selectPreferenceText.text = ""
            }
        } catch {
            print(error)
        }
    }
    func didUpdatePreference(){
        selectedPreferenceNameArray.removeAllObjects()
        selectedPreferenceIdArray.removeAllObjects()
        let selectedStatus = NSMutableArray()
        do {
            let users = try Constant.database.prepare(Constant.multipreferenceTable)
            for user in users {
                print("id: \(user[Constant.mrid]), needName: \(user[Constant.mrefname]), needId: \(user[Constant.mrefid]), needStatus: \(user[Constant.mrefstatus])")
                let name = user[Constant.mrefname]
                let id = user[Constant.mrefid]
                let status = user[Constant.mrefstatus]
                if(status == "y"){
                    selectedPreferenceNameArray.add(name)
                    selectedPreferenceIdArray.add(id)
                    selectedStatus.add("y")
                }
                else{
                    selectedPreferenceNameArray.remove(name)
                    selectedPreferenceIdArray.remove(id)
                    selectedStatus.add("n")
                }
                
                print(selectedStatus)
            }
            let prefName = selectedPreferenceNameArray.componentsJoined(by: ",")
            let prefid = selectedPreferenceIdArray.componentsJoined(by: ",")
            selectedPreferenceId = selectedPreferenceIdArray.componentsJoined(by: ",")
            print(selectedPreferenceNameArray.count)
            if(selectedPreferenceNameArray.count == 1)
            {
                let title = ("\(prefName)")
                self.selectPreferenceText.text = title
            }
            else  if(selectedPreferenceNameArray.count > 1){
                let title = ("\(selectedPreferenceNameArray[0]) & \(selectedPreferenceNameArray.count - 1) Other(s)")
                self.selectPreferenceText.text = title
            }
            else{
                self.selectPreferenceText.text = ""
            }
        } catch {
            print(error)
        }
    }
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.addressString = place.formattedAddress!
        selectedAddressText.text = self.addressString
        geoPoint = String(format:"%f,%f", place.coordinate.latitude, place.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
         let url: NSURL?
      //  let url = NSURL(string: "\(Constant.GOOGLE_PLACES_BASE_URL)latlng=\(latitude),\(longitude)&key=\(Constant.GooglePlacesApp_ID)")
        var lang = Localize.currentLanguage()
        if(lang == "zh-Hant"){
            url = NSURL(string: "\(Constant.china_google_place)latlng=\(latitude),\(longitude)&key=\(Constant.GooglePlacesApp_ID)")
        }
        else{
            url = NSURL(string: "\(Constant.GOOGLE_PLACES_BASE_URL)latlng=\(latitude),\(longitude)&key=\(Constant.GooglePlacesApp_ID)")
        }
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
                    self.navigationController?.view.makeToast(Validation.ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
            {
                
                if let result = jsonObj!["results"] as? NSArray {
                    let status = jsonObj?.value(forKey: "status") as! String
                    if(status == "ZERO_RESULTS"){
                        DispatchQueue.main.async {
                            self.view.makeToast("Address not found! please select address manually")
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            
                            let address = (result[0] as AnyObject)["formatted_address"] as? String
                            self.addressString = address!
                            self.selectedAddressText.text = self.addressString
                            //  self.selectAddressBtn.setTitle(self.addressString, for: .normal)
                        }
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
    func didUpdateAudiance(){
        selectedAudianceNameArray.removeAllObjects()
        selectedAudianceIdArray.removeAllObjects()
        let selectedStatus = NSMutableArray()
        do {
            let users = try Constant.database.prepare(Constant.multiaudianceTable)
            for user in users {
                print("id: \(user[Constant.mid]), needName: \(user[Constant.mresname]), needId: \(user[Constant.mresid]), needStatus: \(user[Constant.mresstatus])")
                let name = user[Constant.mresname]
                let id = user[Constant.mresid]
                let status = user[Constant.mresstatus]
                if(status == "y"){
                    selectedAudianceNameArray.add(name)
                    selectedAudianceIdArray.add(id)
                    selectedStatus.add("y")
                }
                else{
                    selectedAudianceNameArray.remove(name)
                    selectedAudianceIdArray.remove(id)
                    selectedStatus.add("n")
                }
                print(selectedStatus)
            }
            let audianceName = selectedAudianceNameArray.componentsJoined(by: ",")
            let audianceid = selectedAudianceIdArray.componentsJoined(by: ",")
            selectedAudianceId = selectedAudianceIdArray.componentsJoined(by: ",")
            print(selectedAudianceNameArray.count)
            if(selectedAudianceNameArray.count == 1)
            {
                let title = ("\(audianceName)")
                self.selectAudiance.text = title
            }
            else  if(selectedAudianceNameArray.count > 1){
                let title = ("\(selectedAudianceNameArray[0]) & \(selectedAudianceNameArray.count - 1) Other(s)")
                self.selectAudiance.text = title
            }
            else{
                self.selectAudiance.text = ""
            }
        } catch {
            print(error)
        }
    }
    @IBAction func selectAudianceBtnPress(_ sender: UIButton) {
        selectedAudianceNameArray.removeAllObjects()
        selectedAudianceIdArray.removeAllObjects()
        //end
        if(self.needGroupMappingID == "" && needGroupTitle == "")
        {
            self.view.makeToast("Please select group")
        }else{
            let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "ResourceTableViewController") as? ResourceTableViewController
            mapViewControllerObj?.delegate = self
            mapViewControllerObj?.dataText = "audiance"
               mapViewControllerObj?.titles = "Select Audiance"
            mapViewControllerObj?.selectedRows = self.selectedAudianceRows
           // mapViewControllerObj?.categoryId = self.selectedCategoryId
            self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
        }
    }
    @IBAction func selectAddressBtn(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func selectPreferenceBtnPress(_ sender: UIButton) {
        selectedPreferenceNameArray.removeAllObjects()
        selectedPreferenceIdArray.removeAllObjects()
        // selectedCategoryId contain categorytype
        if(self.selectedCategoryId == "")
        {
            self.view.makeToast("Please select category")
        }else{
            let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "ResourceTableViewController") as? ResourceTableViewController
            mapViewControllerObj?.delegate = self
            mapViewControllerObj?.dataText = "preference"
             mapViewControllerObj?.titles = "Select Preference"

          print(self.selectedPreferenceRows)
            mapViewControllerObj?.selectedRows = self.selectedPreferenceRows
            mapViewControllerObj?.categoryId = self.selectedCategoryId
            self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
        }
    }
    @IBAction func selectCategoryBtnPress(_ sender: UIButton) {
       selectedCategotyNameArray.removeAllObjects()
       selectedCategotyIdArray.removeAllObjects()
           self.selectedPreferenceRows.removeAllIndexes()
        self.selectPreferenceText.text = ""
//        initialy set status to n for all rows
        let updateUser1 = Constant.multipreferenceTable.update(Constant.mrefstatus <- "n")
        do {
            try Constant.database.run(updateUser1)
        } catch {
            print(error)
        }
        //end
        if(self.needGroupMappingID == "" && needGroupTitle == "")
        {
            self.view.makeToast("Please select group")
        }else{
             let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "ResourceTableViewController") as? ResourceTableViewController
            mapViewControllerObj?.delegate = self
            mapViewControllerObj?.dataText = "category"
            print(self.selectedCategoryRows)
            mapViewControllerObj?.selectedRows = self.selectedCategoryRows
            mapViewControllerObj?.groupId = self.needGroupMappingID
            mapViewControllerObj?.titles = "Select Category"
            self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
        }
       
    }
    @IBAction func selectGroupBtnPress(_ sender: UIButton) {
        //initialy set status to n for all rows
        let updateUser = Constant.categoryTable.update(Constant.catstatus <- "n")
        do {
            try Constant.database.run(updateUser)
        } catch {
            print(error)
        }
        //end
        //initialy set status to n for all rows
        let updateUser1 = Constant.multipreferenceTable.delete()
        do {
            try Constant.database.run(updateUser1)
        } catch {
            print(error)
        }
        //end
        //initialy set status to n for all rows
        let updateUser2 = Constant.multiaudianceTable.delete()
        do {
            try Constant.database.run(updateUser2)
        } catch {
            print(error)
        }
        //end
        if self.groupListArr.count == 0{
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Group list is empty.")
            return
        }
        ActionSheetStringPicker.show(withTitle: "Select Group",
                                     rows: self.groupListArr as! [Any] ,
                                     initialSelection: 0,
                                     doneBlock: {
                                        picker, indexe, values in
                                        DispatchQueue.main.async{
                                     
                                            self.selectedGroupText.text = values as? String
                                        }
                                        let item = self.groupArr[indexe]
                                        self.needGroupTitle = (item as AnyObject).value(forKey:"group_name") as! String
                                        self.needGroupMappingID = (item as AnyObject).value(forKey:"group_id") as! String
                                     
                                        print("\(self.needGroupTitle)\(self.needGroupMappingID)")
                                        
                                        if(self.needGroupTitle.count > 0){
                                        //   self.downloadCategoryData(mapId: self.needGroupMappingID)
                                        }else{}
                                       
                                        return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    @IBAction func createResourcesBtnPress(_ sender: UIButton) {
       //Edit res or create new res logic
        if(flag){
            /*
             resource_id (int)
             user_id (int)
             group_id (int)
             resource_name(varchar)
             description (varchar)
             sub_type_pref (comma separated sub_type_id's (int) from sub type master table)
             geopoint (comma separated latitude and logintude of address in address field) (varchar)
             address (varchar)
             user_group_ids (comma separated id's (int) of invited/ notified groups) (varchar)
             all_groups "N/Y" (char)
             */
            userId = UserDefaults.standard.value(forKey: "User_ID") as! String
            ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
            let urlString = Constant.BASE_URL + Constant.update_resource
            let url:NSURL = NSURL(string: urlString)!
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
            var paramString = ""
            if(selectedAudianceId == "")
            {
                paramString = String(format: "resource_id=%@&user_id=%@&group_id=%@&resource_name=%@&description=%@&sub_type_pref=%@&geopoint=%@&address=%@&user_group_ids=%@&all_groups=%@&all_individuals=%@&main_category_ids=%@&group_category_ids=%@",self.res_idforedit,userId,self.needGroupMappingID,self.resourceName.text!,self.resourceDescription.text!,selectedPreferenceId,self.geoPoint,self.selectedAddressText.text!,"","Y","N",self.selectedNormalCategoryId,self.selectedCustomCategoryId)
                request.httpBody = paramString.data(using: String.Encoding.utf8)
            }
            else{
                paramString = String(format: "resource_id=%@&user_id=%@&group_id=%@&resource_name=%@&description=%@&sub_type_pref=%@&geopoint=%@&address=%@&user_group_ids=%@&all_groups=%@&all_individuals=%@&main_category_ids=%@&group_category_ids=%@",self.res_idforedit,userId,self.needGroupMappingID,self.resourceName.text!,self.resourceDescription.text!,selectedPreferenceId,self.geoPoint,self.selectedAddressText.text!,selectedAudianceId,"N","N",self.selectedNormalCategoryId,self.selectedCustomCategoryId)
                request.httpBody = paramString.data(using: String.Encoding.utf8)
            }
            
            print(paramString)
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
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                        DispatchQueue.main.async{
                            
                            let d = self.drawer()
                            d!.setMain(identifier: "resource", config: { (vc) in
                                self.view.makeToast("Resource created succesfully")
                            })
                        }
                        
                    }
                    else{
                        
                    }
                    
                }
                
            }
            task.resume()
        }
        else{
            userId = UserDefaults.standard.value(forKey: "User_ID") as! String
            ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
            let urlString = Constant.BASE_URL + Constant.add_resources
            let url:NSURL = NSURL(string: urlString)!
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60.0
            let session = URLSession(configuration: sessionConfig)
            let request = NSMutableURLRequest(url: url as URL)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpMethod = "POST"
        var paramString = ""
        if(selectedAudianceId == "")
        {
            paramString = String(format: "user_id=%@&group_id=%@&resource_name=%@&description=%@&sub_type_pref=%@&geopoint=%@&address=%@&user_group_ids=%@&all_groups=%@&all_individuals=%@&main_category_ids=%@&group_category_ids=%@",userId,self.needGroupMappingID,self.resourceName.text!,self.resourceDescription.text!,selectedPreferenceId,self.geoPoint,self.selectedAddressText.text!,"","Y","N",self.selectedNormalCategoryId,self.selectedCustomCategoryId)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
        }
        else{
            paramString = String(format: "user_id=%@&group_id=%@&resource_name=%@&description=%@&sub_type_pref=%@&geopoint=%@&address=%@&user_group_ids=%@&all_groups=%@&all_individuals=%@&main_category_ids=%@&group_category_ids=%@",userId,self.needGroupMappingID,self.resourceName.text!,self.resourceDescription.text!,selectedPreferenceId,self.geoPoint,self.selectedAddressText.text!,selectedAudianceId,"N","N",self.selectedNormalCategoryId,self.selectedCustomCategoryId)
            request.httpBody = paramString.data(using: String.Encoding.utf8)
        }
     
        print(paramString)
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
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                 let status = jsonObj?.value(forKey: "status") as! Int
                    if(status == 1){
                          DispatchQueue.main.async{
                      
                            let d = self.drawer()
                            d!.setMain(identifier: "resource", config: { (vc) in
                                 self.view.makeToast("Resource created succesfully")
                            })
                        }
                      
                    }
                    else{
                        
                    }
                    
                }
                
            }
            task.resume()
        }
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
                        print("Some error occured.")
                    }
                    
                }
                
            }
            
        }
        task.resume()
    }
}
