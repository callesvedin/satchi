//
//  ContentView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import SwiftUI
import CoreData

struct TrackListView: View {
    
    @ObservedObject private var viewModel:TrackListViewModel
    
    init(viewModel: TrackListViewModel = TrackListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ScrollView {
            LazyVStack(spacing: 0) {
                TrackSectionView(sectionName: "Current")
                    .onTapGesture {
                        print("Header TAP")
                    }
                Divider().frame(height: 2)
                
                ForEach(viewModel.availableTracks) { track in
                    
                    TrackCellView(track: track)
                        .cornerRadius(10)
                        .onTapGesture {
                            print("TAP TAP")
                        }
                    //                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
                
                
                TrackSectionView(sectionName: "Finished")
                    .onTapGesture {
                        print("Header TAP")
                    }
                Divider().frame(height: 2)
                
                ForEach(viewModel.finishedTracks) { track in
                    TrackCellView(track: track)
                        .cornerRadius(10)
                        .onTapGesture {
                            print("TAP TAP")
                        }
                    //                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
                
                //            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            
        }
        .navigationTitle("Dog tracks")
        .toolbar {
            HStack {
                Button(action: addTrack) {
                    Label("Add Track", systemImage: "plus")
                }
            }
        }
        
    }
    
    
    
    
    private func addTrack() {
        withAnimation {
            TrackStorage.shared.add(name: "NEW!")
        }
    }
    
    private func deleteTracks(offsets: IndexSet) {
        withAnimation {
            TrackStorage.shared.delete(tracks:offsets)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    //    formatter.timeStyle = .medium
    return formatter
}()


struct TrackSectionView:View {
    var sectionName:String
    var body: some View {
        HStack {
            Text(sectionName)
                .font(.title3)
                .padding(.horizontal,8)
                .padding(.top, 32)
                .padding(.bottom, 2)
            Spacer()
        }
    }
}

struct TrackCellView: View {
    var track:Track
    
    var body: some View {
        HStack {
            VStack(alignment:.leading)
            {
                Text("\(track.name ?? "")").bold()
                HStack {
                    Image(systemName: "flag.fill").foregroundColor(.green)
                    Text("\(track.created!, formatter: itemFormatter)")
                    Image(systemName: "flag.fill").foregroundColor(.red)
                    if track.finished != nil {
                        Text("\(track.finished!, formatter: itemFormatter)")
                    }else{
                        Text("--/--/--")
                    }
                }
                .font(.caption)
                
            }
            Spacer()
            
        }
        .padding()
        .background(Color(.white))
        .clipped()
        .cornerRadius(5)
        .shadow(color: Color.gray, radius: 5, x: 0, y: 4)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: UIScreen.main.bounds.height - 330)
        .padding(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TrackListView(viewModel: TrackListViewModel.init(trackPublisher: TrackStorage.preview.tracks.eraseToAnyPublisher()))
        }
    }
}
