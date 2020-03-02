//
//  SuggestSubCategoryViewController.swift
//  GiftADeed
//
//  Created by Darshan on 2/26/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import ActionSheetPicker_3_0
import Localize_Swift
import EFInternetIndicator
class SuggestSubCategoryViewController: UIViewController,UIAdaptivePresentationControllerDelegate,InternetStatusIndicable {
    var internetConnectionIndicator:InternetViewIndicator?
    
    static func instantiate() -> SuggestSubCategoryViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(SuggestSubCategoryViewController.self)") as? SuggestSubCategoryViewController
    }
   
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var subTypeBtn: UILabel!
    var subTypeName = ""
    var categoryArr = NSMutableArray()
    var categoryListArr = NSMutableArray()
    var needMappingID = ""
    var needTitle = ""
    @IBOutlet weak var suggestionText: UITextField!
    @IBOutlet weak var categoryBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
downloadCategoryData()
       self.categoryBtn.setTitle(UserDefaults.standard.string(forKey: "category"), for: .normal)
          self.navigationItem.title = "Sub Type".localized()
        // Do any additional setup after loading the view.
        self.suggestionText.setBottomBorder()
        self.suggestionText.layer.borderColor = UIColor.orange.cgColor
        self.categoryBtn.setBorder()
        self.subTypeBtn.text = "Sub Type".localized()
        setText()
       
    }
    func setText(){
        self.suggestionText.placeholder = "Enter suggestion".localized()
        self.subTypeBtn.text = "Sub Type".localized()
        self.okBtn.setTitle("OK".localized(), for: .normal)
        self.cancelBtn.setTitle("Cancel".localized(), for: .normal)
    }
    @IBAction func categoryBtnPress(_ sender: UIButton) {
        print(self.needMappingID)
        if self.categoryListArr.count == 0{
            self.view.hideAllToasts()
            self.navigationController?.view.makeToast("Categories are empty.".localized())
            return
        }
        ActionSheetStringPicker.show(withTitle: self.needTitle,
                                     rows: self.categoryListArr as! [Any] ,
                                     initialSelection: 0,
                                     doneBlock: {
                                        picker, indexe, values in
                                        
                                       self.categoryBtn.setTitle(values as! String, for: .normal)
                                        
                                        let item = self.categoryArr[indexe]
                                        self.needTitle = (item as AnyObject).value(forKey:"Need_Name") as! String
                                        self.needMappingID = (item as AnyObject).value(forKey:"NeedMapping_ID") as! String
                                        
                                      
                                        
                                        return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func saveBtnPress(_ sender: UIButton) {
        print("\(self.needTitle)\(self.needMappingID)")
        if(suggestionText.text?.count == 0){
            self.view.makeToast("Please enter any sub type name".localized())
        }
        else{
            self.view.hideAllToasts()
             saveSubType()
            self .dismiss(animated: true, completion: nil)
        }
       
    }
    @IBAction func CancelBtnPress(_ sender: UIButton) {
         self .dismiss(animated: true, completion: nil)
    }
    //sub type suggestion save to api
    func saveSubType(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.suggest_sub_type
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "type_id=%@&sub_type_name=%@",self.needMappingID,suggestionText.text!)
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
                    self.view.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj!)
                let statusChk = jsonObj?.value(forKey:"status") as? Int
                print(statusChk as Any)
                if statusChk == 1 && statusChk != nil {
                    
                    DispatchQueue.main.async {
                        //Success msg will shown to user
                        self.view.makeToast(Validation.subSuccess_msg.localized())
                      //  self .dismiss(animated: true, completion: nil)
                    }
                    return
                }
                    
                else if statusChk == 0 && statusChk != nil{
                    DispatchQueue.main.async {
                        //Success msg will shown to user
                        self.view.makeToast(Validation.subError_msg.localized())
                    }
                    return
                }
                else if statusChk == 2 && statusChk != nil{
                    DispatchQueue.main.async {
                        //Success msg will shown to user
                        self.view.makeToast(Validation.subExist_msg.localized())
                    }
                    return
                }
                //ANLoader.hide()
                
            }
        }
        
        task.resume()
        
    }
    //MARK:- Download category data
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
                    
                    //self.view.hideAllToasts()
                    //self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let needtype = jsonObj!.value(forKey: "g_need") as? NSArray {
                    
                    self.categoryListArr.removeAllObjects();
                    self.categoryArr.removeAllObjects();
                    
                    for item in needtype {
                        
                        do {
                            
                            try self.categoryListArr.add((item as AnyObject).value(forKey:"Need_Name") as! String)
                             self.needMappingID = (item as AnyObject).value(forKey:"NeedMapping_ID") as! String
                            let needItem = item as? NSDictionary
                            try self.categoryArr.add(needItem!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }
                }
            }
            
        }
        task.resume()
    }

}
