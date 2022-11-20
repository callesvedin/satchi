
import CloudKit
import SwiftUI
import os.log

struct CloudSharingView: UIViewControllerRepresentable {
    private let share: CKShare
    private let container: CKContainer
    private let title: String

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CloudSharingView.self)
    )

    init(container: CKContainer, share:CKShare, title:String) {
        print("Initializing share view")
        self.container = container
        self.title = title
        self.share = share
    }

    func makeCoordinator() -> CloudSharingCoordinator {
        CloudSharingCoordinator(title: self.title)
    }

    func makeUIViewController(context: Context) -> UICloudSharingController {
        share[CKShare.SystemFieldKey.title] = self.title
        let controller = UICloudSharingController(share: share, container: container)
        controller.modalPresentationStyle = .none
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
    let title : String
    init(title: String) {
        self.title = title

    }
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return title
    }

    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Failed to save share: \(error.localizedDescription)")
    }

    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("Share saved")
    }

    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("Stopped sharing track")
    }
}
