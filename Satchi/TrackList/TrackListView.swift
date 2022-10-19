//
//  ContentView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import SwiftUI
import CoreData
import CloudKit

struct TrackListView: View {
    @EnvironmentObject private var stack: CoreDataStack
    @Environment(\.managedObjectContext) var mocc
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.preferredColorPalette) private var palette
    @SectionedFetchRequest(
        sectionIdentifier: \.stateSection,
        sortDescriptors: [SortDescriptor(\.created, order: .reverse)],
        animation: Animation.default
    )

    private var tracks: SectionedFetchResults<StateSection, Track>
    @State private var showMapView = false
    @State var editingTrack: Track?
    @State var sharingTrack: Track?

    var body: some View {
        let sortedSections = tracks.sorted(by: {s1, s2 in
            return s1.id.sortOrder < s2.id.sortOrder
        })
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        return ZStack {
            palette.mainBackground.ignoresSafeArea(.all)
            if tracks.isEmpty {
                NoTracksView(addTrack: $showMapView)
            }else{
                List {
                    ForEach(sortedSections) { section in
                        Section(header: Text(section.id.text)) {
                            ForEach(section,id: \.id) { track in
                                NavigationLink(
                                    destination:{ EditTrackView(track).environmentObject(stack)},
                                    label:{
                                        TrackCellView(deleteFunction: deleteTrackFunction, track: track, waitingForShare: track.id == sharingTrack?.id)
                                    }
                                )
                                .swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        sharingTrack = track
                                        Task{
                                            await shareTrack(track)
                                            sharingTrack = nil
                                        }
                                        print("Runnig by share!!")
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .tint(.green)
                                    Button(role: .destructive) {
                                        deleteTrackFunction(track:track)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }

                                }

                            }
                        }
                        .headerProminence(.increased)
                    }
                    .listRowBackground(palette.midBackground)
                    .hideScroll()
                    .listStyle(.insetGrouped)
                }
            }
        }
        .sheet(item: $editingTrack){
            editingTrack = nil
        } content: { tr in
            if let share = tr.share {
                CloudSharingView(
                    share: share,
                    container: stack.ckContainer,
                    track: tr
                )
            }
        }
        .foregroundColor(palette.primaryText)
        .navigationTitle("Tracks")
        .toolbar {
            HStack {

#if DEBUG
                HStack {
                    Button(action: {
                        environment.palette = Color.Palette.satchi
                    }, label: {
                        RoundedRectangle(cornerRadius: 3)
                            .foregroundColor(Color.Palette.satchi.mainBackground)
                            .frame(width: 15, height: 15)
                            .border(.black)

                    })
                    Button(action: {
                        environment.palette = Color.Palette.darkNature
                    }, label: {
                        RoundedRectangle(cornerRadius: 3)
                            .foregroundColor(Color.Palette.darkNature.mainBackground)
                            .frame(width: 15, height: 15)
                            .border(.black)

                    })
                    Button(action: {
                        environment.palette = Color.Palette.cold
                    }, label: {
                        RoundedRectangle(cornerRadius: 3)
                            .foregroundColor(Color.Palette.cold.mainBackground)
                            .frame(width: 15, height: 15)
                            .border(.black)

                    })
                    Button(action: {
                        environment.palette = Color.Palette.icyGrey
                    }, label: {
                        RoundedRectangle(cornerRadius: 3)
                            .foregroundColor(Color.Palette.icyGrey.mainBackground)
                            .frame(width: 15, height: 15)
                            .border(.black)

                    })
                    Button(action: {
                        environment.palette = Color.Palette.warm
                    }, label: {
                        RoundedRectangle(cornerRadius: 3)
                            .foregroundColor(Color.Palette.warm.mainBackground)
                            .frame(width: 15, height: 15)
                            .border(.black)

                    })

                }
#endif

                Button("Add Track") {
                    showMapView.toggle()
                }
                .foregroundColor(palette.link)
                .padding(0)
            }
        }
        .sheet(isPresented: $showMapView, content: {
            AddTrackView()
        })
    }

    func deleteTrackFunction(track: Track) {
        stack.delete(track)
    }


    // There is an almost identical function in EditTrackView. Should be merged and put in CoreDataStack.
    func shareTrack(_ track:Track) async {
        let task = Task {
            do {
                if track.share == nil {
                    track.share = stack.getShare(track)
                    if track.share == nil {
                        let (_, share, _) = try await stack.persistentContainer.share([track], to: nil)
                        share[CKShare.SystemFieldKey.title] = track.name
                        print("Created share with url:\(String(describing: share.url))")

                        track.share = share
                    }
                }
                if track.share != nil {
                    editingTrack = track
                }
            } catch {
                print("Failed to create share")
            }
        }
        return await task.value
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
    @Binding var addTrack:Bool

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


struct TrackListView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            NavigationView {
                TrackListView()
            }.preferredColorScheme($0)
        }
        .environmentObject(CoreDataStack.preview)
        .environment(\.managedObjectContext, CoreDataStack.preview.context)
        .environment(\.preferredColorPalette, Color.Palette.warm)
    }
}

