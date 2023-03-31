//
//  EditTrackView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-05.
//

import CloudKit
import CoreData
import SwiftUI

struct EditTrackView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.preferredColorPalette) private var palette

    @StateObject var viewModel: TrackViewModel
    var theTrack: Track
    private var persistanceController = PersistenceController.shared

    init(_ track: Track) {
        // let tr = persistanceController.privatePersistentStore.get(manageObject: track)
//        var request = NSFetchRequest<NSFetchRequestResult>()
//        request = Track.fetchRequest()
//        request.returnsObjectsAsFaults = false
//        do {
//            let arrayOfData = try persistanceController.persistentContainer.viewContext.fetch(request)
//            let res = arrayOfData.first { r in
//                let resultTrack = r as! Track
//                return track.id == resultTrack.id
//            }
//            if res != nil {
//                theTrack = res as! Track
//            } else {
//                theTrack = track
//            }
//        } catch {
//            // Handle the error!
//            theTrack = track
//        }
        theTrack = track
        _viewModel = StateObject(wrappedValue: TrackViewModel(track))
    }

    var shareButton: some View {
        Button {
            showShareView(track: theTrack)
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .accentColor(palette.link)
    }

    var showMapViewButton: some View {
        NavigationLink(destination: TrackMapView(track: theTrack, preview: false)) {
            if viewModel.state == .trailTracked {
                Text("Show track")
            } else if viewModel.state == .notStarted {
                Text("Lay track")
            } else {
                Text("Follow Track")
            }
        }
        .isDetailLink(false)
        .accentColor(palette.link)
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        PreviewTrackMapView(track: theTrack)
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.bottom, 30)

                        Spacer()
                    }
                    FieldsView(viewModel: viewModel)
                }
            }
        }
        .foregroundColor(palette.primaryText)
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                showMapViewButton
            }
        }
        .background(palette.mainBackground)
        .navigationBarTitle(viewModel.trackName)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .onChange(of: viewModel.difficulty, perform: { _ in
            theTrack.difficulty = viewModel.difficulty
        })
        .onChange(of: viewModel.comments, perform: { _ in
            theTrack.comments = viewModel.comments
        })
        .onChange(of: viewModel.trackName, perform: { _ in
            theTrack.name = viewModel.trackName
        })
        .onAppear {
            viewModel.setValues(theTrack)
        }
        .onDisappear {
            persistanceController.updateTrack(track: theTrack)
        }
    }

    private func showShareView(track: Track) {
        PersistenceController.shared.presentCloudSharingController(track: track)
    }
}

struct EditRow: View {
    var textOne: String
    var textTwo: String

    var body: some View {
        HStack {
            Text(LocalizedStringKey(textOne)).frame(alignment: .leading)
            Spacer()
            Text(LocalizedStringKey(textTwo)).frame(alignment: .trailing)
        }
    }
}

struct FieldsView: View {
    @Environment(\.preferredColorPalette) private var palette
    @ObservedObject var viewModel: TrackViewModel

    var body: some View {
        Group {
            HStack {
                TextField("Name", text: $viewModel.trackName)
                    .font(Font.title2)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: 4)
                        .fill(palette.midBackground)
                    )
            }.padding(.bottom, 18)

            VStack {
                EditRow(textOne: "Created:", textTwo: "\(viewModel.created != nil ? TimeFormatter.dateStringFrom(date: viewModel.created) : "-")")
                EditRow(textOne: "Time to create:", textTwo: "\(TimeFormatter.shortTimeWithSecondsFor(seconds: viewModel.timeToCreate))")
                EditRow(textOne: "Time since created:", textTwo: "\(getTimeSinceCreated())")

            }.padding(.vertical, 4)

            VStack {
                EditRow(textOne: "Length:", textTwo: "\(DistanceFormatter.distanceFor(meters: Double(viewModel.length)))")

                HStack {
                    Text("Difficulty:").frame(alignment: .leading)
                    Spacer()
                    DifficultyView(difficulty: $viewModel.difficulty).frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.padding(.vertical, 4)

            VStack {
                EditRow(textOne: "Track rested:", textTwo: "\(getTimeBetween(date: viewModel.created, and: viewModel.started))")
            }.padding(.vertical, 4)

            VStack {
                EditRow(textOne: "Tracking started:", textTwo: "\(viewModel.started != nil ? TimeFormatter.dateStringFrom(date: viewModel.started!) : "-")")
                EditRow(textOne: "Time to finish:", textTwo: "\(viewModel.timeToFinish > 0 ? TimeFormatter.shortTimeWithSecondsFor(seconds: viewModel.timeToFinish) : "-")")
            }.padding(.vertical, 4)

            Text("Comments:").padding(.bottom, 0)
            TextField("Comments", text: $viewModel.comments)
                .padding()
                .textFieldStyle(PlainTextFieldStyle())
                .frame(minHeight: 80)
                .border(Color.gray, width: 1)
        }
        .font(
            .body
        )
        .padding(.horizontal, 10)
    }

    private func getTimeBetween(date: Date?, and toDate: Date?) -> String {
        guard let fromDate = date, let toDate = toDate else { return "-" }
        return TimeFormatter.shortTimeWithMinutesFor(seconds: fromDate.distance(to: toDate))
    }

    private func getTimeSinceCreated() -> String {
        guard let timeDistance = viewModel.created?.distance(to: Date()) else { return "-" }
        return TimeFormatter.shortTimeWithMinutesFor(seconds: timeDistance)
    }
}

struct EditTrackView_Previews: PreviewProvider {
    static let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
    static var previews: some View {
        let track = Track(context: PersistenceController.shared.persistentContainer.viewContext)
        track.name = "Test-Track"
        track.created = Date()
        track.timeToFinish = 19*60
        track.difficulty = 3
        track.comments = "A little hard..."
        track.timeToCreate = 21*60
        track.started = Date().addingTimeInterval(60*60*3)
        track.length = 1000
        return ForEach(ColorScheme.allCases, id: \.self) { scheme in
            ForEach(localizations, id: \.identifier) { locale in
                NavigationView {
                    EditTrackView(track)
                        .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
                        .previewDisplayName("iPhone 13 \(scheme) \(locale.identifier) ")
                        .preferredColorScheme(scheme)
                        .environment(\.locale, .init(identifier: locale.identifier))
                }
            }
        }
    }
}
