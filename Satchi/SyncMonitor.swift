import CloudKit
import Combine
import CoreData
import os.log

@available(iOS 14.0, *)
class SyncMonitor {
    /// Where we store Combine cancellables for publishers we're listening to, e.g. NSPersistentCloudKitContainer's notifications.
    fileprivate var disposables = Set<AnyCancellable>()

    fileprivate func logErrorCode(_ error: NSError) {
        // The nsError.domain is most likely `NSCocoaErrorDomain`
        switch error.code {
        case 133000: Logger.persistance.warning("NSError: Data integrity error")
        case 133020: Logger.persistance.warning("NSError: Merge error")
        case 134301: Logger.persistance.warning("NSError: 134301 ???")
        case 134400: Logger.persistance.warning("NSError: Not logged in to iCloud")
        case 134404: Logger.persistance.warning("NSError: Constraint conflict")
        case 134405: Logger.persistance.warning("NSError: iCloud account changed")
        case 134407: Logger.persistance.warning("NSError: 134407 ???")
        case 134419: Logger.persistance.warning("NSError: Too much work to do")
        case 134421: Logger.persistance.warning("NSError: Unhandled exception")
        default:
            Logger.persistance.warning("NSError: Unknown exception \(error.localizedDescription)")
        }
    }

    init() {
        NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .sink(receiveValue: { notification in
                if let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event
                {
                    let isFinished = event.endDate != nil
                    switch (event.type, isFinished) {
                    case (.import, false): break
//                        Logger.persistance.trace("Started downloading records")
                    case (.import, true): break
//                        Logger.persistance.trace("Finished downloading records")
                    case (.export, false): break
//                        Logger.persistance.trace("Started uploading records")
                    case (.export, true): break
//                        Logger.persistance.trace("Finished uploading records")
                    case (.setup, false):
                        Logger.persistance.trace("Started setup")
                    case (.setup, true):
                        Logger.persistance.trace("Finished setup")
                    case (_, _):
                        Logger.persistance.trace("Unknown case. EventType: \(String(describing: event.type)) IsFinished:\(isFinished)")
                    }

                    if let error = event.error as? CKError {
                        self.handleError(error)
                    } else if let error = event.error as? NSError {
                        self.logErrorCode(error)
                    } else if let error = event.error {
                        Logger.persistance.trace("Unknown error \(error.localizedDescription)")
                    }
                }
            })
            .store(in: &disposables)
    }

    private func handleError(_ error: CKError) {
        switch error.code {
        case .quotaExceeded:
            Logger.persistance.trace("CKError quotaExceeded")
        case .internalError:
            Logger.persistance.trace("CKError internalError")
        case .partialFailure:
            Logger.persistance.trace("CKError partialFailure")
        case .networkUnavailable:
            Logger.persistance.trace("CKError networkUnavailable")
        case .networkFailure:
            Logger.persistance.trace("CKError networkFailure")
        case .badContainer:
            Logger.persistance.trace("CKError badContainer")
        case .serviceUnavailable:
            Logger.persistance.trace("CKError serviceUnavailable")
        case .requestRateLimited:
            Logger.persistance.trace("CKError requestRateLimited")
        case .missingEntitlement:
            Logger.persistance.trace("CKError missingEntitlement")
        case .notAuthenticated:
            Logger.persistance.trace("CKError notAuthenticated")
        case .permissionFailure:
            Logger.persistance.trace("CKError permissionFailure")
        case .unknownItem:
            Logger.persistance.trace("CKError unknownItem")
        case .invalidArguments:
            Logger.persistance.trace("CKError invalidArguments")
        case .resultsTruncated:
            Logger.persistance.trace("CKError resultsTruncated")
        case .serverRecordChanged:
            Logger.persistance.trace("CKError serverRecordChanged")
        case .serverRejectedRequest:
            Logger.persistance.trace("CKError serverRejectedRequest")
        case .assetFileNotFound:
            Logger.persistance.trace("CKError assetFileNotFound")
        case .assetFileModified:
            Logger.persistance.trace("CKError assetFileModified")
        case .incompatibleVersion:
            Logger.persistance.trace("CKError incompatibleVersion")
        case .constraintViolation:
            Logger.persistance.trace("CKError constraintViolation")
        case .operationCancelled:
            Logger.persistance.trace("CKError operationCancelled")
        case .changeTokenExpired:
            Logger.persistance.trace("CKError changeTokenExpired")
        case .batchRequestFailed:
            Logger.persistance.trace("CKError batchRequestFailed")
        case .zoneBusy:
            Logger.persistance.trace("CKError zoneBusy")
        case .badDatabase:
            Logger.persistance.trace("CKError badDatabase")
        case .zoneNotFound:
            Logger.persistance.trace("CKError zoneNotFound")
        case .limitExceeded:
            Logger.persistance.trace("CKError limitExceeded")
        case .userDeletedZone:
            Logger.persistance.trace("CKError userDeletedZone")
        case .tooManyParticipants:
            Logger.persistance.trace("CKError tooManyParticipants")
        case .alreadyShared:
            Logger.persistance.trace("CKError alreadyShared")
        case .referenceViolation:
            Logger.persistance.trace("CKError referenceViolation")
        case .managedAccountRestricted:
            Logger.persistance.trace("CKError managedAccountRestricted")
        case .participantMayNeedVerification:
            Logger.persistance.trace("CKError participantMayNeedVerification")
        case .serverResponseLost:
            Logger.persistance.trace("CKError serverResponseLost")
        case .assetNotAvailable:
            Logger.persistance.trace("CKError assetNotAvailable")
        case .accountTemporarilyUnavailable:
            Logger.persistance.trace("CKError accountTemporarilyUnavailable")
        @unknown default:
            Logger.persistance.trace("CKError UNKNOWN")
        }
    }
}
