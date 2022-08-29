//
//  TrackListViewModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import Foundation
import Combine
import CoreData

@MainActor
class TrackListViewModel: NSObject, ObservableObject {
    private var tracks: [Track] = []

    private let trackFetchController: NSFetchedResultsController<Track>
    public var stack: CoreDataStack

    public func isEmpty() -> Bool {
        return tracks.isEmpty
    }

    @Published var finishedTracks: [Track] = []
    @Published var startedTracks: [Track] = []
    @Published var newTracks: [Track] = []

    private var cancellable: AnyCancellable?

    init(stack: CoreDataStack = CoreDataStack.shared) {
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
            reload()
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }

    public func reload() {
        self.finishedTracks = tracks.filter({track in track.getState() == .trailTracked})
        self.startedTracks = tracks.filter({track in track.getState() == .trailAdded})
        self.newTracks = tracks.filter({track in track.getState() == .notStarted})
        self.objectWillChange.send()
    }

}

extension TrackListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tracks = controller.fetchedObjects as? [Track] else {return}
        print("Context has changed, reloading courses")
        self.tracks = tracks
        reload()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        print("Did change content. Diff:\(diff)")
        guard let tracks = controller.fetchedObjects as? [Track] else {return}
        self.tracks = tracks
        reload()
    }
}
