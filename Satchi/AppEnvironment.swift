//
//  AppEnvironment.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-09-18.
//

import Foundation
import SwiftUI

final class AppEnvironment: ObservableObject {
    static let shared = AppEnvironment()

    @Published var palette: Color.Palette

    init(palette: Color.Palette = Color.Palette.cold) {
        self.palette = palette
    }
}
