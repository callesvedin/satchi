//
//  Track+CoreDataProperties.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-14.
//
//

import Foundation
import CoreData
import CoreLocation

extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var comments: String?
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

extension Track {
    public func getState() -> CurrentState {
        if timeToFinish > 0 {
            return .trailTracked
        } else if timeToCreate > 0 {
            return .trailAdded
        } else {
            return .notStarted
        }
    }
}

public enum CurrentState {
    case notStarted, trailAdded, trailTracked
}
