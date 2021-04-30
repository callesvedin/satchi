//
//  EditTrackModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation

class EditTrackModel: ObservableObject {
    @Published var track:Track
    
    init(track:Track) {
        self.track = track
    }
    
//    func save(track:TrackViewModel) {
//        if let id = track.uuid {
//            TrackStorage.shared.update(withId: id, name: track.name, created: track.created, finished: track.finished)
//        }else{
//            TrackStorage.shared.add(name: track.name, created: track.created, finished: track.finished)
//        }
//    }
    
}
