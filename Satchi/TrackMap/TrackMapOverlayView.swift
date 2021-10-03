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
        var buttonText: String
        switch mapModel.state {
        case .layPathNotStarted, .trackingNotStarted:
            buttonText = "Start"
        case .layPathStarted, .trackingStarted:
            buttonText = "Stop"
        case .layPathStopped, .trackingStopped:
            buttonText = "Save"
        case .layPathDone, .trackingDone, .finishedTrack, .allDone:
            buttonText = "Close"
        }
        return
            VStack {
                HStack {
                    Text(String(format: "Distance: %.2f m", (mapModel.distance)))
                    Spacer()
                    Text(String(format: "Time: %.1f sec", mapModel.timer.secondsElapsed))
                }
                .padding(.top, 30)
                .padding()
                .background(Color.white)
                .opacity(0.5)
                Spacer()

                Button(buttonText) {
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
                    }
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: mapModel.state == .layPathStarted ? .red : .green))
                .padding(.bottom, 60)

            }
    }
}

struct TrackMapOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapOverlayView(mapModel: TrackMapModel())
    }
}
