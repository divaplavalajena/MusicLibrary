//
//  MyLibraryTableViewController.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/7/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import CoreData

class MyLibraryTableViewController: CoreDataTableViewController {
    
    //Properties:
    
    lazy var sharedContext: NSManagedObjectContext = {
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        return stack.context
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedResultsController?.fetchedObjects?.count == 0 {
            print("********    ***********   FRC is empty  *******   ****************")
            //loadPhotoAlbum()
            self.tableView.reloadData()
        } else {
            //load books saved in Core Data and accessed by the FRC
            print("********    ***********   FRC pulled values from Core Data  *******   ****************")
            self.tableView.reloadData()
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Set the title
        title = "My Music Library"
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "MusicBook")
        fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true),
                              NSSortDescriptor(key: "publishedDate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This method must be implemented by our subclass. There's no way
        // CoreDataTableViewController can know what type of cell we want to
        // use.

        // Find the right musicBook for this indexpath
        let musicBook = fetchedResultsController!.object(at: indexPath) as! MusicBook
        print(musicBook)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath) as! LibraryCellTableViewCell

        // Configure the cell...
        cell.titleLable.text = musicBook.title
        cell.subtitleLabel.text = musicBook.isbn13
        
        
        //TODO: implement code to use imageLink to get image and save image to CoreData and then display it
        if musicBook.imageData == nil {
            if let imagePath = musicBook.imageLink {
                let _ = GoogleClient.sharedInstance().taskForGETImage(imagePath, completionHandlerForImage: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        musicBook.imageData = imageData as NSData?
                        self.saveToBothContexts()

                        DispatchQueue.main.async {
                            cell.bookImageView.image = image
                        }
                    }
                    
                })
            }
        } else if musicBook.imageData != nil {
            cell.bookImageView.image = UIImage(data: musicBook.imageData as! Data)
        }
 


        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "displayDetailVC", sender: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let context = fetchedResultsController?.managedObjectContext, let musicBook = fetchedResultsController?.object(at: indexPath) as? MusicBook, editingStyle == .delete {
            context.delete(musicBook)
        }
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "displayDetailVC" {
            
            if let detailVC = segue.destination as? DetailViewController {
            
                let indexPath = self.tableView.indexPathForSelectedRow
                let musicBook = self.fetchedResultsController?.object(at: indexPath!) as? MusicBook
                //let detailVC = (segue.destination as? UINavigationController)?.topViewController as! DetailViewController
                detailVC.detailItem = musicBook
                detailVC.navigationItem.leftItemsSupplementBackButton = true
                
            }
            
            
        }

    }
    
    // MARK: Save to Both Contexts function
    func saveToBothContexts() {
        // Save pin data to both contexts
        let stack = (UIApplication.shared.delegate as! AppDelegate).stack
        stack.saveBothContexts()
    }
 

}



