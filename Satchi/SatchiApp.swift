//
//  SatchiApp.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-25.
//

import SwiftUI


class NavigationHelper: ObservableObject {
    @Published var selection: String? = nil {
        didSet {
            print("NavigationHelper selection changed to \(selection ?? "-")")
        }
    }
}


@main
struct SatchiApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainTabView().environmentObject(NavigationHelper())
        }
    }
}

