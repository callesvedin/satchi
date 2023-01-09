//
//  AddTrackView.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-14.
//

import SwiftUI
import CoreData

struct AddTrackView: View {
    @Environment(\.preferredColorPalette) private var palette
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @State private var name: String = ""
    private let persistenceController = PersistenceController.shared

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
                .navigationTitle("Add track")
            }
        }
    }
}

// MARK: Loading image and creating a new destination
extension AddTrackView {

    private func createNewTrack() {
        let controller = persistenceController
        let taskContext = controller.persistentContainer.newTaskContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        controller.addTrack(name:name, context: taskContext)
//        let track = Track(context: managedObjectContext)
//        track.id = UUID()
//        track.name = name
    }
}

struct AddDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        AddTrackView()
    }
}
