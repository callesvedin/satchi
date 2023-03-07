//
//  NotificationCenter.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2023-03-07.
//

import Combine
import Foundation

extension NotificationCenter {
    var storeDidChangePublisher: Publishers.ReceiveOn<NotificationCenter.Publisher, DispatchQueue> {
        return publisher(for: .cdcksStoreDidChange).receive(on: DispatchQueue.main)
    }
}
