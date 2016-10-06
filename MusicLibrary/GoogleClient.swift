//
//  GoogleClient.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 9/29/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import Foundation


// MARK: GoogleClient : NSObject

class GoogleClient : NSObject {
    
    // MARK: Properties
    var dates = [Date]()
    var dateIntervalFormatter = DateIntervalFormatter()
    dateIntervalFormatter.dateStyle = NSDateIntervalFormatterShortStyle
    var dateComponentsFormatter = DateComponentsFormatter()
    dateComponentsFormatter.unitsStyle = .Full
    
    
    // shared session
    var session = URLSession.shared
    

    // MARK: Google API
    
    //Get a random page number of pages searched on Flickr
    func getBookFromGoogleBySearchISBN(_ isbn: String, completionHandlerForGoogleSearch: @escaping (_ resultsISBN: [MusicBook]?, _ error: NSError?) -> Void) {
        
        let isbnQuery = "isbn:" + isbn
        print(isbnQuery)
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let queryParameters: [String : AnyObject] = [
            Constants.GoogleParameterKeys.SearchMethodKey : isbnQuery as AnyObject,
            Constants.GoogleParameterKeys.APIKey: Constants.GoogleParameterValues.APIKey as AnyObject
        ]
        
        
        
        /* 2. Make the request */
        let _ = taskForGETMethod(Constants.Methods.Search, parameters: queryParameters) { (result, error) in
            
            /* 3. Send the desired value(s) to completion handler or print to console */
            func displayError(_ error: String) {
                print("*****************   HERE IS THE ERROR FOR taskForGetMethod  ********************************")
                print(error)
            }
            if let error = error {
                completionHandlerForGoogleSearch(nil, error)
            } else {
                print("**************** Result of JSON parsing from taskToGetMethod before further parsing into objects  ***************************")
                print(result)
                
                //How many items does the search return??
                if let numberOfBooks = result?[GoogleClient.Constants.GoogleResponseKeys.TotalItems] as? Int {
                    print("*********  The number of books returned from ISBN search is: \(numberOfBooks)  ******************")
                    
                    //TODO: Create if statement that if there is more than one entry returned to use one with most recent publish by date
                    //**************************        ***************************     **********************************
                    
                    if numberOfBooks > 1 {
                        
                        /* GUARD: Is "items" key in our result? */
                        if let items = result?[GoogleClient.Constants.GoogleResponseKeys.Items] as? [[String:AnyObject]] {
                            print("**********  The 'items' returned in booksInfoDictionaries  ***********************")
                            print(items)
                            
                            for book in items {
                                if let googleBookID = book[GoogleClient.Constants.GoogleResponseKeys.GoogleID] as? String {
                                    print("***************************  The 'googleBookID' returned in the search results  ***********************")
                                    print(googleBookID)
                                
                                    if let singleBookVolumeInfo = book[GoogleClient.Constants.GoogleResponseKeys.VolumeInfo] as? [String:AnyObject] {
                                        print("**************************  The 'singleBookVolumeInfo' returned in the search results  ***********************")
                                        print(singleBookVolumeInfo)
                                        
                                        if let publishedDate = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.PublishedDate] as? String {
                                            print("**********************************  The 'publishedDate' returned in the search results  ***********************")
                                            print(publishedDate)
                                            //convert date string to type date
                                            dates.append(publishedDate)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    completionHandlerForGoogleSearch(nil, error)
                }
                
                
                /* GUARD: Is "items" key in our result? */
                /*
                if let booksInfoDictionaries = result?[GoogleClient.Constants.GoogleResponseKeys.Items] as? [[String:AnyObject]] {
                    print("**********  The 'items' returned in the search results  ***********************")
                    print(booksInfoDictionaries)
                    
                    //TODO: After if statement above finds one book for the ISBN, get the googleID and use that to iterate over info for book
                    //**************************        ***************************     **********************************
                    
                    
                    //need to store one more level of parsing - from volumeInfo tag in JSON
                    //But also need to store google book ID for two books with same ISBN but different google ID's BUT -
                    //  that happens BEFORE accessing volumeInfo
                    //????????????
                    /*
                    // TODO: fix this below so correct object from parsed JSON data gets used for data
                    let books = MusicBook.booksFromResults(booksInfoDictionaries)
                    print("************* This is the info iterated over. *********")
                    print(books)
                    completionHandlerForGoogleSearch(books, nil)
                    */
                } else {
                    //error if the parsing didn't provide good info to photosDictionary
                    completionHandlerForGoogleSearch(nil, error)
                }
                */
                */
            }
        }
    }

    
    // MARK: GET
    
    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
        //parametersWithApiKey[Constants.GoogleParameterKeys.APIKey] = Constants.GoogleParameterValues.APIKey as AnyObject?
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: googleURLFromParameters(parametersWithApiKey, withPathExtension: method))
        print("**********  THIS SHOULD BE THE URL FOR THE NETWORKING CODE!!  ************")
        print(request)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // create a URL from parameters
    private func googleURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = GoogleClient.Constants.Google.APIScheme
        components.host = GoogleClient.Constants.Google.APIHost
        components.path = GoogleClient.Constants.Google.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }


    // MARK: Shared Instance
    
    class func sharedInstance() -> GoogleClient {
        struct Singleton {
            static var sharedInstance = GoogleClient()
        }
        return Singleton.sharedInstance
    }
    
    

    
}



