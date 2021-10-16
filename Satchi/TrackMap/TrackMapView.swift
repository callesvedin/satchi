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
    @ObservedObject public var mapModel: TrackMapModel
    var trackModel: TrackModel
    @State private var name = ""
    @State var showModal: Bool = false
    @State var done: Bool = false
    @State var showView = false

    init(trackModel: TrackModel) {
        self.trackModel = trackModel
        mapModel = TrackMapModel(laidPath: trackModel.laidPath, trackedPath: trackModel.trackPath)
    }

    var body: some View {
        ZStack {
            if showView {
                MapView(mapModel: mapModel)
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
            case .cancelled:
                presentationMode.wrappedValue.dismiss()
                mapModel.state = mapModel.previousState

            default:
                print("Map model state changed to \(value)")
            }

        }
        .onAppear {
            showView = true
        }
    }
}

struct TrackMapView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapView(trackModel: TrackModel())
    }
}
