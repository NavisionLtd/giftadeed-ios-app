//
//  SubCategoryTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 11/14/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
import CoreData
import SQLite

class SubCategoryTableViewCell: UITableViewCell,UITextFieldDelegate {
    var i = 0
    let typeAdd = NSMutableArray()
    var typeAddDict = [String:String]()
   
    @IBOutlet weak var qtyLblText: UITextField!
    //For audiance
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.qtyLblText.delegate = self
        GlobalClass.sharedInstance.openDb()
    }
    
    required init?(coder aDecoder: NSCoder) {
          //self.qtyLblText.delegate = self
        super.init(coder: aDecoder)
        
    }
   
    @IBAction func qtyLblPress(_ sender: UITextField) {
        print(sender.text)
        self.qtyLblText.keyboardType = .phonePad
        //retrive data
        do {
            let users = try Constant.database.prepare(Constant.preferenceTable)
            for user in users {
                print("userId: \(user[Constant.id]), name: \(user[Constant.prefname]), nameid: \(user[Constant.prefid]),\(user[Constant.prefQty])")
            }
        } catch {
            print(error)
        }
        //update
        let id = typeId.text!
        let user = Constant.preferenceTable.filter(Constant.prefid == id)
        let updateUser = user.update(Constant.prefstatus <- "y",Constant.prefQty <- sender.text!)
        do {
            try Constant.database.run(updateUser)
        } catch {
            print(error)
        }
        //end
        
        typeAddDict["Type"] = typeLbl.text!
        typeAddDict["Quantity"] = sender.text!
        UserDefaults.standard.set(typeAddDict, forKey: "typeDict")
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("typeAdd"), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     //   self.accessoryType = selected ? .checkmark : .none

       
    }
    //End
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("Minus press",String(i),numberLbl)
    }
  

    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var typeId: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!

   
    @IBAction func plusBtnPress(_ sender: UIButton) {
      print("\(self.typeId.text)\(self.typeLbl.text)\(self.numberLbl.text)")
    //retrive data if id is ame as typeId update qty.
    //retrive data
        do {
            let query = Constant.preferenceTable.select(Constant.prefQty)           // SELECT "qty" FROM "preferenvetable"
                .filter(Constant.prefid == self.typeId.text!)                                  // WHERE "preferenceid" IS current cell id
            let users = try Constant.database.prepare(query)
            for user in users {
                print(user[Constant.prefQty])
                i = Int(user[Constant.prefQty])!
            }
        } catch {
            print(error)
        }
        
        if(i == 0){
            i = i + 1
            print("Plus press",String(i))
            numberLbl.text = String(i)
            
            //retrive data
            do {
                let users = try Constant.database.prepare(Constant.preferenceTable)
                for user in users {
                    print("userId: \(user[Constant.id]), name: \(user[Constant.prefname]), nameid: \(user[Constant.prefid]),\(user[Constant.prefQty])")
                }
            } catch {
                print(error)
            }
            //update
            let id = typeId.text!
            let user = Constant.preferenceTable.filter(Constant.prefid == id)
            let updateUser = user.update(Constant.prefstatus <- "y",Constant.prefQty <- self.numberLbl.text!)
            do {
                try Constant.database.run(updateUser)
            } catch {
                print(error)
            }
            //end
            if(typeAddDict.count>0){
                print(typeAddDict.values.contains(typeLbl.text!))
                
                if(typeAddDict.values.contains(typeLbl.text!)){
                    typeAddDict.updateValue(numberLbl.text!, forKey: "Quantity")
                }
            }
            else{
                typeAddDict["Type"] = typeLbl.text!
                typeAddDict["Quantity"] = numberLbl.text!
            }
            
            print(typeAddDict)
            
            
            UserDefaults.standard.set(typeAddDict, forKey: "typeDict")
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("typeAdd"), object: nil)
            
            if(i>0)
            {
                
                minusBtn.isEnabled = true
            }
        }
        else{
            i = i + 1
            print("Plus press",String(i))
            numberLbl.text = String(i)
            
            //retrive data
            do {
                let users = try Constant.database.prepare(Constant.preferenceTable)
                for user in users {
                    print("userId: \(user[Constant.id]), name: \(user[Constant.prefname]), nameid: \(user[Constant.prefid]),\(user[Constant.prefQty])")
                }
            } catch {
                print(error)
            }
            //update
            let id = typeId.text!
            let user = Constant.preferenceTable.filter(Constant.prefid == id)
            let updateUser = user.update(Constant.prefstatus <- "y",Constant.prefQty <- self.numberLbl.text!)
            do {
                try Constant.database.run(updateUser)
            } catch {
                print(error)
            }
            //end
            if(typeAddDict.count>0){
                print(typeAddDict.values.contains(typeLbl.text!))
                
                if(typeAddDict.values.contains(typeLbl.text!)){
                    typeAddDict.updateValue(numberLbl.text!, forKey: "Quantity")
                }
            }
            else{
                typeAddDict["Type"] = typeLbl.text!
                typeAddDict["Quantity"] = numberLbl.text!
            }
            
            print(typeAddDict)
            
            
            UserDefaults.standard.set(typeAddDict, forKey: "typeDict")
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("typeAdd"), object: nil)
            
            if(i>0)
            {
                
                minusBtn.isEnabled = true
            }
        }
       
    }
  
    @IBAction func minusBtnPress(_ sender: UIButton) {
      
        //retrive data
        do {
            let query = Constant.preferenceTable.select(Constant.prefQty)           // SELECT "qty" FROM "preferenvetable"
                .filter(Constant.prefid == self.typeId.text!)                                  // WHERE "preferenceid" IS current cell id
            let users = try Constant.database.prepare(query)
            for user in users {
                print(user[Constant.prefQty])
                i = Int(user[Constant.prefQty])!
            }
        } catch {
            print(error)
        }
        if(i==0)
        {
              numberLbl.text = "0"
              minusBtn.isEnabled = false
            //retrive data
            do {
                let users = try Constant.database.prepare(Constant.preferenceTable)
                for user in users {
                    print("userId: \(user[Constant.id]), name: \(user[Constant.prefname]), nameid: \(user[Constant.prefid])")
                }
            } catch {
                print(error)
            }
            //update
            let id = typeId.text!
            let user = Constant.preferenceTable.filter(Constant.prefid == id)
            let updateUser = user.update(Constant.prefstatus <- "n",Constant.prefQty <- self.numberLbl.text!)
            do {
                try Constant.database.run(updateUser)
            } catch {
                print(error)
            }
            //end
        }
       
        else {
            i = i - 1
            print("Minus press",String(i))

              numberLbl.text = String(i)
            //retrive data
            do {
                let users = try Constant.database.prepare(Constant.preferenceTable)
                for user in users {
                    print("userId: \(user[Constant.id]), name: \(user[Constant.prefname]), nameid: \(user[Constant.prefid])")
                }
            } catch {
                print(error)
            }
            //update
            let id = typeId.text!
            let user = Constant.preferenceTable.filter(Constant.prefid == id)
            let updateUser = user.update(Constant.prefstatus <- "y",Constant.prefQty <- self.numberLbl.text!)
            do {
                try Constant.database.run(updateUser)
            } catch {
                print(error)
            }
            //end
        }
    }
}
