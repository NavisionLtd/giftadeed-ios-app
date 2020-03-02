//
//  ModelMyFullFill.swift
//  GiftADeed
//
//  Created by Spieler on 11/06/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class ModelMyFullFill: NSObject {

    //MARK: Properties
    var Tagged_Title : String?
    var Address : String?
    var FullFilled_Photo_Path : String?
    var FullFilled_Datetime : String?
    var FullFilled_Points : String?
    var Character_Path : String?
    var NeedMapping_ID : String?
    var Need_Name : String?
    var Endorse : String?
    var Views : String?
    
    //MARK: Initialization
    init?(Tagged_Title : String, Address : String, FullFilled_Photo_Path : String, FullFilled_Datetime : String, FullFilled_Points : String,NeedMapping_ID : String,Character_Path : String, Need_Name : String,  Views : String, Endorse : String) {
        
        // Initialize stored properties.
        self.Tagged_Title = Tagged_Title
        self.Address = Address
        self.FullFilled_Photo_Path = FullFilled_Photo_Path
        self.FullFilled_Datetime = FullFilled_Datetime
        self.FullFilled_Points = FullFilled_Points
        self.Character_Path = Character_Path
        self.NeedMapping_ID = NeedMapping_ID
        self.Need_Name = Need_Name
        self.Views = Views
        self.Endorse = Endorse
    }
}
