//
//  FilteredList.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-06-04.
//

import SwiftUI

struct FilteredList: View {
    @EnvironmentObject private var stack: CoreDataStack
    @Environment(\.preferredColorPalette) private var palette
    @Binding var tracks: [Track]

    var body: some View {
        ForEach(tracks) { (track)  in
            NavigationLink(
                destination:{ EditTrackView(track).environmentObject(stack)},
                label:{
                    TrackCellView(deleteFunction: deleteTrackFunction, track: track)
                }
            )
            .swipeActions(allowsFullSwipe: false) {
                Button {
                    print("Share!!")
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(.green)
                Button(role: .destructive) {
                    deleteTrackFunction(track:track)
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }

            }
        }
        .onDelete{offset in
            deleteTrackFunction(track:tracks[offset.first!])
        }
        .listRowBackground(palette.midBackground)

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

