//
//  TrackTransformer.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-06-20.
//

import Foundation
import CoreLocation

class TrackTransformer:ValueTransformer
{
    
    open override class func transformedValueClass() -> AnyClass {
        return CLLocation.self
    }
    
    open override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    
    open override func transformedValue(_ value: Any?) -> Any? {
        guard let location = value as? CLLocation else {
            print("Expected a CLLocation found \(value.debugDescription)")
            return nil
        }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
            return data
        } catch {
            assertionFailure("Failed to transform `CLLocation` to `Data`")
            return nil
        }
        
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
           guard let data = value as? NSData else { return nil }
           
           do {
               let location = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data as Data)
               return location
           } catch {
               assertionFailure("Failed to transform `Data` to `CLLocation`")
               return nil
           }
       }
    
}

extension TrackTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: TrackTransformer.self))

    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = TrackTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
