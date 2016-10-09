//
//  MusicBook.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/3/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import Foundation

// MARK: MusicBook 

struct MusicBook {
    
    // MARK: Properties
    
    let googleID: String
    let title: String
    let subtitle: String?
    let authors: [String]?
    
    let printType: String?
    let pageCount: String?
    let publisher: String?
    let publishedDate: String?
    
    let isbn10: String?
    let isbn13: String?
    
    // TODO: add photo and weblink properties
    let webLink: String?
    let imageLink: String?
    
    // MARK: Initializers
    
    
    // construct a MusicBook from a dictionary
    init(dictionary: [String:AnyObject]) {
        googleID = dictionary[GoogleClient.Constants.GoogleResponseKeys.GoogleID] as! String
        title = dictionary[GoogleClient.Constants.GoogleResponseKeys.Title] as! String
        subtitle = dictionary[GoogleClient.Constants.GoogleResponseKeys.Subtitle] as? String
        authors = dictionary[GoogleClient.Constants.GoogleResponseKeys.Authors] as? [String]
        
        printType = dictionary[GoogleClient.Constants.GoogleResponseKeys.PrintType] as? String
        pageCount = dictionary[GoogleClient.Constants.GoogleResponseKeys.PageCount] as? String
        publisher = dictionary[GoogleClient.Constants.GoogleResponseKeys.Publisher] as? String
        publishedDate = dictionary[GoogleClient.Constants.GoogleResponseKeys.PublishedDate] as? String
        
        isbn10 = dictionary[GoogleClient.Constants.GoogleResponseKeys.isbn10] as? String
        isbn13 = dictionary[GoogleClient.Constants.GoogleResponseKeys.isbn13] as? String
        
        webLink = dictionary[GoogleClient.Constants.GoogleResponseKeys.PreviewLink] as? String
        imageLink = dictionary[GoogleClient.Constants.GoogleResponseKeys.ThumbnailImageLink] as? String
        
    }
    
    static func booksFromResults(_ results: [[String:AnyObject]]) -> [MusicBook] {
        
        var books = [MusicBook]()
        
        // iterate through array of dictionaries, each Book is a dictionary
        for result in results {
            books.append(MusicBook(dictionary: result))
        }
        
        return books
    }
    
    
}

// MARK: - MusicBook: Equatable

extension MusicBook: Equatable {}

func ==(lhs: MusicBook, rhs: MusicBook) -> Bool {
    return lhs.googleID == rhs.googleID
}

