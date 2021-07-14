
import MapKit
import SwiftUI
import Combine

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @ObservedObject var mapModel: TrackMapModel
    
    private var line: MKPolyline?
    private var mapView : MKMapView
    @State private var startingPointAdded = false
    
    init(mapModel:TrackMapModel) {
        self.mapModel = mapModel
        self.mapView = MKMapView()
    }
        
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(mapModel: mapModel)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true
        mapView.mapType = .satellite
        mapView.userTrackingMode = .followWithHeading

        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: StartAnnotation.reuseIdentifier)
        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: StopAnnotation.reuseIdentifier)
        return mapView
    }
    
    func removeOverlays(mapView:MKMapView) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
    }

    func removeAnnotations(mapView:MKMapView) {
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
        }else {
            uiView.addAnnotations(mapModel.annotations)
        }
        
        removeOverlays(mapView: uiView)
        
        if mapModel.laidPath.count > 0 {
            var laidCoordinates = mapModel.laidPath.map({$0.coordinate})
            let polyline = TrackPolyline(coordinates: &laidCoordinates, count: laidCoordinates.count)
            polyline.color = .systemBlue
            uiView.addOverlay(polyline)
        }
        
        if mapModel.trackPath.count > 0 {
            var trackCoordinates = mapModel.trackPath.map({$0.coordinate})
            let polyline = TrackPolyline(coordinates: &trackCoordinates, count: trackCoordinates.count)
            polyline.color = .systemRed
            uiView.addOverlay(polyline)
        }
        
        #if DEBUG
        print("Annotations:\(uiView.annotations.count)")
        print("Overlays:\(uiView.overlays.count)")
        #endif
    }
    
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        let mapModel:TrackMapModel
        
        init(mapModel:TrackMapModel) {
            self.mapModel = mapModel
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if let over = overlay as? TrackPolyline {
                renderer.strokeColor = over.color
                renderer.lineWidth = 5
            }
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                        
            if let ann = annotation as? StartAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: StartAnnotation.reuseIdentifier, for: ann) as! MKPinAnnotationView
                view.pinTintColor = StartAnnotation.color
                return view
            }
            
            if let ann = annotation as? StopAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: StopAnnotation.reuseIdentifier, for: ann) as! MKPinAnnotationView
                view.pinTintColor = StopAnnotation.color
                return view
            }
            
            return nil
        }
                
    }
    
}

class TrackPolyline:MKPolyline {
    var color:UIColor?
}
