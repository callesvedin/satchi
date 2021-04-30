//
//  TrackViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation

class TrackViewModel:ObservableObject {
    var name:String = ""
    var length:Int?
    var finished:Date?
    var created:Date?
    var uuid:UUID?
    
    init() {}
    
    init(track inTrack:Track?) {
        if let track = inTrack {
            self.uuid = track.id
            self.length = Int(track.length)
            self.name = track.name ?? ""
            self.finished = track.finished
            self.created = track.created
        }
    }
    
}
