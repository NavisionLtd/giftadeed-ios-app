//
//  ModelMarker.swift
//  GiftADeed
//
//  Created by nilesh sinha on 31/05/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class ModelHome: NSObject {

    //MARK: Properties
    var Tagged_ID : String?
    var Tagged_Title : String?
    var Address : String?
    var PAddress : String?
    var Geopoint : String?
    var Tagged_Photo_Path : String?
    var Tagged_Datetime : String?
    var Icon_Path : String?
    var Character_Path : String?
    var Need_Name : String?
    var Views : String?
    var Endorse : String?
    var Distance : String?
     var cat_type : String?
    
    //MARK: Initialization
    init?(Tagged_ID : String, Tagged_Title : String, Address : String,PAddress : String, Geopoint : String, Tagged_Photo_Path : String,Tagged_Datetime : String,Icon_Path : String,Character_Path : String, Need_Name : String,  Views : String, Endorse : String, Distance : String,cat_type : String) {
        
        // Initialize stored properties.

        self.Tagged_ID = Tagged_ID
        self.Tagged_Title = Tagged_Title
        self.Address = Address
        self.PAddress = PAddress
        self.Geopoint = Geopoint
        self.Tagged_Photo_Path = Tagged_Photo_Path
        self.Tagged_Datetime = Tagged_Datetime
        self.Icon_Path = Icon_Path
        self.Character_Path = Character_Path
        self.Need_Name = Need_Name
        self.Views = Views
        self.Endorse = Endorse
        self.Distance = Distance
        self.cat_type = cat_type
    }
}
