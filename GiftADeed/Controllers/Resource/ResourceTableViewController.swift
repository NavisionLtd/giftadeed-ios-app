//
//  ResourceTableViewController.swift
//  GiftADeed
//
//  Created by Darshan on 4/3/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import ANLoader
import SQLite
import EzPopup
struct groupCategory {
    let category_name : String
    let category_id : String
     let category_type : String
}
struct audiances {
    let audiance_name : String
    let audiance_id : String
}
struct preferenceCategory {
    let preference_name : String
    let preference_id : String
    let category_name : String
    let category_id : String
}
class ResourceTableViewController: UITableViewController {
    @IBOutlet weak var cancelBtn: UIButton!
    let customAlertVC = SuggestSubCategoryViewController.instantiate()
    var dataText = ""
    var userId = ""
    var titles = ""
    var groupId = ""
    var categoryId = ""
    var delegate : CreateResourceViewController?
    var categoryListArray: [groupCategory]? = []
    var preferenceListArray: [preferenceCategory]? = []
    var audianceListArray: [audiances]? = []
    var selectedRows = NSMutableIndexSet()
    @IBOutlet var resourceTbl: UITableView!
    @IBOutlet weak var subTYpeBtn: UIBarButtonItem!
    @IBOutlet weak var selectBTn: UIButton!
    @IBOutlet weak var cancelResBtn: UIButton!
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    override func viewWillAppear(_ animated: Bool) {
        // downloadCategoryData(mapId: self.groupId)
        self.navigationController?.isNavigationBarHidden = false
       self.navigationItem.rightBarButtonItem=nil;
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = titles
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
       // self.navigationItem.leftBarButtonItem=nil;
        self.navigationItem.hidesBackButton = false
    }
    @IBAction func suggestSubTypeBtnPress(_ sender: UIBarButtonItem) {
        guard let customAlertVC = customAlertVC else { return }
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 300,popupHeight: 200)
        popupVC.cornerRadius = 5
        present(popupVC, animated: true, completion: nil)
    }
    override func viewDidLoad() {
   super.viewDidLoad()
          if(dataText == "preference"){
            cancelBtn.setTitle("Suggest Sub-Type", for: .normal)
            
        }
          else{
            
        }
//        if(dataText == "preference"){
//
//            self.navigationItem.setHidesBackButton(true, animated:true);
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//        else{
//              navigationController?.setNavigationBarHidden(true, animated: true)
//        }
   self.navigationController?.setNavigationBarHidden(false, animated: true)
   userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        downloadCategoryData(mapId: self.groupId)
        downloadMultipleReferenceData(categoryId: self.categoryId)
        downloadAudianceGroupData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(self.categoryListArray!.count == 0){
            self.selectBTn.isHidden = true
            self.cancelBtn.isHidden = true
             return 0
        }
        else{
            self.selectBTn.isHidden = false
            self.cancelBtn.isHidden = false
             return 2
        }
       
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(dataText == "category"){
            guard let names = self.categoryListArray else {
                return 0
            }
            print(self.categoryListArray!)
            return 0 == section ? 1 : names.count
        }
        else if(dataText == "preference"){
            guard let names = self.preferenceListArray else {
                return 0
            }
            print(self.preferenceListArray!)
            return 0 == section ? 1 : names.count
        }
        else if(dataText == "audiance"){
            guard let names = self.audianceListArray else {
                return 0
            }
            print(self.audianceListArray!)
            return 0 == section ? 1 : names.count
        }
        else{

            return 0 == section ? 1 : 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResourceDataTableViewCell
        var text: String
         var id: String
        var accessory = UITableViewCell.AccessoryType.none
        cell.tintColor = UIColor.clear
        print(selectedRows.count)
        print(self.categoryListArray)
        if(self.categoryListArray!.count == 0)
        {
//            self.resourceTbl.isHidden = true
            cell.nameLbl.isHidden = true
          //   cell.contentView.isHidden = true
           
        }
        else{
//            self.resourceTbl.isHidden = false
            cell.nameLbl.isHidden = false
            self.selectBTn.isHidden = false
            self.cancelBtn.isHidden = false
             //  cell.contentView.isHidden = false
            if(dataText == "category"){
                if 0 == indexPath.section {
                    text = "All"
                  
                    if self.selectedRows.count == self.categoryListArray!.count {
                        cell.tintColor = UIColor.blue
                        accessory = .checkmark
                    }
                } else {
                    let value = self.categoryListArray![indexPath.row]
                    text = value.category_name
                    if selectedRows.contains(indexPath.row) {
                        accessory = .checkmark
                        cell.tintColor = UIColor.blue
                    }
                }
                cell.nameLbl!.text = text
                cell.accessoryType = accessory
            }
        }
    
         if(dataText == "preference"){
                if 0 == indexPath.section {
                    text = "All"
                    if self.selectedRows.count == self.preferenceListArray!.count {
                        cell.tintColor = UIColor.blue
                        accessory = .checkmark
                    }
                } else {
                    let value = self.preferenceListArray![indexPath.row]
                    text = ("\(value.preference_name) : \(value.category_name)")
                    if selectedRows.contains(indexPath.row) {
                        accessory = .checkmark
                        cell.tintColor = UIColor.blue
                    }
                }
                cell.nameLbl!.text = text
                cell.accessoryType = accessory
        }
        else if(dataText == "audiance"){
            if 0 == indexPath.section {
                text = "All"
                  id = "AudId"
                if self.selectedRows.count == self.audianceListArray!.count {
                    cell.tintColor = UIColor.blue
                    accessory = .checkmark
                }
            } else {
                let value = self.audianceListArray![indexPath.row]
                text = ("\(value.audiance_name)")
                id = ("\(value.audiance_id)")
                if selectedRows.contains(indexPath.row) {
                    accessory = .checkmark
                    cell.tintColor = UIColor.blue
                }
            }
            cell.nameLbl!.text = text
            cell.idLbl!.text = id
            cell.accessoryType = accessory
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as! ResourceDataTableViewCell
        if(dataText == "category")
        {
            if indexPath.section == 0 {
                if self.selectedRows.count == self.categoryListArray!.count {
                    self.selectedRows = NSMutableIndexSet()
                    //if deselected all preess then change status to n for all rows
                    let updateUser = Constant.categoryTable.update(Constant.catstatus <- "n")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                } else {
                    self.selectedRows = NSMutableIndexSet(indexesIn: NSRange(location: 0, length: self.self.categoryListArray!.count))
                    //if deselected all preess then change status to y for all rows
                    let updateUser = Constant.categoryTable.update(Constant.catstatus <- "y")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                
                tableView.reloadData()
            } else {
                self.selectedRows.contains(indexPath.row) ? self.selectedRows.remove(indexPath.row) : self.selectedRows.add(indexPath.row)
                
                if(self.selectedRows.contains(indexPath.row)){
                    //get cell name of selected index
                    print(cell.nameLbl.text as Any)
                    let categoryName = cell.nameLbl.text
                    //if selected index is equal to index in table then change status to y for that row
                    let user = Constant.categoryTable.filter(Constant.catname == categoryName!)
                    let updateUser = user.update(Constant.catstatus <- "y")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                else{
                    //if selected index is equal to index in table then change status to n for that row
                    let categoryName = cell.nameLbl.text
                    let user = Constant.categoryTable.filter(Constant.catname == categoryName!)
                    let updateUser = user.update(Constant.catstatus <- "n")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                let rows = [IndexPath(row: 0, section: 0), indexPath]
                
                tableView.reloadRows(at: rows, with: .none)
            }
        }
        else if(dataText == "preference"){
            if indexPath.section == 0 {
                if self.selectedRows.count == self.preferenceListArray!.count {
                    self.selectedRows = NSMutableIndexSet()
                    //if deselected all preess then change status to n for all rows
                    let updateUser = Constant.multipreferenceTable.update(Constant.mrefstatus <- "n")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                } else {
                    self.selectedRows = NSMutableIndexSet(indexesIn: NSRange(location: 0, length: self.preferenceListArray!.count))
                    //if deselected all preess then change status to y for all rows
                    let updateUser = Constant.multipreferenceTable.update(Constant.mrefstatus <- "y")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                
                tableView.reloadData()
            } else {
                self.selectedRows.contains(indexPath.row) ? self.selectedRows.remove(indexPath.row) : self.selectedRows.add(indexPath.row)
                
                if(self.selectedRows.contains(indexPath.row)){
                    //get cell name of selected index
                    print(cell.nameLbl.text as Any)
                    let preferenceName = cell.nameLbl.text
                    //if selected index is equal to index in table then change status to y for that row
                    let user = Constant.multipreferenceTable.filter(Constant.mrefname == preferenceName!)
                    let updateUser = user.update(Constant.mrefstatus <- "y")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                else{
                    //if selected index is equal to index in table then change status to n for that row
                    let preferenceName = cell.nameLbl.text
                    let user = Constant.multipreferenceTable.filter(Constant.mrefname == preferenceName!)
                    let updateUser = user.update(Constant.mrefstatus <- "n")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                let rows = [IndexPath(row: 0, section: 0), indexPath]
                
                tableView.reloadRows(at: rows, with: .none)
            }
        }
        if(dataText == "audiance")
        {
            if indexPath.section == 0 {
                if self.selectedRows.count == self.audianceListArray!.count {
                    self.selectedRows = NSMutableIndexSet()
                    //if deselected all preess then change status to n for all rows
                    let updateUser = Constant.multiaudianceTable.update(Constant.mresstatus <- "n")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                } else {
                    self.selectedRows = NSMutableIndexSet(indexesIn: NSRange(location: 0, length: self.self.audianceListArray!.count))
                    //if deselected all preess then change status to y for all rows
                    let updateUser = Constant.multiaudianceTable.update(Constant.mresstatus <- "y")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                
                tableView.reloadData()
            } else {
                self.selectedRows.contains(indexPath.row) ? self.selectedRows.remove(indexPath.row) : self.selectedRows.add(indexPath.row)
                
                if(self.selectedRows.contains(indexPath.row)){
                    //get cell name of selected index
                    print(cell.nameLbl.text as Any)
                    let audianceName = cell.nameLbl.text
                     let audianceId = cell.idLbl.text
                    //if selected index is equal to index in table then change status to y for that row
                    let user = Constant.multiaudianceTable.filter(Constant.mresid == audianceId!)
                    let updateUser = user.update(Constant.mresstatus <- "y")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                else{
                    //if selected index is equal to index in table then change status to n for that row
                    let audianceName = cell.nameLbl.text
                      let audianceId = cell.idLbl.text
                    let user = Constant.multiaudianceTable.filter(Constant.mresid == audianceId!)
                    let updateUser = user.update(Constant.mresstatus <- "n")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                }
                let rows = [IndexPath(row: 0, section: 0), indexPath]
                
                tableView.reloadRows(at: rows, with: .none)
            }
        }
        return nil
    }
    @IBAction func saveBtnPress(_ sender: UIButton) {
        if(dataText == "category"){
            delegate?.selectedCategoryRows = selectedRows
            delegate?.didUpdateCategory()
        }
        else if(dataText == "preference"){
            delegate?.selectedPreferenceRows = selectedRows
            delegate?.didUpdatePreference()
        }
        else{
            delegate?.selectedAudianceRows = selectedRows
            delegate?.didUpdateAudiance()
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func cancelBtnPress(_ sender: UIButton) {
         if(dataText == "preference")
         {
            print("In preference")
            guard let customAlertVC = customAlertVC else { return }
            let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 300,popupHeight: 200)
            popupVC.cornerRadius = 5
            present(popupVC, animated: true, completion: nil)
        }
         else{
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    //MARK:- Download category data
    func downloadCategoryData (mapId : String){
        
        GlobalClass.sharedInstance.openDb()
        GlobalClass.sharedInstance.createCategoryTable()
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.need_type
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        let paramString = String(format: "group_id=%@",mapId)
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                if let needtype = jsonObj!.value(forKey: "g_need") as? NSArray {
                print(needtype)
                    for item in needtype {
                        
                        do {
                            let name = (item as AnyObject).value(forKey: "Need_Name") as! String
                            let id = (item as AnyObject).value(forKey: "NeedMapping_ID") as! String
                             let type = (item as AnyObject).value(forKey: "type") as! String
                            let category = groupCategory(category_name: name, category_id: id, category_type: type)
                            self.categoryListArray?.append(category)
                            //insert values to DB
                            
                            let insertUser = Constant.categoryTable.insert(Constant.catname <- name , Constant.catid <- id ,Constant.catstatus <- "n",Constant.cattype <- type)
                            
                            do {
                                try Constant.database.run(insertUser)
                                print("INSERTED USER")
                            } catch {
                                print(error)
                            }
                            //End
                              print(self.categoryListArray)
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                       
                    }
   
                }
                if let needtype = jsonObj!.value(forKey: "c_need") as? NSArray {
                    print(needtype)
                    for item in needtype {
                        
                        do {
                            let name = (item as AnyObject).value(forKey: "Need_Name") as! String
                            let id = (item as AnyObject).value(forKey: "NeedMapping_ID") as! String
                            let type = (item as AnyObject).value(forKey: "type") as! String
                            let category = groupCategory(category_name: name, category_id: id, category_type: type)
                            self.categoryListArray?.append(category)
                            //insert values to DB
                            
                            let insertUser = Constant.categoryTable.insert(Constant.catname <- name , Constant.catid <- id ,Constant.catstatus <- "n",Constant.cattype <- type)
                            
                            do {
                                try Constant.database.run(insertUser)
                                print("INSERTED USER")
                            } catch {
                                print(error)
                            }
                            //End
                            print(self.categoryListArray)
                        } catch {
                            // Error Handling
                            print("Some error occured.")
                        }
                        
                        
                    }
                    
                    
                }
                DispatchQueue.main.async{
                    print(self.categoryListArray)
                    self.resourceTbl.reloadData()
                    //self.navigationController?.view.makeToast(Validation.NETWORK_ERROR)
                }
            }
            
        }
        task.resume()
    }
    
    //Download multiple preference data
    
    func downloadMultipleReferenceData (categoryId : String){
        GlobalClass.sharedInstance.openDb()
        GlobalClass.sharedInstance.createMultiPreferenceTable()
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.get_multi_sub_type
         let paramString = String(format: "user_id=%@&need_ids=%@",userId,categoryId)
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let url:NSURL = NSURL(string: urlString)!
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let charset = NSMutableCharacterSet.alphanumeric()
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
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
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                for values in jsonObj!{
                
                    let cat_id = (values as AnyObject).value(forKey: "type_id") as! String
                    let cat_name = (values as AnyObject).value(forKey: "Need_Name") as! String
                    let pref_id = (values as AnyObject).value(forKey: "id") as! String
                    let pref_name = (values as AnyObject).value(forKey: "name") as! String
                    let text = ("\(pref_name) : \(cat_name)")
                    let preference = preferenceCategory(preference_name: pref_name, preference_id: pref_id, category_name:cat_name, category_id: cat_id)
                    print(preference)
                    self.preferenceListArray?.append(preference)
                    //insert values to DB
                    
                    let insertUser = Constant.multipreferenceTable.insert(Constant.mrefname <- text , Constant.mrefid <- pref_id ,Constant.mrefstatus <- "n")
                    
                    do {
                        try Constant.database.run(insertUser)
                        print("INSERTED USER")
                    } catch {
                        print(error)
                    }
                    //End
                }
            }
            DispatchQueue.main.async{
                print(self.preferenceListArray as Any)
               
                self.resourceTbl.reloadData()
            }
        }
        
        task.resume()
    }
//download audiance list(general)
    func downloadAudianceGroupData (){
        GlobalClass.sharedInstance.openDb()
        GlobalClass.sharedInstance.createMultiAudianceTable()
        userId = UserDefaults.standard.value(forKey: "User_ID") as! String
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        let urlString = Constant.BASE_URL + Constant.showGroupList
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
                print(jsonObj as Any)
     
                for item in jsonObj!{
                    let group_id = (item as AnyObject).value(forKey: "group_id")
                    let group_name = (item as! AnyObject).value(forKey: "group_name")
                    let audiance = audiances(audiance_name: group_name as! String, audiance_id: group_id as! String)
                    self.audianceListArray?.append(audiance)
                    //insert values to DB
                    
                    let insertUser = Constant.multiaudianceTable.insert(Constant.mresname <- group_name as! String , Constant.mresid <- group_id as! String ,Constant.mresstatus <- "n")
                    
                    do {
                        try Constant.database.run(insertUser)
                        print("INSERTED USER")
                    } catch {
                        print(error)
                    }
                    //End
                }
            }
            DispatchQueue.main.async{
                print(self.preferenceListArray as Any)
                
                self.resourceTbl.reloadData()
            }
        }
        task.resume()
    }
}
