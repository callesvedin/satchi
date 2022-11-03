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
    @NSManaged public var state: Int16

}

extension Track: Identifiable {

}

// MARK: State
extension Track {
    public func getState() -> TrackState {
        if timeToFinish > 0 {
            return .trailTracked
        } else if timeToCreate > 0 {
            return .trailAdded
        } else {
            return .notStarted
        }
    }
}


@objc
public enum TrackState:Int16 {
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

//
//
//public class StateSection:NSObject
//{
//    static let createdState = StateSection(text: "Created tracks", sortOrder: 0)
//    static let startedState = StateSection(text: "Started tracks", sortOrder: 1)
//    static let finishedState = StateSection(text: "Finished tracks", sortOrder: 2)
//
//    let text:String
//    let sortOrder:Int
//    init(text:String, sortOrder:Int) {
//        self.text=text
//        self.sortOrder=sortOrder
//    }
//
//    static func sectionNameFor(order : Int) -> String {
//        switch order {
//        case 0:
//            return createdState.text
//        case 1:
//            return startedState.text
//        case 2:
//            return finishedState.text
//        default:
//            return ""
//        }
//    }
//}



