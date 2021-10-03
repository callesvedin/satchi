//
//  TrackViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation

class TrackViewModel: ObservableObject {
    var name: String = ""
    var length: Int?
    var started: Date?
    var created: Date?
    var uuid: UUID?

    init() {}

    init(track inTrack: Track?) {
        if let track = inTrack {
            self.uuid = track.id
            self.length = Int(track.length)
            self.name = track.name ?? ""
            self.started = track.started
            self.created = track.created
        }
    }

}
