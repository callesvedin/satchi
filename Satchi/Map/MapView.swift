import Combine
import MapKit
import os.log
import SwiftUI

enum AnnotationType: String {
    case trackStart, trackStop, laidStart, laidStop, dummy
    func localized() -> String {
        let typeKey = String.LocalizationValue(stringLiteral: rawValue)
        return String(localized: typeKey)
    }
}

struct MapView: UIViewRepresentable {
    @ObservedObject var mapModel: TrackMapModel

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MapView.self)
    )

    init(mapModel: TrackMapModel) {
        self.mapModel = mapModel
    }

    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(mapModel: mapModel)
    }

    func makeUIView(context: Context) -> MKMapView {
        let theView = MKMapView()
        theView.delegate = context.coordinator

        theView.showsUserLocation = true
        theView.mapType = .satellite
//        theView.userTrackingMode = .follow
        theView.layoutMargins.top = 100.0 // This is for the maps compass that shows up when rotating the view
        theView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trailStart.getIdentifier())
        theView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trailEnd.getIdentifier())
        theView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trackingStart.getIdentifier())
        theView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trackingEnd.getIdentifier())
        theView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: PathAnnotationKind.dummy.getIdentifier())
        theView.tintColor = UIColor.systemBlue

        return theView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let start = Date.now
        context.coordinator.update(mapView)
        mapView.delegate = context.coordinator

        let endDate = Date()
        let consumedTime = endDate.timeIntervalSince(start)
        Logger.mapView.trace("MapView updateUIView. Time spent \(consumedTime). Overlays:\(mapView.overlays.count)")
    }
}

class TrackPolyline: MKPolyline, Identifiable {
    var color: UIColor?
    let id = UUID()
    convenience init(coordinates: [CLLocationCoordinate2D], count: Int, color: UIColor) {
        self.init(coordinates: coordinates, count: count)
        self.color = color
    }
}

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 500
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        setRegion(coordinateRegion, animated: true)
    }
}
