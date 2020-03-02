//
//  GlobalClass.swift
//  GiftADeed
//
//  Created by nilesh sinha on 05/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
import SQLite

class GlobalClass: NSObject {

    var menuIndex = ""
    var FCMTOKEN = ""
    
    var blockStatus : Bool = false
    
    var filterStatus : Bool = false
    var filterCategoryId = ""
    var filterCategoryValue = ""
    var filterRadiusVal :Double = 10.0
    
    var notifilterStatus : Bool = false
    var notifilterCategoryId = ""
    var notifilterCategoryValue = ""
    var notifilterDistanceVal :Int = 10
    var notifilterTimeVal :Int = 10
    
   
    static let sharedInstance = GlobalClass()
    private override init() {}
    
    func openMenu(){
        
        DispatchQueue.main.async {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "menu") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
    func openDb(){
        //Sqlite start
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("GAD").appendingPathExtension("sqlite3")
            print(fileUrl)
            let database = try Connection(fileUrl.path)
            Constant.database = database
        } catch {
            print(error)
        }
    }
    func createAppleLoginTable(){
        //Create preference table
        let createAppleLoginTable = Constant.AppleLoginTable.create { (table) in
            table.column(Constant.loginid, primaryKey: true)
             table.column(Constant.appleid, unique: true)
            table.column(Constant.firstname)
            table.column(Constant.lastname)
            table.column(Constant.email, unique: true)
           
        }
        
        do {
            try Constant.database.run(createAppleLoginTable)
            print("Created apple login Table")
        } catch {
            print(error)
        }
        //end
    }
    func createPreferenceTable(){
        //Create preference table
        let createPreferenceTable = Constant.preferenceTable.create { (table) in
            table.column(Constant.id, primaryKey: true)
            table.column(Constant.prefmapid)
            table.column(Constant.prefname)
            table.column(Constant.prefid, unique: true)
            table.column(Constant.prefQty)
            table.column(Constant.prefstatus)
        }
        
        do {
            try Constant.database.run(createPreferenceTable)
            print("Created preference Table")
        } catch {
            print(error)
        }
        //end
    }
    func createAudianceTable(){
        //Create preference table
        let createAudianceTable = Constant.audianceTable.create { (table) in
            table.column(Constant.aid, primaryKey: true)
            table.column(Constant.audname)
            table.column(Constant.audid, unique: true)
            table.column(Constant.audQty)
            table.column(Constant.audstatus)
        }
        
        do {
            try Constant.database.run(createAudianceTable)
            print("Created audiance Table")
        } catch {
            print(error)
        }
        //end
    }
    func createSosTypeTable(){
        //Create preference table
        let createSosTypeTable = Constant.sosTypeTable.create { (table) in
            table.column(Constant.sid, primaryKey: true)
            table.column(Constant.sosid, unique: true)
            table.column(Constant.sosname)
            table.column(Constant.sosstatus)
        }
        
        do {
            try Constant.database.run(createSosTypeTable)
            print("Created sos type Table")
        } catch {
            print(error)
        }
        //end
    }
    func createCategoryTable(){
        //Create category table
        let createCategoryTable = Constant.categoryTable.create { (table) in
            table.column(Constant.cid, primaryKey: true)
            table.column(Constant.catid, unique: true)
            table.column(Constant.catname)
            table.column(Constant.cattype)
            table.column(Constant.catstatus)
        }
        do {
            try Constant.database.run(createCategoryTable)
            print("Created category type Table")
        } catch {
            print(error)
        }
        //end
    }
    func createMultiPreferenceTable(){
        //Create multipreference table
        let createMultiPreferenceTable = Constant.multipreferenceTable.create { (table) in
            table.column(Constant.mrid, primaryKey: true)
            table.column(Constant.mrefid, unique: true)
            table.column(Constant.mrefname)
            table.column(Constant.mrefstatus)
        }
        
        do {
            try Constant.database.run(createMultiPreferenceTable)
            print("Created multipreference type Table")
        } catch {
            print(error)
        }
        //end
    }
    func createMultiAudianceTable(){
        //Create multipreference table
        let createMultiAudianceTable = Constant.multiaudianceTable.create { (table) in
            table.column(Constant.mid, primaryKey: true)
            table.column(Constant.mresid, unique: true)
            table.column(Constant.mresname)
            table.column(Constant.mresstatus)
        }
        do {
            try Constant.database.run(createMultiAudianceTable)
            print("Created multi resource audiance Table")
        } catch {
            print(error)
        }
        //end
    }
    func createSettingTbl(){
        //Create category table
        let createSettingTable = Constant.settingTable.create { (table) in
            table.column(Constant.set_id, primaryKey: true)
            table.column(Constant.sett_id, unique: true)
            table.column(Constant.set_name)
            table.column(Constant.set_status)
        }
        do {
            try Constant.database.run(createSettingTable)
            print("Created setting Table")
        } catch {
            print(error)
        }
        //end
    }
    func setBaseURL(){
        UserDefaults.standard.set(Constant.BASE_URL, forKey: "BASE_URL");
        UserDefaults.standard.set(Constant.update_location, forKey: "UPDATE_LOCATION");
    }

    func deInitClass() {
      
        filterStatus = false
        filterCategoryId = ""
        filterCategoryValue = ""
        filterRadiusVal = 10.0
        
        notifilterStatus = false
        notifilterCategoryId = ""
        notifilterCategoryValue = ""
        notifilterDistanceVal = 100
        notifilterTimeVal = 7
    }

    func getScreenWidth() -> Int{
        
        let screenSize: CGRect = UIScreen.main.bounds
        return Int(screenSize.width)
    }
    
    func clearLocalData(){
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
       
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return components.day!
    }
    
    func encodeToBase64String(image: UIImage?) -> String? {
        
        let imageData = UIImageJPEGRepresentation(image!, 0.2)
        let encodedImageData = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return encodedImageData!
    }
    
    func converDateFormate(dateString: String) -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        
        let date: Date? = dateFormatterGet.date(from: dateString)
        return (dateFormatter.string(from: date!))
    }

    func nullToNil(value : AnyObject?) -> AnyObject? {
        
        let blankValue = ""
        if value is NSNull {
            
            return blankValue as AnyObject
        } else {
            return value
        }
    }
}
