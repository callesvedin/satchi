//
//  CoreDataStack.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-11.

import CoreData
import CloudKit
import UIKit
import os.log

let appTransactionAuthorName = "app"

@MainActor
final class CoreDataStack: ObservableObject {
    public static let shared = CoreDataStack()
    static let preview: CoreDataStack = {
        let stack = CoreDataStack(inMemory: true)

        createTestData(stack.context)

        stack.save()

        return stack
    }()

    var ckContainer: CKContainer {
        let storeDescription = persistentContainer.persistentStoreDescriptions.first
        guard let identifier = storeDescription?
            .cloudKitContainerOptions?.containerIdentifier else {
            fatalError("Unable to get container identifier")
        }
        return CKContainer(identifier: identifier)
    }


    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CoreDataStack.self)
    )

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
        if !inMemory &&  _sharedPersistentStore == nil {
            fatalError("Shared store is not set")
        }
        return _sharedPersistentStore
    }

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Satchi")
        guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("Unable to get persistentStoreDescription")
        }

        let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
        privateStoreDescription.url = inMemory ? URL(fileURLWithPath: "/dev/null") : storesURL?.appendingPathComponent("private.sqlite")

        if !inMemory {
            let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
            guard let sharedStoreDescription = privateStoreDescription
                .copy() as? NSPersistentStoreDescription else {
                fatalError(
                    "Copying the private store description returned an unexpected value."
                )
            }
            sharedStoreDescription.url = sharedStoreURL

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
        container.viewContext.transactionAuthor = appTransactionAuthorName

        container.viewContext.automaticallyMergesChangesFromParent = true
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("Failed to pin viewContext to the current generation: \(error)")
        }



        do {

            // Use the container to initialize the development schema.

            try container.initializeCloudKitSchema(options: [])

        } catch {

            // Handle any errors.

            print(error)

        }
        
        // Observe Core Data remote change notifications.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeRemoteChange(_:)),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: container.persistentStoreCoordinator)
        return container
    }()

    /**
     Track the last history token processed for a store, and write its value to file.

     The historyQueue reads the token when executing operations and updates it after processing is complete.
     */
    private var lastHistoryToken: NSPersistentHistoryToken? = nil {
        didSet {
            guard let token = lastHistoryToken,
                  let data = try? NSKeyedArchiver.archivedData( withRootObject: token, requiringSecureCoding: true) else { return }

            do {
                try data.write(to: tokenFile)
            } catch {
                print("###\(#function): Failed to write token data. Error = \(error)")
            }
        }
    }

    /**
     The file URL for persisting the persistent history token.
     */
    private lazy var tokenFile: URL = {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("CoreDataCloudKitDemo", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("###\(#function): Failed to create persistent container URL. Error = \(error)")
            }
        }
        return url.appendingPathComponent("token.data", isDirectory: false)
    }()

    /**
     An operation queue for handling history processing tasks: watching changes, deduplicating tags, and triggering UI updates if needed.
     */
    private lazy var historyQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()


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
                print("Could not save context \(error.localizedDescription)")
            }
        }
    }

    func delete(_ track: Track) {
        print("Deleting track")
        context.perform {
            self.context.delete(track)
            self.save()
        }
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
            print("Could not fetch objects. Error:\(error.localizedDescription)")}
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
                    print("Failed to fetch share: \(error.localizedDescription)")
                }
            }
        }
        print("Managed object \(objectID.debugDescription) is shared: \(isShared)")
        return isShared
    }

    func canEdit(object: NSManagedObject) -> Bool {
        return persistentContainer.canUpdateRecord(
            forManagedObjectWith: object.objectID
        )
    }

    func canDelete(object: NSManagedObject) -> Bool {
        return persistentContainer.canDeleteRecord(
            forManagedObjectWith: object.objectID
        )
    }

    func isOwner(object: NSManagedObject) -> Bool {
        guard isShared(object: object) else { return false }
        guard let share = try? persistentContainer.fetchShares(matching: [object.objectID])[object.objectID] else {
            print("Get ckshare error")
            return false
        }
        if let currentUser = share.currentUserParticipant, currentUser == share.owner {
            return true
        }
        return false
    }

    func getShare(_ track: Track) -> CKShare? {
        guard isShared(object: track) else { return nil }
        guard let shareDictionary = try? persistentContainer.fetchShares(matching: [track.objectID]),
              let share = shareDictionary[track.objectID] else {
            print("Failed to get share")
            return nil
        }
        share[CKShare.SystemFieldKey.title] = track.name
        print("Returning share from getShare(): \(share.debugDescription) \n Url:\(String(describing: share.url ?? nil))")
        return share
    }

}

// MARK: - Notifications

extension CoreDataStack {
    /**
     Handle remote store change notifications (.NSPersistentStoreRemoteChange).
     */
    @objc
    func storeRemoteChange(_ notification: Notification) {
        // Process persistent history to merge changes from other coordinators.
        historyQueue.addOperation {
            self.processPersistentHistory()
        }
    }
}

/**
 Custom notifications in this sample.
 */
extension Notification.Name {
    static let didFindRelevantTransactions = Notification.Name("didFindRelevantTransactions")
}

// MARK: - Persistent history processing

extension CoreDataStack {

    /**
     Process persistent history, posting any relevant transactions to the current view.
     */
    func processPersistentHistory() {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.performAndWait {

            // Fetch history received from outside the app since the last token
            let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
            historyFetchRequest.predicate = NSPredicate(format: "author != %@", appTransactionAuthorName)
            let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
            request.fetchRequest = historyFetchRequest

            let result = (try? taskContext.execute(request)) as? NSPersistentHistoryResult
            guard let transactions = result?.result as? [NSPersistentHistoryTransaction],
                  !transactions.isEmpty
            else { return }

            // Post transactions relevant to the current view.
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didFindRelevantTransactions, object: self, userInfo: ["transactions": transactions])
            }
            
            // Update the history token using the last transaction.
            lastHistoryToken = transactions.last!.token
        }
    }
}
// MARK: Create testdata for preview/test

extension CoreDataStack {
    private static func createTestData(_ context: NSManagedObjectContext) {

        let testImage = UIImage(named: "SVTTestImage")?.pngData()
        for number in 0..<2 {
            let newTrack = Track(context: context)
            newTrack.id = UUID()
            newTrack.name = "Trc \(number)"
            newTrack.length = Int32(number * 500)
            newTrack.created = Date(timeIntervalSinceNow: TimeInterval(-60*60*24+365))
            newTrack.difficulty = 4
            newTrack.image = testImage
            newTrack.laidPath = [
                CLLocation(latitude: 56.65418, longitude: 16.32639),
                CLLocation(latitude: 58.41190, longitude: 15.61221)
            ]
        }
        for number in 2..<6 {
            let newTrack = Track(context: context)
            newTrack.id = UUID()
            newTrack.name = "Trc \(number)"
            newTrack.length = Int32(number * 500)
            newTrack.timeToCreate = (35+Double(number))*60
            let createdTimeInterval = DateComponents(day: number)
            newTrack.created = Calendar.current.date(byAdding: createdTimeInterval, to: Date())
            let finishedTimeInterval = DateComponents(day: number+1)
            newTrack.started = Calendar.current.date(byAdding: finishedTimeInterval, to: Date())
            newTrack.timeToFinish = (35+Double(number))*60
            newTrack.difficulty = 5
            newTrack.image = testImage
            newTrack.laidPath = [
                CLLocation(latitude: 56.65418, longitude: 16.32639),
                CLLocation(latitude: 58.41190, longitude: 15.61221)
            ]
            newTrack.trackPath = [
                CLLocation(latitude: 56.65418, longitude: 16.32639),
                CLLocation(latitude: 58.20236, longitude: 15.99773)
            ]

        }

        let timeInterval = DateComponents(day: 2)

        let newTrack = Track(context: context)
        newTrack.id = UUID()
        newTrack.name = "Stensö"
        newTrack.length = 5000
        newTrack.created = Date()
        newTrack.difficulty = 4
        newTrack.started = Calendar.current.date(byAdding: timeInterval, to: Date())
        newTrack.timeToFinish = 68 * 60
        newTrack.image = testImage
        newTrack.laidPath = [
            CLLocation(latitude: 56.65418, longitude: 16.32639),
            CLLocation(latitude: 58.41190, longitude: 15.61221)
        ]
        newTrack.trackPath = [
            CLLocation(latitude: 56.65418, longitude: 16.32639),
            CLLocation(latitude: 58.20236, longitude: 15.99773)
        ]

        let newTrack2 = Track(context: context)
        newTrack2.id = UUID()
        newTrack2.name = "Udden"
        newTrack2.length = 5400
        newTrack2.created = Date()
        newTrack2.difficulty = 2
        newTrack2.started = Calendar.current.date(byAdding: timeInterval, to: Date())
        newTrack2.timeToFinish = 98*60
        newTrack2.image = testImage
        newTrack2.laidPath = [
            CLLocation(latitude: 56.65418, longitude: 16.32639),
            CLLocation(latitude: 58.41190, longitude: 15.61221)
        ]
        newTrack2.trackPath = [
            CLLocation(latitude: 56.65418, longitude: 16.32639),
            CLLocation(latitude: 58.20236, longitude: 15.99773)
        ]
    }
}
