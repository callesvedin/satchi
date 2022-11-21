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
        sectionIdentifier: \Track.state,
        sortDescriptors: [
            SortDescriptor(\Track.state, order: .forward),
            SortDescriptor(\Track.name, order: .forward)
        ],
        animation: Animation.default
    )

    private var tracks: SectionedFetchResults<Int16, Track>
    @State private var showMapView = false
    @State private var waitingForShareId : UUID?
    @State var sharingTrack: Track?
    @State var selectedTrack: Track?

    var body: some View {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        return ZStack {
            palette.mainBackground.ignoresSafeArea(.all)
            if tracks.isEmpty {
                NoTracksView(addTrack: $showMapView)
            }else{
                List {
                    ForEach(tracks) { section in
                        Section(header: Text(TrackState(rawValue: section.id)!.text())) {
                            ForEach(section,id: \.id) { track in
                                Button(
                                    action:{selectedTrack = track},
                                    label: {
                                        TrackCellView(deleteFunction: deleteTrackFunction, track: track, waitingForShare:track.id == waitingForShareId)
                                    }
                                )
                                .swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        do {
                                            try createShare(track)
                                            print("Runnig by share!!")
                                        }catch{
                                            print("Could not create Share")
                                        }
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

                }
                .listStyle(.automatic)
                .navigationDestination(for: $selectedTrack) { tr in
                    EditTrackView(tr).environmentObject(stack)
                }
            }
        }
        .sheet(item: $sharingTrack){
            sharingTrack = nil
            waitingForShareId = nil
        } content: { tr in
            CloudSharingView(
                container: stack.ckContainer,
                share: tr.share!,
                title: tr.name!
            )
        }
        .foregroundColor(palette.primaryText)
        .navigationTitle("Tracks")        
        .toolbar {
            HStack {

//                ColorSelectionView()
                Button("Add Track") {
                    showMapView.toggle()
                }
                .foregroundColor(palette.link)
                .padding(0)
            }
        }
        .onAppear() {
            stack.save()
        }
        .sheet(isPresented: $showMapView, content: {
            AddTrackView()
        })
    }

    func createShare(_ track:Track) throws {        
        waitingForShareId = track.id

        mocc.perform {
            Task {
                if track.share != nil {
                    return
                }

                let (_, share, _) = try await stack.persistentContainer.share([track], to: nil)
                share[CKShare.SystemFieldKey.title] = track.name
                print("Created share with url:\(String(describing: share.url))")
                sharingTrack = track
                track.share = share
            }
        }

    }

    func deleteTrackFunction(track: Track) {
        stack.delete(track)
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
        let environment = AppEnvironment.shared
        return
//        ForEach(ColorScheme.allCases, id: \.self) {
            NavigationView {
                TrackListView()
            }
//            .preferredColorScheme($0)
//        }
        .environmentObject(CoreDataStack.preview)
        .environment(\.managedObjectContext, CoreDataStack.preview.context)
        .environment(\.preferredColorPalette,environment.palette)
        .environmentObject(environment)
    }
}


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
