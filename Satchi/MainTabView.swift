//
//  MainTabView.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-03-26.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.preferredColorPalette) private var palette
    var body: some View {
        setNavigationColors(background: palette.mainBackground, text: palette.primaryText)

        return NavigationView {
            TrackListView()
        }
        .navigationViewStyle(.stack)
        .id(palette.name)
        .accentColor(palette.link)        
    }
}

fileprivate func setNavigationColors(background:Color, text:Color) {
    let backgroundColor = UIColor(background)

    let textColor = UIColor(text)
    //      let textColor = UIColor.green
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithTransparentBackground()
    coloredAppearance.backgroundColor = backgroundColor
    coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
    coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]
    if #available(iOS 15.0, *) {
        UINavigationBar.appearance().compactScrollEdgeAppearance = coloredAppearance
    }
    UINavigationBar.appearance().standardAppearance = coloredAppearance
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    UINavigationBar.appearance().tintColor = textColor

}
//
//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//            .environmentObject(CoreDataStack.preview)
//            .environment(\.managedObjectContext, CoreDataStack.preview.context)
//
//    }
//}
