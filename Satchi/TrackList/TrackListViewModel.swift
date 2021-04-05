//
//  TrackListViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import Foundation
import Combine

class TrackListViewModel:ObservableObject {
    var tracks: [Track] = [] {
        willSet {
            NSLog("Updating tracks to \(newValue)")
            finishedTracks = newValue.filter({track in track.finished != nil})
            availableTracks = newValue.filter({track in track.finished == nil})
        }
    }
    @Published var finishedTracks:[Track] = []
    @Published var availableTracks:[Track] = []
    
    private var cancellable:AnyCancellable?
    
    init(trackPublisher: AnyPublisher<[Track], Never> = TrackStorage.shared.tracks.eraseToAnyPublisher()){
        cancellable = trackPublisher.sink {tracks in
            NSLog("Updating tracks")
            self.tracks = tracks            
        }
    }
}
