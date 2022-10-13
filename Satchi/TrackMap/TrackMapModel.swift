//
//  TrackMapModel.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-06.
//

import Foundation
import CoreLocation
import SwiftUI
import os.log
import SwiftState

enum RunningState:StateType {
    case  notStarted ,running, paused, done, viewing
}

enum RunningEvent: EventType {
    case start, pause, resume, stop
}


class TrackMapModel: NSObject, ObservableObject {
    private var locationManager: CLLocationManager
    public var stack:CoreDataStack?
    //    public var image: UIImage?

    public var regionIsSet: Bool = false
    public var trackingStarted: Date?

    public var track:Track
    public var stateMachine:Machine<RunningState, RunningEvent>!

    @Published var pathStartLocation:CLLocationCoordinate2D?
    @Published var pathEndLocation:CLLocationCoordinate2D?
    @Published var trackStartLocation:CLLocationCoordinate2D?
    @Published var trackEndLocation:CLLocationCoordinate2D?

    var followUser: Bool = true
    @Published var timer: TrackTimer = TrackTimer()
    @Published var distance: CLLocationDistance = 0
    @Published public var gotUserLocation = false
    public var currentLocation: CLLocation?
    @Published public var accuracy: Double = 0
    @Published public var done: Bool = false

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

    init(track:Track, stack:CoreDataStack){
        self.track = track
        self.laidPath = track.laidPath ?? []
        self.trackPath = track.trackPath ?? []        
        self.stack = stack
        self.locationManager = CLLocationManager()
        let isViewing = track.getState() == .trailTracked
        stateMachine = Machine(state: isViewing ? .viewing : .notStarted)
        super.init()
        if isViewing {
            followUser = false
            distance = Double(track.length)
            timer.secondsElapsed = track.timeToFinish
        }

        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        locationManager.delegate = self
        locationManager.requestLocation()
        if track.getState() == .trailTracked
        {
            trackStartLocation = trackPath.first?.coordinate
            trackEndLocation = trackPath.last?.coordinate
        }

        if track.getState() == .trailAdded || track.getState() == .trailTracked {
            pathStartLocation = laidPath.first?.coordinate
            pathEndLocation = laidPath.last?.coordinate
        }
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
            case (.stop, .viewing):
                return .done

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
            if context.fromState == .viewing {
                self.done = true
            }else{
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
            self.pathEndLocation = nil
        }else{
            self.trackEndLocation = nil
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
            stack?.save()
        case .trailAdded:
            track.trackPath = trackPath
            track.timeToFinish = timer.secondsElapsed
            track.started = trackingStarted
            stack?.save()
        default:
            print("Unknown state when stopRunning is called \(track.getState())")
        }
        self.done = true
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

    private func getLength(from locations: [CLLocation]) -> Double {
        var length: Double = 0
        for (count, location) in locations.enumerated() {
            if count == 0 {continue}
            length +=  location.distance(from: locations[count-1])
        }
        return length
    }


    public func startTracking() {
        print("Start tracking.")
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
        print("locationManager:_:didUpdateLocations called")
        if stateMachine.state == .running && track.getState() == .notStarted { // If we want to continue updating while paused we have to add .paused state here but we then have to save the location where we paused...
            laidPath.append(contentsOf: locations)
        } else if stateMachine.state == .running && track.getState() == .trailAdded { // If we want to continue updating while paused we have to add .paused state here but we then have to save the location where we paused...
            trackPath.append(contentsOf: locations)
        }
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
