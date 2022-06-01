import CloudKit
import SwiftUI
import os.log

struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    let track: Track

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CloudSharingView.self)
    )

    func makeCoordinator() -> CloudSharingCoordinator {
        CloudSharingCoordinator(track: track)
    }

    func makeUIViewController(context: Context) -> UICloudSharingController {
        // 1
        share[CKShare.SystemFieldKey.title] = track.name
        // 2
        let controller = UICloudSharingController(share: share, container: container)
        controller.modalPresentationStyle = .formSheet
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
    }
}

final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CloudSharingCoordinator.self)
    )

    let stack = CoreDataStack.shared
    let track: Track
    init(track: Track) {
        self.track = track
    }

    func itemTitle(for sharingController: UICloudSharingController) -> String? {
        track.name
    }

    func cloudSharingController(_ sharingController: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Failed to save share: \(error.localizedDescription)")
    }

    func cloudSharingControllerDidSaveShare(_ sharingController: UICloudSharingController) {
        print("Share saved")
    }

    func cloudSharingControllerDidStopSharing(_ sharingController: UICloudSharingController) {
        print("Did stop sharing")
    }
}
