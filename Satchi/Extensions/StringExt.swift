//
//  StringExt.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-14.
//

import Foundation

// MARK: String
extension String {
    var isBlank: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
