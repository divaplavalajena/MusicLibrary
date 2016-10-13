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
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var addToLibraryTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var results: [MusicBook]?
    var zeroItemsFound: Bool?
    
    lazy var sharedContext: NSManagedObjectContext = {
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        return stack.context
    }()
    
    @IBOutlet var scanBarcodeOutlet: UIButton!
    @IBAction func scanBarcode(_ sender: AnyObject) {
        //Storyboard Segue in this button press modally to camera view (BarcodeReaderVC) to capture barcode image
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BarcodeReaderViewController") as! BarcodeReaderViewController
        controller.delegate = self
        controller.navigationItem.leftItemsSupplementBackButton = true
        self.present(controller, animated: true, completion: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.activityIndicator.isHidden = true
        
        scanBarcodeOutlet.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        if Reachability.connectedToNetwork() == true {
            print("Internet Connection Available!")
        } else {
            print("Internet Connection NOT Available!")
            let alert = UIAlertController(title: "Internet Connection not available!", message: "Please connect and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        
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
        
        //Edit button explicitly instantiated with method to use since table view is added to view and not baked in to view like MyLibraryTVC
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddToLibraryTableViewController.editButtonPressed))
        
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        if (searchBar.text?.isEmpty)! {
            print("***** **** *** ISBN manual search NOT completed due to empty text field.  *** **** *****")
        } else {
            let isbnNumber = searchBar.text

            // Remove the spaces.
            let trimmedCode = isbnNumber!.trimmingCharacters(in: CharacterSet.whitespaces)
            
            GoogleClient.sharedInstance().getBookFromGoogleBySearchISBN(trimmedCode, completionHandlerForGoogleSearch: { (bookDictionary, error, zeroItemsFound) in
                //code to take array of dictionaries (bookDictionary) and create CoreData info
                if let bookDictionary = bookDictionary {
                    
                    print("****  ****  ****Network calls to GoogleBooksAPI successful - here is the array of dictionaries.  ****  *****  ****")
                    print(bookDictionary)
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = false
                        self.activityIndicator.startAnimating()
                        
                        //create fetch of core data and compare to see if it already exists in core data so no duplicates are added
                        //Get fetch request before mapping GoogleClient info to Core Data for good baseline comparison
                        let request: NSFetchRequest<NSFetchRequestResult> = MusicBook.fetchRequest()
                        do {
                            let results = try self.sharedContext.fetch(request) as! [MusicBook]
                            
                            //perform GoogleClient mapping into Core Data ready objects
                            _ = bookDictionary.map() { (dictionary: [String: AnyObject]) -> MusicBook in
                                let book = MusicBook(dictionary: dictionary, context: self.sharedContext)
                                //googleID is primary key to test for existence in core data
                                let testGoogleID = book.googleID
                                //if results count is not zero
                                if results.count != 0 {
                                    //where the googleID is equal or found, don't add to core data and delete from context to prevent saving
                                    if results.contains(where: { $0.googleID == testGoogleID}) {
                                        print("Not saving on BarcodeReaderVC to Core Data - GoogleID already exists in CoreData")
                                        print("Here is \(testGoogleID) that is equal to fetch.")
                                        self.sharedContext.delete(book)
                                        self.bookAlreadyInLibrary()
                                        //where googleID is NOT equal or found, DO add to core data by saving the context.
                                    } else if results.contains(where: { $0.googleID != testGoogleID}) {
                                        print("This will save because fetch googleID is != to \(testGoogleID).")
                                        self.saveToBothContexts()
                                        self.activityIndicator.stopAnimating()
                                        self.activityIndicator.isHidden = true
                                    }
                                }
                                return book
                            }
                        } catch let error as NSError {
                            print("Fetch failed: \(error.localizedDescription)")
                            self.errorInSearchAlert()
                        }
                    }
                } else if zeroItemsFound == true {
                    print("Zero items were returned from search")
                    DispatchQueue.main.async {
                        self.zeroResultsFoundAlert()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                    
                } else {
                    print(error)
                    print("**** The error is in the GoogleClient method getting the book info from the API - in the barcodeDetected func.  ****")
                    self.errorInSearchAlert()
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                }
            })
        }
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
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
        print(musicBook)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddToCell", for: indexPath) as! LibraryCellTableViewCell
        
        // Configure the cell...
        cell.titleLable.text = musicBook.title
        cell.subtitleLabel.text = musicBook.isbn13
        
        
        // code to use imageLink with taskForGetImage to get image and save image to CoreData and then display it
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
                self.saveToBothContexts()
                print("*** *** *** DELETE called and book deleted from Core Data. *** *** ***")
            }
        }
    }
    
    func editButtonPressed(){
        addToLibraryTableView.setEditing(!addToLibraryTableView.isEditing, animated: true)
        if addToLibraryTableView.isEditing == true{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddToLibraryTableViewController.editButtonPressed))
        }else{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddToLibraryTableViewController.editButtonPressed))
        }
    }
    
    
    // MARK: - CoreDataTableViewController (Table Data Source)
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(" This is the numberOfRowsInSection with the FRC: \(fetchedResultsController.sections?[section].numberOfObjects)")
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recently Added"
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
                detailVC.detailItem = musicBook
                detailVC.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: Alert helper methods
    
    func zeroResultsFoundAlert() {
        let alert = UIAlertController(title: "Book not found!", message: "ISBN not found. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func bookExistsAlert() {
        let alert = UIAlertController(title: "Book exists in library already.", message: "Please try another ISBN to add to your library.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorInSearchAlert() {
        let alert = UIAlertController(title: "Please try again.", message: "There was a network error with the search.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }))
        self.present(alert, animated: true, completion: nil)
        
    }

}


extension AddToLibraryTableViewController: BarcodeReaderDelegate {
    
    // Adheres to protocol on BarcodeReaderVC so that BarcodeReaderVC can
    //    "pass" info back here to AddToLibraryTVC
    func barcodeReaderDidFail() {
        //Zero Items Found - present Alert View Controller
        print("BarcodeReader did complete but found ZERO results")
        zeroResultsFoundAlert()
    }
    
    func bookAlreadyInLibrary() {
        //Core Data determined the book is already in the library
        print("Book already in Core Data - See the library contents.")
        bookExistsAlert()
        
    }
    
    func errorInGoogleSearch() {
        //Core Data determined the book is already in the library
        print("There was an error with the network in searching.  Check numbers and try again.")
        errorInSearchAlert()
        
    }
}








