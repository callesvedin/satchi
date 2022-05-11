//
//  TrackViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import Foundation

class TrackViewModel: ObservableObject {

    @Published var difficulty: Int = 1
    @Published var showTrackView = false
    @Published var editName = false
    @Published var trackName: String = ""
    @Published var finished = false
    @Published var comments = ""

    init() {}

}
