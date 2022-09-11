//
//  TrackCellView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-07-12.
//

import SwiftUI

typealias DeleteFunction = (Track) -> Void

struct TrackCellView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var stack: CoreDataStack

    let deleteFunction: DeleteFunction
    var track: Track
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            HStack {
                Text("\(track.name ?? "")")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: {
                    withAnimation {
                        deleteFunction(track)
                    }
                }, label: {
                    Image(systemName: "trash").font(.system(size: 16))
                })
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "flag.fill").foregroundColor(.green)
                    Text("\(track.created != nil ? itemFormatter.string(from: track.created!) : "--/--/--" )")
                    Spacer()
                }
                Label("\(DistanceFormatter.distanceFor(meters: Double(track.length)))", systemImage: "arrow.left.and.right")

                HStack {
                    Image(systemName: "flag.fill").foregroundColor(.red)
                    if track.started != nil {
                        Text("\(track.started!, formatter: itemFormatter)")
                    } else {
                        Text("--/--/--")
                    }
                    Spacer()
                }
                Text("Difficulty:\(track.difficulty)")
                if stack.isShared(object: track) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .font(.caption)
        .background(Color(.systemBackground))
        .clipped()
        .cornerRadius(5)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: UIScreen.main.bounds.height - 330)
        .shadow(color: Color.gray, radius: 5, x: 0, y: 4)
        .padding(8)
    }

    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        //    formatter.timeStyle = .medium
        return formatter
    }()
}

 struct TrackCellView_Previews: PreviewProvider {
    static var previews: some View {
        let track = CoreDataStack.preview.getTracks()[0]
//        ForEach(ColorScheme.allCases, id: \.self) {
        TrackCellView(deleteFunction: {_ in }, track: track).frame(height: 90)
//            .preferredColorScheme($0)
            .environmentObject(CoreDataStack.preview)
                .environment(\.managedObjectContext, CoreDataStack.preview.context)
//        }
    }
 }
