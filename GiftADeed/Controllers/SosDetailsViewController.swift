//
//  SosDetailsViewController.swift
//  GiftADeed
//
//  Created by Darshan on 4/10/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import Firebase
import FirebaseStorage
import FirebaseDatabase
import EFInternetIndicator
class SosDetailsViewController: UIViewController,InternetStatusIndicable{
    var internetConnectionIndicator:InternetViewIndicator?
     var sos_id = ""
     var userId = ""
    // Firebase services
    var database = FIRDatabase.database()
    var storage = FIRStorage.storage()
    @IBOutlet weak var sosImage: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var sosCreatedDate: UITextField!
    @IBOutlet weak var sosAddress: UILabel!
    @IBOutlet weak var sosEmergencyType: FloatLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        sosDetailsApiCall()
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        downloadProfileImg()
        self.navigationItem.title = "SOS detail"
        self.sosCreatedDate.setBottomBorder()
        self.userName.setBottomBorder()
        self.sosAddress.addBottomBorder(UIColor.black, height: 1.0)
        self.sosEmergencyType.setBottomBorder()
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "delete"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        btn1.addTarget(self, action: #selector(SosDetailsViewController.deletesos), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
        // Do any additional setup after loading the view.
    }
    @objc func deletesos(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.remove_sos
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "user_id=%@&sos_id=%@",userId,sos_id)
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
                let status = jsonObj?.value(forKey: "status") as! Int
                if(status == 1){
                     DispatchQueue.main.async{
                        self.view.makeToast("Sos successfully deleted".localized())
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home")
                        UIApplication.shared.keyWindow?.rootViewController = viewController
                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.view.makeToast("Please try again.".localized())
                    }
                }
                
            }
            
        }
        
        task.resume()
    
    }


    func downloadProfileImg(){
        let dbRef = database.reference().child("SOSDev")
        dbRef.observeSingleEvent(of:.value) { (snapshot) in
            if !snapshot.exists() { return }
            
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                print(data)
                let object = data.value as? [String:AnyObject]
                let id = object?["sosid"]
                print(id as Any,self.sos_id)
                if (id?.isEqual(self.sos_id))!{
                    let downloadUrl = object?["sosurl"]
                    print(downloadUrl!)
                    let storageRef = self.storage.reference(forURL: downloadUrl as! String)
                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
                    storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        // Create a UIImage, add it to the array
                        if(data == nil){
                            
                        }else{
                        let pic = UIImage(data: data!)
//                        self.imgAvater.layer.cornerRadius =  self.imgAvater.frame.size.width / 2
//                        self.imgAvater.clipsToBounds = true
                        self.sosImage.layer.borderWidth = 0.5
                        self.sosImage.layer.borderColor = UIColor.white.cgColor
                        self.sosImage.image = pic
                        }
                    }
                }
                else{
                    
                    print("Default Image")
                }
            }
        }
    }
    func sosDetailsApiCall(){
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.sos_details
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "sos_id=%@",sos_id)
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
                for values in jsonObj!{
                    let username = (values as AnyObject).value(forKey: "user_name") as? String
                    
                     let date = (values as AnyObject).value(forKey: "c_date") as! String
                     let emergencyType = (values as AnyObject).value(forKey: "sos_type") as? String
                     let address = (values as AnyObject).value(forKey: "address") as! String
                      DispatchQueue.main.async{
                        if(username?.count == 0){
                            self.userName.text = "Data not available"
                        }
                        else{
                             self.userName.text = username
                        }
                   
                         self.sosCreatedDate.text = date
                         self.sosAddress.text = address
                        if(emergencyType == nil){
                          self.sosEmergencyType.text  = "Data not available"
                        }
                        else{
                            self.sosEmergencyType.text = emergencyType!
                        }
                        
                  }
                }
                
            }
          
        }
        
        task.resume()
    }

}
