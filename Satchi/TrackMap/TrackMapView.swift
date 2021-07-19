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
    @State var showView = false
    
    init(trackModel:TrackModel) {
        self.trackModel = trackModel
        mapModel = TrackMapModel(laidPath: trackModel.laidPath,trackedPath: trackModel.trackPath)
    }
    
    var body: some View {
        ZStack {
            if showView {
                MapView(mapModel: mapModel)
                TrackMapOverlayView(mapModel:mapModel)
            }
        }
        //        .sheet(isPresented: $showModal) {
        //            TextInputDialog(prompt: "Track name:" , value: $name)
        //        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onChange(of:mapModel.state) { value in
            
            switch value {
            case .layPathDone:
                trackModel.laidPath = mapModel.laidPath
                trackModel.trackPath = mapModel.trackPath
                trackModel.timeToCreate = mapModel.timer.secondsElapsed
                trackModel.length = Int(mapModel.distance)
                trackModel.save()
                presentationMode.wrappedValue.dismiss()
            case .trackingDone:
                trackModel.trackPath = mapModel.trackPath
                trackModel.timeToFinish = mapModel.timer.secondsElapsed
                trackModel.finished = Date()
                trackModel.save()
                presentationMode.wrappedValue.dismiss()
            case .allDone:
                presentationMode.wrappedValue.dismiss()            
            default:
                print("Map model state changed to \(value)")
            }
            
        }
        .onAppear() {
            showView = true
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
