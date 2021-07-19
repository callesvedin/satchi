//
//  EditTrackModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation
import CoreLocation

class TrackModel: ObservableObject {
    var uuid : UUID?
    var laidPath : [CLLocation]?
    var trackPath : [CLLocation]?
    var created : Date
    var finished : Date?
    var length : Int?
    var timeToCreate : Double?
    var timeToFinish : Double?
    var difficulty : Int
    var name : String
    
    init(created:Date = Date(), difficulty:Int = 3, name:String = "New Track") {
        self.created = created
        self.difficulty = difficulty
        self.name = name
    }
    
    convenience init(uuid:UUID? = nil, laidPath:[CLLocation], trackPath:[CLLocation], length:Int, created:Date, finished:Date?,  name:String, difficulty:Int, timeToCreate:Double, timeToFinish:Double){
        self.init(created:created, difficulty:difficulty)
        self.uuid = uuid
        self.laidPath = laidPath
        self.trackPath = trackPath
        self.finished = finished
        self.length = length
        self.name = name
        self.difficulty = difficulty
        self.timeToCreate = timeToCreate
        self.timeToFinish = timeToFinish
    }

    convenience init(track:Track) {
        self.init(uuid:track.id,
                  laidPath: track.laidPath ?? [],
                  trackPath: track.trackPath ?? [],
                  length: Int(track.length),
                  created: track.created ?? Date(),
                  finished: track.finished,
                  name: track.name ?? "New Track",
                  difficulty: Int(track.difficulty),
                  timeToCreate: track.timeToCreate,
                  timeToFinish: track.timeToFinish
        )
    }
    
    func save() {
        TrackStorage.shared.update(with:self)        
    }
}
