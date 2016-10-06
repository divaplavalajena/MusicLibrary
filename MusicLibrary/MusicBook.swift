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
    
    //let googleID: String
    let title: String
    let subtitle: String?
    let authors: [String]?
    let industryIdentifiers: [[String: AnyObject]]?
    let printType: String?
    let pageCount: String?
    let publisher: String?
    let publishedDate: String?
    
    //let isbn10: String!
    //let isbn13: String!
    
    
    // MARK: Initializers
    
    
    // construct a MusicBook from a dictionary
    init(dictionary: [String:AnyObject]) {
        title = dictionary[GoogleClient.Constants.GoogleResponseKeys.Title] as! String
        subtitle = dictionary[GoogleClient.Constants.GoogleResponseKeys.Subtitle] as? String
        authors = dictionary[GoogleClient.Constants.GoogleResponseKeys.Authors] as? [String]
        industryIdentifiers = dictionary[GoogleClient.Constants.GoogleResponseKeys.IndustryIdentifiers] as? [[String: AnyObject]]
        printType = dictionary[GoogleClient.Constants.GoogleResponseKeys.PrintType] as? String
        pageCount = dictionary[GoogleClient.Constants.GoogleResponseKeys.PageCount] as? String
        publisher = dictionary[GoogleClient.Constants.GoogleResponseKeys.Publisher] as? String
        publishedDate = dictionary[GoogleClient.Constants.GoogleResponseKeys.PublishedDate] as? String
        
        //isbn10 = isbnFromDictionary(industryIdentifiers)
        //isbn13 = isbnFromDictionary(industryIdentifiers)
    }
    
    static func booksFromResults(_ results: [[String:AnyObject]]) -> [MusicBook] {
        
        var books = [MusicBook]()
        
        // iterate through array of dictionaries, each Book is a dictionary
        for result in results {
            books.append(MusicBook(dictionary: result))
        }
        
        return books
    }
    
    func isbnFromDictionary(_ results: [[String: AnyObject]]) -> String {
        
        var isbn: String = ""
        
        // iterate through the array of dictionaries, each industry identifier is a dictionary
        // func to assign isbn 10 and 13 to proper variables
        for result in results where  result[GoogleClient.Constants.GoogleResponseKeys.isbnType] as! String == GoogleClient.Constants.GoogleResponseValues.typeISBN10 as String {
            
            isbn = result[GoogleClient.Constants.GoogleResponseKeys.isbnIndetifier] as! String
        }
        
        for result in results where result[GoogleClient.Constants.GoogleResponseKeys.isbnType] as! String == GoogleClient.Constants.GoogleResponseValues.typeISBN13 as String {
            
            isbn = result[GoogleClient.Constants.GoogleResponseKeys.isbnIndetifier] as! String
        }
        
        
        return isbn
    }
    
}

// MARK: - MusicBook: Equatable

// TODO: change Equatable comparison to ISBN if possible??

extension MusicBook: Equatable {}

func ==(lhs: MusicBook, rhs: MusicBook) -> Bool {
    return lhs.title == rhs.title
}

