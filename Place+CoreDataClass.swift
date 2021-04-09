//
//  Place+CoreDataClass.swift
//  ff_RW_Sample
//
//  Created by Rube Williams on 4/8/21.
//
//

import Foundation
import CoreData

@objc(Place)
public class Place: NSManagedObject {

    
    @objc class func createPlace(_ name : String, weather: String, acquireDate: Date, context: NSManagedObjectContext)-> Place{
        
        var place : Place?
        var results : [Place] = []
        do {
            let request = Place.fetchRequest() as NSFetchRequest<Place>
            
            let predicate = NSPredicate(format: "name == %@", name)
            request.predicate = predicate
            
            results = try context.fetch(request)
         
        }
        catch{
            print ("create Place Error")
        }
        
        
        if results.count > 0{
            place = results.last
        }
        else{
            place = Place(context: context)
            place?.name = name;
        }
        
        place?.lastWeather = weather;
        place?.acquireDate = acquireDate;
        
        try! context.save()
        return place!
    }
}
