//
//  TrackMapView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import SwiftUI
import MapKit

struct TrackMapView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject public var mapModel = TrackMapModel()
    var trackModel: TrackModel
    @State private var name = ""
    @State var showModal: Bool = false
    @State var done: Bool = false
    var preview = true

    init(trackModel: TrackModel, preview: Bool = false) {
        self.trackModel = trackModel
        self.preview = preview
    }

    var body: some View {
        ZStack {
            MapView(mapModel: mapModel)
            if !preview {
                TrackMapOverlayView(mapModel: mapModel)
            }
        }
//        .navigationTitle("Track")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onChange(of: mapModel.state) { value in

            switch value {
            case .layPathDone:
                trackModel.laidPath = mapModel.laidPath
                trackModel.trackPath = mapModel.trackPath
                trackModel.timeToCreate = mapModel.timer.secondsElapsed
                trackModel.length = Int(mapModel.distance)
                trackModel.image = mapModel.image
                trackModel.save()
                presentationMode.wrappedValue.dismiss()
            case .trackingDone:
                trackModel.trackPath = mapModel.trackPath
                trackModel.timeToFinish = mapModel.timer.secondsElapsed
                trackModel.started = mapModel.trackingStarted
                trackModel.image = mapModel.image
                trackModel.save()
                presentationMode.wrappedValue.dismiss()
            case .allDone:
                presentationMode.wrappedValue.dismiss()
                mapModel.state = mapModel.previousState
            case .cancelled:
                presentationMode.wrappedValue.dismiss()
                mapModel.state = mapModel.previousState

            default:
                print("Map model state changed to \(value)")
            }
        }
        .onAppear {
            mapModel.laidPath = trackModel.laidPath ?? []
            mapModel.trackPath = trackModel.trackPath ?? []
            mapModel.previewing = preview
            mapModel.start()
        }
    }
}

struct TrackMapView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapView(trackModel: TrackModel())
    }
}
