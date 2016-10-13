//
//  Constants.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 9/29/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import Foundation
import UIKit

extension GoogleClient {
    
    // MARK: - Constants
    
    struct Constants {
        
        // MARK: Google
        struct Google {
            static let APIScheme = "https"
            static let APIHost = "www.googleapis.com"
            static let APIPath = "/books/v1/"
            
        }
        
        // MARK: Methods
        struct Methods {
            // MARK: Search
            static let Search = "volumes"
        }
        
        // MARK: Google Parameter Keys
        struct GoogleParameterKeys {
            
            static let APIKey = "key"
            static let SearchMethodKey = "q"
            static let ISBN = "isbn:"
            static let JSONCallback = "callback"
            
        }
        
        // MARK: Google Parameter Values
        struct GoogleParameterValues {
            static let SearchMethodValue = ""
            static let APIKey = "AIzaSyAcmcez-BwQI4iRIBBlhgtkc872zYgzZ5w"
            
        }
        
        // MARK: Google Response Keys
        struct GoogleResponseKeys {
            //static let Status = "stat"
            
            static let Items = "items"
            static let TotalItems = "totalItems"
            static let GoogleID = "id"
            
            static let VolumeInfo = "volumeInfo"
            
            static let Title = "title"
            static let Subtitle = "subtitle"
            static let Authors = "authors"
            static let IndustryIdentifiers = "industryIdentifiers"
            static let PrintType = "printType"
            static let PageCount = "pageCount"
            static let Publisher = "publisher"
            static let PublishedDate = "publishedDate"
            
            static let isbnType = "type"
            static let isbnIdentifier = "identifier"
            
            static let isbn10 = "ISBN_10"
            static let isbn13 = "ISBN_13"
            
            static let PreviewLink = "previewLink"
            static let ImageLinks = "imageLinks"
            static let ThumbnailImageLink = "thumbnail"
        }
        
        // MARK: Google Response Values
        struct GoogleResponseValues {
            //static let OKStatus = "ok"
            
            static let typeISBN10 = "ISBN_10"
            static let typeISBN13 = "ISBN_13"
        }

    }
}
