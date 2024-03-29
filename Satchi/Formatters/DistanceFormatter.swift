//
//  DistanceFormatter.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-07-08.
//

import Foundation

struct DistanceFormatter {
    private static let measurementFormatter: MeasurementFormatter = {
        let theFormatter = MeasurementFormatter()
        theFormatter.unitStyle = MeasurementFormatter.UnitStyle.short
        theFormatter.unitOptions = MeasurementFormatter.UnitOptions.providedUnit
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        theFormatter.numberFormatter = numberFormatter
        return theFormatter
    }()

    public static func distanceFor(meters: Double) -> String {
        let distanceInMeters = Measurement(value: meters, unit: UnitLength.meters)
        return measurementFormatter.string(from: distanceInMeters)
    }
}
