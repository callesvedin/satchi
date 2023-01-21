//
//  ContentView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import CloudKit
import CoreData
import SwiftUI

struct TrackListView: View {
//    @EnvironmentObject private var stack: CoreDataStack
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.preferredColorPalette) private var palette
    @SectionedFetchRequest(
        sectionIdentifier: \Track.state,
        sortDescriptors: [
            SortDescriptor(\Track.state, order: .forward),
            SortDescriptor(\Track.name, order: .forward)
        ],
        animation: Animation.default
    )
    private var tracks: SectionedFetchResults<Int16, Track>
    private let persistenceController = PersistenceController.shared

    @State private var showMapView = false
    @State private var waitingForShareId: UUID?
    @State var sharingTrack: Track?
    @State var selectedTrack: Track?

    var body: some View {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        return ZStack {
            palette.mainBackground.ignoresSafeArea(.all)
            if tracks.isEmpty {
                NoTracksView(addTrack: $showMapView)
            } else {
                List {
                    ForEach(tracks) { section in
                        Section(header: Text(LocalizedStringKey(TrackState(rawValue: section.id)!.text()))) {
                            ForEach(section, id: \.id) { track in
                                Button(
                                    action: { selectedTrack = track },
                                    label: {
                                        TrackCellView(deleteFunction: deleteTrack, track: track, waitingForShare: track.id == waitingForShareId)
                                    }
                                )
                                .swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        createNewShare(track: track)
                                        print("Runnig by share!!")
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
                .navigationDestination(for: $selectedTrack) { tr in
                    EditTrackView(tr)
                }
            }
        }
        .sheet(item: $sharingTrack) {
            sharingTrack = nil
            waitingForShareId = nil
        } content: { _ in
//            CloudSharingView(
//                container: stack.ckContainer,
//                share: tr.share!,
//                title: tr.name!
//            )
        }
        .foregroundColor(palette.primaryText)
        .navigationTitle(LocalizedStringKey("Tracks"))
        .toolbar {
            HStack {
//                ColorSelectionView()
                Button(action: { showMapView.toggle() }, label: { Text("Add track") })
                    .foregroundColor(palette.link)
                    .padding(0)
            }
        }
//        .onAppear() {
//            stack.save()
//        }
        .sheet(isPresented: $showMapView, content: {
            AddTrackView()
        })
        .onReceive(NotificationCenter.default.storeDidChangePublisher) { notification in
            processStoreChangeNotification(notification)
        }
    }

    private func processStoreChangeNotification(_ notification: Notification) {
        let transactions = persistenceController.trackTransactions(from: notification)
        if !transactions.isEmpty {
            persistenceController.mergeTransactions(transactions, to: viewContext)
        }
    }

    private func createNewShare(track: Track) {
        PersistenceController.shared.presentCloudSharingController(track: track)
    }

    private func manageParticipation(track: Track) {
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
    @Binding var addTrack: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("You have no tracks.")
            Button("Add track") {
                addTrack.toggle()
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

//
//
// struct TrackListView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let environment = AppEnvironment.shared
//        return
//        ForEach(ColorScheme.allCases, id: \.self) {
//            NavigationView {
//                TrackListView()
//            }.previewDevice(PreviewDevice(rawValue: "iPhone 14")).previewDisplayName("iPhone 14")
//            .preferredColorScheme($0)
//            NavigationView {
//                TrackListView()
//            }.previewDevice(PreviewDevice(rawValue: "iPhone 13 ios 15.5")).previewDisplayName("iPhone 13 ios15")
//            .preferredColorScheme($0)
//        }
//        .environment(\.locale, .init(identifier: "sv"))
//        .environmentObject(CoreDataStack.preview)
//        .environment(\.managedObjectContext, CoreDataStack.preview.context)
//        .environment(\.preferredColorPalette,environment.palette)
//        .environmentObject(environment)
//    }
// }

struct ColorSelectionView: View {
    @EnvironmentObject var environment: AppEnvironment
    var body: some View {
#if DEBUG
        HStack {
            Button(action: {
                environment.palette = Color.Palette.satchi
                print("Changed color palette to \(environment.palette)")
            }, label: {
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(Color.Palette.satchi.mainBackground)
                    .frame(width: 15, height: 15)
                    .border(.black)

            })
//            Button(action: {
//                environment.palette = Color.Palette.darkNature
//                print("Changed color palette to \(environment.palette)")
//            }, label: {
//                RoundedRectangle(cornerRadius: 3)
//                    .foregroundColor(Color.Palette.darkNature.mainBackground)
//                    .frame(width: 15, height: 15)
//                    .border(.black)
//
//            })
//            Button(action: {
//                environment.palette = Color.Palette.cold
//                print("Changed color palette to \(environment.palette)")
//            }, label: {
//                RoundedRectangle(cornerRadius: 3)
//                    .foregroundColor(Color.Palette.cold.mainBackground)
//                    .frame(width: 15, height: 15)
//                    .border(.black)
//
//            })
//            Button(action: {
//                environment.palette = Color.Palette.icyGrey
//                print("Changed color palette to \(environment.palette)")
//            }, label: {
//                RoundedRectangle(cornerRadius: 3)
//                    .foregroundColor(Color.Palette.icyGrey.mainBackground)
//                    .frame(width: 15, height: 15)
//                    .border(.black)
//
//            })
//            Button(action: {
//                environment.palette = Color.Palette.warm
//                print("Changed color palette to \(environment.palette)")
//            }, label: {
//                RoundedRectangle(cornerRadius: 3)
//                    .foregroundColor(Color.Palette.warm.mainBackground)
//                    .frame(width: 15, height: 15)
//                    .border(.black)
//
//            })
        }
#endif
    }
}
