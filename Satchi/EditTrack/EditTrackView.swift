//
//  EditTrackView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import SwiftUI
import Sliders

struct EditTrackView: View {
    var trackModel: TrackModel
    @State private var difficulty: Int = 100
    @State private var showTrackView = false
    @State private var editName = false
    @State private var trackName: String = ""

    let dateFormatter: DateFormatter
    let elapsedTimeFormatter: DateComponentsFormatter
    let shortElapsedTimeFormatter: DateComponentsFormatter

    init(trackModel: TrackModel) {
        self.trackModel = trackModel
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        //        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd hh:mm")

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
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                TrackMapView(trackModel: trackModel, preview: true)
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding(.bottom, 30)
                Spacer()
            }
            HStack {
                Text("Difficulty: \(difficulty/100)")
                DifficultySlider(difficulty: $difficulty)
            }
            .frame(height: 22)
            .padding(.vertical, 4)
            Group {
                Text("Length: \(trackModel.length ?? 0)m").padding(.vertical, 4)
                Text("Time to create: \(shortElapsedTimeFormatter.string(from: trackModel.timeToCreate!) ?? "-")")
                    .padding(.vertical, 4)
                Text("Created: \(dateFormatter.string(from: trackModel.created))").padding(.vertical, 4)
                if trackModel.started != nil {
                    Text("""
                        Time between creation and start: \
                        \(getTimeBetween(date: trackModel.created, and: trackModel.started!))
                        """
                    ).padding(.vertical, 4)
                } else {
                    Text("Time since created:\(getTimeSinceCreated())")
                        .padding(.vertical, 4)
                }
                if trackModel.started != nil {
                    Text("Tracking started: \(dateFormatter.string(from: trackModel.started!))").padding(.vertical, 4)
                    Text("""
                         Time to finish:\(shortElapsedTimeFormatter.string(from: trackModel.timeToFinish!) ?? "-")
                         """
                    ).padding(.vertical, 4)
                }

            }
            Divider()
            HStack {
                Spacer()
                VStack {
                    NavigationLink(destination: TrackMapView(trackModel: trackModel)) {
                        if trackModel.started == nil {
                            Text("Start Tracking").font(.headline)
                        } else {
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if editName {
                    TextField("Name", text: $trackName, onCommit: {
                        editName = false
                    })
                    .font(Font.largeTitle)
                } else {
                    HStack {
                        Text(trackName).font(Font.largeTitle)
                        Button(action: {editName = true}, label: {
                            Image(systemName: "square.and.pencil").font(Font.subheadline)
                        })
                        Spacer()
                    }
                }
            }
        }
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            trackName = trackModel.name
            difficulty = max(100, Int(trackModel.difficulty * 100))
        }
        .onDisappear {
            trackModel.name = trackName
            trackModel.difficulty = Int(difficulty/100)
            trackModel.save()
        }
    }

    private func getTimeBetween(date: Date, and toDate: Date) -> String {
        elapsedTimeFormatter.string(from: date.distance(to: toDate)) ?? "-"
    }

    private func getTimeSinceCreated() -> String {
        return elapsedTimeFormatter.string(from: trackModel.created.distance(to: Date())) ?? "-"
    }
}

struct DifficultySlider: View {
    @Binding var difficulty: Int

    var body: some View {
        ValueSlider(value: $difficulty, in: 100...500)
            .valueSliderStyle(
                HorizontalValueSliderStyle(
                    track: LinearGradient(
                        gradient: Gradient(colors: [.green, .blue, .orange, .yellow, .purple, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                        .frame(height: 8)
                        .cornerRadius(4),
                    thumbSize: CGSize(width: 10, height: 15)
                )
            )
    }
}

struct EditTrackView_Previews: PreviewProvider {
    static var previews: some View {
        let track = TrackStorage.preview.tracks.value[2]
        return Group {
            NavigationView {
                EditTrackView(trackModel: TrackModel(track: track))
            }
            NavigationView {
                EditTrackView(trackModel: TrackModel(track: track)).preferredColorScheme(.dark)
            }
        }

    }
}
