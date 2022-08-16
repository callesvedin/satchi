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
import os.log
import SwiftState

enum OldRunningState: String, CustomStringConvertible {
    var description: String {
        self.rawValue
    }

    case layPathNotStarted, layPathStarted, layPathStopped, layPathDone,
         trackingNotStarted, trackingStarted, trackingStopped,
         trackingDone, finishedTrack, allDone, cancelled
}

enum RunningState:StateType {
    case notStarted, running, paused, done, saved
}

enum RunningEvent: EventType {
    case start, pause, resume, stop
}


class TrackMapModel: NSObject, ObservableObject {
    private var locationManager: CLLocationManager
    public var stack:CoreDataStack?
    //    public var image: UIImage?
    @Published var followUser: Bool = true
    public var annotations: [MKAnnotation] = []
    public var regionIsSet: Bool = false
    public var trackingStarted: Date?
    //    public var previousState: OldRunningState = .allDone
    public var previewing = false
    public var track:Track! { //Hold on!!!! No force unwrapp in my code!
        didSet {
            self.laidPath = track.laidPath ?? []
            self.trackPath = track.trackPath ?? []
        }
    }
    public var stateMachine:Machine<RunningState, RunningEvent>!

    @Published var timer: TrackTimer = TrackTimer()
    @Published var distance: CLLocationDistance = 0
    @Published public var gotUserLocation = false
    @Published public var currentLocation: CLLocation? {didSet {print("location set: \(currentLocation)")}}
    @Published public var accuracy: Double = 0
    @Published public var done: Bool = false

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TrackMapModel.self)
    )

    public var laidPath: [CLLocation] = [] {
        didSet {
            print("laidPath set \(laidPath)")
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

    init(track:Track, isPreview preview:Bool, stack:CoreDataStack){
        self.track = track
        self.previewing = preview || track.getState() == .finished
        self.stack = stack
        self.locationManager = CLLocationManager()
        stateMachine = Machine(state: .notStarted)
        super.init()

        stateMachine.addRouteMapping { event, fromState, userInfo -> RunningState? in
            // no route for no-event
            guard let event = event else { return nil }

            switch (event, fromState) {
            case (.start, .notStarted):
                return .running
            case (.pause, .running):
                return .paused
            case (.stop, .paused):
                return .done
            case (.resume, .paused):
                return .running
            default:
                print("Unknown event \(event) from state \(fromState)")
                return nil
            }
        }
        stateMachine.addHandler(event: .start) {context in
            print(".start is triggered! Context:\(context)")
            self.startRunning()
        }
        stateMachine.addHandler(event: .pause) { context in
            print(".pause is triggered! Context:\(context)")
            self.pauseRunning()
        }
        stateMachine.addHandler(event: .stop) { context in
            print(".stop is triggered! Context:\(context)")
            self.stopRunning()
        }
        stateMachine.addHandler(event: .resume) { context in
            print(".resume is triggered! Context:\(context)")
            self.resumeRunning()
        }

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        locationManager.delegate = self
        locationManager.requestLocation()
    }

    private func resumeRunning() {

    }


    private func stopRunning() {
        switch track.getState() {
        case .notStarted:
            track.laidPath = laidPath
            track.trackPath = trackPath
            track.timeToCreate = timer.secondsElapsed
            track.length = Int32(distance)
            track.created = Date()
            //                trackModel.image = mapModel.image
            stack?.save()
        case .started:
            track.trackPath = trackPath
            track.timeToFinish = timer.secondsElapsed
            track.started = trackingStarted
            //                trackModel.image = mapModel.image
            stack?.save()
        default:
            print("Unknown state when stopRunning is called \(track.getState())")
        }
    }

    private func pauseRunning() {
        timer.stop()
        stopTracking()
    }

    private func startRunning() {
        self.followUser = true
        switch track.getState() {
        case .notStarted:
            reset()
            addStartAnnotation(at: currentLocation!)
            timer.start()
        case .started:
            addStartAnnotation(at: laidPath.first!)
            addStopAnnotation(at: laidPath.last!)
            trackingStarted = Date()
            addTrackStartAnnotation(at: currentLocation!)
            timer.start()
        default:
            print("Can not start Running on track state \(track.getState()). Maybe view() instead")
            return
        }
    }

    public func view() {
        addStartAnnotation(at: laidPath.first!)
        addStopAnnotation(at: laidPath.last!)
        addTrackStartAnnotation(at: trackPath.first!)
        addTrackStopAnnotation(at: trackPath.last!)
        followUser = false
    }

    public func start() {
        stateMachine <-! .start
    }

    private func addTrackStartAnnotation(at location: CLLocation) {
        let annotation = PathAnnotation(kind: .trackPathStart)
        annotation.coordinate = location.coordinate
        annotation.title = "Start"
        addAnnotation(annotation)
        print("Track path start annotation added")
    }

    private func addTrackStopAnnotation(at location: CLLocation) {
        let annotation = PathAnnotation(kind: .trackPathStop)
        annotation.coordinate = location.coordinate
        annotation.title = "Stop"
        addAnnotation(annotation)
        print("Track path stop annotation added")
    }

    private func addStartAnnotation(at location: CLLocation) {
        let annotation = PathAnnotation(kind: .layPathStart)
        annotation.coordinate = location.coordinate
        annotation.title = "Track Start"
        addAnnotation(annotation)
        print("Lay path start annotation added")
    }

    private func addStopAnnotation(at location: CLLocation) {
        let annotation = PathAnnotation(kind: .layPathStop)
        annotation.coordinate = location.coordinate
        annotation.title = "Track Stop"
        addAnnotation(annotation)
        print("Lay path stop annotation added")
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
        print("Start tracking.")
//        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    private func stopTracking() {
        print("Stop tracking.")
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
}

extension TrackMapModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if stateMachine.state == .running && track.getState() == .notStarted {
            laidPath.append(contentsOf: locations)
        } else if stateMachine.state == .running && track.getState() == .started {
            trackPath.append(contentsOf: locations)
        }
        print("GPS location Accuracy \(locations.first?.horizontalAccuracy ?? 0)")
        accuracy = locations.first?.horizontalAccuracy ?? 0
        currentLocation = manager.location
        self.gotUserLocation = true
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("locationManagerDidChangeAuthorization:manager. Status:\(manager.authorizationStatus.rawValue)")
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Status not determined. Requesting authorization")
            self.gotUserLocation = false
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startTracking()
        default:
            self.gotUserLocation = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed. \(error.localizedDescription)")
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("Location manager paused location updates.")
    }

}
