//
//  AddTrackView.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-14.
//

import SwiftUI
struct AddTrackView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var name: String = ""

    @EnvironmentObject private var stack: CoreDataStack

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Name", text: $name)
                    } footer: {
                        Text("Name is required")
                            .font(.caption)
                            .foregroundColor(name.isBlank ? .red : .clear)
                    }
                    Button {
                        createNewTrack()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled(name.isBlank)

                }

            }.navigationTitle("Add Track")
        }
    }
}

// MARK: Loading image and creating a new destination
extension AddTrackView {

    private func createNewTrack() {
        let track = Track(context: managedObjectContext)
        track.id = UUID()
        track.name = name

        stack.save()
    }
}

struct AddDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        AddTrackView()
    }
}
