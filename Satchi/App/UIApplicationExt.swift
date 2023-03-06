//
//  UIApplicationExt.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-01-12.
//

import Foundation
import UIKit

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
}
