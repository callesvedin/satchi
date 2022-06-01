import MapKit
import SwiftUI
import Combine
import os.log

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView

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
        theView.userTrackingMode = .follow

        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "LayStart")
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "LayStop")
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "TrackStart")
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "TrackStop")

        return theView
    }

    func removeOverlays(mapView: MKMapView) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
    }

    func removeAnnotations(mapView: MKMapView) {
        let annotations = mapView.annotations.filter {
            $0 !== mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        print("Map span\(mapView.region.span.longitudeDelta)")
        if mapModel.followUser {
            mapView.userTrackingMode = .follow
        } else {
            mapView.userTrackingMode = .none
        }

        if mapModel.annotations.isEmpty {
            removeAnnotations(mapView: mapView)
        } else {
            mapView.addAnnotations(mapModel.annotations)
        }

//        removeOverlays(mapView: uiView)

        if mapModel.laidPath.count > 0 {
            var laidCoordinates = mapModel.laidPath.map({$0.coordinate})
            let polyline = TrackPolyline(coordinates: &laidCoordinates, count: laidCoordinates.count)
            polyline.color = .systemGreen
            mapView.addOverlay(polyline)
        }

        if mapModel.trackPath.count > 0 {
            var trackCoordinates = mapModel.trackPath.map({$0.coordinate})
            let polyline = TrackPolyline(coordinates: &trackCoordinates, count: trackCoordinates.count)
            polyline.color = .systemRed
            mapView.addOverlay(polyline)
        }

        if (mapModel.state == .finishedTrack || mapModel.previewing), let first = mapView.overlays.first {
            let rect = mapView.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
            mapView.setVisibleMapRect(rect,
                                      edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0),
                                      animated: true)
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

//        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//
//        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if let over = overlay as? TrackPolyline {
                renderer.strokeColor = over.color
                renderer.lineWidth = 2
//                renderer.lineDashPhase = 2
//                renderer.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 5)]
            }
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? PathAnnotation {
                if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.reuseIdentifier,
                                                                    for: annotation)as? MKMarkerAnnotationView {
                    view.glyphImage = UIImage(systemName: annotation.imageIdentifier)
                    view.markerTintColor = annotation.color
                    return view
                } else {
                    print("dequeued view not known")
                }
            }
            return nil
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            print("Region will change")
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            print("Region did change")
        }

        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            print("did finish loading map")
        }
        func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
            print("Will start loading map")
        }
        func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
            print("Will start rendering map")
        }
        func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
            print("Finished rendering map")
        }
        func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
            print("Will start locating user")
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
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
