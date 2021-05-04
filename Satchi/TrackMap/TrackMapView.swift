//
//  TrackMapView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import SwiftUI
import MapKit


struct TrackMapView: View {    

    @StateObject private var mapModel = TrackMapModel()
    @State private var editActive = false
    @State private var name = ""
    @State private var track:Track?
    
    var body: some View {
            ZStack {
                MapView(mapModel: mapModel)
                TrackMapOverlayView(state: $mapModel.state)
                NavigationLink("",
                               destination: EditTrackView(track: track ?? Track()),
                               isActive: $editActive
                )
            }
            .sheet(isPresented: $mapModel.stateDone) {
                TextInputDialog(prompt: "Enter a name" , value: $name)
            }
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .onChange(of: name) { value in
                track = TrackStorage.shared.create(name: name, created: Date(), finished: nil)
                editActive = true
            }
//        else{
//            EditTrackView(model: EditTrackModel(track: TrackStorage.shared.add(name: "Tracky", created: Date(), finished: nil)))
//        }
    }
}

struct TrackMapView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapView()
    }
}
