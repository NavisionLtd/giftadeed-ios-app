//
//  AudianceViewController.swift
//  GiftADeed
//
//  Created by Darshan on 2/22/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//4.1 ref no

import UIKit
import ANLoader
import SQLite
import Localize_Swift
import EFInternetIndicator
class AudianceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,InternetStatusIndicable {
   
     var internetConnectionIndicator:InternetViewIndicator?
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.receivedText == "filter"){
            return 2
        }
        else{
           
        return 3
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return groupListArray.count
        }else  if(section == 1){
            return 1
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(receivedStatusArray)
        receivedStatusArray.removeAllObjects()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AudianceTableViewCell
        if(groupListArray.count >= 0){
        //Retrive type data
        do {
            let users = try Constant.database.prepare(Constant.audianceTable)
            for user in users {
                print("id: \(user[Constant.aid]), dayName: \(user[Constant.audname]), dayId: \(user[Constant.audid]), dayStatus: \(user[Constant.audstatus])")
                let name = user[Constant.audname]
                let id = user[Constant.audid]
                let status = user[Constant.audstatus]
                self.receivedIdArray.add(id)
                self.receivedStatusArray.add(status)
                
            }
        } catch {
            print(error)
        }
       
        //retrive data of each cell status and get status if status is y then put chkmark otherwiser no
        var status = ""
        var statusone = ""
         var statustwo = ""
        //retrive data

        if(indexPath.section == 0){
             print(receivedStatusArray)
            status = (receivedStatusArray[indexPath.row] as? String)!
            if(status == "y"){
              
                 cell.tintColor = UIColor.blue
                 cell.accessoryType = .checkmark
               
            }
            else{
                cell.accessoryType = .none
               
            }
            let values = groupListArray[indexPath.row]
                  print(groupListArray.count)
            cell.groupName.text = values.group_name.localized()
            cell.groupId.text = values.group_id
            
        }
        else if(indexPath.section == 1){
           receivedStatusArray.removeAllObjects()
            //Retrive type data
            do {
                let query = Constant.audianceTable.select(Constant.audstatus)
                    .filter(Constant.audid == "0")

                let users = try Constant.database.prepare(query)
                for user in users {
                    print("AudianceStatus: \(user[Constant.audstatus])")
                    let status = user[Constant.audstatus]
                    self.receivedStatusArray.add(status)

                }
            } catch {
                print(error)
            }
            if(receivedStatusArray.count > 0){
                statusone = (receivedStatusArray[indexPath.row] as? String)!
                if(statusone == "y"){
                    
                    cell.tintColor = UIColor.blue
                    cell.accessoryType = .checkmark
                    
                }
                else{
                    cell.accessoryType = .none
                    
                }
            }
            else{
                
            }
            cell.groupName.text = "All groups".localized()
            cell.groupId.text = "0"
            print(cell.groupId.text)
        }
        else if(indexPath.section == 2){
            print(receivedStatusArray)
            receivedStatusArray.removeAllObjects()
            //Retrive type data
            do {
                let query = Constant.audianceTable.select(Constant.audstatus)
                    .filter(Constant.audid == "1")

                let users = try Constant.database.prepare(query)
                for user in users {
                    print("AudianceStatus: \(user[Constant.audstatus])")
                    let status = user[Constant.audstatus]
                    self.receivedStatusArray.add(status)

                }
            } catch {
                print(error)
            }
              print(receivedStatusArray)
            if(receivedStatusArray.count > 0){
                statustwo = (receivedStatusArray[indexPath.row] as? String)!
                if(statustwo == "y"){
                    
                    cell.tintColor = UIColor.blue
                    cell.accessoryType = .checkmark
                    
                }
                else{
                    cell.accessoryType = .none
                    
                }
            }
            else{
                
            }

            cell.groupName.text = "All indivisual users".localized()
            cell.groupId.text = "1"
        }
        }
        else{
            
        }
        return cell
    }
    func setText(){
//        self.okBtn.setTitle("Ok", for: .normal)
//        self.cancelBtn.setTitle("Cancel", for: .normal)
    }
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var audianceTable: UITableView!
    var receivedText = ""
    var userId = ""
    var userIds = ""
    var groupListArray = [Group]()
    var receivedStatusArray = NSMutableArray()
    var receivedIdArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startMonitoringInternet()
        self.audianceTable.tableFooterView = UIView()
         getAudianceAPiCall()
        setText()
        GlobalClass.sharedInstance.openDb()
        GlobalClass.sharedInstance.createAudianceTable()
        userIds = UserDefaults.standard.value(forKey: "User_ID") as! String
        print(userIds)
         getAudianceAPiCall()
        //register cell
        audianceTable.register(UINib(nibName: "AudianceTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
          customView.layer.shadowColor = UIColor.black.cgColor
        self.audianceTable.allowsMultipleSelection = true
        self.audianceTable.allowsMultipleSelectionDuringEditing = true
       
     //   audianceTable.layer.borderColor = UIColor.orange.cgColor
      //  audianceTable.layer.borderWidth = 1
       // audianceTable.layer.cornerRadius = 0.5
        // Do any additional setup after loading the view.
      self.selectAllRows()
       
        //end
    }
    override func viewWillAppear(_ animated: Bool) {
    
    }
    func selectAllRows() {
        for section in 0..<self.audianceTable.numberOfSections {
            for row in 0..<self.audianceTable.numberOfRows(inSection: section) {
                self.audianceTable.selectRow(at: IndexPath(row: row, section: section), animated: false, scrollPosition: .none)
            }
        }
    }
    @IBAction func okBtnPress(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("audianceselecte"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelBtnPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let cell = tableView.cellForRow(at: indexPath) as! AudianceTableViewCell
        if(indexPath.section == 0){
            print("selected table\(indexPath.row)")
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            receivedStatusArray.removeAllObjects()
            receivedIdArray.removeAllObjects()
            //Retrive type data
            do {
                let users = try Constant.database.prepare(Constant.audianceTable)
                for user in users {
                    print("id: \(user[Constant.aid]), dayName: \(user[Constant.audname]), dayId: \(user[Constant.audid]), dayStatus: \(user[Constant.audstatus])")
                    let name = user[Constant.audname]
                  
                    let status = user[Constant.audstatus]
                      let id = user[Constant.audid]
                    self.receivedIdArray.add(id)
                    self.receivedStatusArray.add(status)
                    
                }
            } catch {
                print(error)
            }
            
            let status = receivedStatusArray[indexPath.row] as? String
             let id = receivedIdArray[indexPath.row] as? String
             if(cell.groupId.text == id){
                
            if(status == "y"){
                //update status to n
                //update
                let id = cell.groupId.text
                print(id)
                let user = Constant.audianceTable.filter(Constant.audid == id!)
                let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "0")
                do {
                    try Constant.database.run(updateUser)
                } catch {
                    print(error)
                }
                //end
                
                if(groupListArray.count == 0){
                    
                }
                else{
                    do {
                        let alice = Constant.audianceTable.filter(Constant.audid == "0")
                        if try Constant.database.run(alice.update(Constant.audstatus <- "n")) == 0 {
                            print("updated alice")
                        } else {
                            print("alice not found")
                        }
                    } catch {
                        print("update failed: \(error)")
                    }
                    cell.tintColor = UIColor.clear
                }
             
             audianceTable.reloadData()
            }
            else{
                 //update status to y
                //save selected data in sqlite
                //retrive data
                do {
                    let users = try Constant.database.prepare(Constant.audianceTable)
                    for user in users {
                        print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
                    }
                } catch {
                    print(error)
                }
                //update
                let id = cell.groupId.text
                print(id)
                let user = Constant.audianceTable.filter(Constant.audid == id!)
                let updateUser = user.update(Constant.audstatus <- "y",Constant.audQty <- "0")
                do {
                    try Constant.database.run(updateUser)
                } catch {
                    print(error)
                }
                //end
                
                cell.tintColor = UIColor.blue
            }
            }
            
           
            print(cell.groupName?.text!)
          
        }else if(indexPath.section == 1){
            //insert new row
            //insert values to DB
            //            GlobalClass.sharedInstance.openDb()
            //            GlobalClass.sharedInstance.createAudianceTable()
            let insertUser = Constant.audianceTable.insert(Constant.audname <- "All groups", Constant.audid <- "0",Constant.audQty <- "0",Constant.audstatus <- "n")
            
            do {
                try Constant.database.run(insertUser)
                print("INSERTED USER")
            } catch {
                print(error)
//                //update
//                let id = cell.groupId.text
//                print(id)
//                let user = Constant.audianceTable.filter(Constant.audid == id!)
//                let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "0")
//                do {
//                    try Constant.database.run(updateUser)
//                } catch {
//                    print(error)
//                }
//                //end
            }
            //End
            
            //retrive status and place chkmark according to it
            print("selected table\(indexPath.row)")
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            receivedStatusArray.removeAllObjects()
           
            
            
            
            //Retrive type data
            do {
                let query = Constant.audianceTable.select(Constant.audstatus,Constant.audid)
                    .filter(Constant.audid == "0")
                
                let users = try Constant.database.prepare(query)
                print(users)
                for user in users {
                    print("AudianceStatus: \(user[Constant.audstatus])")
                    let status = user[Constant.audstatus]
                    self.receivedStatusArray.add(status)
                    let id = user[Constant.audid]
                    self.receivedIdArray.add(id)
                }
            } catch {
                print(error)
            }
            print(receivedStatusArray)
            print(cell.groupId.text)
            let status = receivedStatusArray[indexPath.row] as? String
            if(cell.groupId.text == "0"){
                
                if(status == "y"){
                    //update status to n
                    //update
                    let id = cell.groupId.text
                    print(id)
                    let user = Constant.audianceTable.filter(Constant.audid == id!)
                    let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "0")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                    //if all groups selected then show checkmark to all group in section zero
                    if(groupListArray.count == 0){
                        
                    }
                    else{
                    do {
                        let alice = Constant.audianceTable.filter(Constant.audQty == "0" && Constant.audname != "All indivisual users")
                        if try Constant.database.run(alice.update(Constant.audstatus <- "n")) > 0 {
                            print("updated alice")
                        } else {
                            print("alice not found")
                        }
                    } catch {
                        print("update failed: \(error)")
                    }
                    //end
                    cell.tintColor = UIColor.clear
                    }
                    audianceTable.reloadData()
                }
                else{
                    //update status to y
                    //save selected data in sqlite
                    //retrive data
                    do {
                        let users = try Constant.database.prepare(Constant.audianceTable)
                        for user in users {
                            print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
                        }
                    } catch {
                        print(error)
                    }
                    //update
                    let id = cell.groupId.text
                    print(id)
                    let user = Constant.audianceTable.filter(Constant.audid == id!)
                    let updateUser = user.update(Constant.audstatus <- "y",Constant.audQty <- "0")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //if all groups selected then show checkmark to all group in section zero
                    do {
                        let alice = Constant.audianceTable.filter(Constant.audQty == "0")
                        if try Constant.database.run(alice.update(Constant.audstatus <- "y")) > 0 {
                            print("updated alice")
                        } else {
                            print("alice not found")
                        }
                    } catch {
                        print("update failed: \(error)")
                    }
                    //end
                    cell.tintColor = UIColor.blue
                    audianceTable.reloadData()
                    
                }
            }
            
        }else if(indexPath.section == 2){
            let insertUser = Constant.audianceTable.insert(Constant.audname <- "All indivisual users", Constant.audid <- "1",Constant.audQty <- "0",Constant.audstatus <- "n")
            
            do {
                try Constant.database.run(insertUser)
                print("INSERTED USER")
            } catch {
                print(error)
//                //update
//                let id = cell.groupId.text
//                print(id)
//                let user = Constant.audianceTable.filter(Constant.audid == id!)
//                let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "1")
//                do {
//                    try Constant.database.run(updateUser)
//                } catch {
//                    print(error)
//                }
//                //end
            }
            //End
            //retrive status and place chkmark according to it
            print("selected table\(indexPath.row)")
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            receivedStatusArray.removeAllObjects()
            receivedIdArray.removeAllObjects()
          
            //Retrive type data
            do {
                let query = Constant.audianceTable.select(Constant.audstatus)
                    .filter(Constant.audid == "1")
                
                let users = try Constant.database.prepare(query)
                print(users)
                for user in users {
                    print("AudianceStatus: \(user[Constant.audstatus])")
                    let status = user[Constant.audstatus]
                    self.receivedStatusArray.add(status)
                    
                }
            } catch {
                print(error)
            }
             print(receivedStatusArray)
            let status = receivedStatusArray[indexPath.row] as? String
            if(cell.groupId.text == "1"){
                
                if(status == "y"){
                    //update status to n
                    //update
                    let id = cell.groupId.text
                    print(id)
                    let user = Constant.audianceTable.filter(Constant.audid == id!)
                    let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "1")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                    cell.tintColor = UIColor.clear
                    
                }
                else{
                    //update status to y
                    //save selected data in sqlite
                    //retrive data
                    do {
                        let users = try Constant.database.prepare(Constant.audianceTable)
                        for user in users {
                            print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
                        }
                    } catch {
                        print(error)
                    }
                    //update
                    let id = cell.groupId.text
                    print(id)
                    let user = Constant.audianceTable.filter(Constant.audid == id!)
                    let updateUser = user.update(Constant.audstatus <- "y",Constant.audQty <- "1")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                    cell.tintColor = UIColor.blue
                    
                    
                }
            }
        }
    }
    private func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.isSelected {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0){
            print("Deselected table\(indexPath.row)")
            receivedStatusArray.removeAllObjects()
            receivedIdArray.removeAllObjects()
            //save Deselected data in sqlite
            //retrive data
            do {
                let users = try Constant.database.prepare(Constant.audianceTable)
                for user in users {
                    print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
                    let id = user[Constant.audid]
                    let status = user[Constant.audstatus]
                    self.receivedIdArray.add(id)
                    self.receivedStatusArray.add(status)
                }
            } catch {
                print(error)
            }

            let cell = tableView.cellForRow(at: indexPath) as! AudianceTableViewCell
          
        
            let status = receivedStatusArray[indexPath.row] as? String
            let id = receivedIdArray[indexPath.row] as? String
            if(cell.groupId.text == id){
           
            if(status == "y"){
                //update status to n
                //update
                let id = cell.groupId.text
                print(id)
                let user = Constant.audianceTable.filter(Constant.audid == id!)
                let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "0")
                do {
                    try Constant.database.run(updateUser)
                } catch {
                    print(error)
                }
              
                
               
                //end
                do {
                    let alice = Constant.audianceTable.filter(Constant.audid == "0")
                    if try Constant.database.run(alice.update(Constant.audstatus <- "n")) == 0 {
                        print("updated alice")
                    } else {
                        print("alice not found")
                    }
                } catch {
                    print("update failed: \(error)")
                }
                cell.tintColor = UIColor.clear
             
                audianceTable.reloadData()
            }
            else{
                //update status to y
                //save selected data in sqlite
                //retrive data
                do {
                    let users = try Constant.database.prepare(Constant.audianceTable)
                    for user in users {
                        print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
                    }
                } catch {
                    print(error)
                }
                //update
                let id = cell.groupId.text
                print(id)
                let user = Constant.audianceTable.filter(Constant.audid == id!)
                let updateUser = user.update(Constant.audstatus <- "y",Constant.audQty <- "0")
                do {
                    try Constant.database.run(updateUser)
                } catch {
                    print(error)
                }
                //end
                cell.tintColor = UIColor.blue
               
                
            }
        }
            
            
            //               let status = receivedStatusArray[indexPath.row] as? String
//            if(status == "y"){
//                cell.tintColor = UIColor.blue}
//            else{
//                 cell.tintColor = UIColor.clear
//            }
//            //update
//            let id = cell.groupId.text
//            print(id)
//            let user = Constant.audianceTable.filter(Constant.audid == id!)
//            let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "0")
//            do {
//                try Constant.database.run(updateUser)
//            } catch {
//                print(error)
            //}
            //end
        }
        else if(indexPath.section == 1){
            print("Deselected table\(indexPath.row)")
            
//            //save Deselected data in sqlite
//            //retrive data
//            do {
//                let users = try Constant.database.prepare(Constant.audianceTable)
//                for user in users {
//                    print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
//                }
//            } catch {
//                print(error)
//            }
//            let cell = tableView.cellForRow(at: indexPath) as! AudianceTableViewCell
//            //update
//            let id = cell.groupName.text
//            print(id)
//            let user = Constant.audianceTable.filter(Constant.audname == id!)
//            let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "0")
//            do {
//                try Constant.database.run(updateUser)
//            } catch {
//                print(error)
//            }
//            //end
            //retrive status and place chkmark according to it
            let cell = tableView.cellForRow(at: indexPath) as! AudianceTableViewCell
            print("selected table\(indexPath.row)")
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            receivedStatusArray.removeAllObjects()
            receivedIdArray.removeAllObjects()
            //Retrive type data
            do {
                let query = Constant.audianceTable.select(Constant.audstatus)
                    .filter(Constant.audid == "0")
                
                let users = try Constant.database.prepare(query)
                for user in users {
                    print("AudianceStatus: \(user[Constant.audstatus])")
                    let status = user[Constant.audstatus]
                    self.receivedStatusArray.add(status)
                    
                }
            } catch {
                print(error)
            }
            print(receivedStatusArray)
            let status = receivedStatusArray[indexPath.row] as? String
            if(cell.groupId.text == "0"){
                
                if(status == "y"){
                    //update status to n
                    //update
                    let id = cell.groupId.text
                    print(id)
                    let user = Constant.audianceTable.filter(Constant.audid == id!)
                    let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "0")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                    do {
                        let alice = Constant.audianceTable.filter(Constant.audQty == "0")
                        if try Constant.database.run(alice.update(Constant.audstatus <- "n")) > 0 {
                            print("updated alice")
                        } else {
                            print("alice not found")
                        }
                    } catch {
                        print("update failed: \(error)")
                    }
                    //end
                    cell.tintColor = UIColor.clear
                    
                }
                else{
                    //update status to y
                    //save selected data in sqlite
                    //retrive data
                    do {
                        let users = try Constant.database.prepare(Constant.audianceTable)
                        for user in users {
                            print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
                        }
                    } catch {
                        print(error)
                    }
                    //update
                    let id = cell.groupId.text
                    print(id)
                    let user = Constant.audianceTable.filter(Constant.audid == id!)
                    let updateUser = user.update(Constant.audstatus <- "y",Constant.audQty <- "0")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                    do {
                        let alice = Constant.audianceTable.filter(Constant.audQty == "0")
                        if try Constant.database.run(alice.update(Constant.audstatus <- "y")) > 0 {
                            print("updated alice")
                        } else {
                            print("alice not found")
                        }
                    } catch {
                        print("update failed: \(error)")
                    }
                    //end
                    cell.tintColor = UIColor.blue
                    
                    
                }
            }
        }
            
        else if(indexPath.section == 2){
            //save Deselected data in sqlite
//            //retrive data
//            do {
//                let users = try Constant.database.prepare(Constant.audianceTable)
//                for user in users {
//                    print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
//                }
//            } catch {
//                print(error)
//            }
//            let cell = tableView.cellForRow(at: indexPath) as! AudianceTableViewCell
//            //update
//            let id = cell.groupName.text
//            print(id)
//            let user = Constant.audianceTable.filter(Constant.audname == id!)
//            let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "0")
//            do {
//                try Constant.database.run(updateUser)
//            } catch {
//                print(error)
//            }
//            //end
            //retrive status and place chkmark according to it
            let cell = tableView.cellForRow(at: indexPath) as! AudianceTableViewCell
            print("selected table\(indexPath.row)")
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            receivedStatusArray.removeAllObjects()
            receivedIdArray.removeAllObjects()
            //Retrive type data
            do {
                let query = Constant.audianceTable.select(Constant.audstatus)
                    .filter(Constant.audid == "1")
                
                let users = try Constant.database.prepare(query)
                print(users)
                for user in users {
                    print("AudianceStatus: \(user[Constant.audstatus])")
                    let status = user[Constant.audstatus]
                    self.receivedStatusArray.add(status)
                    
                }
            } catch {
                print(error)
            }
            print(receivedStatusArray)
            let status = receivedStatusArray[indexPath.row] as? String
          
            if(cell.groupId.text == "1"){
                
                if(status == "y"){
                    //update status to n
                    //update
                    let id = cell.groupId.text
                    print(id)
                    let user = Constant.audianceTable.filter(Constant.audid == id!)
                    let updateUser = user.update(Constant.audstatus <- "n",Constant.audQty <- "1")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                    cell.tintColor = UIColor.clear
                    
                }
                else{
                    //update status to y
                    //save selected data in sqlite
                    //retrive data
                    do {
                        let users = try Constant.database.prepare(Constant.audianceTable)
                        for user in users {
                            print("userId: \(user[Constant.aid]), name: \(user[Constant.audname]), nameid: \(user[Constant.audid])")
                        }
                    } catch {
                        print(error)
                    }
                    //update
                    let id = cell.groupId.text
                    print(id)
                    let user = Constant.audianceTable.filter(Constant.audid == id!)
                    let updateUser = user.update(Constant.audstatus <- "y",Constant.audQty <- "1")
                    do {
                        try Constant.database.run(updateUser)
                    } catch {
                        print(error)
                    }
                    //end
                    cell.tintColor = UIColor.blue
                    
                    
                }
            }
        }
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0){
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            headerView.backgroundColor = UIColor.orange
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-30)
            label.text = "My Groups".localized()
            //        label.font = UIFont().futuraPTMediumFont(16) // my custom font
                 label.textColor = UIColor.white // my custom colour
            
            headerView.addSubview(label)
            
            return headerView
            
        }
        else if(section == 1){
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            headerView.backgroundColor = UIColor.orange
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-30)
            label.text = "All groups".localized()
             label.textColor = UIColor.white
            headerView.addSubview(label)
            return headerView
        }
        else if(section == 2){
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            headerView.backgroundColor = UIColor.orange
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-30)
            label.text = "All indivisual users".localized()
            label.textColor = UIColor.white
            headerView.addSubview(label)
            return headerView
        }else{
            return nil
        }
        
    }
    //get groupList
    func getAudianceAPiCall()
    {
       
        ANLoader.showLoading(Validation.LOADING_MESSAGE.localized(), disableUI: true)
        
        let urlString = Constant.BASE_URL + Constant.showGroupList
        let url:NSURL = NSURL(string: urlString)!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"
        
        let paramString = String(format: "user_id=%@",userIds)
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
                for values in jsonObj!{
                    let group_id = (values as AnyObject).value(forKey: "group_id") as! String
                 //   let group_logo = (values as AnyObject).value(forKey: "group_logo") as! String
                    let group_name = (values as AnyObject).value(forKey: "group_name") as! String
                    
                    let groups = Group(group_name: group_name , group_imageURL: "" , group_id: group_id )
                    print(groups)
                    //insert values to DB
                  
                    let insertUser = Constant.audianceTable.insert(Constant.audname <- group_name, Constant.audid <- group_id,Constant.audQty <- "0",Constant.audstatus <- "n")
                    
                    do {
                        try Constant.database.run(insertUser)
                        print("INSERTED USER")
                    } catch {
                        print(error)
                    }
                    //End
               
                    self.groupListArray.append(groups)
                    print(self.groupListArray.count)
                }
                DispatchQueue.main.async{
                    print(self.groupListArray.count)
                    print(self.groupListArray)
                    //   self.refreshControl.endRefreshing()
                 self.audianceTable.reloadData()
                }
            }
            
        }
        
        task.resume()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
