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

enum RunningState {
    case layPathNotStarted, layPathStarted, layPathStopped, layPathDone,
         trackingNotStarted, trackingStarted, trackingStopped,
         trackingDone, finishedTrack, allDone, cancelled
}

class TrackMapModel: NSObject, ObservableObject {
    private var locationManager: CLLocationManager
//    public var image: UIImage?
    @Published var followUser: Bool = true
    public var annotations: [MKAnnotation] = []
    public var regionIsSet: Bool = false
    public var trackingStarted: Date?
    public var previousState: RunningState = .allDone
    public var previewing = false
    @Published var timer: TrackTimer = TrackTimer()
    @Published var distance: CLLocationDistance = 0
    @Published public var gotUserLocation = false

    @Published public var currentLocation: CLLocation?

    @Published public var state = RunningState.layPathNotStarted {
        didSet {
            print("Running state changed:\(state)")
            if state == .layPathStarted && currentLocation != nil {
                reset()
                addStartAnnotation(at: currentLocation!)
                timer.start()
            } else if state == .trackingStarted && currentLocation != nil {
                trackingStarted = Date()
                addTrackStartAnnotation(at: currentLocation!)
                timer.start()
            } else if (state == .layPathStopped || state == .trackingStopped) && currentLocation != nil {
                if state == .trackingStopped {
                    addTrackStopAnnotation(at: currentLocation!)
                } else {
                    addStopAnnotation(at: currentLocation!)
                }
//                createImage()
                timer.stop()
                stopTracking()
            }
        }
    }

    public var laidPath: [CLLocation] = [] {
        didSet {
            if laidPath.count >= 2 {
                distance = getLength(from: laidPath)
            }
        }
    }

    public var trackPath: [CLLocation] = [] {
        didSet {
            if trackPath.count >= 2 {
                distance = getLength(from: trackPath)
            }
        }
    }

//    private func createImage() {
//        if region != nil {
//            let snapShotOptions: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
//            var snapShot: MKMapSnapshotter!
//
//            snapShotOptions.region = region!
//            //            _snapShotOptions.size = mapView.frame.size
//            snapShotOptions.scale = UIScreen.main.scale
//
//            // Set MKMapSnapShotOptions to MKMapSnapShotter.
//            snapShot = MKMapSnapshotter(options: snapShotOptions)
//
//            snapShot.start { [self] (snapshot, error) -> Void in
//                if error == nil {
//                    image = snapshot!.image
//                } else {
//                    print("error")
//                }
//            }
//        }
//
//    }

    override init() {
        self.locationManager = CLLocationManager()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        super.init()
    }

    public func start() {
        if !laidPath.isEmpty && !trackPath.isEmpty {
            self.addStartAnnotation(at: laidPath.first!)
            self.addStopAnnotation(at: laidPath.last!)
            self.addTrackStartAnnotation(at: trackPath.first!)
            self.addTrackStopAnnotation(at: trackPath.last!)
            self.followUser = false
            self.state = .finishedTrack
        } else if !laidPath.isEmpty {
            self.addStartAnnotation(at: laidPath.first!)
            self.addStopAnnotation(at: laidPath.last!)
            self.followUser = true
            self.state = .trackingNotStarted
        } else {
            self.followUser = true
            self.state = .layPathNotStarted
        }

        if !previewing && (self.state == .trackingNotStarted || self.state == .layPathNotStarted) {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
//            startTracking()
        }
        self.previousState = self.state
    }

    private func addTrackStartAnnotation(at location: CLLocation) {
        let annotation = PathAnnotation(kind: .trackPathStart)
        annotation.coordinate = location.coordinate
        annotation.title = "Start"

        addAnnotation(annotation)
    }

    private func addTrackStopAnnotation(at location: CLLocation) {
        let annotation = PathAnnotation(kind: .trackPathStop)
        annotation.coordinate = location.coordinate
        annotation.title = "Stop"

        addAnnotation(annotation)
    }

    private func addStartAnnotation(at location: CLLocation) {
        let annotation = PathAnnotation(kind: .layPathStart)
        annotation.coordinate = location.coordinate
        annotation.title = "Track Start"
        addAnnotation(annotation)
    }

    private func addStopAnnotation(at location: CLLocation) {
        let annotation = PathAnnotation(kind: .layPathStop)
        annotation.coordinate = location.coordinate
        annotation.title = "Track Stop"
        addAnnotation(annotation)
    }

    private func getLength(from locations: [CLLocation]) -> Double {
        var length: Double = 0
        for (count, location) in locations.enumerated() {
            if count == 0 {continue}
            length +=  location.distance(from: locations[count-1])
        }
        return length
    }

    public func addAnnotation(_ annotation: MKAnnotation) {
        annotations.append(annotation)
    }

    private func reset() {
        annotations = []
        laidPath = []
        trackPath = []
    }

    public func startTracking() {
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    private func stopTracking() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
}

extension TrackMapModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if state == .layPathStarted {
            laidPath.append(contentsOf: locations)
        } else if state == .trackingStarted {
            trackPath.append(contentsOf: locations)
        }
        print("GPS location Accuracy \(locations.first?.horizontalAccuracy ?? 0)")
        currentLocation = manager.location
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("locationManagerDidChangeAuthorization:manager. Status:\(manager.authorizationStatus)")
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Status not determined")
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startTracking()
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
