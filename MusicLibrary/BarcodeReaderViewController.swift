//
//  BarcodeReaderViewController.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/10/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class BarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //Properties:
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var results: [MusicBook]?
    
    lazy var sharedContext: NSManagedObjectContext = {
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        return stack.context
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a session object.
        session = AVCaptureSession()
        
        // Set the captureDevice.
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Create input object.
        
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // Add input to the session.
        
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            scanningNotPossible()
        }
        
        // Create output object.
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        // Add output to the session.
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            
            // Send captured data to the delegate object via a serial queue.
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Set barcode type for which to scan: EAN-13.
            
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code]
            
        } else {
            scanningNotPossible()
        }
        
        // Add previewLayer and have it show the video data.
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        
        // Begin the capture session.
        
        session.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        if (session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
    
    func scanningNotPossible() {
        
        // Let the user know that scanning isn't possible with the current device.
        
        let alert = UIAlertController(title: "Can't Scan.", message: "Let's try a device equipped with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        session = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Get the first object from the metadataObjects array.
        
        if let barcodeData = metadataObjects.first {
            
            // Turn it into machine readable code
            
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
            
            if let readableCode = barcodeReadable {
                
                // Send the barcode as a string to barcodeDetected()
                
                barcodeDetected(readableCode.stringValue);
            }
            
            // Vibrate the device to give the user some feedback.
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Avoid a very buzzy device.
            
            session.stopRunning()
        }
    }
    
    func barcodeDetected(_ code: String) {
        
        // Let the user know we've found something.
        
        let alert = UIAlertController(title: "Found a Barcode!", message: code, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.destructive, handler: { action in
            
            // Remove the spaces.
            
            let trimmedCode = code.trimmingCharacters(in: CharacterSet.whitespaces)
            
            GoogleClient.sharedInstance().getBookFromGoogleBySearchISBN(trimmedCode, completionHandlerForGoogleSearch: { (bookDictionary, error, zeroItemsFound) in
                //code to take array of dictionaries (bookDictionary) and init CoreData info
                if let bookDictionary = bookDictionary {
                    
                    print("****  ****  ****Network calls to GoogleBooksAPI successful - here is the array of dictionaries.  ****  *****  ****")
                    print(bookDictionary)
                    
                    DispatchQueue.main.async {
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
                                     //where googleID is NOT equal or found, DO add to core data by saving the context.
                                    } else if results.contains(where: { $0.googleID != testGoogleID}) {
                                        print("This will save because fetch googleID is != to \(testGoogleID).")
                                        self.saveToBothContexts()
                                    }
                                }
                                return book
                            }
                        } catch let error as NSError {
                            print("Fetch failed: \(error.localizedDescription)")
                        }

                    }
                } else if zeroItemsFound == true {
                    print("Zero items were returned from search")
                    self.dismiss(animated: true, completion: {
                        //AddToLibraryTableViewController.zeroItemsFound = zeroItemsFound
                    })
                    
                }else {
                    print(error)
                    print("**** The error is in the GoogleClient method getting the book info from the API - in the barcodeDetected func.  ****")
                }
            })
            self.dismiss(animated: true, completion: {})
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Save to Both Contexts function
    func saveToBothContexts() {
        // Save pin data to both contexts
        let stack = (UIApplication.shared.delegate as! AppDelegate).stack
        stack.saveBothContexts()
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
