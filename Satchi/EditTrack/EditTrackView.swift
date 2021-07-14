//
//  EditTrackView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import SwiftUI
import Sliders

struct EditTrackView: View {
    @EnvironmentObject var navigationHelper: NavigationHelper
    @ObservedObject var trackModel:TrackModel
    @State private var difficulty:Int
    @State private var showTrackView = false
    @State private var editName = false
    @State private var save = true
    
    let dateFormatter:DateFormatter
    
    
    init(trackModel:TrackModel) {
        self.trackModel = trackModel
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        difficulty = max(100, Int(trackModel.difficulty * 100))
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Group {
                if editName {
                    TextField("Name", text: $trackModel.name, onCommit:{
                        editName = false
                        trackModel.save()
                    })
                        .font(.title)
                }else{
                    Text(trackModel.name).font(.title).fontWeight(.bold).padding(.bottom)
                        .onTapGesture {
                            editName = true
                        }
                }
                
            }
            
            HStack {
                Text("Difficulty: \(difficulty/100)")
                
                DifficultySlider(difficulty: $difficulty)
                    .onChange(of: difficulty, perform: { value in
                        trackModel.difficulty = Int(difficulty/100)
                        trackModel.save()
                    })
            }.frame(height: 22).padding(.vertical, 4)
            Group {
                Text("Length: \(trackModel.length ?? 0)m").padding(.vertical, 4)
                Text(String(format:"Time to create: %.1f sec", trackModel.timeToCreate ?? 0)).padding(.vertical, 4)
                Text("Created: \(dateFormatter.string(from: trackModel.created))").padding(.vertical, 4)
                Text("Time since created:").padding(.vertical, 4)
                if trackModel.finished != nil {
                    Text("Finished: \(dateFormatter.string(from: trackModel.finished!))").padding(.vertical, 4)
                    Text("Time to finish:").padding(.vertical, 4)
                }else {
                    Text("Finished: -").padding(.vertical, 4)
                }
                
            }
            Divider()
            HStack {
                Spacer()
                VStack {
                    if trackModel.finished == nil {
                        NavigationLink(destination: TrackMapView(trackModel: trackModel))
                        {
                            Text("Track!").font(.title)
                        }
                        .isDetailLink(false)
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .font(Font.system(size: 22))
        .padding()
        //        .navigationTitle(trackModel.name)
        .navigationBarBackButtonHidden(false)
    }
}

struct EditTrackView_Previews: PreviewProvider {
    static var previews: some View {
        let track = TrackStorage.preview.tracks.value[1]
        return NavigationView {
            EditTrackView(trackModel: TrackModel(track:track))
        }
    }
}

struct DifficultySlider: View {
    @Binding var difficulty:Int
    
    var body: some View {
        ValueSlider(value: $difficulty, in:100...500)
            .valueSliderStyle(
                HorizontalValueSliderStyle(
                    track: LinearGradient(
                        gradient: Gradient(colors: [.green, .blue, .orange, .yellow, .purple, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 8)
                    .cornerRadius(4),
                    thumbSize:CGSize(width:10,height:15)
                )
            )
    }
}
