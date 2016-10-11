//
//  AddToLibraryTableViewController.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/7/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import CoreData

class AddToLibraryTableViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var addToLibraryTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBAction func scanBarcode(_ sender: AnyObject) {
        //Storyboard Segue in this button press modally to camera view (BarcodeReaderVC) to capture barcode image
    }
    
    // MARK: Properties
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            addToLibraryTableView.reloadData()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedResultsController?.fetchedObjects?.count == 0 {
            print("********    ***********   FRC is empty  *******   ****************")
            //loadPhotoAlbum()
            self.addToLibraryTableView.reloadData()
        } else {
            //load books saved in Core Data and accessed by the FRC
            print("********    ***********   FRC pulled values from Core Data  *******   ****************")
            self.addToLibraryTableView.reloadData()
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Set the title
        title = "Add To Music Library"
        
        view.addSubview(addToLibraryTableView)
        addToLibraryTableView.delegate = self
        addToLibraryTableView.dataSource = self
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "MusicBook")
        fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true),
                              NSSortDescriptor(key: "publishedDate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        /**
        GoogleClient.sharedInstance().getBookFromGoogleBySearchISBN("0793510066") { (resultsISBN, error) in
            print(resultsISBN)
        }
        **/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This method must be implemented by our subclass. There's no way
        // CoreDataTableViewController can know what type of cell we want to
        // use.

        // Find the right musicBook for this indexpath
        let musicBook = fetchedResultsController!.object(at: indexPath) as! MusicBook
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddToCell", for: indexPath) as! LibraryCellTableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = musicBook.title
        cell.detailTextLabel?.text = musicBook.isbn13

        return cell
    }
 

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let context = fetchedResultsController?.managedObjectContext, let musicBook = fetchedResultsController?.object(at: indexPath) as? MusicBook, editingStyle == .delete {
            context.delete(musicBook)
        }
    }
    
    //Added from CoreDataTableViewController
    // MARK: - CoreDataTableViewController (Table Data Source)
    func numberOfSections(in tableView: UITableView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fc = fetchedResultsController {
            return fc.sections![section].name
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.section(forSectionIndexTitle: title, at: index)
        } else {
            return 0
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let fc = fetchedResultsController {
            return fc.sectionIndexTitles
        } else {
            return nil
        }
    }
    
    // MARK: - CoreDataTableViewController (Fetches)
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    
    // MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        addToLibraryTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            addToLibraryTableView.insertSections(set, with: .fade)
        case .delete:
            addToLibraryTableView.deleteSections(set, with: .fade)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            addToLibraryTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            addToLibraryTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            addToLibraryTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            addToLibraryTableView.deleteRows(at: [indexPath!], with: .fade)
            addToLibraryTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        addToLibraryTableView.endUpdates()
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
