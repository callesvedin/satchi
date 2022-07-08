//
//  FilteredList.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-06-04.
//

import SwiftUI

struct FilteredList: View {
    @Environment(\.managedObjectContext) var mocc

    @FetchRequest var tracks: FetchedResults<Track>

    let header: String
    @Binding var selection: Track?

    var body: some View {
        if !tracks.isEmpty {
            TrackSectionView(sectionName: header)
            Divider().frame(height: 2)
        }
        ForEach(tracks) { (track)  in
            TrackCellView(deleteFunction: deleteTrackFunction, track: track)
                .onTapGesture {
                    selection = track
                }
        }
    }

    func deleteTrackFunction(track: Track) {
        mocc.delete(track)
        do {
            try mocc.save()
        } catch {
            print("Could not delete track \(error.localizedDescription)")
        }
    }

}

struct FilteredList_Previews: PreviewProvider {
    static var previews: some View {
        FilteredList(tracks: FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Track.created, ascending: true)],
                                          predicate: NSPredicate(format: "laidPath == nil AND trackPath == nil")),
                     header: "Created tracks",
                     selection: .constant(nil))
    }
}
