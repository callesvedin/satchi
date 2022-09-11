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
                Button("Start") {
                    mapModel.start()
                }
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
                Button("Pause") {
                    print("Pause pressed\n")
                    mapModel.pause()
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                .padding(15)
            }
            if mapModel.stateMachine.state == .paused {
                Button("Continue") {
                    print("Continue pressed\n")
                    mapModel.resume()
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: .green))
                .padding(15)
                Button("Stop") {
                    print("Stop pressed\n")
                    // TODO: Ask for confirmation!
                    mapModel.stop()
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: .red))
                .padding(15)

            }
            if mapModel.stateMachine.state == .viewing {
                Button("Close") {
                    mapModel.stop()
                }
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



