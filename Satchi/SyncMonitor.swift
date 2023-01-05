import Combine
import CoreData
import CloudKit

@available(iOS 14.0, *)
class SyncMonitor {
    /// Where we store Combine cancellables for publishers we're listening to, e.g. NSPersistentCloudKitContainer's notifications.
    fileprivate var disposables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .sink(receiveValue: { notification in
                if let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event {

                    let isFinished = event.endDate != nil
                    switch (event.type, isFinished) {
                    case (.import, false):
                        print("Started downloading records")
                    case (.import, true):
                        print("Finished downloading records")
                        case (.export, false):
                        print("Started uploading records")
                        case (.export, true):
                        print("Finished uploading records")
                    case (.setup, false):
                        print("Started setup")
                    case (.setup, true):
                        print("Finished setup")
                    case (_, _):
                        print("Unknown case. EventType: \(event.type) IsFinished:\(isFinished)")
                    }


                    if let error = event.error as? CKError {
                        self.handleError(error)
                    }else if let error = event.error as? NSError {
                        // nsError.domain is most likely `NSCocoaErrorDomain`

                        switch error.code {
                        case 133000: print("NSError: Data integrity error")
                        case 133020: print("NSError: Merge error")
                        case 134301: print("NSError: 134301 ???")
                        case 134400: print("NSError: Not logged in to iCloud")
                        case 134404: print("NSError: Constraint conflict")
                        case 134405: print("NSError: iCloud account changed")
                        case 134407: print("NSError: 134407 ???")
                        case 134419: print("NSError: Too much work to do")
                        case 134421: print("NSError: Unhandled exception")
                        default:
                            print("NSError: Unknown exception")
                        }
                    }else if let error = event.error {
                        print("Unknown error \(error.localizedDescription)")
                    }
                }
            })
            .store(in: &disposables)
    }

    private func handleError(_ error:CKError) {
        switch error.code {
        case .quotaExceeded:
            print("CKError quotaExceeded")
        case .internalError:
            print("CKError internalError")
        case .partialFailure:
            print("CKError partialFailure")
        case .networkUnavailable:
            print("CKError networkUnavailable")
        case .networkFailure:
            print("CKError networkFailure")
        case .badContainer:
            print("CKError badContainer")
        case .serviceUnavailable:
            print("CKError serviceUnavailable")
        case .requestRateLimited:
            print("CKError requestRateLimited")
        case .missingEntitlement:
            print("CKError missingEntitlement")
        case .notAuthenticated:
            print("CKError notAuthenticated")
        case .permissionFailure:
            print("CKError permissionFailure")
        case .unknownItem:
            print("CKError unknownItem")
        case .invalidArguments:
            print("CKError invalidArguments")
        case .resultsTruncated:
            print("CKError resultsTruncated")
        case .serverRecordChanged:
            print("CKError serverRecordChanged")
        case .serverRejectedRequest:
            print("CKError serverRejectedRequest")
        case .assetFileNotFound:
            print("CKError assetFileNotFound")
        case .assetFileModified:
            print("CKError assetFileModified")
        case .incompatibleVersion:
            print("CKError incompatibleVersion")
        case .constraintViolation:
            print("CKError constraintViolation")
        case .operationCancelled:
            print("CKError operationCancelled")
        case .changeTokenExpired:
            print("CKError changeTokenExpired")
        case .batchRequestFailed:
            print("CKError batchRequestFailed")
        case .zoneBusy:
            print("CKError zoneBusy")
        case .badDatabase:
            print("CKError badDatabase")
        case .zoneNotFound:
            print("CKError zoneNotFound")
        case .limitExceeded:
            print("CKError limitExceeded")
        case .userDeletedZone:
            print("CKError userDeletedZone")
        case .tooManyParticipants:
            print("CKError tooManyParticipants")
        case .alreadyShared:
            print("CKError alreadyShared")
        case .referenceViolation:
            print("CKError referenceViolation")
        case .managedAccountRestricted:
            print("CKError managedAccountRestricted")
        case .participantMayNeedVerification:
            print("CKError participantMayNeedVerification")
        case .serverResponseLost:
            print("CKError serverResponseLost")
        case .assetNotAvailable:
            print("CKError assetNotAvailable")
        case .accountTemporarilyUnavailable:
            print("CKError accountTemporarilyUnavailable")
        @unknown default:
            print("CKError UNKNOWN")
        }

    }

}
