//
//  ContentView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import SwiftUI
import CoreData

struct TrackListView: View {
    @ObservedObject private var viewModel: TrackListViewModel
    @State var selectedTrack: Track?
    @State var showEdit = false
    @State private var showMapView = false

    init(stack: CoreDataStack = CoreDataStack.shared) {
        viewModel = TrackListViewModel(stack: stack)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !viewModel.newTracks.isEmpty {
                    TrackSectionView(sectionName: "Not started")
                        .onTapGesture {
                            print("Header TAP")
                        }
                    Divider().frame(height: 2)
                }
                ForEach(viewModel.newTracks, id: \.objectID) { track in
                    if track.getState() == .notStarted {
                        TrackCellView(track: track)
                            .onTapGesture {
                                selectedTrack = track
                                showEdit = true
                            }
                    }
                }

                if !viewModel.startedTracks.isEmpty {
                    TrackSectionView(sectionName: "Started")
                        .onTapGesture {
                            print("Header TAP")
                        }
                    Divider().frame(height: 2)
                }
                ForEach(viewModel.startedTracks, id: \.objectID) { track in
                    if track.getState() == .started {
                        TrackCellView(track: track)
                            .onTapGesture {
                                selectedTrack = track
                                showEdit = true
                        }
                    }
                }
                if !viewModel.finishedTracks.isEmpty {
                    TrackSectionView(sectionName: "Finished")
                        .onTapGesture {
                            print("Header TAP")
                        }.padding(.top, 20)
                    Divider().frame(height: 2)

                    ForEach(viewModel.finishedTracks, id: \.objectID) { track in
                        if track.getState() == .finished {
                            TrackCellView(track: track)
                                .onTapGesture {
                                    selectedTrack = track
                                    showEdit = true
                                }
                        }
                    }
                }
            }
            if selectedTrack != nil {
                NavigationLink("", destination: EditTrackView(selectedTrack!), isActive: $showEdit)
                    .opacity(0)
            }
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
                TrackListView(stack: CoreDataStack.preview)
            }.preferredColorScheme($0)
        }.environmentObject(CoreDataStack.preview)
    }
}
