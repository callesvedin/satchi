//
//  CoreDataStack.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-11.
//  From a copy of https://www.raywenderlich.com/29934862-sharing-core-data-with-cloudkit-in-swiftui
//
import CoreData
import CloudKit

final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    static let preview: CoreDataStack = {
        let stack = CoreDataStack(inMemory: true)

        createTestData(stack.context)

        stack.save()

        return stack
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var privatePersistentStore: NSPersistentStore {
        guard let privateStore = _privatePersistentStore else {
            fatalError("Private store is not set")
        }
        return privateStore
    }

    var sharedPersistentStore: NSPersistentStore? {
//        guard let sharedStore = _sharedPersistentStore else {
//            fatalError("Shared store is not set")
//        }
//        return sharedStore
        return _sharedPersistentStore
    }

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Satchi")
        guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("Unable to get persistentStoreDescription")
        }
        let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
        privateStoreDescription.url = inMemory ? URL(fileURLWithPath: "/dev/null") : storesURL?.appendingPathComponent("private.sqlite")

        // TODO: 1
        if !inMemory {
            let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
            guard let sharedStoreDescription = privateStoreDescription
                .copy() as? NSPersistentStoreDescription else {
                fatalError(
                    "Copying the private store description returned an unexpected value."
                )
            }
            sharedStoreDescription.url = inMemory ? URL(fileURLWithPath: "/dev/null") : sharedStoreURL

            guard let containerIdentifier = privateStoreDescription
                .cloudKitContainerOptions?.containerIdentifier else {
                fatalError("Unable to get containerIdentifier")
            }
            let sharedStoreOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: containerIdentifier
            )
            sharedStoreOptions.databaseScope = .shared
            sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions

            container.persistentStoreDescriptions.append(sharedStoreDescription)
        }
        container.loadPersistentStores { loadedStoreDescription, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error)")
            } else if let cloudKitContainerOptions = loadedStoreDescription
                .cloudKitContainerOptions {
                guard let loadedStoreDescritionURL = loadedStoreDescription.url else {
                    return
                }
                if cloudKitContainerOptions.databaseScope == .private {
                    let privateStore = container.persistentStoreCoordinator
                        .persistentStore(for: loadedStoreDescritionURL)
                    self._privatePersistentStore = privateStore
                } else if cloudKitContainerOptions.databaseScope == .shared {
                    let sharedStore = container.persistentStoreCoordinator
                        .persistentStore(for: loadedStoreDescritionURL)
                    self._sharedPersistentStore = sharedStore
                }
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var ckContainer: CKContainer {
        let storeDescription = persistentContainer.persistentStoreDescriptions.first
        guard let identifier = storeDescription?
            .cloudKitContainerOptions?.containerIdentifier else {
            fatalError("Unable to get container identifier")
        }
        return CKContainer(identifier: identifier)
    }

    private static func createTestData(_ context: NSManagedObjectContext) {
        let trackNames = ["Track 1", "Track 3", "Track 4"]
        for trackName in trackNames {
            let newTrack = Track(context: context)
            newTrack.id = UUID()

            newTrack.started = Date()
            newTrack.timeToFinish = 3600 * 2
            newTrack.laidPath = [
                CLLocation(latitude: 56.65418, longitude: 16.32639),
                CLLocation(latitude: 58.41190, longitude: 15.61221)
            ]
            newTrack.trackPath = [
                CLLocation(latitude: 56.65418, longitude: 16.32639),
                CLLocation(latitude: 58.20236, longitude: 15.99773)
            ]
            newTrack.name = trackName
            newTrack.length = 12312
            newTrack.comments = "\(trackName) comments"
            newTrack.created = Date()
            newTrack.difficulty = Int16.random(in: 1...5)
        }

    }

    private var inMemory = false
    private var _privatePersistentStore: NSPersistentStore?
    private var _sharedPersistentStore: NSPersistentStore?
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }
}

// MARK: Save or delete from Core Data
extension CoreDataStack {
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("ViewContext save error: \(error)")
            }
        }
    }

    func delete(_ track: Track) {
        context.perform {
            self.context.delete(track)
            self.save()
        }
    }

    func createTrack() -> Track {
        print("Creating new track")
        let newTrack = Track(context: context)
        newTrack.created = Date()
        newTrack.id = UUID()
        return newTrack
    }

    func getTracks() -> [Track] {
        let fetchRequest: NSFetchRequest = Track.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Track.created, ascending: true)]
        let trackFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        do {
            try trackFetchController.performFetch()
            return trackFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
        return []
    }
}

extension CoreDataStack {

    func isShared(object: NSManagedObject) -> Bool {
        isShared(objectID: object.objectID)
    }

    private func isShared(objectID: NSManagedObjectID) -> Bool {
        var isShared = false
        if let persistentStore = objectID.persistentStore {
            if persistentStore == sharedPersistentStore {
                isShared = true
            } else {
                let container = persistentContainer
                do {
                    let shares = try container.fetchShares(matching: [objectID])
                    if shares.first != nil {
                        isShared = true
                    }
                } catch {
                    print("Failed to fetch share for \(objectID): \(error)")
                }
            }
        }
        return isShared
    }

    func getShare(_ track: Track) -> CKShare? {
        guard isShared(object: track) else { return nil }
        guard let shareDictionary = try? persistentContainer.fetchShares(matching: [track.objectID]),
              let share = shareDictionary[track.objectID] else {
            print("Unable to get CKShare")
            return nil
        }
        share[CKShare.SystemFieldKey.title] = track.name
        return share
    }

}
