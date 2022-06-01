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
    @StateObject public var mapModel = TrackMapModel()
    var track: Track
    @State private var name = ""
    @State var showModal: Bool = false
    @State var done: Bool = false
    var preview = false

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TrackMapView.self)
    )

    init(track: Track, preview: Bool = false) {
        self.track = track
        self.preview = preview
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
        .onChange(of: mapModel.state) { value in
            print("Map model state changed to \(value)")
            switch value {
            case .layPathDone:
                track.laidPath = mapModel.laidPath
                track.trackPath = mapModel.trackPath
                track.timeToCreate = mapModel.timer.secondsElapsed
                track.length = Int32(mapModel.distance)
                track.created = Date()
//                trackModel.image = mapModel.image
                stack.save()
                presentationMode.wrappedValue.dismiss()
            case .trackingDone:
                track.trackPath = mapModel.trackPath
                track.timeToFinish = mapModel.timer.secondsElapsed
                track.started = mapModel.trackingStarted
//                trackModel.image = mapModel.image
                stack.save()
                presentationMode.wrappedValue.dismiss()
            case .allDone:
                presentationMode.wrappedValue.dismiss()
                mapModel.state = mapModel.previousState
            case .cancelled:
                presentationMode.wrappedValue.dismiss()
                mapModel.state = mapModel.previousState

            default:
                print("Unhandled state")
            }
        }
        .onAppear {
            mapModel.laidPath = track.laidPath ?? []
            mapModel.trackPath = track.trackPath ?? []
            mapModel.previewing = preview
            mapModel.start()
        }
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
