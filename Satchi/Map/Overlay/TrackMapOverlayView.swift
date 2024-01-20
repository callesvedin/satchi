//
//  TrackMapOverlayView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-12.
//

import SwiftUI

struct TrackMapOverlayView: View {
    @Environment(\.preferredColorPalette) private var palette
    @Environment(\.openURL) var openURL
    @ObservedObject var mapModel: TrackMapModel
    @Environment(\.colorScheme) var colorScheme
    @State var showAccessDenied = false
    @State var animate = true

    init(mapModel: TrackMapModel) {
        self.mapModel = mapModel
        if mapModel.locationAuthorizationStatus == .denied || mapModel.locationAuthorizationStatus == .restricted {
            showAccessDenied = true
        }
    }

//    var addApportButton: some View {
//        Button(action: { mapModel.addApport() }, label: { Text("Add dummy") })
//            .buttonStyle(OverlayButtonStyle(backgroundColor: palette.mainBackground))
//            .padding(15)
//    }

    var antennaImage: some View {
            if #available(iOS 17, *) {
                return Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .symbolEffect(
                        .pulse,
                        isActive: animate
                    )
                    .fontWeight(.bold)
                    .imageScale(.large)
                    .padding(8)
                    .foregroundColor(Color.red)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous).fill(palette.mainBackground).opacity(0.8)
                    )
            } else {
                return Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .fontWeight(.bold)
                    .imageScale(.large)
                    .padding(8)
                    .foregroundColor(Color.red)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous).fill(palette.mainBackground).opacity(0.8)
                    )
            }
    }

    var body: some View {
        let window = UIApplication.shared.currentKeyWindow
        let topPadding = window == nil ? 40 : window!.safeAreaInsets.top + 10
        return VStack {
            HStack {
                Text("Distance: \(DistanceFormatter.distanceFor(meters: mapModel.distance))")
                Spacer()
                Text("Time: \(TimeFormatter.shortTimeWithSecondsFor(seconds: mapModel.timer.secondsElapsed))")
            }
            .padding(.top, topPadding)
            .padding(.horizontal)
            .padding(.bottom)
            .background(palette.mainBackground.opacity(0.8))

            if mapModel.stateMachine.state != .viewing {
                HStack {
//                    if mapModel.stateMachine.state == .running {
//                        addApportButton
//                    }
                    Spacer()
                    if mapModel.accuracy > 10 {
                        antennaImage
                    }
                    Button(
                        action: { mapModel.followUser.toggle() },
                        label: {
                            Image(systemName: "location")
                                .symbolVariant(mapModel.followUser ? .fill : .none)
                                .imageScale(.large)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous).fill(palette.mainBackground).opacity(0.8)
                                )
                        }
                    ).buttonStyle(.plain)
                }
                .frame(height: 40)
                .padding(.horizontal, 10)
            }

            Spacer()
                .alert("Location tracking denied", isPresented: $mapModel.showAccessDenied, actions: {
                    Button("Cancel", role: .cancel, action: { showAccessDenied = false })
                    Button("Show me the settings", role: .none, action: {
                        openSettingsApp()
                    })
                },
                message: {
                    Text("allow.tracking.info")
                })
            StateButtonView(mapModel: mapModel)
                .padding(.bottom, 30)
        }.onAppear {
            showAccessDenied = mapModel.locationAuthorizationStatus == .denied
        }
    }

    private func openSettingsApp() {
        guard let theUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        openURL(theUrl)
    }
}

 struct TrackMapOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        let track = Track(context: PersistenceController.shared.persistentContainer.viewContext)
        track.name = "Test-Track"
        track.created = Date()
        // track.timeToFinish = 19*60
        track.difficulty = 3
        track.comments = "A little hard..."
        track.timeToCreate = 21*60
        track.started = Date().addingTimeInterval(60*60*3)
        track.length = 1000
        track.timeToCreate = 300.0

        let model: TrackMapModel = TrackMapModel(track: track)
        model.followUser = true
        model.accuracy = 45

        return Group {
            TrackMapOverlayView(mapModel: model).ignoresSafeArea()
            TrackMapOverlayView(mapModel: model).ignoresSafeArea().preferredColorScheme(.dark)
        }
    }
 }
