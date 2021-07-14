//
//  TrackMapOverlayView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-12.
//

import SwiftUI


struct TrackMapOverlayView: View {    
    @ObservedObject var mapModel:TrackMapModel
    @ObservedObject var timer : TrackTimer
    
    init(mapModel:TrackMapModel) {
        self.mapModel = mapModel
        self.timer = mapModel.timer
    }
    
    var body: some View {
        var buttonText:String
        switch mapModel.state {
        case .notStarted:
            buttonText = "Start"
        case .started:
            buttonText = "Stop"
        case .stopped, .done:
            buttonText = "Save"
        }
        return
            VStack{
                HStack{
                    Text(String(format: "Distance: %.2f m", (mapModel.distance)))
                    Spacer()
                    Text(String(format:"Time: %.1f sec", mapModel.timer.secondsElapsed))
                }
                .padding(.top, 30)
                .padding()
                .background(Color.white)
                .opacity(0.5)
                Spacer()
                
                Button(buttonText) {
//                    switch mapModel.timer.mode {
//
//                    case .running:
//                        mapModel.timer.stop()
//                    case .stopped:
//                        mapModel.timer.start()
//                    }
                    
                    switch mapModel.state {
                    case .started:
                        mapModel.state = .stopped
                    case .notStarted:
                        mapModel.state = .started
                    case .stopped:
                        mapModel.state = .done
                    default:
                        break;
                    }
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: mapModel.state == .started ? .red : .green))
                .padding(.bottom, 60)
            
            
        }
    }
}

struct TrackMapOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapOverlayView(mapModel:TrackMapModel())
    }
}
