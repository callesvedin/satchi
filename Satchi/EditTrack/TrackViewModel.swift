//
//  TrackViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation
import CoreLocation
import CoreData
import CloudKit

//@MainActor
class TrackViewModel: ObservableObject, Identifiable {
    var objectID: NSManagedObjectID
    var share: CKShare?
    var id: UUID?
    @Published var showTrackView = false
    @Published var editName = false

    @Published var difficulty: Int16 = 1
    @Published var trackName: String = ""
    @Published var comments = ""
    @Published var created: Date?
    @Published var laidPath: [CLLocation]?
    @Published var trackPath: [CLLocation]?
    @Published var length: Int32
    @Published var started: Date?
    @Published var timeToCreate: Double
    {
        didSet {state = getState()}
    }
    @Published var timeToFinish: Double
    {
        didSet {state = getState()}
    }
    @Published var state: TrackState

    
    init(_ track:Track) {
        id = track.id
        objectID = track.objectID
        trackName = track.name  ?? ""
        comments = track.comments ?? ""
        difficulty = max(1, track.difficulty)
        created = track.created
        laidPath = track.laidPath
        trackPath = track.trackPath
        length = track.length
        started = track.started
        timeToCreate = track.timeToCreate
        timeToFinish = track.timeToFinish
        state = track.getState()
    }

    public func setValues(_ track:Track) {
        id = track.id
        objectID = track.objectID
        trackName = track.name  ?? ""
        comments = track.comments ?? ""
        difficulty = max(1, track.difficulty)
        created = track.created
        laidPath = track.laidPath
        trackPath = track.trackPath
        length = track.length
        started = track.started
        timeToCreate = track.timeToCreate
        timeToFinish = track.timeToFinish
        state = track.getState()

    }
    
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


//enum ModelTrackState {
//    case notCreated, created, tracked
//}
