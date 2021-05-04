//
//  EditTrackModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation

class EditTrackModel: ObservableObject {
    var uuid : UUID?
    
    var created : Date
    var finished : Date?
    var length : Int
    @Published var name : String
    
    init(uuid:UUID?, created:Date = Date(), finished:Date?, length:Int, name:String){
        self.uuid = uuid
        self.created = created
        self.finished = finished
        self.length = length
        self.name = name
    }
//    
    convenience init(track:Track) {
        self.init(uuid:track.id,
                  created: track.created ?? Date(),
                  finished: track.finished,
                  length: Int(track.length),
                  name: track.name ?? "No Name"
        )
    }
    
//    func save(track:TrackViewModel) {
//        if let id = track.uuid {
//            TrackStorage.shared.update(withId: id, name: track.name, created: track.created, finished: track.finished)
//        }else{
//            TrackStorage.shared.add(name: track.name, created: track.created, finished: track.finished)
//        }
//    }
    
}
