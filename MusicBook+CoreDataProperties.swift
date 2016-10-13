//
//  MusicBook+CoreDataProperties.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/10/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import Foundation
import CoreData


extension MusicBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MusicBook> {
        return NSFetchRequest<MusicBook>(entityName: "MusicBook");
    }

    @NSManaged public var authors: String?
    @NSManaged public var googleID: String!
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageLink: String?
    @NSManaged public var isbn10: String?
    @NSManaged public var isbn13: String?
    @NSManaged public var pageCount: String?
    @NSManaged public var printType: String?
    @NSManaged public var publishedDate: String?
    @NSManaged public var publisher: String?
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var webLink: String?
    @NSManaged public var dateAdded: NSDate?

}
