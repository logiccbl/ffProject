//
//  Place+CoreDataProperties.swift
//  ff_RW_Sample
//
//  Created by Rube Williams on 4/8/21.
//
//

import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var acquireDate: Date?
    @NSManaged public var lastWeather: String?
    @NSManaged public var name: String?

}

extension Place : Identifiable {

}
