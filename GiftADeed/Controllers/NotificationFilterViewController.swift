//
//  NotificationFilterViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 04/05/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import ANLoader
import Localize_Swift
import EFInternetIndicator

class NotificationFilterViewController: UIViewController,InternetStatusIndicable {
    var internetConnectionIndicator:InternetViewIndicator?
    

    let defaults = UserDefaults.standard
    var userId = ""
    
    var categoryArr = NSMutableArray()
    var categoryListArr = NSMutableArray()
    var needMappingID = ""
    var needTitle = ""
    
    @IBOutlet var outletDistanceSlider: UISlider!
    @IBOutlet var outlletDistanceValue: UILabel!
    @IBOutlet var outletTimeSlider: UISlider!
    @IBOutlet var outlletTimeValue: UILabel!
    @IBOutlet var outletCategoryTxt: UITextField!
    @IBOutlet weak var applyFilterLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var selectCategoryLbl: UILabel!
    @IBOutlet weak var seachBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
self.navigationItem.title = "Filter".localized()
        self.applyFilterLbl.text = "Apply Filters".localized()
         self.distanceLbl.text = "Distance".localized()
         self.timeLbl.text = "Time".localized()
         self.selectCategoryLbl.text = "Select category".localized()
        self.seachBtn.setTitle("Search".localized(), for: .normal)
        // Do any additional setup after loading the view.
        userId = defaults.value(forKey: "User_ID") as! String
        self.updateUI()
        self.downloadCategoryData()
    }
    
    //Update UI, if user set filter already update from already saved data otherwise update default data
    func updateUI(){

        if GlobalClass.sharedInstance.notifilterStatus{

            self.outletTimeSlider.value = Float(GlobalClass.sharedInstance.notifilterTimeVal)
            self.outletDistanceSlider.value = Float(GlobalClass.sharedInstance.notifilterDistanceVal)
            self.outlletDistanceValue.text = "\(GlobalClass.sharedInstance.notifilterDistanceVal) km".localized()
            self.outlletTimeValue.text = "\(GlobalClass.sharedInstance.notifilterTimeVal) day".localized()
            self.outletCategoryTxt.text = GlobalClass.sharedInstance.notifilterCategoryValue
        }
        else{
            
            self.outletTimeSlider.value = 7.0
            self.outletDistanceSlider.value = 10.0
            self.outlletDistanceValue.text = "10 km".localized()
            self.outlletTimeValue.text = "7 day".localized()
            self.outletCategoryTxt.text = "All".localized()
        }
    }
    
    //Slider for distance
    @IBAction func sliderDistanceAction(sender: UISlider) {
        
        let currentValue = Int(sender.value)
        outlletDistanceValue.text = "\(currentValue) km".localized()
    }
    
    //Slider for number of days
    @IBAction func sliderTimeAction(sender: UISlider) {
        
        let currentValue = Int(sender.value)
        outlletTimeValue.text = "\(currentValue) day".localized()
    }
    
    //Select category
    @IBAction func categoryAction(_ sender: Any) {
        
        if self.categoryListArr.count == 0{
            
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Categories are empty.".localized())
        }
        
        ActionSheetStringPicker.show(withTitle: "Select Category", rows: self.categoryListArr as? [Any] , initialSelection: 0, doneBlock: {
            picker, indexe, values in
            
            if indexe == 0{
                
                self.outletCategoryTxt.text = "All".localized()
                GlobalClass.sharedInstance.notifilterCategoryValue = "All"
                return
            }
            else{
                self.outletCategoryTxt.text = values as? String
            }
        //    self.outletCategoryTxt.text = values as? String
            
            let item = self.categoryArr[indexe]
            GlobalClass.sharedInstance.notifilterCategoryValue = (item as AnyObject).value(forKey:"Need_Name") as! String
            GlobalClass.sharedInstance.notifilterCategoryId = (item as AnyObject).value(forKey:"NeedMapping_ID") as! String
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //Download category data
    func downloadCategoryData (){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.need_type
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
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
                
                let blockStatus = jsonObj?.value(forKey:"is_blocked") as? Int
                if blockStatus == 1 && blockStatus != nil {
                    
                    DispatchQueue.main.async {
                        
                        GlobalClass.sharedInstance.deInitClass()
                        GlobalClass.sharedInstance.clearLocalData()
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                        
                        self.view.hideAllToasts()
                        self.navigationController?.view.makeToast("\(GlobalClass.sharedInstance.blockStatus = true)")
                    }
                    return
                }
                
                if let needtype = jsonObj!.value(forKey: "g_need") as? NSArray {
                    
                    self.categoryListArr.removeAllObjects();
                    self.categoryArr.removeAllObjects();
                    
                    for item in needtype {
                        
                        do {
                            
                            try self.categoryListArr.add((item as AnyObject).value(forKey:"Need_Name") as! String)
                            
                            let needItem = item as? NSDictionary
                            try self.categoryArr.add(needItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }

                    }
//                    self.categoryArr.insert("All", at: 0)
//                    self.categoryListArr.insert("All", at: 0)
                }
                if let needtype1 = jsonObj!.value(forKey: "c_need") as? NSArray {
                    
                    //                    self.categoryListArr.removeAllObjects();
                    //                    self.categoryArr.removeAllObjects();
                    
                    for item in needtype1 {
                        
                        do {
                            
                            try self.categoryListArr.add((item as AnyObject).value(forKey:"Need_Name") as! String)
                            
                            let needItem = item as? NSDictionary
                            try self.categoryArr.add(needItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        self.categoryArr.insert("All", at: 0)
                        self.categoryListArr.insert("All", at: 0)
                    }
                }
            }
        }
        task.resume()
    }

    //Apply filter on notification
    @IBAction func applyAction(_ sender: Any) {
        
        GlobalClass.sharedInstance.notifilterStatus = true
        GlobalClass.sharedInstance.notifilterDistanceVal = Int(CGFloat((self.outlletDistanceValue.text! as NSString).doubleValue))
        GlobalClass.sharedInstance.notifilterTimeVal = Int(CGFloat((self.outlletTimeValue.text! as NSString).doubleValue))
        GlobalClass.sharedInstance.notifilterCategoryValue = self.outletCategoryTxt.text!
print(GlobalClass.sharedInstance.notifilterCategoryValue)
        print(GlobalClass.sharedInstance.notifilterTimeVal)
        self.navigationController?.popViewController(animated: true)
    }
}
