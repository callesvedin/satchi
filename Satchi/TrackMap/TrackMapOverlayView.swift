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
    @Environment(\.colorScheme) var colorScheme

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

        let window = UIApplication.shared.currentKeyWindow
        let topPadding = window == nil ? 40 : window!.safeAreaInsets.top + 10

        return VStack {
            HStack {
                Text("Distance: \(DistanceFormatter.distanceFor(meters:mapModel.distance))")
                Spacer()
                Text("Time: \(TimeFormatter.shortTimeWithSecondsFor(seconds: mapModel.timer.secondsElapsed))")
            }
            .padding(.top, topPadding)
            .padding(.horizontal)
            .padding(.bottom)
            .background(Color(UIColor.systemBackground))
            .opacity(0.8)
            if mapModel.state != .finishedTrack {
                HStack {
                    Spacer()
                    if mapModel.accuracy > 10 {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .imageScale(.large)
                            .padding(8)
                            .foregroundColor(Color.red)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(UIColor.systemBackground).opacity(0.8))
                            )
                    }
                    Button(
                        action: {mapModel.followUser.toggle()},
                        label: {
                            Image.init(systemName: "location")
                                .symbolVariant(mapModel.followUser ? .fill: .none)
                                .imageScale(.large)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(UIColor.systemBackground).opacity(0.8))
                                )
                            }
                    ).buttonStyle(.plain)
                }
                .frame(height: 40)
                .padding(.horizontal, 10)
            }
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
                .disabled((mapModel.state == .layPathNotStarted || mapModel.state == .trackingNotStarted) && mapModel.accuracy > 10)
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
        let model: TrackMapModel = TrackMapModel()
        model.followUser = false
        model.accuracy = 15

        return Group {
            TrackMapOverlayView(mapModel: model).ignoresSafeArea()
            TrackMapOverlayView(mapModel: model).ignoresSafeArea().preferredColorScheme(.dark)
        }
    }
}
