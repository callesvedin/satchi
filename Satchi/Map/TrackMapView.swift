//
//  TrackMapView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import MapKit
import os.log
import SwiftUI

struct TrackMapView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var environment: AppEnvironment
    @StateObject public var mapModel: TrackMapModel
    @State var showAccessDenied: Bool = false
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TrackMapView.self)
    )

    init(track: Track, preview: Bool = false) {
        TrackMapView.logger.debug("Initializing TrackMapView")
        _mapModel = StateObject(wrappedValue: {
            let model = TrackMapModel(track: track)
            return model

        }())
    }

    var body: some View {
        ZStack {
            MapView(mapModel: mapModel)
            TrackMapOverlayView(mapModel: mapModel)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onChange(of: mapModel.done) { _ in
            Logger.mapView.debug("Map model done")
            presentationMode.wrappedValue.dismiss()
        }
        .onDisappear {
            Logger.mapView.debug("TrackMapView disappears")
        }
        
    }
}

//
// struct TrackMapView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let stack = CoreDataStack.preview
//
//        NavigationView {
//            TrackMapView(track: stack.getTracks()[0])
//                .environmentObject(CoreDataStack.preview)
//        }
//    }
// }
