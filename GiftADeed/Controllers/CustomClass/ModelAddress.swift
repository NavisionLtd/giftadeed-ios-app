//
//  ModelAddress.swift
//  GiftADeed
//
//  Created by nilesh sinha on 23/07/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class ModelAddress: NSObject {

    //MARK: Properties
    var name: String
    var typeId: String
    
    //MARK: Initialization
    init?(name: String, typeId: String) {
        
        // Initialize stored properties.
        self.name = name
        self.typeId = typeId
    }
    
}
