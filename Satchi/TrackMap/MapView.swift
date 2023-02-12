import Combine
import MapKit
import os.log
import SwiftUI

enum AnnotationType: String {
    case trackStart, trackStop, laidStart, laidStop, dummy
    func localized() -> String {
        let key = String.LocalizationValue(stringLiteral: rawValue)
        return String(localized: key)
    }
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView

    @ObservedObject var mapModel: TrackMapModel
    @State var firstView = true

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
        theView.userTrackingMode = .follow
        theView.layoutMargins.top = 100.0 // This is for the maps compass that shows up when rotating the view
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trailStart.getIdentifier())
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trailEnd.getIdentifier())
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trackingStart.getIdentifier())
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trackingEnd.getIdentifier())
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.dummy.getIdentifier())
        theView.tintColor = UIColor.systemBlue

        return theView
    }

    private func getAnnotation(kind: PathAnnotationKind, in view: MKMapView) -> MKAnnotation? {
        return view.annotations.first(where: { annotation in
            guard let pathAnnotation = annotation as? PathAnnotation else { return false }
            return pathAnnotation.kind == kind
        })
    }

    private func upateAnnotation(_ type: AnnotationType, in view: MKMapView, to location: CLLocationCoordinate2D) {
        if let annotation = view.annotations.first(where: { annotation in annotation.title == type.rawValue }) as? PathAnnotation {
            annotation.coordinate = location
        } else {
            addAnnotation(to: view, withType: type, at: location)
        }
    }

    private func addAnnotation(to view: MKMapView, withType type: AnnotationType, at location: CLLocationCoordinate2D) {
        let annotation: PathAnnotation
        switch type {
        case .trackStart:
            annotation = PathAnnotation(kind: .trackingStart)
            annotation.title = type.localized()
        case .trackStop:
            annotation = PathAnnotation(kind: .trackingEnd)
            annotation.title = type.localized()
        case .laidStart:
            annotation = PathAnnotation(kind: .trailStart)
            annotation.title = type.localized()
        case .laidStop:
            annotation = PathAnnotation(kind: .trailEnd)
            annotation.title = type.localized()
        case .dummy:
            annotation = PathAnnotation(kind: .dummy)
        }
        annotation.coordinate = location
        view.addAnnotation(annotation)
    }

    private func removeAnnotation(from view: MKMapView, type: AnnotationType) {
        guard let annotation = view.annotations.first(where: { annotation in annotation.title == type.rawValue }) else { return }
        view.removeAnnotation(annotation)
    }

    private func updateAnnotations(mapView: MKMapView) {
        if let location = mapModel.pathStartLocation {
            upateAnnotation(AnnotationType.laidStart, in: mapView, to: location)
        } else {
            removeAnnotation(from: mapView, type: AnnotationType.laidStart)
        }

        if let location = mapModel.pathEndLocation {
            upateAnnotation(AnnotationType.laidStop, in: mapView, to: location)
        } else {
            removeAnnotation(from: mapView, type: AnnotationType.laidStop)
        }

        if let location = mapModel.trackStartLocation {
            upateAnnotation(AnnotationType.trackStart, in: mapView, to: location)
        } else {
            removeAnnotation(from: mapView, type: AnnotationType.trackStart)
        }

        if let location = mapModel.trackEndLocation {
            upateAnnotation(AnnotationType.trackStop, in: mapView, to: location)
        } else {
            removeAnnotation(from: mapView, type: AnnotationType.trackStop)
        }

        if !mapModel.dummies.isEmpty {
            for location in mapModel.dummies {
                addAnnotation(to: mapView, withType: AnnotationType.dummy, at: location)
            }
        }
    }

    func removeAnnotations(mapView: MKMapView) {
        let annotations = mapView.annotations.filter {
            $0 !== mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if mapModel.followUser {
            mapView.userTrackingMode = .follow
        } else {
            mapView.userTrackingMode = .none
        }

        updateAnnotations(mapView: mapView)

        if mapModel.laidPath.count > 0 {
            var laidCoordinates = mapModel.laidPath.map { $0.coordinate }
            let polyline = TrackPolyline(coordinates: &laidCoordinates, count: laidCoordinates.count)
            polyline.color = .systemGreen
            mapView.addOverlay(polyline)
        }

        if mapModel.trackPath.count > 0 {
            var trackCoordinates = mapModel.trackPath.map { $0.coordinate }
            let polyline = TrackPolyline(coordinates: &trackCoordinates, count: trackCoordinates.count)
            polyline.color = .systemRed
            mapView.addOverlay(polyline)
        }

        if firstView && mapModel.stateMachine.state == .viewing, let first = mapView.overlays.first {
            let rect = mapView.overlays.reduce(first.boundingMapRect) { $0.union($1.boundingMapRect) }
            mapView.showsUserLocation = true
            mapView.setVisibleMapRect(rect,
                                      edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0),
                                      animated: true)
            firstView = false
        } else if mapModel.stateMachine.state != .viewing {
            mapView.showsUserLocation = true
        }
    }

    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        let mapModel: TrackMapModel

        private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: MapViewCoordinator.self)
        )

        init(mapModel: TrackMapModel) {
            self.mapModel = mapModel
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if let over = overlay as? TrackPolyline {
                renderer.strokeColor = over.color
                renderer.lineWidth = 2
            }
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? PathAnnotation {
                if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.reuseIdentifier,
                                                                    for: annotation) as? MKMarkerAnnotationView
                {
                    view.glyphImage = UIImage(systemName: annotation.imageIdentifier)
                    view.markerTintColor = annotation.color
                    return view
                } else {
                    print("dequeued view not known")
                }
            }
            return nil
        }
    }
}

class TrackPolyline: MKPolyline {
    var color: UIColor?
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
