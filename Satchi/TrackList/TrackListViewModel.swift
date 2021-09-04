//
//  TrackListViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import Foundation
import Combine

class TrackListViewModel:ObservableObject {
    var tracks: [Track] = []
    
    @Published var finishedTracks:[Track] = []
    @Published var availableTracks:[Track] = []
    
    private var cancellable:AnyCancellable?
    
    init(trackPublisher: AnyPublisher<[Track], Never> = TrackStorage.shared.tracks.eraseToAnyPublisher()){
        cancellable = trackPublisher.sink {tracks in
            NSLog("Updating tracks")
            self.tracks = tracks
        }
    }
    
    public func reload() {
        self.finishedTracks = tracks.filter({track in track.started != nil})
        self.availableTracks = tracks.filter({track in track.started == nil})
    }
    
    public func delete(track:Track) {
        TrackStorage.shared.delete(track: track)
    }
}
