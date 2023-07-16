//
//  StateButtonView.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-08-17.
//

import SwiftUI

struct StateButtonView: View {
    @ObservedObject var mapModel: TrackMapModel

    var body: some View {
        HStack {
            if mapModel.stateMachine.state == .notStarted {
                Button(action: { mapModel.stop() }, label: { Text("Close") })
                    .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                    .padding(15)
                if mapModel.locationAuthorizationStatus != .denied {
                    Button(action: { mapModel.start() }, label: { Text("Start") })
                        .buttonStyle(OverlayButtonStyle(backgroundColor: .green))
                        .disabled(mapModel.accuracy > 10)
                        .padding(15)
                }
            }
            if mapModel.stateMachine.state == .running {
                Button(action: { mapModel.pause() }, label: { Text("Pause") })
                    .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                    .padding(15)
            }
            if mapModel.stateMachine.state == .paused {
                Button(action: { mapModel.resume() }, label: { Text("Continue") })
                    .buttonStyle(OverlayButtonStyle(backgroundColor: .green))
                    .padding(15)
                Button(action: { mapModel.stop() }, label: { Text("Stop") })
                    .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                    .padding(15)
            }
            if mapModel.stateMachine.state == .viewing {
                Button(action: { mapModel.stop() }, label: { Text("Close") })
                    .buttonStyle(OverlayButtonStyle(backgroundColor: .green))
                    .padding(15)
            }
        }
    }
}

struct StateButtonView_Previews: PreviewProvider {
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
        let m1 = TrackMapModel(track: track)
        m1.followUser = false
        m1.accuracy = 4
        let m2 = TrackMapModel(track: track)
        m1.followUser = false
        m1.accuracy = 20

        let track2 = Track(context: PersistenceController.shared.persistentContainer.viewContext)
        track2.name = "Test-Track"
        track2.created = Date()
        track2.timeToFinish = 19*60
        track2.difficulty = 3
        track2.comments = "A little hard..."
        track2.timeToCreate = 21*60
        track2.started = Date().addingTimeInterval(60*60*3)
        track2.length = 1000
        let m3 = TrackMapModel(track: track2)
        m3.followUser = false
        m3.accuracy = 4

        let examples = [m1, m2, m3]

        return ForEach(examples, id: \.self) { model in
            VStack {
                Spacer()
                StateButtonView(mapModel: model)
            }
        }
    }
}
