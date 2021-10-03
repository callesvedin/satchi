//
//  StartAnnotation.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-04-14.
//

import Foundation
import MapKit

enum PathAnnotationKind {
    case layPathStart,
         layPathStop,
         trackPathStart,
         trackPathStop
}

class PathAnnotation: MKPointAnnotation {
    let kind: PathAnnotationKind
    let reuseIdentifier: String
    let imageIdentifier: String
    let color: UIColor

    init(kind: PathAnnotationKind) {
        self.kind = kind

        switch kind {
        case .layPathStart:
            self.reuseIdentifier = "LayStart"
            self.imageIdentifier = "flag.circle"
            self.color = UIColor.systemGreen
        case .layPathStop:
            self.reuseIdentifier = "LayStop"
            self.imageIdentifier = "flag.circle"
            self.color = UIColor.systemGreen
        case .trackPathStart:
            self.reuseIdentifier = "TrackStart"
            self.imageIdentifier = "figure.walk.circle"
            self.color = UIColor.systemRed
        case .trackPathStop:
            self.reuseIdentifier = "TrackStop"
            self.imageIdentifier = "figure.walk.circle"
            self.color = UIColor.systemRed
        }
    }

}
