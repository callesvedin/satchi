//
//  Track+CoreDataClass.swift
//  Satchi
//
//  Created by carl-johan.svedin on 2021-09-28.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Track)
public class Track: NSManagedObject {
    var share: CKShare?
}
