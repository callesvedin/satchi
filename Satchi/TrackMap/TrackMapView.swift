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

    var preview = false

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TrackMapView.self)
    )

    init(track: Track, preview: Bool = false, previewStack:Bool = false) {

        _mapModel = StateObject(wrappedValue: {
            let model = TrackMapModel(track: track,
                                      stack: CoreDataStack.shared)
            return model

        }())

        self.preview = preview
    }

    var body: some View {
        ZStack {
            MapView(mapModel: mapModel, isPreview: preview)
            if !preview {
                TrackMapOverlayView(mapModel: mapModel)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onChange(of: mapModel.done) { value in
            print("Map model done")
            if preview == false {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    
}

struct TrackMapView_Previews: PreviewProvider {

    static var previews: some View {
        let stack = CoreDataStack.preview

        NavigationView {
            TrackMapView(track: stack.getTracks()[0], preview: true)
                .environmentObject(CoreDataStack.preview)
        }
    }
}
