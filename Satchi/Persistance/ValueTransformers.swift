//
//  ValueTransformers.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2023-03-21.
//

import CoreLocation
import Foundation

@objc(MyTestClassValueTransformer)
final class CLLocationValueTransformer: NSSecureUnarchiveFromDataTransformer {
    // The name of the transformer. This is what we will use to register the transformer `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: CLLocationValueTransformer.self))

    // Our class `Test` should in the allowed class list. (This is what the unarchiver uses to check for the right class)
    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, CLLocation.self]
    }

    /// Registers the transformer.
    public static func register() {
        let transformer = CLLocationValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
