//
//  ContentView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import CloudKit
import CoreData
import os.log
import SwiftUI

struct TrackListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var coordinator: ViewCoordinator
    @Environment(\.preferredColorPalette) private var palette
    @Environment(\.colorScheme) private var colorScheme

    @SectionedFetchRequest(
        sectionIdentifier: \Track.state,
        sortDescriptors: [
            SortDescriptor(\Track.state, order: .forward),
            SortDescriptor(\Track.created, order: .reverse),
            SortDescriptor(\Track.name, order: .forward)
        ],
        animation: Animation.default
    )
    private var tracks: SectionedFetchResults<Int16, Track>
    private let persistenceController = PersistenceController.shared

    @State private var waitingForShareId: UUID?

    @AppStorage("systemTheme") private var systemTheme: Int = SchemeType.allCases.first!.rawValue

    private var selectedScheme: ColorScheme? {
        guard let theme = SchemeType(rawValue: systemTheme) else { return nil }
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return nil
        }
    }

    var body: some View {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        return ZStack {
            palette.mainBackground.ignoresSafeArea(.all)
            if tracks.isEmpty {
                NoTracksView(callback: createNewTrack)
            } else {
                List {
                    ForEach(tracks) { section in
                        Section(header: Text(LocalizedStringKey(TrackState(rawValue: section.id)!.text()))) {
                            ForEach(section, id: \.id) { track in
                                Button(
                                    action: {
                                        coordinator.path.append(Destination.editView(track: track))
                                    },
                                    label: {
                                        TrackCellView(deleteFunction: deleteTrack,
                                                      track: track,
                                                      waitingForShare: track.id == waitingForShareId)
                                    }
                                )
                                .swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        showShareView(track: track)
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .tint(.green)
                                    Button(role: .destructive) {
                                        deleteTrack(track)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }
                        .headerProminence(.increased)
                    }
                    .listRowBackground(palette.midBackground)
                }
                .listStyle(.automatic)
                .hideScroll()
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case Destination.editView(track: let track):
                        EditTrackView(track)
                    case .runView(track: let track):
                        TrackMapView(track: track, preview: false)
                    }
                }
            }
        }
        .foregroundColor(palette.primaryText)
        .navigationTitle(LocalizedStringKey("Tracks"))
        .toolbar {
            HStack {
                Button(action: {
                    createNewTrack()
                }, label: {
                    Text("Add track")
                })
                .foregroundColor(palette.link)
                .padding(0)
            }
        }
        .onReceive(NotificationCenter.default.storeDidChangePublisher) { notification in
            processStoreChangeNotification(notification)
        }.preferredColorScheme(selectedScheme)
    }

    private func createNewTrack() {
        let trackName = TimeFormatter.dayDateStringFrom(date: Date())
        if let track = persistenceController.addTrack(name: trackName, context: viewContext) {
            coordinator.path.append(Destination.editView(track: track))
            coordinator.path.append(Destination.runView(track: track))
        } else {
            Logger.listView.warning("Could not create a new track when add button pushed.")
        }
    }

    private func processStoreChangeNotification(_ notification: Notification) {
        let transactions = persistenceController.trackTransactions(from: notification)
        if !transactions.isEmpty {
            persistenceController.mergeTransactions(transactions, to: viewContext)
        }
    }

    private func showShareView(track: Track) {
        PersistenceController.shared.presentCloudSharingController(track: track)
    }

    func deleteTrack(_ track: Track) {
        PersistenceController.shared.delete(track: track)
    }
}

struct HideScrollModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(Visibility.hidden)
        } else {
            content
        }
    }
}

extension View {
    func hideScroll() -> some View {
        modifier(HideScrollModifier())
    }
}

struct NoTracksView: View {
    @Environment(\.preferredColorPalette) private var palette
    var callback: () -> Void
    var body: some View {
        VStack {
            Spacer()
            Text("You have no tracks.")
            Button("Add track") {
                callback()
            }
            .foregroundColor(palette.link)
            Spacer()
        }
    }
}

struct TrackSectionView: View {
    var sectionName: String
    var body: some View {
        HStack {
            Text(sectionName)
                .font(.title3)
                .padding(.horizontal, 8)
                .padding(.top, 32)
                .padding(.bottom, 2)
            Spacer()
        }
    }
}
