//
//  DateComparable.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/6/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import Foundation

extension NSDate: Comparable { }

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqual(to: rhs as Date)
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs as Date) == .orderedAscending
}
