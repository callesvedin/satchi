//
//  TrackMapView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import SwiftUI
import MapKit
import os.log

struct TrackMapView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var stack: CoreDataStack
    @StateObject public var mapModel: TrackMapModel
    var track: Track
    var preview = false

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TrackMapView.self)
    )

    init(track: Track, preview: Bool = false, previewStack:Bool = false) {
        self.track = track
        self.preview = preview


        _mapModel = StateObject(wrappedValue: {
            let model = TrackMapModel(track: track, onlyViewing: preview || track.getState() == .finished,
                                      stack: previewStack ? CoreDataStack.preview:CoreDataStack.shared)
            return model

        }())

    }

    var body: some View {
        ZStack {
            MapView(mapModel: mapModel)
            if !preview {
                TrackMapOverlayView(mapModel: mapModel)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onChange(of: mapModel.done) { value in
            print("Map model done")
            presentationMode.wrappedValue.dismiss()
        }
    }
    func reload(track:Track) {
        mapModel.track = track
    }
    
}

struct TrackMapView_Previews: PreviewProvider {

    static var previews: some View {
        let stack = CoreDataStack.preview
        NavigationView {
        TrackMapView(track: stack.getTracks()[0])
            .environmentObject(CoreDataStack.preview)
        }
    }
}
