//
//  TrackViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation

@MainActor
class TrackViewModel: ObservableObject {

    @Published var difficulty: Int16 = 1
    @Published var showTrackView = false
    @Published var editName = false
    @Published var trackName: String = ""
//    @Published var finished = false
    @Published var runningState = TrackState.notCreated
    @Published var comments = ""

    init() {}
    func setState(pathLaid: Bool, tracked: Bool) {
        if tracked {
            self.runningState = .tracked
        } else if pathLaid {
            self.runningState = .created
        } else {
            self.runningState = .notCreated
        }
        objectWillChange.send()
    }
}

enum TrackState {
    case notCreated, created, tracked
}
