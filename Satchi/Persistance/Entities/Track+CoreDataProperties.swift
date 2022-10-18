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
        let fetchRequest = NSFetchRequest<Track>(entityName: "Track")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.created, ascending: true)]
        return fetchRequest
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

    @objc var state:String {
        get {
            return getState().text()
        }
    }
}

public enum CurrentState:String {
    case notStarted, trailAdded, trailTracked
    func text() -> String {
        switch self {
        case .notStarted:
            return "Created tracks"
        case .trailAdded:
            return "Started tracks"
        case .trailTracked:
            return "Finished tracks"
        }

    }
}
