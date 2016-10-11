//
//  DetailViewController.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/10/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var publisherInfo: UILabel!
    @IBOutlet var authors: UILabel!
    @IBOutlet var dateInfo: UILabel!
    @IBOutlet var pagesCount: UILabel!
    @IBOutlet var webLink: UILabel!
    @IBOutlet var isbn10Label: UILabel!
    @IBOutlet var isbn13Label: UILabel!
    @IBOutlet var googleIDLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.configureView()
    }

    //variable and method to compose and configure main view
    var detailItem: MusicBook? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let imageView = self.imageView {
                //imageView.image = detail.imageData
            }
            if let titleLabel = self.titleLabel {
                titleLabel.text = detail.title
            }
            if let publisherInfo = self.publisherInfo {
                publisherInfo.text = detail.publisher
            }
            if let authors = self.authors {
                authors.text = detail.authors
            }
            if let dateInfo = self.dateInfo {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd yyyy"
                let dateFormatted = dateFormatter.string(from: detail.dateAdded as! Date)
                dateInfo.text = dateFormatted
            }
            if let pagesCount = self.pagesCount {
                pagesCount.text = detail.pageCount
            }
            if let webLink = self.webLink {
                webLink.text = detail.webLink
            }
            if let isbn10Label = self.isbn10Label {
                isbn10Label.text = detail.isbn10
            }
            if let isbn13Label = self.isbn13Label {
                isbn13Label.text = detail.isbn13
            }
            if let googleIDLabel = self.googleIDLabel {
                googleIDLabel.text = detail.googleID
            }
            print(detail)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
