//
//  SatchiApp.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import SwiftUI
import os

@main
struct SatchiApp: App {
    let syncMonitor = SyncMonitor()
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    private let persistentContainer = PersistenceController.shared.persistentContainer

    @ObservedObject var environment = AppEnvironment.shared

    init() {
        #if DEBUG
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                        FileManager.SearchPathDomainMask.userDomainMask, true)
        print("Path to device content \(paths[0])")
        #endif
    }

    var body: some Scene {
        #if InitializeCloudKitSchema
        WindowGroup {
            Text("Initializing CloudKit Schema...").font(.title)
            Text("Stop after Xcode says 'no more requests to execute', " +
                 "then check with CloudKit Console if the schema is created correctly.").padding()
        }
        #else
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext,persistentContainer.viewContext)
                .environment(\.preferredColorPalette,environment.palette)
                .environmentObject(environment)
        }
        #endif
    }
}
