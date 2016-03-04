//
//  DevicesCollection.swift
//  NRG
//
//  Created by Kevin Argumedo on 1/31/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DevicesCollection : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UISearchBarDelegate {
  
    var devices = [JSON]()
    var user = JSON!()
    var room = JSON!()
    var house = JSON!()
    var filteredData = [JSON]()
    var link = String()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
        self.collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)

        
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
        filteredData = devices

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        let myURL = self.link+"/devices/"
        
        self.devices.removeAll()
        
        let parameters = ["owner": String(self.user["id"]), "room": String(self.room["id"]), "house": String(self.house["id"])]
        
        Alamofire.request(.GET, myURL, parameters: parameters)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,dev) in JSON(JSON1)
                    {
                        self.devices.append(dev)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.filteredData = self.devices
                        self.collectionView.reloadData()
                    }
                }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DeviceCell
        
        cell.deviceName.text = String(devices[indexPath.row]["name"])
        cell.deviceID = String(devices[indexPath.row]["id"])
        
        if(!(String(devices[indexPath.row]["image"]) == "Phone Charger"))
        {
            cell.imageView.image = UIImage(named: String(devices[indexPath.row]["image"]))
        }

        let tStringWatt = String(devices[indexPath.row]["watts"])
                
        let dWatts = Double(tStringWatt)
        
        cell.watts.text = "Watts: " +  String(dWatts!)
        
        if(String(devices[indexPath.row]["trigger"]) == "Off")
        {
            cell.trigger.setOn(false, animated: true)
            cell.on = false
            if(String(devices[indexPath.row]["image"]) == "Phone Charger")
            {
                cell.imageView.image = UIImage(named: "Phone_Charging_Off")
            }
//            self.postTrigger(String(self.devices[indexPath.row]["id"]), trigger: String("Off"))
        }
        else
        {
            cell.on = true;
            cell.trigger.setOn(true, animated: true)
            cell.imageView.animateWithImage(named: "Phone_Charger.gif")
            cell.imageView.startAnimatingGIF()
            
//            self.postTrigger(String(self.devices[indexPath.row]["id"]), trigger: String("On"))
        }
        
        cell.trigger?.layer.setValue(indexPath, forKey: "sendIndex")
        cell.trigger?.layer.setValue(cell, forKey: "sendCell")
        cell.trigger?.addTarget(self, action: "changeTrigger:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func changeTrigger(sender: UISwitch)
    {
        let cell = sender.layer.valueForKey("sendCell") as! DeviceCell
        let index = sender.layer.valueForKey("sendIndex") as! NSIndexPath
        var trigger = "Off"
        
        if(cell.on!)
        {
            cell.on = false
            trigger = "Off"
            cell.imageView.image = UIImage(named: "Phone_Charging_Off")
        }
        else
        {
            cell.on = true
            trigger = "On"
            cell.imageView.animateWithImage(named: "Phone_Charger.gif")
            cell.imageView.startAnimatingGIF()
        }
        
        Alamofire.upload(
            .POST,
            self.link+"/devices/update/"+String(self.devices[index.row]["id"]),
            multipartFormData: {
                multipartFormData in
                multipartFormData.appendBodyPart(data: trigger.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "trigger")
            },
            encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _ ):
                    upload.responseJSON { response in
                    }
                case .Failure(let encodingError):
                    print("Failure")
                    print(encodingError)
                }
            }
        )
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = gestureReconizer.locationInView(self.collectionView)
        let indexPath = self.collectionView.indexPathForItemAtPoint(p)
        
        if let index = indexPath {
            //       let cell = self.collectionView.cellForItemAtIndexPath(index)
            print("tou tocuej")
            self.editMenu(index)
        }
    }
    
    func editMenu(c : NSIndexPath)
    {
        let cell = self.collectionView.cellForItemAtIndexPath(c) as! DeviceCell
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Device Options", message: String(cell.deviceName.text!), preferredStyle: .ActionSheet)
        
        
        let editNameAction: UIAlertAction = UIAlertAction(title: "Edit Name", style: .Default) { action -> Void in
            
            self.editAlert(c)
            
        }
        
        
        let deleteDeviceAction: UIAlertAction = UIAlertAction(title: "Delete Device", style: .Default) { action -> Void in
            
            let tempCell = self.collectionView.cellForItemAtIndexPath(c) as! DeviceCell
            
            let tempString = "Are you sure you want to delete \"" + String(tempCell.deviceName.text!) + "\"?"
            
            let deleteAlert: UIAlertController = UIAlertController(title: "Confirm Delete", message: tempString, preferredStyle:  .Alert)
            
            let confirmDelete: UIAlertAction = UIAlertAction(title: "Confirm", style: .Default) { action ->
                Void in
                
                
                let myURL = self.link+"/devices/destroy/" + tempCell.deviceID!
                
                Alamofire.request(.POST, myURL)
                    .response { request, response, data, error in
                        
                        self.displayMessage("Device has been deleted.")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView.reloadData()
                            self.viewWillAppear(true)
                        }
                }
            }
            
            let cancelDelete: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //do nothing on cancel
            }
            
            deleteAlert.addAction(confirmDelete)
            deleteAlert.addAction(cancelDelete)
            self.presentViewController(deleteAlert, animated: true, completion: nil)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //do nothing on cancel
        }
        
        actionSheetController.addAction(editNameAction)
        actionSheetController.addAction(deleteDeviceAction)
        actionSheetController.addAction(cancelAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
        
    }
    
    func editAlert(c : NSIndexPath)
    {
        var nameTextField: UITextField!
        
        let alertController = UIAlertController(title: "Edit Device Name", message: "Please enter new name for your device.", preferredStyle: .Alert)
        
        let submit = UIAlertAction(title: "Submit", style: .Default, handler: { (action) -> Void in
            
            let newName = nameTextField.text
            var allow = true
            
            if (String(newName).isEmpty)
            {
                self.displayMessage("Text Field can not be empty!")
                allow = false
                return
            }
            
            for tempDev in self.devices
            {
                if(String(tempDev["name"]) == newName)
                {
                    allow = false
                    return
                }
            }
            
            if(allow)
            {
                
                let tempCell = self.collectionView.cellForItemAtIndexPath(c) as! DeviceCell
                
                
                let myURL = self.link+"/devices/update/" + tempCell.deviceID! + "/?name=" + String(newName!)
                print(myURL)
                Alamofire.request(.GET, myURL)
                    .responseJSON { response in
                        
                        self.displayMessage("Name has been updated.")
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView.reloadData()
                            self.viewWillAppear(true)
                        }
                }
                
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            //do nnothing
        }
        alertController.addAction(submit)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            // Enter the textfiled customization code here.
            nameTextField = textField
            nameTextField?.placeholder = "Enter New Name"
        }
        presentViewController(alertController, animated: true, completion: nil)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        
        if searchText.isEmpty {
            filteredData = devices
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = devices.filter({(dataItem : JSON ) -> Bool in
                if String(dataItem["name"]).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        
        print(filteredData)
        self.collectionView.reloadData()
    }
    
    func displayMessage(message: String)
    {
        let myAlert = UIAlertController(title:"Alert", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated:true, completion: nil);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toAddDevice")
        {
            let dest = segue.destinationViewController as! AddDevice
            dest.user = self.user
            dest.room = self.room
            dest.house = self.house
            dest.devices = self.devices
            
        }
    }
    
}