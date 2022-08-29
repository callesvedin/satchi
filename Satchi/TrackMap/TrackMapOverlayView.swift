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
            if mapModel.stateMachine.state != .viewing  {
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
            StateButtonView(mapModel:mapModel)
                .padding(.bottom, 30)

        }
    }
}


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
