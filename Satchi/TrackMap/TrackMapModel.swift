//
//  TrackMapModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit


struct TrackAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

enum RunningState {
    case notStarted, started, stopped, done
}

class TrackMapModel:NSObject, ObservableObject {
    private var locationManager = CLLocationManager()
    
    @Published public var currentLocation:CLLocation? {
        didSet {
            if currentLocation != nil {
                setRegion(center:currentLocation)
            }
        }
    }
    
    @Published var stateDone: Bool = false
    
    public var startPointAdded = false
    
    public var annotations:[MKAnnotation] = []
    
    @Published public var state = RunningState.notStarted {
        didSet {
            if state == .started {
                reset()
            }else if state == .stopped && currentLocation != nil {
                let annotation = StopAnnotation()
                annotation.coordinate = currentLocation!.coordinate
                annotation.title = "Stop"
                addAnnotation(annotation)
                stopTracking()
            }else if state == .done {
                stateDone = true
            }
        }
    }
    
    
    public var trackPath:[CLLocation] = [] {
        didSet {
            if !startPointAdded && !trackPath.isEmpty {
                let newStartingpoint = trackPath.first!
                startPointAdded = true
                let annotation = StartAnnotation()
                annotation.coordinate = newStartingpoint.coordinate
                annotation.title = "Start"
                addAnnotation(annotation)
            }
        }
    }
    
    
    @Published public var gotUserLocation = false
    
    public var region:MKCoordinateRegion?
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self
        setStartLocation()
    }
    
    private func setRegion(center:CLLocation?) {
        guard let center = center else {return}
        if region != nil {
            region!.center = CLLocationCoordinate2D(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude)
        }else{
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude),
                                             span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        }
    }
    
    public func addAnnotation(_ annotation:MKAnnotation){
        annotations.append(annotation)
    }
    
    private func reset() {
        stateDone = false
        startPointAdded = false
        annotations = []
        trackPath = []
    }
    
    public func setStartLocation() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    private func stopTracking() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
}

extension TrackMapModel:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if state == .started {
            trackPath.append(contentsOf: locations)            
        }
        
        currentLocation = manager.location
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization changed to: \(manager.authorizationStatus.rawValue)")
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            self.gotUserLocation = true
        default:
            self.gotUserLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed. \(error.localizedDescription)")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("Did pause location updates")
    }
    
}
