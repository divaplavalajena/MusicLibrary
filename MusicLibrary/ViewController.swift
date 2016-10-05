//
//  ViewController.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 9/28/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GoogleClient.sharedInstance().getBookFromGoogleBySearchISBN("0793510066") { (resultsISBN, error) in
            print(resultsISBN)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

