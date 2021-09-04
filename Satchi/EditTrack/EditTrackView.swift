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
    
    let dateFormatter: DateFormatter
    let elapsedTimeFormatter: DateComponentsFormatter
    let shortElapsedTimeFormatter: DateComponentsFormatter
    
    init(trackModel:TrackModel) {
        self.trackModel = trackModel
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
//        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd hh:mm")
        
        difficulty = max(100, Int(trackModel.difficulty * 100))
        elapsedTimeFormatter = DateComponentsFormatter()
        elapsedTimeFormatter.unitsStyle = .abbreviated
        elapsedTimeFormatter.zeroFormattingBehavior = .dropAll
        elapsedTimeFormatter.allowedUnits = [.day, .hour, .minute]
        
        shortElapsedTimeFormatter = DateComponentsFormatter()
        shortElapsedTimeFormatter.unitsStyle = .abbreviated
        shortElapsedTimeFormatter.zeroFormattingBehavior = .dropAll
        shortElapsedTimeFormatter.allowedUnits = [.hour, .minute, .second]

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
                Text("Time to create: \(shortElapsedTimeFormatter.string(from: trackModel.timeToCreate!) ?? "-")").padding(.vertical, 4)
                Text("Created: \(dateFormatter.string(from: trackModel.created))").padding(.vertical, 4)
                if trackModel.started != nil {
                    Text("Time between creation and start: \(elapsedTimeFormatter.string(from:  trackModel.created.distance(to:trackModel.started!)) ?? "-")").padding(.vertical,4)
                }else{
                    Text("Time since created: \(elapsedTimeFormatter.string(from:  trackModel.created.distance(to:Date())) ?? "-")").padding(.vertical, 4)
                }
                if trackModel.started != nil {
                    Text("Tracking started: \(dateFormatter.string(from: trackModel.started!))").padding(.vertical, 4)
                    Text("Time to finish:\(shortElapsedTimeFormatter.string(from: trackModel.timeToFinish!) ?? "-")").padding(.vertical, 4)
                }
                
            }
            Divider()
            HStack {
                Spacer()
                VStack {
                        NavigationLink(destination: TrackMapView(trackModel: trackModel))
                        {
                            if trackModel.started == nil {
                                Text("Start Tracking").font(.headline)
                            }else{
                                Text("Show Track").font(.headline)
                            }
                        }
                        .isDetailLink(false)
                        .buttonStyle(OverlayButtonStyle(backgroundColor: .green))
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

struct EditTrackView_Previews: PreviewProvider {
    static var previews: some View {
        let track = TrackStorage.preview.tracks.value[2]
        return NavigationView {
            EditTrackView(trackModel: TrackModel(track:track))
        }
    }
}
