//
//  Notifications+CoreDataProperties.swift
//  
//
//  Created by nilesh sinha on 02/05/18.
//
//

import Foundation
import CoreData


extension Notifications {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notifications> {
        return NSFetchRequest<Notifications>(entityName: "Notifications")
    }

    @NSManaged public var date: String?
    @NSManaged public var geopoint: String?
    @NSManaged public var need_Name: String?
    @NSManaged public var nt_type: String?
    @NSManaged public var tag_type: String?
    @NSManaged public var time: String?

}
