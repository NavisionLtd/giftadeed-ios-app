//
//  FirstLoginViewController.swift
//  GiftADeed
//
//  Created by nilesh sinha on 23/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

/*
 •    If the user logs in using social media accounts, then any mandatory information that is not received from those accounts will be asked for during the first login (e.g. Country, State, City, email). The email input field will be displayed only if the email cannot be fetched from the social media account.
 •    Also, for regular first login, the User will have to input the State (based on country) and City (based on city). The country will be prepopulated (editable). The User cannot continue unless all the mandatory information has been input.
*/
import EFInternetIndicator
import UIKit
import ActionSheetPicker_3_0
import Toast_Swift
import ANLoader
import Localize_Swift
import SQLite
class FirstLoginViewController: UIViewController,InternetStatusIndicable {
   var internetConnectionIndicator:InternetViewIndicator?

    var countryId = "",stateId = "",cityId = ""
    
    let defaults = UserDefaults.standard
    var userId = ""
    var email = ""
    
    var flag = ""
    
    var countryDataArr = NSMutableArray()
    var countryNameArr = NSMutableArray()
    var stateDataArr = NSMutableArray()
    var stateNameArr = NSMutableArray()
    var cityDataArr = NSMutableArray()
    var cityNameArr = NSMutableArray()
    @IBOutlet var outletEmailHeight: NSLayoutConstraint!
    
    var editStatus : Bool!
    var downloadStatus : Bool!
    var togglePwd : Bool!
    
    @IBOutlet var outletEmailSeperator: UIImageView!
    @IBOutlet var outletFirstLoginView: UIView!
    @IBOutlet var outletEmail: UITextField!
    @IBOutlet  var outletCountry: UITextField!
    @IBOutlet  var outletState: UITextField!
    @IBOutlet  var outletCity: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
self.startMonitoringInternet()
        // Do any additional setup after loading the view.

        
        
        self.outletEmail.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                      attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
               self.outletCountry.attributedPlaceholder = NSAttributedString(string: "Select Country",
                                                                              attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        self.outletState.attributedPlaceholder = NSAttributedString(string: "Select State",
                                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        self.outletCity.attributedPlaceholder = NSAttributedString(string: "Select City",
                                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        userId = defaults.value(forKey: "User_ID") as! String
        email = defaults.value(forKey: "Email") as! String
       
        //Check email has been present
        if email.count == 0 || email.contains("privaterelay"){
           
            
            outletEmailSeperator.isHidden = false
            self.outletEmailHeight.constant = 30.0
            self.outletEmail.isHidden = false
            //   self.defaults.set(self.outletEmail, forKey: "Email")
        }
        else{
            
            outletEmailSeperator.isHidden = true
            self.outletEmailHeight.constant = 0.0
            self.outletEmail.isHidden = true
        }
        downloadStatus = false
        
        //Download Country data
        self.downloadCountryData();
            
        let network = NetworkManager.sharedInstance
        network.reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                
                self.view.hideAllToasts()
                self.view.makeToast(Validation.ERROR.localized())
            }
        }
        
        network.reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                
                if self.countryId.count == 0{
                    
                    self.downloadCountryData();
                }
                else if self.stateId.count == 0{
                    
                    self.downloadStateData()
                }
                else if self.cityId.count == 0{
                    
                    self.downloadCityData()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            ANLoader.hide()
        }
    }
    
    //MARK:- Select Country
    @IBAction func selectCountry(_ sender: Any) {
        
        if self.countryNameArr.count==0{
            
            self.outletFirstLoginView.hideAllToasts()
            self.outletFirstLoginView.makeToast("No data found".localized())
            return
        }
        
        ActionSheetStringPicker.show(withTitle: "Select Country", rows: self.countryNameArr as! [Any], initialSelection: 0, doneBlock: {
            picker, index, value in
 
            self.downloadStatus = false
            
            let model = self.countryDataArr[index] as! ModelAddress
            self.countryId = model.typeId
            self.outletCountry.text = model.name
            
            self.outletState.text = "Select State"
            self.outletCity.text = "Select City"
            
            self.stateId = ""
            self.cityId = ""
            
            self.stateNameArr.removeAllObjects()
            self.stateDataArr.removeAllObjects()
            
            self.cityDataArr.removeAllObjects()
            self.cityNameArr.removeAllObjects()
            
            DispatchQueue.main.async {
                //Download State data
                
                self.downloadStateData()
            }

            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //MARK:- Select State
    @IBAction func selectState(_ sender: Any) {
        
        if self.countryId.isEqual(""){
            
            self.outletFirstLoginView.hideAllToasts()
            self.outletFirstLoginView.makeToast("Select Country".localized())
            return
        }
        
        if self.stateNameArr.count==0{
            
            self.outletFirstLoginView.hideAllToasts()
            self.outletFirstLoginView.makeToast("No data found".localized())
            return
        }
        
        ActionSheetStringPicker.show(withTitle: "Select State", rows: self.stateNameArr as! [Any], initialSelection: 0, doneBlock: {
            picker, index, value in
            
            self.downloadStatus = false
            
            let model = self.stateDataArr[index] as! ModelAddress
            self.stateId = model.typeId
            self.outletState.text = model.name
            
            self.outletCity.text = "Select City"
            
            self.cityId = ""
            self.cityDataArr.removeAllObjects()
            self.cityNameArr.removeAllObjects()
            
            DispatchQueue.main.async {
                
                //Download City Data
                self.downloadCityData()
                return
            }
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //MARK:- Select City
    @IBAction func selectCity(_ sender: Any) {
        
        if self.stateId.isEqual(""){
            
            self.outletFirstLoginView.hideAllToasts()
            self.outletFirstLoginView.makeToast(Validation.validCity)
            return
        }
        
        if self.cityNameArr.count==0{
            
            self.outletFirstLoginView.hideAllToasts()
            self.outletFirstLoginView.makeToast("No data found".localized())
            return
        }

        ActionSheetStringPicker.show(withTitle: "Select City", rows: self.cityNameArr as! [Any], initialSelection: 0, doneBlock: {
            picker, index, value in
            
            DispatchQueue.main.async {
              
                self.downloadStatus = false
                let model = self.cityDataArr[index] as! ModelAddress
                self.outletCity.text = model.name
                self.cityId = model.typeId
            }
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //MARK:- Submit selected data to server
    //Sending data to server we need country ID , State ID, city ID which we get from server and if any situalation we not get Email id then we need to enter email id also
    @IBAction func submitAction(_ sender: Any) {
        
        if email.count == 0 || email.contains("privaterelay"){
            
            email = outletEmail.text!
            
            
            let appleId = defaults.value(forKey: "appleId") as! String
                        GlobalClass.sharedInstance.openDb()
                      let user = Constant.AppleLoginTable.filter(Constant.appleid == appleId)
                                     let updateUser = user.update(Constant.email <- email)
                                     do {
                                         try Constant.database.run(updateUser)
                                     } catch {
                                         print(error)
                                     }
            
            if Validation.sharedInstance.isValidEmail(Email: email){
                
            }else{
                
                self.outletFirstLoginView.hideAllToasts()
                self.outletFirstLoginView.makeToast(Validation.validLoginEmail)
                return
            }
        }
        
        if self.countryId.count == 0{
           
            self.outletFirstLoginView.hideAllToasts()
            self.outletFirstLoginView.makeToast(Validation.validCountry)
            return
        }
        
        if self.stateId.count == 0{
            
            self.outletFirstLoginView.hideAllToasts()
            self.outletFirstLoginView.makeToast(Validation.validState)
            return
        }
        
        if self.cityId.count == 0{
            
            self.outletFirstLoginView.hideAllToasts()
            self.outletFirstLoginView.makeToast(Validation.validCity)
            return
        }
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.first_login
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "Country_ID=%@&State_ID=%@&City_ID=%@&Email=%@&User_ID=%@",self.countryId,self.stateId,self.cityId,email,userId)
        print(paramString)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in

            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
                
                DispatchQueue.main.async{
                    
                    self.outletFirstLoginView.hideAllToasts()
                    self.outletFirstLoginView.makeToast(Validation.ERROR.localized())
                }
                return
            }
  
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                print(jsonObj)
                if let checkstatus = jsonObj!.value(forKey: "checkstatus") as? NSArray {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        ANLoader.hide()
                    }
                    
                    let status  = ((checkstatus[0] as AnyObject).value(forKey: "status") as? String)!
                    if status.isEqual("1"){
                        
                        DispatchQueue.main.async {
                            
                            DispatchQueue.main.async {
                                
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "home") 
                                UIApplication.shared.keyWindow?.rootViewController = viewController
                            }
                            return
                        }
                    }
                    else {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                            
                            ANLoader.hide()
                        }
                        
                        DispatchQueue.main.async {
                            
                          //  self.outletFirstLoginView.hideAllToasts()
                            self.outletFirstLoginView.makeToast("Some error occured.".localized())
                            return
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK:- Download Country data
    func downloadCountryData(){
        
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.country_list
        
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
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
                
                DispatchQueue.main.async{
                    
                    self.outletFirstLoginView.hideAllToasts()
                    self.outletFirstLoginView.makeToast(Validation.ERROR)
                }
                return
            }
            
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let taggedlist = jsonObj!.value(forKey: "countrydata") as? NSArray {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        ANLoader.hide()
                    }
                    
                    self.countryNameArr.removeAllObjects();
                    self.countryDataArr.removeAllObjects();
                    
                    for countryItem in taggedlist {
                        
                        let item = countryItem as! NSDictionary
                        
                        let name = String(format: "%@", item.value(forKey:"Cntry_Name") as! String);
                        let typeId = String(format: "%@", item.value(forKey:"Cntry_ID") as! String);
                        
                        let model = ModelAddress.init(name: name, typeId: typeId)
                        
                        do {
                            
                            try self.countryNameArr.add(model?.name as Any)
                            try self.countryDataArr.add(model!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.".localized())
                        }

                        
                        let screenType = self.defaults.value(forKey: "FISRTSCREEN")
                        if (screenType! as AnyObject).isEqual("normal"){
                            
                            let countryID = model?.typeId
                            let Country_ID = self.defaults.value(forKey: "Country_ID") as! String
                            
                            if Country_ID.isEqual(countryID){
                                
                                DispatchQueue.main.async {
                                    
                                    self.countryId = Country_ID
                                    self.outletCountry.text = model?.name
                                    self.downloadStateData()
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK:- Download State data
    func downloadStateData(){

        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.state_list
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "Cntry_ID=%@", self.countryId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        print(self.countryId)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
                
                DispatchQueue.main.async{
                    
                    self.outletFirstLoginView.hideAllToasts()
                    self.outletFirstLoginView.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
                
                self.stateNameArr.removeAllObjects();
                self.stateDataArr.removeAllObjects();
                
                if let statelist = jsonObj!.value(forKey: "statedata") as? NSArray {
                    
                    for stateItem in statelist {
                        
                        let item = stateItem as! NSDictionary
                        
                        let name = String(format: "%@", item.value(forKey:"State_Name") as! String);
                        let typeId = String(format: "%@", item.value(forKey:"State_ID") as! String);
                        
                        let model = ModelAddress.init(name: name, typeId: typeId)

                        do {
                            
                            try self.stateNameArr.add(model?.name as Any)
                            try self.stateDataArr.add(model!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                        if self.downloadStatus{
                            
                            let stateID = model?.typeId
                            if (stateID?.isEqual(self.stateId))!{
                                
                                DispatchQueue.main.async {
                                    
                                    self.outletState.text = model?.name
                                    self.downloadCityData()
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
            }
        }
        task.resume()
    }
    
    //MARK:- Download city data
    func downloadCityData(){

        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.city_list
        
        let url:NSURL = NSURL(string: urlString)!
                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "State_ID=%@", self.stateId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            
            data, response, error) in

            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
                
                DispatchQueue.main.async{
                    
                    self.outletFirstLoginView.hideAllToasts()
                    self.outletFirstLoginView.makeToast(Validation.ERROR.localized())
                }
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                self.cityNameArr.removeAllObjects();
                self.cityDataArr.removeAllObjects();
                
                if let citylist = jsonObj!.value(forKey: "citydata") as? NSArray {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        ANLoader.hide()
                    }
                    
                    for cityItem in citylist {
                        
                        let item = cityItem as! NSDictionary
                        
                        let name = String(format: "%@", item.value(forKey:"City_Name") as! String);
                        let typeId = String(format: "%@",  item.value(forKey:"City_ID") as! String);
                        
                        let model = ModelAddress.init(name: name, typeId: typeId)

                        do {
                            
                            try self.cityNameArr.add(model?.name as Any)
                            try self.cityDataArr.add(model!)
                            
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                        if self.downloadStatus{
                            
                            let cityID = model?.typeId
                            if (cityID?.isEqual(self.cityId))!{
                                
                                DispatchQueue.main.async {
                                    
                                    self.outletCity.text = model?.name
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    ANLoader.hide()
                }
            }
            
        }
        task.resume()
    }
}
