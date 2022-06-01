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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init() {
        #if DEBUG
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                        FileManager.SearchPathDomainMask.userDomainMask, true)
        print("Path to device content \(paths[0])")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(CoreDataStack.shared)
                .environment(\.managedObjectContext, CoreDataStack.shared.context)

        }
    }
}
