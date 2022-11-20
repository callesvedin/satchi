//
//  CoreDataStack+Sharing.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-11-17.
//

import Foundation

extension CoreDataStack {
    // There is an almost identical function in EditTrackView. Should be merged and put in CoreDataStack.
//    func shareTrack(_ track:Track) async {
//        let task = Task {
//            do {
//                if track.share == nil {
//                    track.share = getShare(track)
//                    if track.share == nil {
//                        let (_, share, _) = try await persistentContainer.share([track], to: nil)
//                        share[CKShare.SystemFieldKey.title] = track.name
//                        print("Created share with url:\(String(describing: share.url))")
//
//                        track.share = share
//                    }
//                }
//                if track.share != nil {
//                    editingTrack = track
//                }
//            } catch {
//                print("Failed to create share")
//            }
//        }
//        return await task.value
//    }
}
