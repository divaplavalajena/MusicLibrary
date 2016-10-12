//
//  AddToLibraryTableViewController.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/7/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import CoreData

class AddToLibraryTableViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var addToLibraryTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    lazy var sharedContext: NSManagedObjectContext = {
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        return stack.context
    }()
    
    @IBAction func scanBarcode(_ sender: AnyObject) {
        //Storyboard Segue in this button press modally to camera view (BarcodeReaderVC) to capture barcode image
        performSegue(withIdentifier: "displayBarcodeReaderVC", sender: sender)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            print("********    ***********   FRC is empty  *******   ****************")
            executeSearch()
            self.addToLibraryTableView.reloadData()
        } else {
            //load books saved in Core Data and accessed by the FRC
            print("********    ***********   FRC pulled values from Core Data  *******   ****************")
            executeSearch()
            self.addToLibraryTableView.reloadData()
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Set the title
        title = "Add To Music Library"
        
        //Core Data implementation
        fetchedResultsController.delegate = self
        
        //Make the search bar a delegate of self so that keyboard responds to button tap
        searchBar.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Search Bar methods
    //var customDelegate: UISearchBarDelegate!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        if (searchBar.text?.isEmpty)! {
            print("***** **** *** ISBN manual search NOT completed due to empty text field.  *** **** *****")
        } else {
            let isbnNumber = searchBar.text
            
            // Let the user know we've found something.
            
            let alert = UIAlertController(title: "Search this Barcode?", message: isbnNumber, preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.destructive, handler: { action in
                
                // Remove the spaces.
                
                let trimmedCode = isbnNumber!.trimmingCharacters(in: CharacterSet.whitespaces)
                
                GoogleClient.sharedInstance().getBookFromGoogleBySearchISBN(trimmedCode, completionHandlerForGoogleSearch: { (bookDictionary, error) in
                    
                    //code to take array of dictionaries (bookDictionary) and create CoreData info
                    if let bookDictionary = bookDictionary {
                        
                        print("****  ****  ****Network calls to GoogleBooksAPI successful - here is the array of dictionaries.  ****  *****  ****")
                        print(bookDictionary)
                        
                        DispatchQueue.main.async {
                            _ = bookDictionary.map() { (dictionary: [String: AnyObject]) -> MusicBook in
                                let book = MusicBook(dictionary: dictionary, context: self.sharedContext)
                                self.saveToBothContexts()
                                return book
                            }
                        }
                    } else {
                        print("**** The error is in the GoogleClient method getting the book info from the API - in the barcodeDetected func.  ****")
                    }
                })
                self.dismiss(animated: true, completion: {})
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(AddToLibraryTableViewController.dismissKeyboard))
        return recognizer
    }()
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This method must be implemented by our subclass. There's no way
        // CoreDataTableViewController can know what type of cell we want to
        // use.

        // Find the right musicBook for this indexpath
        let musicBook = fetchedResultsController.object(at: indexPath) as! MusicBook
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddToCell", for: indexPath) as! LibraryCellTableViewCell
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "displayDetailVC", sender: nil)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

 

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let musicBook = fetchedResultsController.object(at: indexPath) as? MusicBook {
                sharedContext.delete(musicBook)
            }
        }
    }
    
    //Added from CoreDataTableViewController
    // MARK: - CoreDataTableViewController (Table Data Source)
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(" This is the numberOfRowsInSection with the FRC: \(fetchedResultsController.sections?[section].numberOfObjects)")
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
    }
    
    // MARK: - CoreDataTableViewController (Fetches)
    func executeSearch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
    }
    
    // MARK: NSFetchedResultsController Methods
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "MusicBook")
        fr.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: true),
                              NSSortDescriptor(key: "title", ascending: false)]
        
        // Create the FetchedResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
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
    
    // MARK: Save to Both Contexts function
    func saveToBothContexts() {
        // Save pin data to both contexts
        let stack = (UIApplication.shared.delegate as! AppDelegate).stack
        stack.saveBothContexts()
    }

    
    
    
    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "displayDetailVC" {
            
            if let detailVC = segue.destination as? DetailViewController {
                
                let indexPath = self.addToLibraryTableView.indexPathForSelectedRow
                let musicBook = self.fetchedResultsController.object(at: indexPath!) as? MusicBook
                //let detailVC = (segue.destination as? UINavigationController)?.topViewController as! DetailViewController
                detailVC.detailItem = musicBook
                detailVC.navigationItem.leftItemsSupplementBackButton = true
                //detailVC.navigationController?.pushViewController(detailVC, animated: true)
                
            }
   
        }
        
        if segue.identifier! == "displayBarcodeReaderVC" {
            if let barcodeReaderVC = segue.destination as? BarcodeReaderViewController {
                barcodeReaderVC.navigationItem.leftItemsSupplementBackButton = true
            }
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

 

}
