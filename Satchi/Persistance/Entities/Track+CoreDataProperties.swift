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

// MARK: State
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

public enum CurrentState:String {
    case notStarted, trailAdded, trailTracked
}


// MARK: State to section
extension Track {
    // This is for use in the TrackListView. Has to get a sort order and be @objc compatible :-/
    @objc var stateSection:StateSection {
        get {
            switch getState() {
            case .notStarted:
                return StateSection.createdState
            case .trailAdded:
                return StateSection.startedState
            case .trailTracked:
                return StateSection.finishedState
            }
        }
    }
}


public class StateSection:NSObject
{
    static let createdState = StateSection(text: "Created tracks", sortOrder: 0)
    static let startedState = StateSection(text: "Started tracks", sortOrder: 1)
    static let finishedState = StateSection(text: "Finished tracks", sortOrder: 2)

    let text:String
    let sortOrder:Int
    init(text:String, sortOrder:Int) {
        self.text=text
        self.sortOrder=sortOrder
    }
}



