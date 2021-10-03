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
         trackingNotStarted, trackingStarted, trackingStopped, trackingDone, finishedTrack, allDone
}

class TrackMapModel: NSObject, ObservableObject {
    private var locationManager = CLLocationManager()
    public var image: UIImage?
    public var annotations: [MKAnnotation] = []
    public var region: MKCoordinateRegion?
    public var trackingStarted: Date?
    @Published var timer: TrackTimer = TrackTimer()
    @Published var distance: CLLocationDistance = 0
    @Published public var gotUserLocation = false

    @Published public var currentLocation: CLLocation? {
        didSet {
            if currentLocation != nil {
                setRegion(center: currentLocation)
            }
        }
    }

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
                createImage()
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

    public override init() {
        super.init()
        self.state = .layPathNotStarted
    }

    init(laidPath: [CLLocation]? = nil, trackedPath: [CLLocation]? = nil) {
        super.init()

        if let lPath = laidPath, !lPath.isEmpty, let tPath = trackedPath, !tPath.isEmpty {
            self.laidPath = lPath
            self.trackPath = tPath
            self.addStartAnnotation(at: lPath.first!)
            self.addStopAnnotation(at: lPath.last!)
            self.addTrackStartAnnotation(at: tPath.first!)
            self.addTrackStopAnnotation(at: tPath.last!)
            self.state = .finishedTrack
        } else if let lPath = laidPath, !lPath.isEmpty {
            self.laidPath = lPath
            self.addStartAnnotation(at: lPath.first!)
            self.addStopAnnotation(at: lPath.last!)
            self.state = .trackingNotStarted
        } else {
            self.state = .layPathNotStarted
        }

        if self.state == .trackingNotStarted || self.state == .layPathNotStarted {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            setStartLocation()
        }
    }

    private func createImage() {
        if region != nil {
            let snapShotOptions: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
            var snapShot: MKMapSnapshotter!

            snapShotOptions.region = region!
            //            _snapShotOptions.size = mapView.frame.size
            snapShotOptions.scale = UIScreen.main.scale

            // Set MKMapSnapShotOptions to MKMapSnapShotter.
            snapShot = MKMapSnapshotter(options: snapShotOptions)

            snapShot.start { [self] (snapshot, error) -> Void in
                if error == nil {
                    image = snapshot!.image
                } else {
                    print("error")
                }
            }
        }

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

    private func setRegion(center: CLLocation?, spanDelta: Double = 0.001) {
        guard let center = center else {return}
        if region != nil {
            region!.center = CLLocationCoordinate2D(
                latitude: center.coordinate.latitude, longitude: center.coordinate.longitude)
        } else {
            self.region = MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(latitude: center.coordinate.latitude,
                                                                       longitude: center.coordinate.longitude),
                                             span: MKCoordinateSpan(latitudeDelta: spanDelta,
                                                                    longitudeDelta: spanDelta)
            )
        }
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

extension TrackMapModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if state == .layPathStarted {
            laidPath.append(contentsOf: locations)
        } else if state == .trackingStarted {
            trackPath.append(contentsOf: locations)
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
