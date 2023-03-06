//
//  TrackTimer.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-05-18.
//

import Foundation

enum TimerMode {
    case running
    case stopped
}

class TrackTimer: ObservableObject {
    var timer = Timer()
    @Published var secondsElapsed = 0.0
    @Published var mode: TimerMode = .stopped

    public func start() {
        print("Starting timer")
        secondsElapsed = 0.0
        mode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.secondsElapsed += 0.1
        }
    }

    public func stop() {
        print("Stopping timer")
        timer.invalidate()
        mode = .stopped
    }

    public func resume() {
        print("Resuming timer")
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.secondsElapsed += 0.1
        }
    }
}
