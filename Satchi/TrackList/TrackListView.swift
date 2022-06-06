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

    @State var selectedTrack: Track?
    @State var showEdit = false
    @State private var showMapView = false

    var body: some View {
        //        LazyVStack {
        ScrollView {
            VStack {
                FilteredList(tracks: FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Track.created, ascending: true)],
                                                 predicate: NSPredicate(format: "timeToCreate == 0")),
                             header: "Created tracks",
                             selection: $selectedTrack)
                FilteredList(tracks: FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Track.created, ascending: true)],
                                                 predicate: NSPredicate(format: "timeToCreate > 0 AND timeToFinish == 0")),
                             header: "Started tracks",
                             selection: $selectedTrack)
                FilteredList(tracks: FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Track.created, ascending: true)],
                                                 predicate: NSPredicate(format: "timeToCreate > 0 AND timeToFinish > 0")),
                             header: "Finished tracks",
                             selection: $selectedTrack)
            }

            if selectedTrack != nil {
                NavigationLink("", destination: EditTrackView(selectedTrack!), isActive: $showEdit)
                    .opacity(0)
            }
        }
        .onChange(of: selectedTrack, perform: {track in
            print("selected track \(track?.name ?? "-")")
            if selectedTrack != nil {
                showEdit = true
            }
        })
        .onAppear() {
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
