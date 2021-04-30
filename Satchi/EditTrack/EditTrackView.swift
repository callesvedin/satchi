//
//  EditTrackView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import SwiftUI

struct EditTrackView: View {
    
    @ObservedObject var model:EditTrackModel
    
    var body: some View {
        Text("Name= \(model.track.name ?? "-")")
    }
}

struct EditTrackView_Previews: PreviewProvider {
    static var previews: some View {
        let track = TrackStorage.preview.tracks.value[0]
        EditTrackView(model:EditTrackModel(track: track))
    }
}
