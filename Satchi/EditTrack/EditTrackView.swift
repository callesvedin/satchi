//
//  EditTrackView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import SwiftUI

struct EditTrackView: View {
    
    //@ObservedObject var model:EditTrackModel
    @ObservedObject var track:Track
    
    let hideBackButton : Bool
    let dateFormatter:DateFormatter
        
    init(track:Track, hideBackButton: Bool = true) {
        self.track = track
        self.hideBackButton = hideBackButton
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
    }
        
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text("Length: \(track.length)m")
                Text("Created: \(dateFormatter.string(from: track.created ?? Date()))")
                if track.finished != nil {
                    Text("Finished: \(dateFormatter.string(from: track.finished!))")
                }else {
                    Text("Finished: -")
                }
                HStack {
                    Spacer()
                    Button("Done"){
                        
                    }
                    Spacer()
                }
                .padding(.top,100)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .navigationTitle(track.name ?? "NoName")
        .navigationBarBackButtonHidden(hideBackButton)
    }
}

struct EditTrackView_Previews: PreviewProvider {
    static var previews: some View {
        let track = TrackStorage.preview.tracks.value[2]
        NavigationView {
            EditTrackView(track: track)
        }
    }
}
