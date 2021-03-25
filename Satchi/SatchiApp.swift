//
//  SatchiApp.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import SwiftUI

@main
struct SatchiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
