/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 Extensions that add convenience methods to Core Data.
 */

import CloudKit
import CoreData
import os.log

extension NSPersistentStore {
    func contains(manageObject: NSManagedObject) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: manageObject.entity.name!)
        fetchRequest.predicate = NSPredicate(format: "self == %@", manageObject)
        fetchRequest.affectedStores = [self]

        if let context = manageObject.managedObjectContext,
           let result = try? context.count(for: fetchRequest), result > 0
        {
            return true
        }
        return false
    }

    func get(manageObject: NSManagedObject) -> Track? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: manageObject.entity.name!)
        fetchRequest.predicate = NSPredicate(format: "self == %@", manageObject)
        fetchRequest.affectedStores = [self]

        if let context = manageObject.managedObjectContext,
           let result = try? context.fetch(fetchRequest)
        {
            return result.first as? Track
        }
        return nil
    }
}

extension NSManagedObject {
    var persistentStore: NSPersistentStore? {
        let persistenceController = PersistenceController.shared
        if persistenceController.sharedPersistentStore.contains(manageObject: self) {
            return persistenceController.sharedPersistentStore
        } else if persistenceController.privatePersistentStore.contains(manageObject: self) {
            return persistenceController.privatePersistentStore
        }
        return nil
    }
}

extension NSManagedObjectContext {
    /**
     Contextual information for handling errors that occur when saving a managed object context.
     */
    enum ContextualInfoForSaving: String {
        case addTrack, deleteTrack, updateTrack
    }

    /**
     Save a context and handle the save error. This sample simply prints the error message. Real apps can
     implement comprehensive error handling based on the contextual information.
     */
    func save(with contextualInfo: ContextualInfoForSaving) {
        if hasChanges {
            do {
                try save()
            } catch {
                Logger.persistance.error("\(#function): Failed to save Core Data context for \(contextualInfo.rawValue): \(error)")
            }
        }
    }
}

/**
 A convenience method for creating background contexts that specify the app as their transaction author.
 */
extension NSPersistentCloudKitContainer {
    func newTaskContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.transactionAuthor = TransactionAuthor.app
        return context
    }

    /**
     Fetch and return shares in the persistent stores.
     */
    func fetchShares(in persistentStores: [NSPersistentStore]) throws -> [CKShare] {
        var results = [CKShare]()
        for persistentStore in persistentStores {
            do {
                let shares = try fetchShares(in: persistentStore)
                results += shares
            } catch {
                Logger.sharing.error("Failed to fetch shares in \(persistentStore).")
                throw error
            }
        }
        return results
    }
}
