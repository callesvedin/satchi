//
//  TrackMapView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import SwiftUI
import MapKit
import os.log

struct PreviewTrackMapView: View {
    @Environment(\.presentationMode) var presentationMode

    var track:Track

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PreviewTrackMapView.self)
    )

    init(track: Track) {
        self.track = track
    }

    var body: some View {
        PreviewMapView(laidPath: track.laidPath, trackPath:track.trackPath)
        .navigationBarHidden(true)
        .ignoresSafeArea()        
    }
}

struct PreviewTrackMapView_Previews: PreviewProvider {
    static var previews: some View {
        let stack = CoreDataStack.preview

        NavigationView {
            PreviewTrackMapView(track: stack.getTracks()[0])
                .environmentObject(CoreDataStack.preview)
        }
    }
}
