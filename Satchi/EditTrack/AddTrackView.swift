//
//  AddTrackView.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-14.
//

import CoreData
import SwiftUI

struct AddTrackView: View {
    @Environment(\.preferredColorPalette) private var palette
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @State private var name: String = TimeFormatter.dayDateStringFrom(date: Date())
    private let persistenceController = PersistenceController.shared
    var trackAdded: (String?) -> Void

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

// MARK: Createing a new track

extension AddTrackView {
    private func createNewTrack() {
//        let taskContext = persistenceController.persistentContainer.newTaskContext()
//        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        let track = persistenceController.addTrack(name: name, context: taskContext)
        trackAdded(name)
    }
}

struct AddTrackView_Previews: PreviewProvider {
    static var previews: some View {
        AddTrackView { _ in }
    }
}
