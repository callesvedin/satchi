//
//  Track+CoreDataProperties.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-09-28.
//
//

import Foundation
import CoreData
import CoreLocation

extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var created: Date?
    @NSManaged public var difficulty: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var laidPath: [CLLocation]?
    @NSManaged public var length: Int32
    @NSManaged public var name: String?
    @NSManaged public var started: Date?
    @NSManaged public var timeToCreate: Double
    @NSManaged public var timeToFinish: Double
    @NSManaged public var trackPath: [CLLocation]?

}

extension Track: Identifiable {

}
