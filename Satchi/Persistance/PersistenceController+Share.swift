/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 Extensions that wrap the related methods for sharing.
 */

import CloudKit
import CoreData
import Foundation
import os.log
import UIKit

enum ShareError: Error {
    case noPersistentStore(share: CKShare)
}

extension ShareError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .noPersistentStore(share):
            return "No persistent store found for share \(share.title)"
        }
    }
}

#if os(iOS) // UICloudSharingController is only available in iOS.

// MARK: - Convenient methods for managing sharing.

//
extension PersistenceController {
    func presentCloudSharingController(track: Track) {
        Logger.sharing.debug("presentCloudSharingController called with track: \(track)")

        sharedTrack = track
        /**
         Grab the share if the track is already shared.
         */
        if let shareSet = try? persistentContainer.fetchShares(matching: [track.objectID]),
           let (_, share) = shareSet.first
        {
            Logger.sharing.debug("Track is already shared")
            trackShare = share
        }

        let sharingController: UICloudSharingController
        if trackShare == nil {
            sharingController = newSharingController(unsharedTrack: track, persistenceController: self)
        } else {
            sharingController = UICloudSharingController(share: trackShare!, container: cloudKitContainer)
        }
        sharingController.delegate = self
        /**
         Setting the presentation style to .formSheet so there's no need to specify sourceView, sourceItem, or sourceRect.
         */
        if let viewController = rootViewController {
            sharingController.modalPresentationStyle = .formSheet
            sharingController.view.backgroundColor = .white
            viewController.present(sharingController, animated: true)
        }
    }

    func presentCloudSharingController(share: CKShare) {
        Logger.sharing.debug("\(#function):")

        let sharingController = UICloudSharingController(share: share, container: cloudKitContainer)
        sharingController.delegate = self
        /**
         Setting the presentation style to .formSheet so there's no need to specify sourceView, sourceItem, or sourceRect.
         */
        if let viewController = rootViewController {
            sharingController.modalPresentationStyle = .formSheet
            viewController.present(sharingController, animated: true)
        }
    }

    private func newSharingController(unsharedTrack: Track, persistenceController: PersistenceController) -> UICloudSharingController {
        Logger.sharing.debug("\(#function):")
        return UICloudSharingController { (_, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            /**
             The app doesn't specify a share intentionally, so Core Data creates a new share (zone).
             CloudKit has a limit on how many zones a database can have, so this app provides an option for users to use an existing share.

             If the share's publicPermission is CKShareParticipantPermissionNone, only private participants can accept the share.
             Private participants mean the participants an app adds to a share by calling CKShare.addParticipant.
             If the share is more permissive, and is, therefore, a public share, anyone with the shareURL can accept it,
             or self-add themselves to it.
             The default value of publicPermission is CKShare.ParticipantPermission.none.
             */
            self.persistentContainer.share([unsharedTrack], to: nil) { _, share, container, error in
                if let share = share {
                    self.configure(share: share, with: unsharedTrack)
                }
                completion(share, container, error)
            }
        }
    }

    private var rootViewController: UIViewController? {
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive,
               let sceneDeleate = (scene as? UIWindowScene)?.delegate as? UIWindowSceneDelegate,
               let window = sceneDeleate.window
            {
                return window?.rootViewController
            }
        }
        Logger.sharing.warning("\(#function): Failed to retrieve the window's root view controller.")
        return nil
    }
}

extension PersistenceController: UICloudSharingControllerDelegate {
    /**
     CloudKit triggers the delegate method in two cases:
     - An owner stops sharing a share.
     - A participant removes themselves from a share by tapping the Remove Me button in UICloudSharingController.

     After stopping the sharing,  purge the zone or just wait for an import to update the local store.
     This sample chooses to purge the zone to avoid stale UI. That triggers a "zone not found" error because UICloudSharingController
     deletes the zone, but the error doesn't really matter in this context.

     Purging the zone has a caveat:
     - When sharing an object from the owner side, Core Data moves the object to the shared zone.
     - When calling purgeObjectsAndRecordsInZone, Core Data removes all the objects and records in the zone.
     To keep the objects, deep copy the object graph you want to keep and make sure no object in the new graph is associated with any share.

     The purge API posts an NSPersistentStoreRemoteChange notification after finishing its job, so observe the notification to update
     the UI, if necessary.
     */
    func cloudSharingControllerDidStopSharing(_ cloudSharingController: UICloudSharingController) {
        if trackShare != nil {
            trackShare = nil // This is not how we like to do it... But why is this called more than once?
            if let share = cloudSharingController.share {
                if let currentUserParticipant = share.currentUserParticipant {
                    let role = string(for: currentUserParticipant.role)
                    Logger.sharing
                        .debug("""
                           \(#function): Called with share \(share.title). \
                           (User role:\(role) Owner:\(share.owner) Participants:\(share.participants)
                        """)
                } else {
                    Logger.sharing
                        .debug("""
                            \(#function): Called with no currentUserParticipant. \
                            Share \(share.title). Owner: \(share.owner) Participants:\(share.participants)
                        """)
                }
                Logger.sharing.debug("\nBefore task\n")
                Task {
                    do {
                        Logger.sharing.debug("\nBefore purge\n")

                        let id = try await purgeObjectsAndRecords(with: share)
                        Logger.sharing.trace("\nreturned \(id) from purge\n")
                        _ = sharedTrack?.clone(with: persistentContainer.viewContext)
                        Logger.sharing.debug("\nAfter clone\n")

                        try persistentContainer.viewContext.save()
                        Logger.sharing.debug("\nAfter save\n")

                    } catch let ShareError.noPersistentStore(errShare) {
                        Logger.sharing.error("\(#function): No persistetent store found for share: \(errShare).")
                    } catch {
                        Logger.sharing.error("Could not clone unshared object.\(error)")
                    }
                    Logger.sharing.debug("\nEnd of task\n")
                }
                Logger.sharing.debug("\nAfter task\n")
            }
        }
    }

    func cloudSharingControllerDidSaveShare(_ cloudSharingController: UICloudSharingController) {
        if let share = cloudSharingController.share, let persistentStore = share.persistentStore {
            Logger.sharing.debug("\(#function): With share title:\(share.title)")
            persistentContainer.persistUpdatedShare(share, in: persistentStore) { _, error in
                if let error = error {
                    Logger.sharing.error("\(#function): Failed to persist updated share: \(error)")
                }
            }
        }
    }

    func cloudSharingController(_ cloudSharingController: UICloudSharingController, failedToSaveShareWithError error: Error) {
        Logger.sharing.error("\(#function): Failed to save a share: \(error)")
    }

    func itemTitle(for cloudSharingController: UICloudSharingController) -> String? {
        Logger.sharing.debug("\(#function):")

        if sharedTrack == nil {
            Logger.sharing.warning("\(#function): Shared track is nil")
        }
        return cloudSharingController.share?.title ?? (sharedTrack?.name ?? "A cool track")
    }
}
#endif
extension PersistenceController {
    func string(for permission: CKShare.ParticipantPermission) -> String {
        switch permission {
        case .unknown:
            return "Unknown"
        case .none:
            return "None"
        case .readOnly:
            return "Read-Only"
        case .readWrite:
            return "Read-Write"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.Permission")
        }
    }

    func string(for role: CKShare.ParticipantRole) -> String {
        switch role {
        case .owner:
            return "Owner"
        case .privateUser:
            return "Private User"
        case .publicUser:
            return "Public User"
        case .unknown:
            return "Unknown"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.Role")
        }
    }

    func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
        switch acceptanceStatus {
        case .accepted:
            return "Accepted"
        case .removed:
            return "Removed"
        case .pending:
            return "Invited"
        case .unknown:
            return "Unknown"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
        }
    }
}

#if os(watchOS)
extension PersistenceController {
    func presentCloudSharingController(share: CKShare) {
        Logger.sharing.error("\(#function): Cloud sharing controller is unavailable on watchOS.")
    }
}
#endif

extension PersistenceController {
    func shareObject(_ unsharedObject: NSManagedObject,
                     to existingShare: CKShare?,
                     completionHandler: ((_ share: CKShare?, _ error: Error?) -> Void)? = nil)
    {
        Logger.sharing.debug("\(#function):")

        persistentContainer.share([unsharedObject], to: existingShare) { _, share, _, error in
            guard error == nil, let share = share else {
                Logger.sharing.error("\(#function): Failed to share an object: \(error!))")
                completionHandler?(share, error)
                return
            }
            /**
             Deduplicate tags, if necessary, because adding a track to an existing share moves the whole object graph to the associated
             record zone, which can lead to duplicated tags.
             */
            if existingShare == nil {
                self.configure(share: share)
            }
            /**
             Synchronize the changes on the share to the private persistent store.
             */
            self.persistentContainer.persistUpdatedShare(share, in: self.privatePersistentStore) { share, error in
                if let error = error {
                    Logger.sharing.error("\(#function): Failed to persist updated share: \(error)")
                }
                completionHandler?(share, error)
            }
        }
    }

    /**
     Delete the Core Data objects and the records in the CloudKit record zone associated with the share.
     */
    func purgeObjectsAndRecords(with share: CKShare, in persistentStore: NSPersistentStore? = nil) async throws -> CKRecordZone.ID {
        guard let store = (persistentStore ?? share.persistentStore) else {
            Logger.sharing.error("\(#function): Failed to find the persistent store for share. \(share))")
            throw ShareError.noPersistentStore(share: share)
        }

        let recordId = try await persistentContainer.purgeObjectsAndRecordsInZone(with: share.recordID.zoneID, in: store)
        return recordId
    }

    func existingShare(track: Track) -> CKShare? {
        if let shareSet = try? persistentContainer.fetchShares(matching: [track.objectID]),
           let (_, share) = shareSet.first
        {
            return share
        }
        return nil
    }

    func share(with title: String) -> CKShare? {
        let stores = [privatePersistentStore, sharedPersistentStore]
        let shares = try? persistentContainer.fetchShares(in: stores)
        let share = shares?.first(where: { $0.title == title })
        return share
    }

    func shareTitles() -> [String] {
        let stores = [privatePersistentStore, sharedPersistentStore]
        let shares = try? persistentContainer.fetchShares(in: stores)
        return shares?.map { $0.title } ?? []
    }

    private func configure(share: CKShare, with track: Track? = nil) {
        Logger.sharing.debug("\(#function):")

        share[CKShare.SystemFieldKey.title] = track?.name ?? "A cool track"
    }
}

extension PersistenceController {
    func addParticipant(emailAddress: String,
                        permission: CKShare.ParticipantPermission = .readWrite,
                        share: CKShare,
                        completionHandler: ((_ share: CKShare?, _ error: Error?) -> Void)?)
    {
        Logger.sharing.debug("\(#function):")

        /**
         Use the email address to look up the participant from the private store. Return if the participant doesn't exist.
         Use privatePersistentStore directly because only the owner may add participants to a share.
         */
        let lookupInfo = CKUserIdentity.LookupInfo(emailAddress: emailAddress)
        let persistentStore = privatePersistentStore // share.persistentStore!
        Logger.sharing.debug("\(#function): Called with email = \(emailAddress)")
        persistentContainer.fetchParticipants(matching: [lookupInfo], into: persistentStore) { results, error in
            guard let participants = results, let participant = participants.first, error == nil else {
                completionHandler?(share, error)
                return
            }

            participant.permission = permission
            participant.role = .privateUser
            share.addParticipant(participant)

            self.persistentContainer.persistUpdatedShare(share, in: persistentStore) { share, error in
                if let error = error {
                    Logger.sharing.error("\(#function): Failed to persist updated share: \(error)")
                }
                completionHandler?(share, error)
            }
        }
    }

    func deleteParticipant(_ participants: [CKShare.Participant],
                           share: CKShare,
                           completionHandler: ((_ share: CKShare?, _ error: Error?) -> Void)?)
    {
        Logger.sharing.debug("\(#function): Called")

        for participant in participants {
            share.removeParticipant(participant)
        }
        /**
         Use privatePersistentStore directly because only the owner may delete participants to a share.
         */
        persistentContainer.persistUpdatedShare(share, in: privatePersistentStore) { share, error in
            if let error = error {
                Logger.sharing.error("\(#function): Failed to persist updated share: \(error)")
            }
            completionHandler?(share, error)
        }
    }
}

extension CKShare.ParticipantAcceptanceStatus {
    var stringValue: String {
        return ["Unknown", "Pending", "Accepted", "Removed"][rawValue]
    }
}

extension CKShare {
    var title: String {
        Logger.sharing.debug("\(#function): Share.title")

        guard let date = creationDate else {
            return "Share-\(UUID().uuidString)"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return "Share-" + formatter.string(from: date)
    }

    var persistentStore: NSPersistentStore? {
        let persistentContainer = PersistenceController.shared.persistentContainer
        let privatePersistentStore = PersistenceController.shared.privatePersistentStore
        if let shares = try? persistentContainer.fetchShares(in: privatePersistentStore) {
            let zoneIDs = shares.map { $0.recordID.zoneID }
            if zoneIDs.contains(recordID.zoneID) {
                return privatePersistentStore
            }
        }
        let sharedPersistentStore = PersistenceController.shared.sharedPersistentStore
        if let shares = try? persistentContainer.fetchShares(in: sharedPersistentStore) {
            let zoneIDs = shares.map { $0.recordID.zoneID }
            if zoneIDs.contains(recordID.zoneID) {
                return sharedPersistentStore
            }
        }
        return nil
    }
}
