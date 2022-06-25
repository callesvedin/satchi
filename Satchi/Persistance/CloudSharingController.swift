//
//  CloudSharingView.swift
//  (cloudkit-samples) Sharing
//

import Foundation
import SwiftUI
import UIKit
import CloudKit

/// This struct wraps a `UICloudSharingController` for use in SwiftUI.
struct CloudSharingView: UIViewControllerRepresentable {

    // MARK: - Properties

    @Environment(\.presentationMode) var presentationMode
    let container: CKContainer
    let share: CKShare

    // MARK: - UIViewControllerRepresentable

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let sharingController = UICloudSharingController(share: share, container: container)
        sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
        sharingController.delegate = context.coordinator
        sharingController.modalPresentationStyle = .formSheet
        return sharingController
    }

    func makeCoordinator() -> CloudSharingView.Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UICloudSharingControllerDelegate {
        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            debugPrint("Error saving share: \(error)")
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            "Sharing Example"
        }


        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            print("Share saved")
        }

        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            print("Stopped sharing track")
//            if !stack.isOwner(object: track) {
//                stack.delete(track)
//            }
        }

    }
}





//import CloudKit
//import SwiftUI
//import os.log
//
//struct CloudSharingView: UIViewControllerRepresentable {
//    let share: CKShare
//    let container: CKContainer
//    let track: Track
//
//
//    private static let logger = Logger(
//        subsystem: Bundle.main.bundleIdentifier!,
//        category: String(describing: CloudSharingView.self)
//    )
//
//    init(share:CKShare, container: CKContainer, track:Track) {
//        print("Initializing share view")
//        self.share = share
//        self.container = container
//        self.track = track
//    }
//
//    func makeCoordinator() -> CloudSharingCoordinator {
//        CloudSharingCoordinator(track: track)
//    }
//
//    func makeUIViewController(context: Context) -> UICloudSharingController {
//        // 1
//        share[CKShare.SystemFieldKey.title] = track.name
//        // 2
//        let controller = UICloudSharingController(share: share, container: container)
//        controller.modalPresentationStyle = .none
//        controller.delegate = context.coordinator
//
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
//    }
//}
//
//final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
//    private static let logger = Logger(
//        subsystem: Bundle.main.bundleIdentifier!,
//        category: String(describing: CloudSharingCoordinator.self)
//    )
//
//    let stack = CoreDataStack.shared
//    let track: Track
//    init(track: Track) {
//        self.track = track
//    }
//    func itemTitle(for csc: UICloudSharingController) -> String? {
//        return track.name
//    }
//
//    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
//        print("Failed to save share: \(error.localizedDescription)")
//    }
//
//    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
//        print("Share saved")
//    }
//
//    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
//        print("Stopped sharing track")
//        if !stack.isOwner(object: track) {
//            stack.delete(track)
//        }
//    }
//}
