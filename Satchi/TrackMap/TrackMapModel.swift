//
//  TrackMapModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import CoreLocation
import Foundation
import os.log
import SwiftState
import SwiftUI

enum RunningState: StateType {
    case notStarted, running, paused, done, viewing
}

enum RunningEvent: EventType {
    case start, pause, resume, stop
}

class TrackMapModel: NSObject, ObservableObject {
    private var locationManager: CLLocationManager
    //    public var image: UIImage?

    public var regionIsSet: Bool = false
    public var trackingStarted: Date?

    public var track: Track
    public var stateMachine: Machine<RunningState, RunningEvent>!

    @Published var pathStartLocation: CLLocationCoordinate2D?
    @Published var pathEndLocation: CLLocationCoordinate2D?
    @Published var trackStartLocation: CLLocationCoordinate2D?
    @Published var trackEndLocation: CLLocationCoordinate2D?
    private var isTracking = false
    var followUser: Bool = true
    @Published var timer: TrackTimer = .init()
    @Published var distance: CLLocationDistance = 0
    @Published public var gotUserLocation = false
    public var currentLocation: CLLocation?
    @Published public var accuracy: Double = 0
    @Published public var done: Bool = false
    @Published public var showAccessDenied: Bool = false
    public var locationAuthorizationStatus: CLAuthorizationStatus {
        didSet {
            switch locationAuthorizationStatus {
            case .notDetermined:
                print("Status not determined. Requesting authorization")
                locationManager.requestAlwaysAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                startTracking()
            case .denied, .restricted:
                showAccessDenied = true
                print("locationAuthorizationStatus prohibits tracking")
            @unknown default:
                gotUserLocation = false
            }
        }
    }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TrackMapModel.self)
    )

    @Published public var laidPath: [CLLocation] = [] {
        didSet {
            if laidPath.count >= 2 {
                distance = getLength(from: laidPath)
            }
        }
    }

    @Published public var trackPath: [CLLocation] = [] {
        didSet {
            if trackPath.count >= 2 {
                distance = getLength(from: trackPath)
            }
        }
    }

    @Published public var dummies: [CLLocationCoordinate2D] = []

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

    init(track: Track) {
        self.track = track
        laidPath = track.laidPath ?? []
        trackPath = track.trackPath ?? []
        dummies = track.dummies ?? []
        locationManager = CLLocationManager()
        let isViewing = track.getState() == .trailTracked
        stateMachine = Machine(state: isViewing ? .viewing : .notStarted)
        locationAuthorizationStatus = locationManager.authorizationStatus

        super.init()
        if isViewing || locationAuthorizationStatus == .denied || locationAuthorizationStatus == .restricted {
            followUser = false
            distance = Double(track.length)
            timer.secondsElapsed = track.timeToFinish
        }

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        locationManager.delegate = self
        if locationAuthorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }

        if track.getState() == .trailTracked {
            trackStartLocation = trackPath.first?.coordinate
            trackEndLocation = trackPath.last?.coordinate
        }

        if track.getState() == .trailAdded || track.getState() == .trailTracked {
            pathStartLocation = laidPath.first?.coordinate
            pathEndLocation = laidPath.last?.coordinate
        }
        stateMachine.addRouteMapping { event, fromState, _ -> RunningState? in
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
            case (.stop, .viewing):
                return .done
            case (.stop, .notStarted):
                return .done

            default:
                print("Unknown event \(event) from state \(fromState)")
                return nil
            }
        }

        stateMachine.addHandler(event: .start) { context in
            print(".start is triggered! Context:\(context)")
            self.startRunning()
        }
        stateMachine.addHandler(event: .pause) { context in
            print(".pause is triggered! Context:\(context)")
            self.pauseRunning()
        }
        stateMachine.addHandler(event: .stop) { context in
            print(".stop is triggered! Context:\(context)")
            if context.fromState == .viewing {
                self.stopRunning()
            } else if context.fromState == .notStarted {
                self.cancelRunning()

            } else if context.fromState == .paused {
                self.stopRunning()
            }
        }
        stateMachine.addHandler(event: .resume) { context in
            print(".resume is triggered! Context:\(context)")
            self.resumeRunning()
        }
    }

    private func resumeRunning() {
        timer.resume()
        if track.getState() == .notStarted {
            pathEndLocation = nil
        } else {
            trackEndLocation = nil
        }
    }

    private func stopRunning() {
        switch track.getState() {
        case .notStarted:
            track.laidPath = laidPath
            track.trackPath = trackPath
            track.timeToCreate = timer.secondsElapsed
            track.length = Int32(distance)
            track.created = Date()
            track.state = track.getState().rawValue
            track.dummies = dummies
            PersistenceController.shared.updateTrack(track: track)
        case .trailAdded:
            track.trackPath = trackPath
            track.timeToFinish = timer.secondsElapsed
            track.started = trackingStarted
            track.state = track.getState().rawValue
            PersistenceController.shared.updateTrack(track: track)
        default:
            print("Unknown state when stopRunning is called \(track.getState())")
        }
        stopTracking()
        done = true
    }

    private func pauseRunning() {
        timer.stop()
        switch track.getState() {
        case .notStarted:
            pathEndLocation = laidPath.last?.coordinate
        case .trailAdded:
            trackEndLocation = trackPath.last?.coordinate
        default:
            print("Can not start Running on track state \(track.getState()). Maybe view() instead")
            return
        }
    }

    private func startRunning() {
        switch track.getState() {
        case .notStarted:
            pathStartLocation = currentLocation?.coordinate
            timer.start()
        case .trailAdded:
            pathStartLocation = laidPath.first?.coordinate
            pathEndLocation = laidPath.last?.coordinate
            trackingStarted = Date()
            trackStartLocation = currentLocation?.coordinate
            timer.start()
        default:
            print("Can not start Running on track state \(track.getState()). Maybe view() instead")
            return
        }
    }

    private func cancelRunning() {
        stopTracking()
        done = true
    }

    public func start() {
        stateMachine <-! .start
    }

    public func pause() {
        stateMachine <-! .pause
    }

    public func resume() {
        stateMachine <-! .resume
    }

    public func stop() {
        stateMachine <-! .stop
    }

    public func addApport() {
        print("Add dummy now!")
        if let location = locationManager.location {
            dummies.append(location.coordinate)
        }
    }

    private func getLength(from locations: [CLLocation]) -> Double {
        var length: Double = 0
        for (count, location) in locations.enumerated() {
            if count == 0 { continue }
            length += location.distance(from: locations[count - 1])
        }
        return length
    }

    public func startTracking() {
        print("Start tracking.")
        if !isTracking {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            isTracking = true
        }
    }

    private func stopTracking() {
        print("Stop tracking.")
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        isTracking = false
    }
}

extension TrackMapModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if stateMachine.state == .running && track.getState() == .notStarted { // If we want to continue updating while paused we have to add .paused state here but we then have to save the location where we paused...
            laidPath.append(contentsOf: locations)
        } else if stateMachine.state == .running && track.getState() == .trailAdded { // If we want to continue updating while paused we have to add .paused state here but we then have to save the location where we paused...
            trackPath.append(contentsOf: locations)
        }
        accuracy = locations.first?.horizontalAccuracy ?? 0
        currentLocation = manager.location
        gotUserLocation = true
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("locationManagerDidChangeAuthorization:manager. Status:\(manager.authorizationStatus)")
        locationAuthorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed. \(error.localizedDescription)")
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("Location manager paused location updates.")
    }
}
