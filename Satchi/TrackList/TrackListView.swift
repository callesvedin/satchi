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
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var environment: AppEnvironment
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

    @State private var showMapView = false
    @State private var waitingForShareId: UUID?
    @State var selectedTrack: Track?

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
                .navigationDestination(for: $selectedTrack) { tr in
                    EditTrackView(tr)
                }
            }
        }
        .foregroundColor(palette.primaryText)
        .navigationTitle(LocalizedStringKey("Tracks"))
        .toolbar {
            HStack {
                HStack {
                    //            Button(action: {
                    //                environment.palette = Color.Palette.satchi
                    //                print("Changed color palette to \(environment.palette)")
                    //            }, label: {
                    //                RoundedRectangle(cornerRadius: 3)
                    //                    .foregroundColor(Color.Palette.satchi.mainBackground)
                    //                    .frame(width: 15, height: 15)
                    //                    .border(.black)
                    //
                    //            })
                }
                Button(action: { showMapView.toggle() }, label: { Text("Add track") })
                    .foregroundColor(palette.link)
                    .padding(0)
            }
        }
        .sheet(isPresented: $showMapView, content: {
            AddTrackView()
        })
        .onReceive(NotificationCenter.default.storeDidChangePublisher) { notification in
            processStoreChangeNotification(notification)
        }.preferredColorScheme(selectedScheme)
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

// struct ColorSelectionView: View {
//    @EnvironmentObject var environment: AppEnvironment
//    var body: some View {
// #if DEBUG
//        HStack {
////            Button(action: {
////                environment.palette = Color.Palette.satchi
////                print("Changed color palette to \(environment.palette)")
////            }, label: {
////                RoundedRectangle(cornerRadius: 3)
////                    .foregroundColor(Color.Palette.satchi.mainBackground)
////                    .frame(width: 15, height: 15)
////                    .border(.black)
////
////            })
//            Button(action: {
//                print("Changed mode to dark")
//                systemTheme = .dark
//            }, label: {
//                Text("Dark")
//            })
//        }
// #endif
//    }
// }

enum SchemeType: Int, Identifiable, CaseIterable {
    var id: Self { self }
    case system
    case light
    case dark
}

extension SchemeType {
    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}
