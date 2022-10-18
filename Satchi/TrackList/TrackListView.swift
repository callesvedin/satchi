//
//  ContentView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import SwiftUI
import CoreData

struct TrackListView: View {
    @EnvironmentObject private var stack: CoreDataStack
    @Environment(\.managedObjectContext) var mocc
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.preferredColorPalette) private var palette

    @StateObject private var model = TrackListViewModel()
    @State private var showMapView = false

    var body: some View {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        return ZStack {
            palette.mainBackground.ignoresSafeArea(.all)
            if model.isEmpty() {
                NoTracksView(addTrack: $showMapView)
            }else{
                List {
                    if !model.newTracks.isEmpty {
                        Section(header:Text("Created tracks")) {
                            FilteredList(tracks:$model.newTracks)
                        }.headerProminence(.increased)
                    }
                    if !model.startedTracks.isEmpty {
                        Section(header:Text("Started tracks")) {
                            FilteredList(tracks: $model.startedTracks)
                        }.headerProminence(.increased)
                    }
                    if !model.finishedTracks.isEmpty {
                        Section(header:Text("Finished tracks")) {
                            FilteredList(tracks: $model.finishedTracks)
                        }.headerProminence(.increased)
                    }
                }
                .hideScroll()
                .listStyle(.insetGrouped)
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

