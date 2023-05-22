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
    @Environment(\.preferredColorPalette) private var palette

    let persistenceController = PersistenceController.shared
    let deleteFunction: DeleteFunction
    var track: Track
    var waitingForShare = false

    let columns = [
        GridItem(.flexible(maximum: 140)),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            HStack {
                Text("\(track.name)")
                    .font(.headline)
                    .bold()
                Spacer()
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "flag.fill").foregroundColor(.green)
                    Text("\(track.created != nil ? itemFormatter.string(from: track.created!) : "--/--/--")")
                }
                Label("\(DistanceFormatter.distanceFor(meters: Double(track.length)))", systemImage: "arrow.left.and.right")

                HStack {
                    Image(systemName: "flag.fill").foregroundColor(.red)
                    if track.started != nil {
                        Text("\(track.started!, formatter: itemFormatter)")
                    } else {
                        Text("--/--/--")
                    }
                }
                Text("Difficulty: \(track.difficulty)")
                if persistenceController.existingShare(track: track) != nil {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .padding(.vertical, 4)
                }
            }.font(.body)
        }
        .padding(.vertical, 10)
        .font(.caption)
        .background(palette.midBackground)
        .overlay {
            ProgressView().opacity(waitingForShare ? 1 : 0)
        }
    }

    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

//
// struct TrackCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        let track = CoreDataStack.preview.getTracks()[0]
//        //        ForEach(ColorScheme.allCases, id: \.self) {
//        TrackCellView(deleteFunction: {_ in }, track: track)
//            .frame(height: 90)
//            .previewDevice(PreviewDevice(rawValue: "iPhone 9"))
//            .previewDisplayName("iPhone 9")
//        //            .preferredColorScheme($0)
//            .environmentObject(CoreDataStack.preview)
//            .environment(\.managedObjectContext, CoreDataStack.preview.context)
//        //        }
//
//    }
// }
