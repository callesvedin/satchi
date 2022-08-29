//
//  StartAnnotation.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-14.
//

import Foundation
import MapKit

enum PathAnnotationKind {
    case trailStart,
         trailEnd,
         trackingStart,
         trackingEnd

    func getTitle() -> String {
        switch self {
        case .trailStart:
            return "Start"
        case .trailEnd:
            return "Stop"
        case .trackingStart:
            return "Track Start"
        case .trackingEnd:
            return "Track Stop"
        }
    }

    func getIdentifier() -> String {
        switch self {
        case .trailStart:
            return "TrailStart"
        case .trailEnd:
            return "TrailEnd"
        case .trackingStart:
            return "TrackStart"
        case .trackingEnd:
            return "TrackEnd"
        }
    }
    
}

class PathAnnotation: MKPointAnnotation {
    let kind: PathAnnotationKind
    let reuseIdentifier: String
    let imageIdentifier: String
    let color: UIColor

    init(kind: PathAnnotationKind) {
        self.kind = kind

        switch kind {
        case .trailStart:
            self.imageIdentifier = "flag.circle"
            self.color = UIColor.systemGreen
        case .trailEnd:
            self.imageIdentifier = "flag.circle"
            self.color = UIColor.systemGreen
        case .trackingStart:
            self.imageIdentifier = "figure.walk.circle"
            self.color = UIColor.systemRed
        case .trackingEnd:
            self.imageIdentifier = "figure.walk.circle"
            self.color = UIColor.systemRed
        }
        self.reuseIdentifier = kind.getIdentifier()
        super.init()
        self.title = kind.getTitle()
    }

}
