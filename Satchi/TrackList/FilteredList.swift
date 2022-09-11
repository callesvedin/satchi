//
//  FilteredList.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-06-04.
//

import SwiftUI

struct FilteredList: View {
    @EnvironmentObject private var stack: CoreDataStack

    @Binding var tracks: [Track]

//    let header: String
//    @Binding var selection: Track?

    var body: some View {
//        if !tracks.isEmpty {
//            TrackSectionView(sectionName: header)
//            Divider().frame(height: 2)
//        }
        ForEach(tracks) { (track)  in
//            TrackCellView(deleteFunction: deleteTrackFunction, track: track)
            NavigationLink(
                destination:{ EditTrackView(track).environmentObject(stack)},
                label:{
                    TrackCellView(deleteFunction: deleteTrackFunction, track: track)
                }
            )

        }.onDelete{offset in
            deleteTrackFunction(track:tracks[offset.first!])
        }
    }

    func deleteTrackFunction(track: Track) {
        stack.delete(track)
    }

}

struct FilteredList_Previews: PreviewProvider {
    static var previews: some View {
        List {
        FilteredList(tracks: .constant( CoreDataStack.preview.getTracks())
        ).environmentObject(CoreDataStack.preview)}
    }
}
