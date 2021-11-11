import MapKit
import SwiftUI
import Combine

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView

    @ObservedObject var mapModel: TrackMapModel

    init(mapModel: TrackMapModel) {
        self.mapModel = mapModel
    }

    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(mapModel: mapModel)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        mapView.showsUserLocation = true
        mapView.mapType = .satellite
        mapView.userTrackingMode = .followWithHeading

        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "LayStart")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "LayStop")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "TrackStart")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "TrackStop")

        return mapView
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

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if mapModel.region != nil {
            uiView.setRegion(
                mapModel.region!, animated: true
            )
        }

        if mapModel.annotations.isEmpty {
            removeAnnotations(mapView: uiView)
        } else {
            uiView.addAnnotations(mapModel.annotations)
        }

        removeOverlays(mapView: uiView)

        if mapModel.laidPath.count > 0 {
            var laidCoordinates = mapModel.laidPath.map({$0.coordinate})
            let polyline = TrackPolyline(coordinates: &laidCoordinates, count: laidCoordinates.count)
            polyline.color = .systemGreen
            uiView.addOverlay(polyline)
        }

        if mapModel.trackPath.count > 0 {
            var trackCoordinates = mapModel.trackPath.map({$0.coordinate})
            let polyline = TrackPolyline(coordinates: &trackCoordinates, count: trackCoordinates.count)
            polyline.color = .systemRed
            uiView.addOverlay(polyline)
        }

        if (mapModel.state == .finishedTrack || mapModel.previewing), let first = uiView.overlays.first {
            let rect = uiView.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
            uiView.setVisibleMapRect(rect,
                                      edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0),
                                      animated: true)
        }

    }

    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        let mapModel: TrackMapModel

        init(mapModel: TrackMapModel) {
            self.mapModel = mapModel
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if let over = overlay as? TrackPolyline {
                renderer.strokeColor = over.color
                renderer.lineWidth = 5
                renderer.lineDashPhase = 2
                renderer.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 5)]
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
                    print("dequeued view not a MKMarkerAnnotationView")
                }
            }
            return nil
        }
    }
}

class TrackPolyline: MKPolyline {
    var color: UIColor?
}
