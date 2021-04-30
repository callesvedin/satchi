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
    
    var body: some View {
        if mapModel.state != .done {
            ZStack {
                MapView(mapModel: mapModel)
                TrackMapOverlayView(state: $mapModel.state)
            }
            .navigationBarHidden(true)
            .ignoresSafeArea()
        }else{
            EditTrackView(model: EditTrackModel(track: TrackStorage.shared.add(name: "Tracky", created: Date(), finished: nil)))
        }
    }
}

struct TrackMapView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapView()
    }
}
