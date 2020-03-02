//
//  ModelTop10Taggers.swift
//  GiftADeed
//
//  Created by Spieler on 11/06/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class ModelTop10Taggers: NSObject {

    //MARK: Properties
    var First_Name: String
    var Last_Name: String
    var Total_Credit_Point: String
    
    //MARK: Initialization
    init?(First_Name: String, Last_Name: String, Total_Credit_Point: String) {
        
        // Initialize stored properties.
        self.First_Name = First_Name
        self.Last_Name = Last_Name
        self.Total_Credit_Point = Total_Credit_Point
    }
}
