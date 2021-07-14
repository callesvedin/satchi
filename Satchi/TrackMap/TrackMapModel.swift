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
    public var tracking = false
    public var annotations:[MKAnnotation] = []
    public var region:MKCoordinateRegion?
    @Published var stateDone: Bool = false
    @Published var timer:TrackTimer = TrackTimer()
    @Published var distance:CLLocationDistance = 0
    @Published public var gotUserLocation = false
    
    @Published public var currentLocation:CLLocation? {
        didSet {
            if currentLocation != nil {
                setRegion(center:currentLocation)
            }
        }
    }

    
    @Published public var state = RunningState.notStarted {
        didSet {
            print("Running state changed:\(state)")
            if state == .started && currentLocation != nil {
                reset()
                addStartAnnotation(at: currentLocation!)
                timer.start()
            }else if state == .stopped && currentLocation != nil {
                addStopAnnotation(at: currentLocation!)
                timer.stop()
                stopTracking()
            }else if state == .done {
                stateDone = true
            }
        }
    }
    
    
    public var laidPath:[CLLocation] = [] {
        didSet {
            if laidPath.count >= 2 {
                distance = getLength(from: laidPath)
            }
        }
    }
  

    public var trackPath:[CLLocation] = [] {
        didSet {
            if trackPath.count >= 2 {
                distance = getLength(from: trackPath)
            }
        }
    }
    
    
    init(laidPath:[CLLocation]? = nil) {
        super.init()
        if let path = laidPath, !path.isEmpty{
            self.laidPath = path
            self.addStartAnnotation(at: path.first!)
            self.addStopAnnotation(at: path.last!)
            self.tracking = true
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self
        setStartLocation()
    }
    
    private func addStartAnnotation(at location:CLLocation) {
        let annotation = StartAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "Start"
        addAnnotation(annotation)
    }
    
    private func addStopAnnotation(at location:CLLocation) {
        let annotation = StopAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "Stop"
        addAnnotation(annotation)
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
    private func getLength(from locations : [CLLocation]) -> Double {
        var length:Double = 0
        for (i,location) in locations.enumerated() {
            if i == 0 {continue}
            length = length + location.distance(from: locations[i-1])
        }
        return length
    }

    
    public func addAnnotation(_ annotation:MKAnnotation){
        annotations.append(annotation)
    }
    
    private func reset() {
        stateDone = false
        annotations = []
        laidPath = []
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
            if tracking {
                trackPath.append(contentsOf: locations)
            }else{
                laidPath.append(contentsOf: locations)
            }
        }
        
        currentLocation = manager.location
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {        
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
