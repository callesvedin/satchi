
import MapKit
import SwiftUI
import Combine

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @ObservedObject var mapModel: TrackMapModel
    
    //private var cancellable: AnyCancellable?
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
        var coordinates = mapModel.trackPath.map({$0.coordinate})
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        uiView.addOverlay(polyline)
        #if DEBUG
        print("Annotations:\(uiView.annotations.count)")
        print("Overlays:\(uiView.overlays.count)")
        #endif
    }
    

    
    
    func updateUIView2(_ uiView: MKMapView, context: Context) {
        if mapModel.region != nil {
            uiView.setRegion(
                mapModel.region!, animated: true
            )
        }
        
        
        if mapModel.state == .started && !startingPointAdded && !mapModel.annotations.isEmpty {
            uiView.addAnnotation(mapModel.annotations.first!)
        }
        
        
        if mapModel.state == .started, let newLocation = mapModel.trackPath.last, mapModel.trackPath.count > 1 {
            let oldLocation = mapModel.trackPath[mapModel.trackPath.count - 2]
            let oldCoordinates = oldLocation.coordinate
            let newCoordinates =  newLocation.coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            uiView.addOverlay(polyline)
         }
    }
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        let mapModel:TrackMapModel
        
        init(mapModel:TrackMapModel) {
            self.mapModel = mapModel
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5            
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
            
            
            switch annotation {
            case is StartAnnotation:
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: StartAnnotation.reuseIdentifier, for: annotation) as! MKPinAnnotationView
                
                return view
            default:
                return nil
            }

        }
                
    }
    
}
