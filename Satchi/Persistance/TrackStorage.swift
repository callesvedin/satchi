//
//  TrackStorage.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import Foundation
import Combine
import CoreData

class TrackStorage: NSObject, ObservableObject {
    var tracks = CurrentValueSubject<[Track], Never>([])
    private let trackFetchController: NSFetchedResultsController<Track>

    static let shared: TrackStorage = TrackStorage()
    static let preview: TrackStorage = TrackStorage(persistanceController: PersistenceController.preview)

    let persistanceController: PersistenceController

    private init(persistanceController: PersistenceController = PersistenceController.shared) {
        self.persistanceController = persistanceController
        let fetchRequest: NSFetchRequest = Track.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.created, ascending: true)]
        trackFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistanceController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        trackFetchController.delegate = self

        do {
            try trackFetchController.performFetch()
            tracks.value = trackFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }

    func create() -> Track {
        print("Creating new track")
        let newTrack = Track(context: persistanceController.container.viewContext)
        //        newTrack.name = name
        newTrack.created = Date()
        //        newTrack.timeToCreate = timeToCreate
        //        newTrack.length = Int32(length)
        newTrack.id = UUID()
        //        newTrack.laidPath = laidPath

        do {
            try persistanceController.container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return newTrack
    }

    func update(with trackModel: TrackModel) {
        do {
            let track = try getTrack(trackModel.uuid)
            track.difficulty = Int16(trackModel.difficulty)
            track.started = trackModel.started
            track.laidPath = trackModel.laidPath
            track.trackPath = trackModel.trackPath
            if trackModel.length != nil {
                track.length = Int32(trackModel.length!)
            }
            track.name = trackModel.name
            if trackModel.timeToCreate != nil {
                track.timeToCreate = trackModel.timeToCreate!
            }
            if trackModel.timeToFinish != nil {
                track.timeToFinish = trackModel.timeToFinish!
            }
            if trackModel.comments != nil {
                track.comments = trackModel.comments!
            }
            track.started = trackModel.started
            track.image = trackModel.image?.pngData()
            try persistanceController.container.viewContext.save()

        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }

    }

    private func getTrack(_ uuid: UUID?) throws -> Track {
        if uuid == nil {
            return TrackStorage.shared.create()
        } else {
            let trackRequest: NSFetchRequest<Track> = Track.fetchRequest()
            let query = NSPredicate(format: "%K == %@", "id", uuid! as CVarArg)
            trackRequest.predicate = query

            // Perform the fetch with the predicate
            do {
                let foundEntities: [Track] = try persistanceController.container.viewContext.fetch(trackRequest)

                return foundEntities.first!
            } catch {
                let fetchError = error as NSError
                debugPrint(fetchError)
                throw error
            }
        }
    }

    func delete(track: Track) {
        persistanceController.container.viewContext.delete(track)

        do {
            try persistanceController.container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

    }

    func delete(tracks: IndexSet) {
        tracks.map {self.tracks.value[$0]}.forEach {
            persistanceController.container.viewContext.delete($0)
        }

        do {
            try persistanceController.container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

    }
}

extension TrackStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tracks = controller.fetchedObjects as? [Track] else {return}
        NSLog("Context has changed, reloading courses")
        self.tracks.value = tracks

    }
}
