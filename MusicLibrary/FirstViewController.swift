//
//  FirstViewController.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/7/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet var button: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        GoogleClient.sharedInstance().getBookFromGoogleBySearchISBN("0793510066") { (resultsISBN, error) in
            print(resultsISBN)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
