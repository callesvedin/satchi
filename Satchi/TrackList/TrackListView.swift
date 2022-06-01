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
                if !viewModel.tracks.filter({$0.getState() == .notStarted}).isEmpty {
                    TrackSectionView(sectionName: "Created tracks")
                    Divider().frame(height: 2)
                }
                ForEach(Array(viewModel.tracks.filter({$0.getState() == .notStarted}).enumerated()), id: \.element) { (_, track)  in
                    TrackCellView(deleteFunction: deleteTrackFunction, track: track)
                        .onTapGesture {
                            selectedTrack = track
                            showEdit = true
                        }
                }

                if !viewModel.tracks.filter({$0.getState() == .started}).isEmpty {
                    TrackSectionView(sectionName: "Started tracks")
                    Divider().frame(height: 2)
                }
                ForEach(Array(viewModel.tracks.filter({$0.getState() == .started}).enumerated()), id: \.element) { (_, track)  in
                    TrackCellView(deleteFunction: deleteTrackFunction, track: track)
                        .onTapGesture {
                            selectedTrack = track
                            showEdit = true
                        }

                }
                if !viewModel.tracks.filter({$0.getState() == .finished}).isEmpty {
                    TrackSectionView(sectionName: "Finished tracks")
                        .padding(.top, 20)
                    Divider().frame(height: 2)

                    ForEach(Array(viewModel.tracks.filter({$0.getState() == .finished}).enumerated()), id: \.element) { (_, track)  in
                        TrackCellView(deleteFunction: deleteTrackFunction, track: track)
                            .onTapGesture {
                                selectedTrack = track
                                showEdit = true
                            }
                    }
                }
            }
            .transition(.scale)

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

    func deleteTrackFunction(track: Track) {
        viewModel.tracks.remove(at: viewModel.tracks.firstIndex(of: track)!)
        viewModel.stack.delete(track)
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
