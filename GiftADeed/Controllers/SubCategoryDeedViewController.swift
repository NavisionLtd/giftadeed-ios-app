//
//  SubCategoryDeedViewController.swift
//  GiftADeed
//
//  Created by Darshan on 11/14/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//
//   let urlString = Constant.BASE_URLThree + Constant.suggest_sub_type
// let paramString = String(format: "type_id=%@,sub_type_name=%@", "1",customSubCategoryText.text!)
import UIKit
import ANLoader
import Toast_Swift
import SQLite
import EzPopup
import Localize_Swift
import EFInternetIndicator
class SubCategoryDeedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,InternetStatusIndicable {
   
     var internetConnectionIndicator:InternetViewIndicator?
    @IBOutlet weak var subTypeLbl: UILabel!
    @IBOutlet weak var subTypePeopleLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var suggestSubTypeBtn: UIButton!
    let customAlertVC = SuggestSubCategoryViewController.instantiate()
    @IBOutlet weak var categoryNameText: UILabel!
    @IBOutlet weak var customSubCategoryText: UITextField!
    var type_id = ""
    var type_name = " "
    var flag : Bool = false
    var subTypeArray = NSMutableArray()
    var subTypeIdArray = NSMutableArray()
    var subTypes = NSMutableArray()
    var plistHelepr = PlistManagment()
    var selectedSubTypeArray = NSMutableArray()
    var selectedSubTypenewArray = NSMutableArray()
   // var delegate = TagADeedViewController()
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.subTypeArray.count)
        if(self.subTypeArray.count == 0){
            self.view.makeToast("No Data Found".localized())
            return 0
        }
        else{
        return self.subTypeArray.count
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
            if string.characters.count == 0 {
                return true
            }
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let newString = (currentText as NSString).replacingCharacters(in: range, with: string) as NSString
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789") &&
                newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 && newString.length <= 5
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SubCategoryTableViewCell
        print(self.subTypeArray)
        let subTypeQtyArray = NSMutableArray()
        let names = self.subTypeArray[indexPath.row] as? String
        cell.typeLbl.text = names?.localized()
        cell.typeId.text = self.subTypeIdArray[indexPath.row] as? String
       cell.qtyLblText.delegate = self
        cell.qtyLblText.keyboardType = .phonePad
        do {
            let query = Constant.preferenceTable.select(Constant.prefname,Constant.prefQty,Constant.prefstatus)
                .filter(Constant.prefmapid == self.type_id)
            let users = try Constant.database.prepare(query)
          
            var qty = "0"
            var name = ""
            for user in users {
                 let status = user[Constant.prefstatus]
                qty = user[Constant.prefQty]
                if(status == "y"){
                    
                                      //  let id = user[Constant.prefid]
                                        subTypeQtyArray.add(qty)
                    
                                    }else{
                                         subTypeQtyArray.add(qty)
                                    }
            }
        } catch {
            print(error)
        }
        print(subTypeQtyArray)
        if(subTypeQtyArray.count > 0){
            cell.qtyLblText.text = (subTypeQtyArray[indexPath.row] as! String)
        }else{
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            if launchedBefore  {
                cell.qtyLblText.text = (subTypeQtyArray[indexPath.row] as! String)
                print("Not first launch.")
            } else {
                 cell.qtyLblText.text = "0"
                print("First launch, setting UserDefault.")
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            }
        }
        
        return cell
    }
    
    @IBOutlet weak var subCategoryTbl: UITableView!
    func setText(){
        self.categoryNameText.text = "\(type_name)".localized()
        self.doneBtn.setTitle("Done".localized(), for: .normal)
        self.suggestSubTypeBtn.setTitle("Suggest sub type".localized(), for: .normal)
        self.subTypeLbl.text = "Name".localized()
        self.subTypePeopleLbl.text = "Number Of People".localized()
    }
    @IBOutlet weak var popupVc: UIView!
    override func viewDidLoad() {
        self.startMonitoringInternet()
         getSubTypeAPiCall()
        setText()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(typeadded), name: Notification.Name("typeAdd"), object: nil)
        super.viewDidLoad()
        popupVc.layer.shadowColor = UIColor.black.cgColor
        print(type_id,type_name)
        categoryNameText.text = type_name.localized()
    }
    @IBAction func suggestSubTYpeBtnPress(_ sender: UIButton) {
        guard let customAlertVC = customAlertVC else { return }
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 300,popupHeight: 200)
        popupVC.cornerRadius = 5
        UserDefaults.standard.set(self.categoryNameText.text, forKey: "category")
        present(popupVC, animated: true, completion: nil)
    }
    @objc func typeadded(){
        //type contain new type
        let type = UserDefaults.standard.dictionaryWithValues(forKeys:["typeDict"])
        let newValue = (type as AnyObject).value(forKey:"typeDict") as? AnyObject
        let newType = (newValue as AnyObject).value(forKey:"Type") as! String
        let newQty = (newValue as AnyObject).value(forKey:"Quantity") as! String
        print(newType,newQty) // new subtype
        print(selectedSubTypeArray) //OLD SUBTYPE

        selectedSubTypeArray .add(type)
        print(selectedSubTypeArray)
        
    }
    @IBAction func sloseBtnPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //Get Path
    func getPath() -> String {
        let plistFileName = "SubCategoryList.plist"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = paths[0] as NSString
        let plistPath = documentPath.appendingPathComponent(plistFileName)
        return plistPath
    }
    
    @IBAction func doneBtnPress(_ sender: UIButton) {
    NotificationCenter.default.post(name: Notification.Name("preferenceselecte"), object: nil)
         self.dismiss(animated: true, completion: nil)
    }
//    func getSelectedPreference() {
//
//    }
    @IBAction func otherPreferanceBtnPress(_ sender: UIButton) {
        customSubCategoryText.isEnabled = true
        flag = true
    }
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
        
        let paramString = String(format: "type_id=%@&sub_type_name=%@",type_id,customSubCategoryText.text!)
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
                        self .dismiss(animated: true, completion: nil)
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
    func getSubTypeAPiCall()
    {
        //insert values to DB
        GlobalClass.sharedInstance.openDb()

        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.get_sub_type
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "type_id=%@",type_id)
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
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                print(jsonObj!)
                for item in jsonObj!{
                    //  print(item)
                    // print( (item as AnyObject).value(forKey:"status") as! Int)

                    let statusChk = (item as AnyObject).value(forKey:"status") as? Int
                    if statusChk == 0 && statusChk != nil{
                        DispatchQueue.main.async {
                            //Success msg will shown to user
                            self.view.makeToast("SubCategories not found please try again".localized())
                        }
                        return
                    }
                    else{
                        do {
                            print(item)
                            let subTypeId = (item as AnyObject).value(forKey:"sub_type_id") as! String
                            let subTypename = (item as AnyObject).value(forKey:"sub_type_name") as! String
                            GlobalClass.sharedInstance.createPreferenceTable()
                            //insert user
                            let insertUser = Constant.preferenceTable.insert(Constant.prefmapid <- self.type_id,Constant.prefname <- subTypename,Constant.prefid   <- subTypeId,Constant.prefQty <- "0",Constant.prefstatus <- "n")
                            do {
                                try Constant.database.run(insertUser)
                                print("INSERTED USER")
                            } catch {
                                print(error)
                            }
                            //End
                            
                            try self.subTypeArray.add((item as AnyObject).value(forKey:"sub_type_name") as! String)
                              try self.subTypeIdArray.add((item as AnyObject).value(forKey:"sub_type_id") as! String)
                            let needItem = item as? NSDictionary
                            try self.subTypes.add(needItem!)
                           
                            print(needItem as Any,self.subTypeArray,self.subTypes)
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                    }}
                  DispatchQueue.main.async {
                 self.subCategoryTbl.reloadData()
                }
            }
        }
        
        task.resume()
    }
}
