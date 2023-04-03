//
//  ViewCoordinator.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2023-04-01.
//

import Foundation
import SwiftUI

class ViewCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func gotoRoot() {
        path.removeLast(path.count)
    }
}

enum Destination: Hashable {
    case editView(track: Track)
    case runView(track: Track)
}
