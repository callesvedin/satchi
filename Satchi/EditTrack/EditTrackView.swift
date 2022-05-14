//
//  EditTrackView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import SwiftUI
import Sliders

struct EditTrackView: View {
    @Environment(\.presentationMode) var presentationMode
    private var stack = CoreDataStack.shared
    var track: Track
    @StateObject var viewModel = TrackViewModel()
    @FocusState var isFocused: Bool
    let dateFormatter: DateFormatter
    let elapsedTimeFormatter: DateComponentsFormatter
    let shortElapsedTimeFormatter: DateComponentsFormatter
    //    @StateObject var trackModel = TrackModel()
    @Environment(\.managedObjectContext) var managedObjectContext

    init(_ track: Track) {
        self.track = track
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current

        elapsedTimeFormatter = DateComponentsFormatter()
        elapsedTimeFormatter.unitsStyle = .abbreviated
        elapsedTimeFormatter.zeroFormattingBehavior = .dropAll
        elapsedTimeFormatter.allowedUnits = [.day, .hour, .minute]

        shortElapsedTimeFormatter = DateComponentsFormatter()
        shortElapsedTimeFormatter.unitsStyle = .abbreviated
        shortElapsedTimeFormatter.zeroFormattingBehavior = .dropAll
        shortElapsedTimeFormatter.allowedUnits = [.hour, .minute, .second]
        //        trackModel.initialize(with: track)
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {

                    HStack {
                        Spacer()
                        TrackMapView(track: track, preview: true)
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.bottom, 30)
                        Spacer()
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text("**Name**")
                            TextField("Name", text: $viewModel.trackName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        HStack {
                            Text("**Difficulty**: \(viewModel.difficulty)")
                            DifficultySlider(difficulty: $viewModel.difficulty, sliderValue: viewModel.difficulty*100)
                        }
                        .frame(height: 22)
                        .padding(.vertical, 4)
                        Group {
                            Text("**Length**: \(track.length)m").padding(.vertical, 4)
                            Text("**Time to create:** \(shortElapsedTimeFormatter.string(from: track.timeToCreate) ?? "-")")

                                .padding(.vertical, 4)
                            Text("**Created:** \(track.created != nil ? dateFormatter.string(from: track.created!) : "-")")
                                .padding(.vertical, 4)
                            if track.started != nil {
                                Text("""
                            **Track rested:** \
                            \(getTimeBetween(date: track.created, and: track.started))
                            """
                                ).padding(.vertical, 4)
                            } else {
                                Text("**Time since created**:\(getTimeSinceCreated())")
                                    .padding(.vertical, 4)
                            }
                            if track.started != nil {
                                Text("**Tracking started:** \(dateFormatter.string(from: track.started!))")
                                    .padding(.vertical, 4)
                                Text("""
                             **Time to finish:** \
                             \(shortElapsedTimeFormatter.string(from: track.timeToFinish) ?? "**-**")
                             """
                                ).padding(.vertical, 4)
                            }

                        }
                        Text("**Comments:**")
                        TextEditor(text: $viewModel.comments)
                            .font(.body)
                            .frame(minHeight: 80)
                            .border(Color.gray, width: 1)
                    }
                }
            }
            HStack {
                Spacer()
                Button(action: {
                    save()
                    presentationMode.wrappedValue.dismiss()
                }, label: {Text("Save")})
                //                        .buttonStyle(OverlayButtonStyle(backgroundColor: Color.green))
                Spacer()
            }
        }
        .font(Font.system(size: 22))
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: TrackMapView(track: track)) {
                    if viewModel.runningState == .tracked {
                        Text("Show Track")
                    } else if viewModel.runningState == .notCreated {
                        Text("Create track")
                    } else {
                        Text("Follow Track")
                    }
                }
                .isDetailLink(false)
            }
        }
        .navigationBarTitle(viewModel.trackName)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            viewModel.trackName = track.name  ?? ""
            viewModel.comments = track.comments ?? ""
            viewModel.difficulty = max(1, track.difficulty)
            viewModel.setState(pathLaid: !(track.laidPath?.isEmpty ?? true),
                               tracked: !(track.trackPath?.isEmpty ?? true))
        }
    }

    private func getTimeBetween(date: Date?, and toDate: Date?) -> String {
        guard let fromDate = date, let toDate = toDate else {return "-"}
        return elapsedTimeFormatter.string(from: fromDate.distance(to: toDate)) ?? "-"
    }

    private func getTimeSinceCreated() -> String {
        guard let timeDistance = track.created?.distance(to: Date()) else {return "-"}

        return elapsedTimeFormatter.string(from: timeDistance) ?? "-"
    }

    private func save() {
        managedObjectContext.performAndWait {
            track.name = viewModel.trackName
            track.comments = viewModel.comments
            track.difficulty = viewModel.difficulty
            stack.save()
        }
    }
}

struct DifficultySlider: View {
    @Binding var difficulty: Int16
    @State var sliderValue: Int16

    var body: some View {
        ValueSlider(value: $sliderValue, in: 100...500)
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
            .onChange(of: sliderValue) { sliderV in
                print("Value:\(sliderV)")
                if difficulty != sliderV / 100 {
                    print("Changed difficulty:\(difficulty)")
                    difficulty = sliderV / 100
                }
            }
            .onAppear {
                sliderValue = difficulty * 100
            }
    }
}

struct EditTrackView_Previews: PreviewProvider {
    static var previews: some View {
        let track = TrackStorage.preview.tracks.value[2]
        return
        Group {
            ForEach(ColorScheme.allCases, id: \.self) {
                NavigationView {
                    EditTrackView(track)
                }
                .preferredColorScheme($0)
            }
        }
    }
}
