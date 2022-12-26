//
//  OverlayButtonStyle.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-12.
//

import Foundation
import SwiftUI

struct OverlayButtonStyle: ButtonStyle {
    var backgroundColor: Color
    @Environment(\.isEnabled) var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .black.opacity(isEnabled ? 1.0:0.4))
            .padding(6)
            .frame(minWidth: 80)
            .background(backgroundColor.opacity(isEnabled ? 0.8:0.4))
            .cornerRadius(8)
    }
}
