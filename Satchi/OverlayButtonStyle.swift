//
//  OverlayButtonStyle.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-12.
//

import Foundation
import SwiftUI

struct OverlayButtonStyle: ButtonStyle {
    var backgroundColor:Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .black)
            .padding(6)
            .frame(minWidth:80)
            .background(backgroundColor)
            .opacity(0.6)
            .cornerRadius(8)        
    }
}
