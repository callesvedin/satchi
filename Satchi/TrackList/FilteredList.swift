//
//  FilteredList.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-06-04.
//

import SwiftUI
import CloudKit

struct FilteredList: View {
    @EnvironmentObject private var stack: CoreDataStack
    @Environment(\.preferredColorPalette) private var palette

    @Binding var tracks: [Track]
    @State var editingTrack: Track?
    @State var sharingTrack: Track?

    var body: some View {
        ForEach(tracks) { (track)  in
            NavigationLink(
                destination:{ EditTrackView(track).environmentObject(stack)},
                label:{
                    TrackCellView(deleteFunction: deleteTrackFunction, track: track, waitingForShare: track == sharingTrack)
                }
            )
            .swipeActions(allowsFullSwipe: false) {
                Button {
                    sharingTrack = track
                    Task{
                        await shareTrack(track)
                        sharingTrack = nil
                    }
                    print("Runnig by share!!")
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
        .listRowBackground(palette.midBackground)
        .sheet(item: $editingTrack){
            editingTrack = nil
        } content: { tr in
            if let share = tr.share {
                CloudSharingView(
                    share: share,
                    container: stack.ckContainer,
                    track: tr
                )
            }
        }
    }

    // There is an almost identical function in EditTrackView. Should be merged and put in CoreDataStack.
    func shareTrack(_ track:Track) async {
        let task = Task {
            do {
                if track.share == nil {
                    track.share = stack.getShare(track)
                    if track.share == nil {
                        let (_, share, _) = try await stack.persistentContainer.share([track], to: nil)
                        share[CKShare.SystemFieldKey.title] = track.name
                        print("Created share with url:\(String(describing: share.url))")

                        track.share = share
                    }
                }
                if track.share != nil {
                    editingTrack = track
                }
            } catch {
                print("Failed to create share")
            }
        }
        return await task.value
    }

    func deleteTrackFunction(track: Track) {
        stack.delete(track)
    }

}

struct FilteredList_Previews: PreviewProvider {
    static var previews: some View {
        List {
            FilteredList(tracks: .constant( CoreDataStack.preview.getTracks()))
                .environmentObject(CoreDataStack.preview)
        }
    }
}

