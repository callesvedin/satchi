//
//  TrackListViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import Foundation
import Combine
import CoreData

class TrackListViewModel: NSObject, ObservableObject {
    @Published var tracks: [Track] = []

    private let trackFetchController: NSFetchedResultsController<Track>
    public var stack: CoreDataStack
//    @Published var finishedTracks: [Track] = []
//    @Published var startedTracks: [Track] = []
//    @Published var newTracks: [Track] = []

    private var cancellable: AnyCancellable?

    init(stack: CoreDataStack) {
        self.stack = stack
        let fetchRequest: NSFetchRequest = Track.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.created, ascending: true)]
        trackFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: stack.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        trackFetchController.delegate = self

        do {
            try trackFetchController.performFetch()
            tracks = trackFetchController.fetchedObjects ?? []
//            reload()
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }

//    public func reload() {
//        self.finishedTracks = tracks.filter({track in track.getState() == .finished})
//        self.startedTracks = tracks.filter({track in track.getState() == .started})
//        self.newTracks = tracks.filter({track in track.getState() == .notStarted})
//    }
}

extension TrackListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tracks = controller.fetchedObjects as? [Track] else {return}
        NSLog("Context has changed, reloading courses")
        self.tracks = tracks
//        reload()
    }
}
