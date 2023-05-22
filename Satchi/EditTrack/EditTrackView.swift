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

    @ObservedObject var theTrack: Track
    private var persistanceController = PersistenceController.shared

    init(_ track: Track) {
        theTrack = track
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
            if theTrack.getState() == .trailTracked {
                Text("Show track")
            } else if theTrack.getState() == .notStarted {
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
                    FieldsView(theTrack: theTrack)
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
        .navigationBarTitle(theTrack.name)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .navigationDestination(for: Track.self) { _ in
            TrackMapView(track: theTrack, preview: false)
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
    @ObservedObject var theTrack: Track

    var body: some View {
        Group {
            HStack {
                TextField("Name", text: $theTrack.name)
                    .font(Font.title2)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: 4)
                        .fill(palette.midBackground)
                    )
            }.padding(.bottom, 18)

            VStack {
                EditRow(textOne: "Created:", textTwo: "\(theTrack.created != nil ? TimeFormatter.dateStringFrom(date: theTrack.created) : "-")")
                EditRow(textOne: "Time to create:", textTwo: "\(TimeFormatter.shortTimeWithSecondsFor(seconds: theTrack.timeToCreate))")
                EditRow(textOne: "Time since created:", textTwo: "\(getTimeSinceCreated())")

            }.padding(.vertical, 4)

            VStack {
                EditRow(textOne: "Length:", textTwo: "\(DistanceFormatter.distanceFor(meters: Double(theTrack.length)))")

                HStack {
                    Text("Difficulty:").frame(alignment: .leading)
                    Spacer()
                    DifficultyView(difficulty: $theTrack.difficulty).frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.padding(.vertical, 4)

            VStack {
                EditRow(textOne: "Track rested:", textTwo: "\(getTimeBetween(date: theTrack.created, and: theTrack.started))")
            }.padding(.vertical, 4)

            VStack {
                EditRow(textOne: "Tracking started:", textTwo: "\(theTrack.started != nil ? TimeFormatter.dateStringFrom(date: theTrack.started!) : "-")")
                EditRow(textOne: "Time to finish:", textTwo: "\(theTrack.timeToFinish > 0 ? TimeFormatter.shortTimeWithSecondsFor(seconds: theTrack.timeToFinish) : "-")")
            }.padding(.vertical, 4)

            Text("Comments:").padding(.bottom, 0)
            TextField("Comments", text: $theTrack.comments)
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
        guard let timeDistance = theTrack.created?.distance(to: Date()) else { return "-" }
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
