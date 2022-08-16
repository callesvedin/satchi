//
//  TrackMapOverlayView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-12.
//

import SwiftUI

struct TrackMapOverlayView: View {
//    @EnvironmentObject private var stack: CoreDataStack
    @ObservedObject var mapModel: TrackMapModel
    @Environment(\.colorScheme) var colorScheme

    init(mapModel: TrackMapModel) {
        self.mapModel = mapModel
    }

    var body: some View {
        var actionText: String
        switch mapModel.stateMachine.state {
        case .notStarted, .paused:
            actionText = "Start"
        case .running:
            actionText = "Pause"
        default:
            actionText = "What?"
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
            if !mapModel.previewing  {
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
                Button(actionText) {
                    switch mapModel.stateMachine.state {
                    case .notStarted:
                        mapModel.start()
                    default:
                        print("Not a state to use in button")
                    }
                }
                .disabled(mapModel.accuracy > 10)
                .buttonStyle(OverlayButtonStyle(backgroundColor: mapModel.stateMachine.state == .running ? .red : .green))
                .padding(15)
            }.padding(.bottom, 30)

        }
    }
}
//    private func showResume(state: OldRunningState) -> Bool {
//        switch state {
//        case .layPathStopped, .trackingStopped:
//            return true
//        case .layPathStarted, .trackingStarted,.layPathNotStarted,
//                .trackingNotStarted,.layPathDone, .trackingDone, .finishedTrack, .allDone, .cancelled:
//            return false
//        }
//
//    }
//
//
//    private func showCancel(state: OldRunningState) -> Bool {
//        switch state {
//        case .layPathStarted, .trackingStarted:
//            return true
//        case .layPathNotStarted, .trackingNotStarted, .layPathStopped, .layPathDone, .trackingStopped, .trackingDone, .finishedTrack, .allDone, .cancelled:
//            return false
//        }
//
//    }
//}

//struct TrackMapOverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        let model: TrackMapModel = TrackMapModel()
//        model.followUser = false
//        model.accuracy = 15
//
//        return Group {
//            TrackMapOverlayView(mapModel: model).ignoresSafeArea()
//            TrackMapOverlayView(mapModel: model).ignoresSafeArea().preferredColorScheme(.dark)
//        }
//    }
//}
