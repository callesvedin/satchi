//
//  StateButtonView.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-08-17.
//

import SwiftUI

struct StateButtonView: View {
 @ObservedObject var mapModel:TrackMapModel

    var body: some View {
        HStack {
            if mapModel.stateMachine.state == .notStarted {
                Button(action: {mapModel.stop()}, label: {Text("Close")})
                .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                .padding(15)
                Button(action: {mapModel.start()}, label: {Text("Start")})
                    .buttonStyle(OverlayButtonStyle(backgroundColor: .green))
                    .disabled(mapModel.accuracy > 10)
                    .padding(15)
/*
 Button(action: {mapModel.start()},
 label:  {
 Image(systemName: "play.circle.fill")
 .symbolRenderingMode(.palette)
 .foregroundStyle(.white, .green)
 .font(.system(size: 50))
 })
 .opacity(mapModel.accuracy > 10 ? 0.4:0.8)
 .disabled(mapModel.accuracy > 10)
 .padding(15)
 */
            }
            if mapModel.stateMachine.state == .running {
                Button(action: {mapModel.pause()}, label: {Text("Pause")})
                .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                .padding(15)
            }
            if mapModel.stateMachine.state == .paused {
                Button(action: {mapModel.resume()}, label: {Text("Continue")})
                .buttonStyle(OverlayButtonStyle(backgroundColor: .green))
                .padding(15)
                Button(action: {mapModel.stop()}, label: {Text("Stop")})
                .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                .padding(15)

            }
            if mapModel.stateMachine.state == .viewing {               
                Button(action: {mapModel.stop()}, label: {Text("Close")})
                .buttonStyle(OverlayButtonStyle(backgroundColor: .green))            
                .padding(15)
            }
        }
    }
}

//struct StateButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        let track = CoreDataStack.preview.getTracks()[0]
//        let model = TrackMapModel(track: track, stack: CoreDataStack.preview)
//        model.followUser = false
//        model.accuracy = 15
//
//        return StateButtonView(mapModel:model)
//    }
//}



