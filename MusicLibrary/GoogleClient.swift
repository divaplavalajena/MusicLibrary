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
    var bookInfoDictionary = [[String:AnyObject]]()
    
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
                print(error)
            }
            if let error = error {
                completionHandlerForGoogleSearch(nil, error)
            } else {
                print("**************** Result of JSON parsing from taskToGetMethod before further parsing into objects  ***************************")
                print(result)
                
                //How many items does the search return??
                //TODO: If more than one item returned in search, give user option to choose which one to save in library
                guard let numberOfBooks = result?[GoogleClient.Constants.GoogleResponseKeys.TotalItems] as? Int else {
                    displayError("Number of books - number of TotalItems not returned in JSON parsing of:   ********************")
                    print(result)
                    return
                }
                print("*********  The number of books returned from ISBN search is: \(numberOfBooks)  ******************")
                
                if numberOfBooks > 1 {
                    /* GUARD: Is "items" key in our result? */
                    guard let items = result?[GoogleClient.Constants.GoogleResponseKeys.Items] as? [[String:AnyObject]] else {
                        displayError("***************   The 'items' NOT returned in the JSON data: ************************* ")
                        print(result)
                        return
                    }
                    print("**********  The 'items' returned in the JSON data ***********************")
                    print(items)
                    
                    for book in items {
                        guard let googleBookID = book[GoogleClient.Constants.GoogleResponseKeys.GoogleID] as? String else {
                            displayError("********************  The googleBookID was NOT found in the for loop of JSON data:  **************")
                            print(book)
                            return
                        }
                        print("***************************  The 'googleBookID' returned in the search results  ***********************")
                        print(googleBookID)
                        self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseKeys.GoogleID : googleBookID as AnyObject])
                        
                        guard let singleBookVolumeInfo = book[GoogleClient.Constants.GoogleResponseKeys.VolumeInfo] as? [String:AnyObject] else {
                            displayError("**************************   The 'volumeInfo' in the next level of JSON data was NOT found:  *****************")
                            print(book)
                            return
                        }
                        print("**************************  The 'singleBookVolumeInfo' returned in the results  ***********************")
                        print(singleBookVolumeInfo)
                        
                        guard let title = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.Title] as? String else {
                            displayError("**************************   The 'title' in the singleBookVolumeInfo level of JSON data was NOT found:  *****************")
                            return
                        }
                        print("**************************  The 'title' returned in the results  ***********************")
                        print(title)
                        self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseKeys.Title : title as AnyObject])
                        
                        if let subtitle = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.Subtitle] as? String {
                            print("**************************  The 'subtitle' returned in the results  ***********************")
                            print(subtitle)
                            self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseKeys.Subtitle : subtitle as AnyObject])
                        } else {
                            displayError("**************************   The 'subtitle' in the singleBookVolumeInfo level of JSON data was NOT found:  *****************")
                        }
                        
                        
                        if let authors = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.Authors] as? [String] {
                            print("**************************  The 'authors' returned in the results  ***********************")
                            print(authors)
                            self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseKeys.Authors : authors as AnyObject])
                        } else {
                            displayError("**************************   The 'authors' in the singleBookVolumeInfo level of JSON data was NOT found:  *****************")
                        }
                        
                        
                        guard let industryIdentifiers = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.IndustryIdentifiers] as? [[String: String]] else {
                            displayError("**************************   The 'industryIdentifiers' in the singleBookVolumeInfo level of JSON data was NOT found:  *****************")
                            return
                        }
                        print("**************************  The 'industryIdentifiers' returned in the results  ***********************")
                        print(industryIdentifiers)
                        
                        
                        for isbn in industryIdentifiers  {
                            if isbn[GoogleClient.Constants.GoogleResponseKeys.isbnType] == GoogleClient.Constants.GoogleResponseValues.typeISBN10 {
                                if let isbn10 = isbn[GoogleClient.Constants.GoogleResponseKeys.isbnIndetifier] {
                                    print("**************************  The 'isbn10' returned in the results  ***********************")
                                    print(isbn10)
                                    self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseValues.typeISBN10 : isbn10 as AnyObject])
                                } else {
                                    displayError("**************************   The 'isbn10' in the 'industryIdentifiers' level of JSON data was NOT found:  *****************")
                                }
                            }
                            
                            if isbn[GoogleClient.Constants.GoogleResponseKeys.isbnType] ==
                                GoogleClient.Constants.GoogleResponseValues.typeISBN13 {
                                if let isbn13 = isbn[GoogleClient.Constants.GoogleResponseKeys.isbnIndetifier] {
                                    print("**************************  The 'isbn13' returned in the results  ***********************")
                                    print(isbn13)
                                    self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseValues.typeISBN13 : isbn13 as AnyObject])
                                } else {
                                    displayError("**************************   The 'isbn13' in the 'industryIdentifiers' level of JSON data was NOT found:  *****************")
                                }
                            }
                            
                                
                        }
                        
                        /**
                        for isbn in industryIdentifiers where isbn[GoogleClient.Constants.GoogleResponseKeys.isbnType] as! String ==
                            GoogleClient.Constants.GoogleResponseValues.typeISBN13 as String {
                                guard let isbn13 = isbn[GoogleClient.Constants.GoogleResponseKeys.isbnIndetifier] else {
                                    displayError("**************************   The 'isbn13' in the 'industryIdentifiers' level of JSON data was NOT found:  *****************")
                                    return
                                }
                                print("**************************  The 'isbn13' returned in the results  ***********************")
                                print(isbn13)
                                self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseValues.typeISBN13 : isbn13])
                        }
                        */
                        
                        if let printType = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.PrintType] as? String {
                            print("**************************  The 'printType' returned in the results  ***********************")
                            print(printType)
                            self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseKeys.PrintType : printType as AnyObject])
                        } else {
                           displayError("**************************   The 'printType' in the singleBookVolumeInfo level of JSON data was NOT found:  *****************")
                        }
                        
                        
                        if let pageCount = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.PageCount] as? String {
                            print("**************************  The 'pageCount' returned in the results  ***********************")
                            print(pageCount)
                            self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseKeys.PageCount : pageCount as AnyObject])
                        } else {
                            displayError("**************************   The 'pageCount' in the singleBookVolumeInfo level of JSON data was NOT found:  *****************")
                        }
                        
                        
                        if let publisher = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.Publisher] as? String {
                            print("**************************  The 'publisher' returned in the results  ***********************")
                            print(publisher)
                            self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseKeys.Publisher : publisher as AnyObject])
                        } else {
                            displayError("**************************   The 'publisher' in the singleBookVolumeInfo level of JSON data was NOT found:  *****************")
                        }
                        
                        
                        if let publishedDate = singleBookVolumeInfo[GoogleClient.Constants.GoogleResponseKeys.PublishedDate] as? String {
                            print("**************************  The 'publishedDate' returned in the results  ***********************")
                            print(publishedDate)
                            self.bookInfoDictionary.append([GoogleClient.Constants.GoogleResponseKeys.PublishedDate : publishedDate as AnyObject])
                        } else {
                            displayError("**************************   The 'publishedDate' in the singleBookVolumeInfo level of JSON data was NOT found:  *****************")
                        }
                        
                    }
                    print("*****************   Here is the 'bookInfoDictionary' complete with contents appended.   *************")
                    print(self.bookInfoDictionary)
                    
                }
                
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



