//
//  TrackStorage.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import Foundation
import Combine
import CoreData


class TrackStorage:NSObject, ObservableObject {
    var tracks = CurrentValueSubject<[Track], Never>([])
    private let trackFetchController : NSFetchedResultsController<Track>
    
    static let shared:TrackStorage = TrackStorage()
    static let preview:TrackStorage = TrackStorage(persistanceController: PersistenceController.preview)
    
    let persistanceController:PersistenceController
    
    private init(persistanceController:PersistenceController = PersistenceController.shared) {
        self.persistanceController = persistanceController
        let fetchRequest:NSFetchRequest = Track.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.created, ascending: true)]
        trackFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest , managedObjectContext: persistanceController.container.viewContext, sectionNameKeyPath: nil, cacheName: nil
        )
        
        super.init()
        
        trackFetchController.delegate = self
        
        do {
            try trackFetchController.performFetch()
            tracks.value = trackFetchController.fetchedObjects ?? []
        }catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func create(name: String, created: Date?, finished:Date?) -> Track {
        print("Creating new track")
        let newTrack = Track(context: persistanceController.container.viewContext)
        newTrack.name = name
        newTrack.created = created
        newTrack.finished = finished
        newTrack.id = UUID()
        
        do {
            try persistanceController.container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return newTrack
    }
    
    func update(withId id: UUID, name: String, created:Date?, finished:Date?) {
//        persistanceController.container.viewContext.performFetch(id)
    }
    
    func delete(tracks:IndexSet) {
        tracks.map{self.tracks.value[$0]}.forEach {
            persistanceController.container.viewContext.delete($0)
        }        
        
        do {
            try persistanceController.container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

    }
}

extension TrackStorage:NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller:NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tracks = controller.fetchedObjects as? [Track] else {return}
        NSLog("Context has changed, reloading courses")
        self.tracks.value = tracks
        
    }
}

