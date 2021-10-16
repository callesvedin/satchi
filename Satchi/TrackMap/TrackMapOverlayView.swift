//
//  TrackMapOverlayView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-12.
//

import SwiftUI

struct TrackMapOverlayView: View {
    @ObservedObject var mapModel: TrackMapModel
    @ObservedObject var timer: TrackTimer

    init(mapModel: TrackMapModel) {
        self.mapModel = mapModel
        self.timer = mapModel.timer
    }

    var body: some View {
        var actionText: String
        switch mapModel.state {
        case .layPathNotStarted, .trackingNotStarted:
            actionText = "Start"
        case .layPathStarted, .trackingStarted:
            actionText = "Stop"
        case .layPathStopped, .trackingStopped:
            actionText = "Save"
        case .layPathDone, .trackingDone, .finishedTrack, .allDone, .cancelled:
            actionText = "Close"
        }

        let window = UIApplication.shared.windows.first
        let topPadding = window == nil ? 40 : window!.safeAreaInsets.top + 10

        return VStack {
            HStack {
                Text(String(format: "Distance: %.2f m", (mapModel.distance)))
                Spacer()
                Text(String(format: "Time: %.1f sec", mapModel.timer.secondsElapsed))
            }
//            .padding()
            .padding(.top, topPadding)
            .padding(.horizontal)
            .padding(.bottom)
            .background(Color.white)
            .opacity(0.8)
            Spacer()
            HStack {
                if showCancel(state: mapModel.state) {
                    Button("Cancel") {
                        mapModel.state = .cancelled
                    }
                    .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                    .padding(15)
                }
                Button(actionText) {
                    switch mapModel.state {
                    case .layPathNotStarted:
                        mapModel.state = .layPathStarted
                    case .layPathStarted:
                        mapModel.state = .layPathStopped
                    case .layPathStopped:
                        mapModel.state = .layPathDone
                    case .layPathDone:
                        print("layPath done should never occur")
                    case .trackingNotStarted:
                        mapModel.state = .trackingStarted
                    case .trackingStarted:
                        mapModel.state = .trackingStopped
                    case .trackingStopped:
                        mapModel.state = .trackingDone
                    case .trackingDone:
                        print("trackPathDone should never occur")
                    case .finishedTrack:
                        mapModel.state = .allDone
                    case .allDone:
                        print("All done")
                    case .cancelled:
                        print("Cancelled should never occur")
                    }
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: mapModel.state == .layPathStarted ? .red : .green))
                .padding(15)
            }.padding(.bottom, 30)

        }
    }

    private func showCancel(state: RunningState) -> Bool {
        switch state {
        case .layPathNotStarted, .layPathStarted, .trackingNotStarted, .trackingStarted:
            return true
        case .layPathStopped, .layPathDone, .trackingStopped, .trackingDone, .finishedTrack, .allDone, .cancelled:
            return false

        }

    }
}

struct TrackMapOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapOverlayView(mapModel: TrackMapModel()).ignoresSafeArea()
    }
}
