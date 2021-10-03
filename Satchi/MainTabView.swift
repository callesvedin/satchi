//
//  MainTabView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-26.
//

import SwiftUI

struct MainTabView: View {

    var body: some View {
        NavigationView {
            TrackListView()
        }
    }
}

struct MainTabView2: View {
    var body: some View {
        TabView {
            NavigationView {
                TrackListView()
            }
            .tabItem {
                Image(systemName: "map")
                Text("Tracks")
            }
            Text("Dogs view")
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Dogs")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
