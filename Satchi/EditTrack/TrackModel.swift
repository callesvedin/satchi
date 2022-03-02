//
//  EditTrackModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation
import UIKit
import CoreLocation
import Combine

class TrackModel: ObservableObject {
    var uuid: UUID?
    var laidPath: [CLLocation]?
    var trackPath: [CLLocation]?
    var created: Date
    var started: Date?
    var length: Int?
    var timeToCreate: Double?
    var timeToFinish: Double?
    var difficulty: Int
    var name: String
    var comments: String?
    var image: UIImage?
    let objectWillChange = PassthroughSubject<Void, Never>()

    init(created: Date = Date(), difficulty: Int = 3, name: String = "New Track") {
        self.created = created
        self.difficulty = difficulty
        self.name = name
    }

    convenience init(uuid: UUID? = nil, laidPath: [CLLocation],
                     trackPath: [CLLocation], length: Int, created: Date, started: Date?,
                     name: String, comments: String?, difficulty: Int, timeToCreate: Double, timeToFinish: Double, image: UIImage?) {
        self.init(created: created, difficulty: difficulty)
        self.uuid = uuid
        self.laidPath = laidPath
        self.trackPath = trackPath
        self.started = started
        self.length = length
        self.name = name
        self.comments = comments
        self.difficulty = difficulty
        self.timeToCreate = timeToCreate
        self.timeToFinish = timeToFinish
        self.image = image
    }

    convenience init(track: Track) {
        self.init(uuid: track.id,
                  laidPath: track.laidPath ?? [],
                  trackPath: track.trackPath ?? [],
                  length: Int(track.length),
                  created: track.created ?? Date(),
                  started: track.started,
                  name: track.name ?? "New Track",
                  comments: track.comments,
                  difficulty: Int(track.difficulty),
                  timeToCreate: track.timeToCreate,
                  timeToFinish: track.timeToFinish,
                  image: track.image != nil ? UIImage(data: track.image!) : nil
        )
    }

    func save() {
        print("TrackModel saved")
        objectWillChange.send()
        TrackStorage.shared.update(with: self)
    }
}
