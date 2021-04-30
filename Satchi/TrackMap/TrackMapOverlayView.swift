//
//  TrackMapOverlayView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-12.
//

import SwiftUI


struct TrackMapOverlayView: View {    
    @Binding var state:RunningState
    
    var body: some View {
        var buttonText:String
        switch state {
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
                    Text("Distance: 200m")
                    Spacer()
                    Text("Time: 0sec")
                }
                .padding(.top, 30)
                .padding()
                Spacer()
                
                Button(buttonText) {
                    switch state {
                    case .started:
                        state = .stopped
                    case .notStarted:
                        state = .started
                    case .stopped:
                        state = .done
                    default:
                        break;
                    }
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: state == .started ? .red : .green))
                .padding(.bottom, 60)
            
            
        }
    }
}

struct TrackMapOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TrackMapOverlayView(state: Binding.constant(RunningState.notStarted))
    }
}
