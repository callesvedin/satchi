/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An extension that wraps the related methods for managing photos.
*/

import Foundation
import CoreData

// MARK: - Convenient methods for managing photos.
//
extension PersistenceController {
    func addTrack(name: String, context: NSManagedObjectContext) {
        context.perform {
            let track = Track(context: context)
            track.id = UUID()
            track.name = name

            context.save(with: .addTrack)
        }
    }
    
    func delete(track: Track) {
        if let context = track.managedObjectContext {
            context.perform {
                context.delete(track)
                context.save(with: .deleteTrack)
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
