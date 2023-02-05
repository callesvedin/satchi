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

    init(mapModel: TrackMapModel) {
        self.mapModel = mapModel
        if mapModel.locationAuthorizationStatus == .denied || mapModel.locationAuthorizationStatus == .restricted {
            showAccessDenied = true
        }
    }

    var addApportButton: some View {
        Button(action: { mapModel.addApport() }, label: { Text("Add dummy") })
            .buttonStyle(OverlayButtonStyle(backgroundColor: palette.mainBackground))
            .padding(15)
    }

    var body: some View {
        let window = UIApplication.shared.currentKeyWindow
        let topPadding = window == nil ? 40 : window!.safeAreaInsets.top + 10
        showAccessDenied = mapModel.locationAuthorizationStatus == .denied
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
                    if mapModel.stateMachine.state == .running {
                        addApportButton
                    }
                    Spacer()
                    if mapModel.accuracy > 10 {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .imageScale(.large)
                            .padding(8)
                            .foregroundColor(Color.red)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(palette.mainBackground).opacity(0.8)
                            )
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
                    Text("You must allow the application to track you. Prefferably while the application is not in use to be able to put away your phone while tracking with your dog.\nYou may always change this setting in Settings->Satchi->Location")
                })
            StateButtonView(mapModel: mapModel)
                .padding(.bottom, 30)
        }
    }

    func openSettingsApp() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        openURL(url)
    }
}

//
//
// struct TrackMapOverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        let model: TrackMapModel = TrackMapModel(track:CoreDataStack.preview.getTracks()[1], stack:CoreDataStack.preview)
//        model.followUser = false
//        model.accuracy = 15
//
//        return Group {
//            TrackMapOverlayView(mapModel: model).ignoresSafeArea().environmentObject(CoreDataStack.preview)
//            TrackMapOverlayView(mapModel: model).ignoresSafeArea().preferredColorScheme(.dark).environmentObject(CoreDataStack.preview)
//        }
//    }
// }
