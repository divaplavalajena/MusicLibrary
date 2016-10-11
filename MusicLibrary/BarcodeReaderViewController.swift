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
            
            GoogleClient.sharedInstance().getBookFromGoogleBySearchISBN(trimmedCode, completionHandlerForGoogleSearch: { (bookDictionary, error) in
                //TODO: Insert code here to take array of dictionaries (bookDictionary) and create CoreData info
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
            
            /**
            // EAN or UPC?
            // Check for added "0" at beginning of code.
            
            let trimmedCodeString = "\(trimmedCode)"
            var trimmedCodeNoZero: String
            
            if trimmedCodeString.hasPrefix("0") && trimmedCodeString.characters.count > 1 {
                trimmedCodeNoZero = String(trimmedCodeString.characters.dropFirst())
                
                // Send the doctored UPC to DataService.searchAPI()
                
                DataService.searchAPI(trimmedCodeNoZero)
            } else {
                
                // Send the doctored EAN to DataService.searchAPI()
                
                DataService.searchAPI(trimmedCodeString)
            }
            **/
            
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
