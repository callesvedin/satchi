import MapKit
import SwiftUI
import Combine
import os.log


struct PreviewMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PreviewMapView.self)
    )

    private var laidPath: [CLLocation]?
    private var trackPath: [CLLocation]?

    init(laidPath: [CLLocation]?, trackPath: [CLLocation]?) {
        self.laidPath = laidPath
        self.trackPath = trackPath
    }


    func makeCoordinator() -> PreviewMapViewCoordinator {
        return PreviewMapViewCoordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let theView = MKMapView()
        theView.delegate = context.coordinator

        theView.showsUserLocation = false
        theView.mapType = .satellite
        theView.userTrackingMode = .none
        theView.showsUserLocation = false
        theView.isUserInteractionEnabled = false
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trailStart.getIdentifier())
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trailEnd.getIdentifier())
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trackingStart.getIdentifier())
        theView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PathAnnotationKind.trackingEnd .getIdentifier())

        return theView
    }


    private func addTrackStartAnnotation(in view: MKMapView) {
        guard getAnnotation(kind: .trackingStart, in: view) == nil else {return}
        if let location = trackPath?.first {
            let annotation = PathAnnotation(kind: .trackingStart)
            annotation.coordinate = location.coordinate
            annotation.title = AnnotationType.trackStart.rawValue
            view.addAnnotation(annotation)
            print("Track path start annotation added")
        }
    }

    private func addTrackStopAnnotation(in view: MKMapView) {
        guard getAnnotation(kind: .trackingEnd, in: view) == nil else {return}
        if let location = trackPath?.last {
            let annotation = PathAnnotation(kind: .trackingEnd)
            annotation.coordinate = location.coordinate
            annotation.title =  AnnotationType.trackStop.rawValue
            view.addAnnotation(annotation)
        }
        print("Track path stop annotation added")
    }

    private func addStartAnnotation(in view: MKMapView) {
        guard getAnnotation(kind: .trailStart, in: view) == nil else {return}
        if let location = laidPath?.first {
            let annotation = PathAnnotation(kind: .trailStart)
            annotation.coordinate = location.coordinate
            annotation.title =  AnnotationType.laidStart.rawValue
            view.addAnnotation(annotation)
            print("Lay path start annotation added")
        }
    }

    private func addStopAnnotation(in view: MKMapView) {
        guard getAnnotation(kind: .trailEnd, in: view) == nil else {return}
        if let location = laidPath?.last {
            let annotation = PathAnnotation(kind: .trailEnd)
            annotation.coordinate = location.coordinate
            annotation.title =  AnnotationType.laidStop.rawValue
            view.addAnnotation(annotation)            
            print("Lay path stop annotation added")
        }
    }

    private func removeStopAnnotation(in view:MKMapView) {
        if let annotation = getAnnotation(kind: .trailEnd, in: view)
        {
            view.removeAnnotation(annotation)
        }
    }

    private func removeStopTrackAnnotation(in view:MKMapView) {
        if let annotation = getAnnotation(kind: .trackingEnd, in: view)
        {
            view.removeAnnotation(annotation)
        }
    }

    private func getAnnotation(kind:PathAnnotationKind, in view:MKMapView) -> MKAnnotation? {
        return view.annotations.first(where: {annotation in
            guard let pathAnnotation = annotation as? PathAnnotation else {return false}
            return pathAnnotation.kind == kind
        })
    }


    private func upateAnnotation(_ type:AnnotationType, in view:MKMapView, to location:CLLocationCoordinate2D) {
        if let annotation = view.annotations.first(where: {annotation in annotation.title == type.rawValue}) as? PathAnnotation {
            annotation.coordinate = location
        }else{
            addAnnotation(to:view, withType: type, at:location)
        }
    }

    private func addAnnotation(to view:MKMapView, withType type:AnnotationType, at location:CLLocationCoordinate2D) {
        let annotation:PathAnnotation
        switch type {
        case .trackStart:
            annotation = PathAnnotation(kind: .trackingStart)
            annotation.title = AnnotationType.trackStart.rawValue
        case .trackStop:
            annotation = PathAnnotation(kind: .trackingEnd)
            annotation.title = AnnotationType.trackStop.rawValue
        case .laidStart:
            annotation = PathAnnotation(kind: .trailStart)
            annotation.title = AnnotationType.laidStart.rawValue
        case .laidStop:
            annotation = PathAnnotation(kind: .trailEnd)
            annotation.title = AnnotationType.laidStop.rawValue
        case .dummy:
            annotation = PathAnnotation(kind: .dummy)        
        }
        annotation.coordinate = location
        view.addAnnotation(annotation)
    }


    private func removeAnnotation(from view:MKMapView, type:AnnotationType){
        guard let annotation = view.annotations.first(where: {annotation in annotation.title==type.rawValue}) else {return}
        view.removeAnnotation(annotation)
    }

    private func updateAnnotations(mapView: MKMapView) {
        if let location = laidPath?.first {
            upateAnnotation( AnnotationType.laidStart, in:mapView, to: location.coordinate)
        }else{
            removeAnnotation(from:mapView, type:AnnotationType.laidStart)
        }
        
        if let location = laidPath?.last {
            upateAnnotation( AnnotationType.laidStop, in:mapView, to: location.coordinate)
        }else{
            removeAnnotation(from:mapView, type:AnnotationType.laidStop)
        }

        if let location = trackPath?.first {
            upateAnnotation( AnnotationType.trackStart, in:mapView, to: location.coordinate)
        }else{
            removeAnnotation(from:mapView, type:AnnotationType.trackStart)
        }

        if let location = trackPath?.last {
            upateAnnotation( AnnotationType.trackStop, in:mapView, to: location.coordinate)
        }else{
            removeAnnotation(from:mapView, type:AnnotationType.trackStop)
        }

    }

    func removeAnnotations(mapView: MKMapView) {
        let annotations = mapView.annotations.filter {
            $0 !== mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {

        updateAnnotations(mapView: mapView)

        if let path = laidPath, path.count > 0 {
            var laidCoordinates = path.map({$0.coordinate})
            let polyline = TrackPolyline(coordinates: &laidCoordinates, count: laidCoordinates.count)
            polyline.color = .systemGreen
            mapView.addOverlay(polyline)
        }

        if let path = trackPath, path.count > 0 {
            var trackCoordinates = path.map({$0.coordinate})
            let polyline = TrackPolyline(coordinates: &trackCoordinates, count: trackCoordinates.count)
            polyline.color = .systemRed
            mapView.addOverlay(polyline)
        }

        if let firstOverlay = mapView.overlays.first {
            let rect = mapView.overlays.reduce(firstOverlay.boundingMapRect, {$0.union($1.boundingMapRect)})
            mapView.setVisibleMapRect(rect,
                                      edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0),
                                      animated: true)
        }

    }

    class PreviewMapViewCoordinator: NSObject, MKMapViewDelegate {

        private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: PreviewMapViewCoordinator.self)
        )


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
    }
}
