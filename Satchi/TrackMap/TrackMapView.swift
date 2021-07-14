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
    @ObservedObject private var mapModel:TrackMapModel
    var trackModel:TrackModel
    @State private var name = ""
    @State var showModal:Bool = false
    @State var done:Bool = false
    
    
    init(trackModel:TrackModel) {
        self.trackModel = trackModel
        mapModel = TrackMapModel(laidPath: trackModel.laidPath)
    }
    
    var body: some View {
        ZStack {
            MapView(mapModel: mapModel)
            TrackMapOverlayView(mapModel:mapModel)
        }
//        .sheet(isPresented: $showModal) {
//            TextInputDialog(prompt: "Track name:" , value: $name)
//        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onChange(of:mapModel.stateDone) { value in
            trackModel.laidPath = mapModel.laidPath
            trackModel.trackPath = mapModel.trackPath
            trackModel.timeToCreate = mapModel.timer.secondsElapsed
            trackModel.finished = mapModel.tracking ? Date():nil
            if !mapModel.tracking
            {
                trackModel.length = Int(mapModel.distance)
            }
            trackModel.save()
            presentationMode.wrappedValue.dismiss()
            
        }
//        .onChange(of: name) { value in
//            showModal = false
//            presentationMode.dismiss()
//        }
    }
}

struct TrackMapView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapView(trackModel: TrackModel())
    }
}
