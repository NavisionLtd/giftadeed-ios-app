//
//  ResourceDetailViewController.swift
//  GiftADeed
//
//  Created by Darshan on 4/16/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import PopOverMenu
import Localize_Swift

struct resCategory {
     let category_id : String
     let category_name : String
     let custom_category_id : String
     let custom_category_name : String
     let subcategory_id : String
     let subcategory_name : String
}
struct subCategory {
    let subcategory_name : String
}

class ResourceDetailViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIAdaptivePresentationControllerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.categoryListArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ResourceCollectionViewCell
        cell.contentView.layer.cornerRadius = 2.0
        cell.contentView.layer.borderWidth = 1.5
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true;
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width:0,height: 2.5)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.5
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath

         let value = self.categoryListArray![indexPath.row]
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.catName.text = value.category_name.localized()
        cell.scroller.contentSize = CGSize(width: cell.scroller.contentSize.width, height: 200)
       cell.subCategory.text = value.subcategory_name
        var array = NSMutableArray()

      
        cell.backgroundColor = UIColor.white // make cell more visible in our example project
     return cell
    }
    
    @IBOutlet weak var resDateLbl: UILabel!
    @IBOutlet weak var resCreatedLbl: UILabel!
    @IBOutlet weak var resNameLbl: UILabel!
    @IBOutlet weak var resourceCategoryLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var customeCategory: UILabel!
    @IBOutlet weak var frontArrow: UIButton!
    @IBOutlet weak var backArrow: UIButton!
    @IBOutlet weak var resCatLbl: UILabel!
    @IBOutlet weak var resCatColloections: UICollectionView!
    @IBOutlet weak var resourceCategoryHeightConstraint: NSLayoutConstraint!
    var resource_id = ""
    var userId = ""
    var latlongStr = ""
    var categoryListArray: [resCategory]? = []
    @IBOutlet weak var resAddedByText: UILabel!
    var menuArray: [String] = [""]
    var menuOption = ""
    //For edit purpose
    var group_name = ""
    var group_id = ""
    var res_category = ""
    var res_cat_id = ""
    var res_preference = ""
    var res_pref_id = ""
    var address = ""
    var geoPoints = ""
    var res_name = ""
    var res_description = ""
    var res_allAudiance = ""
    var res_grpAudiance_id = ""
    var res_audianceName = ""
    var creator_id = ""
    @IBOutlet weak var resScroller: UIScrollView!
    @IBOutlet weak var resCreatedDateText: UILabel!
    @IBOutlet weak var resAddressText: UILabel!
    @IBOutlet weak var resDesText: UILabel!
    @IBOutlet weak var resNameText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
           self.navigationController?.navigationBar.topItem?.title = " "
        self.tabBarController?.tabBar.isHidden = true
         self.menuArray = ["Edit".localized(),"Delete".localized()]
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "plusSign"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(menuButtonTapped(sender:)))

        // Adding button to navigation bar (rightBarButtonItem or leftBarButtonItem)
        self.navigationItem.rightBarButtonItem = barButtonItem
 resCatColloections.layer.borderWidth = 0.2
       resCatColloections.layer.borderColor = UIColor.black.cgColor
       self.navigationItem.title = "Resource Details".localized()
     self.resScroller.contentSize = CGSize(width: self.resScroller.contentSize.width, height: 2100)
  userId = UserDefaults.standard.value(forKey: "User_ID") as! String
      self.resourceDetailsApiCall()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
         self.navigationItem.title = "Resource Details".localized()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    @objc func menuButtonTapped(sender: UIBarButtonItem){
        //show two options
        if(self.creator_id == self.userId){
            let popOverViewController = PopOverViewController.instantiate()
            popOverViewController.setTitles(self.menuArray)
            popOverViewController.popoverPresentationController?.barButtonItem = sender
            popOverViewController.preferredContentSize = CGSize(width: 100, height:100)
            popOverViewController.presentationController?.delegate = self
            popOverViewController.completionHandler = { selectRow in
                switch (selectRow) {
                case 0:
                    //push  resource edit view
                    let editRes = self.storyboard?.instantiateViewController(withIdentifier: "CreateResourceViewController") as! CreateResourceViewController
                    editRes.needGroupTitle = self.group_name
                    editRes.res_idforedit = self.resource_id
                    editRes.needGroupMappingID = self.group_id
                    editRes.selectedCategoryId = self.res_cat_id
                    editRes.selectedCategoryName = self.res_category
                    editRes.selectedPreferenceId = self.res_pref_id
                    editRes.selectedPreferenceName = self.res_preference
                    editRes.selectedAudianceName = self.res_audianceName
                    editRes.geoPoint = self.geoPoints
                    editRes.addressString = self.address
                    editRes.res_name = self.res_name
                    editRes.res_description = self.res_description
                    editRes.selectedAudianceId = self.res_grpAudiance_id
                    editRes.allAudiance =  self.res_allAudiance
                    editRes.flag = true
                    editRes.categoryListArray = self.categoryListArray
                    self.navigationController?.pushViewController(editRes, animated: true)
                    break
                case 1:
                    //push resource delete alert view
                    // Create the alert controller
                    let alertController = UIAlertController(title: "Delete Resource".localized(), message: "Do you really want to delete this  Resource?".localized(), preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Ok".localized(), style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                        self.deleteResourceApiCall()
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
        else{
            self.view.makeToast("You are not permited to take any action")
        }
       
    }
    //delete an resource Api call
    func deleteResourceApiCall(){
        //user_id(int), resource_id(int)
        ANLoader.showLoading("Loading", disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.del_resource
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@&resource_id=%@",userId,self.resource_id)
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
                        self.view.makeToast("You have successfully deleted this resourse".localized(),duration: 1.0)
                        self.navigationController?.popViewController(animated: true)
                        NotificationCenter.default.post(name: Notification.Name("resourceDeleted"), object: nil)
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
    @IBAction func getDirectionBtnPress(_ sender: UIButton) {
        //If details screen not able to download data then it will show error messge and stop to navigate to map view other wise it will navigate
        if self.latlongStr.isEqual(""){
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast(Validation.ERROR)
            return
        }
        
        let mapView = self.storyboard?.instantiateViewController(withIdentifier: "MapTaggerLocationViewController") as! MapTaggerLocationViewController
        
        let latlongStr = self.latlongStr
        let latlong = latlongStr.components(separatedBy: ",")
        
        mapView.lat = (latlong[0] as NSString).doubleValue
        mapView.long = (latlong[1] as NSString).doubleValue
    //   mapView.needTitle = self.need
        mapView.charactorURL = "https://kshandemo.co.in/gad3p2/api/image/feature/f_5c67d44b603960.761042861550308427.png"
//        mapView.taggerID = self.needMapId
        self.navigationController?.pushViewController(mapView, animated: true)
    }
    @IBAction func moveToBackword(_ sender: UIButton) {
        
        let visibleItems: NSArray = self.resCatColloections.indexPathsForVisibleItems as NSArray
        
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        for itr in visibleItems {
            
            if minItem.row > (itr as AnyObject).row {
                minItem = itr as! NSIndexPath
            }
        }
        
        let nextItem = NSIndexPath(row: minItem.row - 1, section: 0)
        self.resCatColloections.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
    }
    @IBAction func moveForwordBtnPress(_ sender: UIButton) {
      
        let visibleItems: NSArray = self.resCatColloections.indexPathsForVisibleItems as NSArray
        
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        for itr in visibleItems {
            
            if minItem.row > (itr as AnyObject).row {
                minItem = itr as! NSIndexPath
            }
        }
        
        let nextItem = NSIndexPath(row: minItem.row + 1, section: 0)
        self.resCatColloections.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
    }
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    func resourceDetailsApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.resource_details
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@&resource_id=%@",userId,resource_id)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                ANLoader.hide()
            }
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.async{
                    
                    self.view.hideAllToasts()
                    self.view.makeToast(Validation.ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj)
               

let resource_details = jsonObj?.value(forKey: "resource_details") as! NSArray
                for items in resource_details{
                    let address = (items as AnyObject).value(forKey: "address") as! String
                     let created_at = (items as AnyObject).value(forKey: "created_at") as! String
                     let creator_id = (items as AnyObject).value(forKey: "creator_id") as! String
                     let description = (items as AnyObject).value(forKey: "description") as! String
                     let geopoint = (items as AnyObject).value(forKey: "geopoint") as! String
                     let group_id = (items as AnyObject).value(forKey: "group_id") as! String
                     let group_name = (items as AnyObject).value(forKey: "group_name") as! String
                    let custom_cat_id = (items as AnyObject).value(forKey: "resource_group_categories") as! String
                    let custom_cat_name = (items as AnyObject).value(forKey: "resource_group_category_names") as! String
                    let geoPoint = (items as AnyObject).value(forKey: "geopoint") as! String
                    self.latlongStr = geoPoint
                    let resource_group_category_names = (items as AnyObject).value(forKey: "resource_group_category_names") as? String
                     let resource_audience_all_groups = (items as AnyObject).value(forKey: "resource_audience_all_groups") as! String
                     let resource_audience_group_ids = (items as AnyObject).value(forKey: "resource_audience_group_ids") as! String
                     let resource_name = (items as AnyObject).value(forKey: "resource_name") as! String
                   let resourceArray = (items as AnyObject).value(forKey: "sub_type") as! NSArray
                   self.creator_id = (items as AnyObject).value(forKey: "creator_id") as! String
                    self.res_audianceName = (items as AnyObject).value(forKey: "resource_audience_group_names") as! String
                    print(resourceArray)
                    self.nullToNil(value: resource_group_category_names as AnyObject)
                  //  print(resource_group_category_names!)
                    if((resource_group_category_names?.count)! > 0){
                     DispatchQueue.main.async{     self.customeCategory.isHidden = false
                        self.customeCategory.text = ("Custom category : \(resource_group_category_names!)")
                        }
                    }
                    else  if(resource_group_category_names?.count == nil || resource_group_category_names == ""){
                        DispatchQueue.main.async{   self.customeCategory.isHidden = true
                        }
                    }
                    if(resourceArray.count == 0){
                        DispatchQueue.main.async{
                            self.resourceCategoryHeightConstraint.constant = 0
                          //  self.resCatLbl.isHidden = true
                            self.backArrow.isHidden = true
                            self.frontArrow.isHidden = true
                        }
                      
                        var Need_ID = ""
                        var need_name = ""
                        var sub_type_id = ""
                        var sub_type_name = ""
                        for items in resourceArray{
                            Need_ID = (items as AnyObject).value(forKey: "Need_ID") as! String
                            need_name = (items as AnyObject).value(forKey: "need_name") as! String
                            sub_type_id = (items as AnyObject).value(forKey: "sub_type_id") as! String
                            sub_type_name = (items as AnyObject).value(forKey: "sub_type_name") as! String
                            var categories: resCategory!
                            categories = resCategory(category_id: Need_ID, category_name: need_name, custom_category_id: custom_cat_id, custom_category_name: custom_cat_name, subcategory_id: sub_type_id, subcategory_name: sub_type_name)
                            print(categories)
                            self.categoryListArray?.append(categories)
                        }
                        DispatchQueue.main.async{
                            self.group_name = group_name
                            self.group_id = group_id
                            self.res_category = need_name
                            self.res_cat_id = Need_ID
                            self.res_pref_id = sub_type_id
                            self.res_preference = sub_type_name
                            self.address = address
                            self.res_name = resource_name
                            self.res_description = description
                            self.res_allAudiance = resource_audience_all_groups
                            self.res_grpAudiance_id = resource_audience_group_ids
                            self.geoPoints = geopoint
                            self.resAddedByText.addBottomBorder(UIColor.black, height: 0.7)
                            self.resNameText.addBottomBorder(UIColor.black, height: 0.7)
                            self.resDesText.addBottomBorder(UIColor.black, height: 0.7)
                            self.resAddressText.addBottomBorder(UIColor.black, height: 0.7)
                            self.resCreatedDateText.addBottomBorder(UIColor.black, height: 0.7)
                            self.resAddedByText.text = group_name
                            self.resNameText.text = resource_name
                            self.resDesText.text = description
                            self.resAddressText.text = address
                            self.resCreatedDateText.text = created_at
                            self.resCatColloections.reloadData()
                        }
                        
                    }
                    else{
                   
                    var Need_ID = ""
                    var need_name = ""
                    var sub_type_id = ""
                    var sub_type_name = ""
                    for items in resourceArray{
                         Need_ID = (items as AnyObject).value(forKey: "Need_ID") as! String
                         need_name = (items as AnyObject).value(forKey: "need_name") as! String
                         sub_type_id = (items as AnyObject).value(forKey: "sub_type_id") as! String
                         sub_type_name = (items as AnyObject).value(forKey: "sub_type_name") as! String
                        var categories: resCategory!
                        categories = resCategory(category_id: Need_ID, category_name: need_name, custom_category_id: custom_cat_id, custom_category_name: custom_cat_name, subcategory_id: sub_type_id, subcategory_name: sub_type_name)
                                              print(categories)
                                                self.categoryListArray?.append(categories)
                    }
                    DispatchQueue.main.async{
                        self.resourceCategoryHeightConstraint.constant = 143
                        self.resCatLbl.isHidden = false
                        self.backArrow.isHidden = false
                        self.frontArrow.isHidden = false
                        self.group_name = group_name
                        self.group_id = group_id
                        self.res_category = need_name
                        self.res_cat_id = Need_ID
                        self.res_pref_id = sub_type_id
                        self.res_preference = sub_type_name
                        self.address = address
                        self.res_name = resource_name
                        self.res_description = description
                        self.res_allAudiance = resource_audience_all_groups
                        self.res_grpAudiance_id = resource_audience_group_ids
                        self.geoPoints = geopoint
                                                self.resAddedByText.addBottomBorder(UIColor.black, height: 0.7)
                                                self.resNameText.addBottomBorder(UIColor.black, height: 0.7)
                                                self.resDesText.addBottomBorder(UIColor.black, height: 0.7)
                                                self.resAddressText.addBottomBorder(UIColor.black, height: 0.7)
                                                self.resCreatedDateText.addBottomBorder(UIColor.black, height: 0.7)
                                                self.resAddedByText.text = group_name
                                                self.resNameText.text = resource_name
                                                self.resDesText.text = description
                                                self.resAddressText.text = address
                                                self.resCreatedDateText.text = created_at
                        self.resNameLbl.text = "Resouce Name".localized()
                        self.resCreatedLbl.text = "Resouce created by".localized()
                        self.resDateLbl.text = "Resouce created date".localized()
                        self.resourceCategoryLbl.text = "Resource category".localized()
                        self.customeCategory.text = "Custom category :".localized()
                        self.descriptionLbl.text = "Description".localized()
                                                self.resCatColloections.reloadData()
                        }
                    }
                }
            }
        }
        
        task.resume()
    }

}
