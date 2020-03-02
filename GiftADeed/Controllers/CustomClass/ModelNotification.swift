//
//  Meal.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 11/10/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit


class ModelNotification {
    
    //MARK: Properties
    var date: String
    var time: String
    var nt_type: String
    var tag_type: String
    var Geopoint: String
    var Need_Name: String
    var numberDays : Int
     var nt_seen : String
    
    //MARK: Initialization
    init?(date: String, time: String, nt_type: String, tag_type: String, Geopoint: String, Need_Name: String, numberDays: Int, nt_seen : String) {

        // Initialize stored properties.
        self.date = date
        self.time = time
        self.tag_type = tag_type
        self.Geopoint = Geopoint
        self.Need_Name = Need_Name
        self.nt_type = nt_type
        self.numberDays = numberDays
        self.nt_seen = nt_seen
    }
}
