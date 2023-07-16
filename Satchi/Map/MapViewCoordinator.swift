//
//  MapViewCoordinator.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2023-03-06.
//

import Foundation
import MapKit
import os.log
import SwiftUI

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    var mapModel: TrackMapModel
    var firstView = true
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
                Logger.mapView.error("dequeued view not known")
            }
        }
        return nil
    }

    func update(_ mapView: MKMapView) {
        if mapModel.followUser {
            mapView.userTrackingMode = .follow
        } else {
            mapView.userTrackingMode = .none
        }

        updateAnnotations(mapView: mapView)
        mapView.removeOverlays(mapView.overlays)
        if !mapModel.laidPath.isEmpty {
            let laidCoordinates = mapModel.laidPath.map { $0.coordinate }
            let polyline = TrackPolyline(coordinates: laidCoordinates, count: laidCoordinates.count, color: .systemGreen)

            mapView.addOverlay(polyline, level: .aboveLabels)
        }

        if !mapModel.trackPath.isEmpty {
            let trackCoordinates = mapModel.trackPath.map { $0.coordinate }
            let polyline = TrackPolyline(coordinates: trackCoordinates, count: trackCoordinates.count, color: .systemRed)
            mapView.addOverlay(polyline, level: .aboveLabels)
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
        if !mapModel.isTracking {
            mapView.showsUserLocation = false
            mapView.userTrackingMode = .none            
        }
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

//        if !mapModel.dummies.isEmpty {
//            for location in mapModel.dummies {
//                addAnnotation(to: mapView, withType: AnnotationType.dummy, at: location)
//            }
//        }
    }

    func removeAnnotations(mapView: MKMapView) {
        let annotations = mapView.annotations.filter {
            $0 !== mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
    }
}
