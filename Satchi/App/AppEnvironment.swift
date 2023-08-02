//
//  AppEnvironment.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-09-18.
//

import Foundation
import SwiftUI
import CoreLocation

final class AppEnvironment: ObservableObject {
    static let shared = AppEnvironment()

    @Published var palette: Color.Palette
    var locationManager: CLLocationManager

    init(palette: Color.Palette = Color.Palette.satchi) {
        self.palette = palette
        self.locationManager = CLLocationManager()
    }
}
