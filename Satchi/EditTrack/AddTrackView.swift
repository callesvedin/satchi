//
//  AddTrackView.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-14.
//

import SwiftUI
struct AddTrackView: View {
    @Environment(\.preferredColorPalette) private var palette
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    @State private var name: String = ""

    @EnvironmentObject private var stack: CoreDataStack

    var body: some View {
        NavigationView {
            ZStack {
                palette.mainBackground.ignoresSafeArea(.all)
                Form {
                    Section {
                        TextField("Name", text: $name)
                    }
                    .listRowBackground(palette.midBackground)
                    Button {
                        createNewTrack()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                    .foregroundColor(palette.link)
                    .disabled(name.isBlank)
                    .listRowBackground(palette.midBackground)
                }

                .padding(.vertical, 20)
                .hideScroll()
                .submitLabel(.done)
                .onSubmit {
                    createNewTrack()
                    presentationMode.wrappedValue.dismiss()
                }
                .navigationTitle("Add Track")
            }
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
