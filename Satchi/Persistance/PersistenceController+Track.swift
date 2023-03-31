/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 An extension that wraps the related methods for managing photos.
 */

import CoreData
import Foundation

// MARK: - Convenient methods for managing photos.

//
extension PersistenceController {
    func addTrack(name: String, context: NSManagedObjectContext) -> Track? {
        var track: Track?
        context.performAndWait {
            track = Track(context: context, name: name, id: UUID())
            context.save(with: .addTrack)
        }
        return track
    }

    func delete(track: Track) {
        if let context = track.managedObjectContext {
            context.perform {
                context.delete(track)
                context.save(with: .deleteTrack)
            }
        }
    }

    func updateTrack(track: Track) {
        if let context = track.managedObjectContext {
            context.perform {
                context.save(with: .updateTrack)
            }
        }
    }

    func trackTransactions(from notification: Notification) -> [NSPersistentHistoryTransaction] {
        var results = [NSPersistentHistoryTransaction]()
        if let transactions = notification.userInfo?[UserInfoKey.transactions] as? [NSPersistentHistoryTransaction] {
            let trackEntityName = Track.entity().name
            for transaction in transactions where transaction.changes != nil {
                for change in transaction.changes! where change.changedObjectID.entity.name == trackEntityName {
                    results.append(transaction)
                    break // Jump to the next transaction.
                }
            }
        }
        return results
    }

    func mergeTransactions(_ transactions: [NSPersistentHistoryTransaction], to context: NSManagedObjectContext) {
        context.perform {
            for transaction in transactions {
                context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
            }
        }
    }
}
