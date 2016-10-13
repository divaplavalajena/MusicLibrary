//
//  MusicBook+CoreDataClass.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/10/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import Foundation
import CoreData


public class MusicBook: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: context)
    }
    
    // construct a MusicBook from a dictionary
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "MusicBook", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // Dictionary
        googleID = dictionary[GoogleClient.Constants.GoogleResponseKeys.GoogleID] as! String
        title = dictionary[GoogleClient.Constants.GoogleResponseKeys.Title] as? String
        subtitle = dictionary[GoogleClient.Constants.GoogleResponseKeys.Subtitle] as? String
        authors = dictionary[GoogleClient.Constants.GoogleResponseKeys.Authors] as? String
        
        printType = dictionary[GoogleClient.Constants.GoogleResponseKeys.PrintType] as? String
        pageCount = dictionary[GoogleClient.Constants.GoogleResponseKeys.PageCount] as? String
        publisher = dictionary[GoogleClient.Constants.GoogleResponseKeys.Publisher] as? String
        publishedDate = dictionary[GoogleClient.Constants.GoogleResponseKeys.PublishedDate] as? String
        
        isbn10 = dictionary[GoogleClient.Constants.GoogleResponseKeys.isbn10] as? String
        isbn13 = dictionary[GoogleClient.Constants.GoogleResponseKeys.isbn13] as? String
        
        webLink = dictionary[GoogleClient.Constants.GoogleResponseKeys.PreviewLink] as? String
        imageLink = dictionary[GoogleClient.Constants.GoogleResponseKeys.ThumbnailImageLink] as? String
        
        imageData = dictionary["imageData"] as? NSData
        dateAdded = dictionary["dateAdded"] as? NSDate
    }
    
        /**
        func booksFromResults(_ results: [[String:AnyObject]]) -> [MusicBook] {
            
            var books = [MusicBook]()
            
            // iterate through array of dictionaries, each Book is a dictionary
            for result in results {
                books.append(MusicBook(context: result))
            }
            
            return books
        }
        **/

}

    /**
    // MARK: - MusicBook: Equatable
    
    extension MusicBook: Equatable {}
    
    static func ==(lhs: MusicBook, rhs: MusicBook) -> Bool {
        return lhs.googleID == rhs.googleID
    }
    **/
