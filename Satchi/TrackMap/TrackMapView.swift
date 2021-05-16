//
//  TrackMapView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import SwiftUI
import MapKit


struct TrackMapView: View {    
//    @EnvironmentObject var navigationHelper: NavigationHelper
    @StateObject private var mapModel = TrackMapModel()
//    @State private var editActive = false
    @State private var name = ""
    @State var showModal:Bool = false
    @State private var track:Track?
    @State var done:Bool = false
    
    var body: some View {
            ZStack {
                MapView(mapModel: mapModel)
                TrackMapOverlayView(state: $mapModel.state)
                
                NavigationLink(destination: EditTrackView(track: track ?? Track()), isActive:$done) {
                    EmptyView()
                }
                .isDetailLink(false)
            }
            .sheet(isPresented: $showModal) {
                TextInputDialog(prompt: "Enter a name" , value: $name)
            }
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .onChange(of: mapModel.stateDone) { value in
                if (mapModel.stateDone == true) {
                    self.showModal = true
                }
            }
            .onChange(of: name) { value in
                track = TrackStorage.shared.create(name: name, created: Date(), finished: nil)
                showModal = false
                done = true
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
