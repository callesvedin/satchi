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
    @StateObject private var model = TrackListViewModel(stack: CoreDataStack.preview)
    @State var selectedTrack: Track?
    @State var showEdit = false
    @State private var showMapView = false

    var body: some View {
        Group {
            if model.isEmpty() {
                VStack {
                    Spacer()
                    Text("You have no tracks.")
                    Button("Add track") {
                        showMapView.toggle()
                    }
                    Spacer()

                }
            }else{
                ScrollView {
                    VStack {
                        NewFilteredList(tracks:$model.newTracks,
                                        header: "New tracks",
                                        selection: $selectedTrack)

                        NewFilteredList(tracks: $model.startedTracks,
                                        header: "Created tracks",
                                        selection: $selectedTrack)

                        NewFilteredList(tracks: $model.finishedTracks,
                                        header: "Finished tracks",
                                        selection: $selectedTrack)
                    }

                    if selectedTrack != nil {
                        NavigationLink("", destination: EditTrackView(selectedTrack!), isActive: $showEdit)
                            .opacity(0)
                    }

                }
            }
        }
        .onChange(of: selectedTrack, perform: {track in
            print("selected track \(track?.name ?? "-")")
            if selectedTrack != nil {
                showEdit = true
            }
        })
        .onChange(of: mocc, perform: {_ in
            print("CHANGED!")
        })
        .onAppear(){
            selectedTrack = nil
        }
        .navigationTitle("Tracks")
        .toolbar {
            HStack {
                Button("Add Track") {
                    showMapView.toggle()
                }
                .padding(0)
            }
        }
        .sheet(isPresented: $showMapView, content: {
            AddTrackView()
        })
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
    }
}
