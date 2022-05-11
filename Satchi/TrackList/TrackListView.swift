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
    @State private var showMapView = false

    init(viewModel: TrackListViewModel = TrackListViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !viewModel.availableTracks.isEmpty {
                    TrackSectionView(sectionName: "Current")
                        .onTapGesture {
                            print("Header TAP")
                        }
                    Divider().frame(height: 2)
                }
                ForEach(viewModel.availableTracks, id: \.id) { track in
                    NavigationLink(destination: EditTrackView(trackModel: TrackModel(track: track))) {
                        TrackCellView(model: viewModel, track: track)
                    }.buttonStyle(PlainButtonStyle())
                }

                if !viewModel.finishedTracks.isEmpty {
                    TrackSectionView(sectionName: "Finished")
                        .onTapGesture {
                            print("Header TAP")
                        }
                    Divider().frame(height: 2)
                }

                ForEach(viewModel.finishedTracks, id: \.id) { track in
                    NavigationLink(destination: EditTrackView(trackModel: TrackModel(track: track))) {
                        TrackCellView(model: viewModel, track: track)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationTitle("Tracks")
        .toolbar {
            HStack {
                NavigationLink(destination: TrackMapView(trackModel: TrackModel()), isActive: $showMapView) { EmptyView() }
                .isDetailLink(false)

                Button("Add Track") {
                    showMapView = true
                }
                .padding(0)
            }
        }
        .onAppear {
            viewModel.reload()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            NavigationView {
                TrackListView(viewModel:
                                TrackListViewModel.init(
                                    trackPublisher: TrackStorage.preview.tracks.eraseToAnyPublisher())
                )
            }.preferredColorScheme($0)
        }
    }
}
