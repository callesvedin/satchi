//
//  Track+CoreDataProperties.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-14.
//
//

import CoreData
import CoreLocation
import Foundation

public extension Track {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Track> {
        let fetchRequest = NSFetchRequest<Track>(entityName: "Track")
        return fetchRequest
    }

    @NSManaged var comments: String?
    @NSManaged var created: Date?
    @NSManaged var difficulty: Int16
    @NSManaged var id: UUID?
    @NSManaged var image: Data?
    @NSManaged var laidPath: [CLLocation]?
    @NSManaged var length: Int32
    @NSManaged var name: String?
    @NSManaged var started: Date?
    @NSManaged var timeToCreate: Double
    @NSManaged var timeToFinish: Double
    @NSManaged var trackPath: [CLLocation]?
    @NSManaged var state: Int16
//    @NSManaged var dummies: [CLLocationCoordinate2D]?
}

extension Track: Identifiable {}

// MARK: State

public extension Track {
    func getState() -> TrackState {
        if timeToFinish > 0 {
            return .trailTracked
        } else if timeToCreate > 0 {
            return .trailAdded
        } else {
            return .notStarted
        }
    }
}

public extension Track {
    func clone(with context: NSManagedObjectContext) -> Track {
        let t = Track(context: context)
        t.comments = comments
        t.created = created
        t.difficulty = difficulty
        t.id = UUID()
        t.image = image
        t.laidPath = laidPath
        t.length = length
        t.name = name
        t.started = started
        t.timeToCreate = timeToCreate
        t.timeToFinish = timeToFinish
        t.trackPath = trackPath
        t.state = state
        return t
    }
}

@objc
public enum TrackState: Int16 {
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
