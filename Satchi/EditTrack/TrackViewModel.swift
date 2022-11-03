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
    @Published var comments = ""

    init() {}
}

enum ModelTrackState {
    case notCreated, created, tracked
}
