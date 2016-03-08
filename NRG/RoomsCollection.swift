//
//  RoomsCollection.swift
//  NRG
//
//  Created by Kevin Argumedo on 2/18/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class RoomsCollection : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UISearchBarDelegate
{
    var rooms = [JSON]()
    var user : JSON!
    var house : JSON!
    var link = String()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredData = [JSON]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
        
        searchBar.delegate = self
        searchBar.barStyle = UIBarStyle.BlackOpaque
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.rooms.removeAll()
        self.filteredData.removeAll()
        self.searchBar.text?.removeAll()
        
        let parameters  = ["owner" : String(self.user["id"]), "house": String(self.house["id"])]
        
        Alamofire.request(.GET, self.link+"/rooms/", parameters: parameters)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,jso) in JSON(JSON1)
                    {
                        self.rooms.append(jso)
                    }
                    if(self.rooms.isEmpty)
                    {
                        self.rooms.removeAll()
                        
                        let randomObject : JSON =  ["name": "You have not added any rooms!", "extra": "gibberish no one will read"]
                        
                        self.rooms.append(randomObject)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.filteredData = self.rooms
                    self.collectionView.reloadData()
                }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! RoomCell
        
        let myURL = self.link+"/devices/"
        
        var counter : Double = 0
        
        let parameters = ["trigger" : "On", "room": String(self.filteredData[indexPath.row]["id"]), "owner": String(self.user["id"]), "house": String(self.house["id"])]
        
        Alamofire.request(.GET, myURL, parameters: parameters)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,dev) in JSON(JSON1)
                    {
                        if let tempCount = Double(String(dev["watts"]))
                        {
                            counter += tempCount
                        }
                    }
                    
                    if(String(self.filteredData[indexPath.row]["name"]) == "You have not added any rooms!")
                    {
                        cell.name.text = String(self.filteredData[indexPath.row]["name"])
                        cell.watts.text = ""
                        cell.userInteractionEnabled = false
                    }
                    else
                    {
                        cell.name.text = String(self.filteredData[indexPath.row]["name"])
                        let tempString = "Power Consumption : " + String(counter) + " Watts"
                        cell.roomID = String(self.filteredData[indexPath.row]["id"])
                        cell.watts.text = tempString
                        cell.userInteractionEnabled = true
                    }
                }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toDevices", sender: self)
    }
    
    @IBAction func addRoom(sender: AnyObject)
    {
        
        var inputTextField: UITextField?
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Add a Room", message: "", preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some cancelation stuff
        }
        actionSheetController.addAction(cancelAction)
        
        
        let nextAction: UIAlertAction = UIAlertAction(title: "Add", style: .Default)
            { action -> Void in
                
                let rName = inputTextField!.text
                
                if(rName!.isEmpty)
                {
                    self.displayMessage("All Fields Required")
                    return
                }
                
                for room in self.rooms
                {
                    if(String(rName!) == String(room["name"]))
                    {
                        self.displayMessage("You already have a room with that name")
                        return
                    }
                }
                
                let myURL = self.link+"/rooms/create?"
                
                let owner = String(self.user["id"])
                let cHouse = String(self.house["id"])
                
                let parameters = ["name": String(rName!), "owner": owner, "house": cHouse]
                
                Alamofire.request(.POST, myURL, parameters: parameters, encoding: .JSON)
                    .responseJSON { response in
                        
                        print(response)
                        
                        if let object = response.result.value
                        {
                            self.displayMessage("A new Room has been added!")
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                if(self.filteredData.count == 1)
                                {
                                    if(self.filteredData[0]["name"] == "You have not added any rooms!")
                                    {
                                        self.filteredData.removeAll()
                                        self.rooms.removeAll()
                                    }
                                }
                                
                                let tempObj = JSON(object)
                                self.rooms.append(tempObj)
                                self.filteredData = self.rooms
                                self.searchBar.text = ""
                                
                                self.collectionView.reloadData()
                            }
                            
                        }
                }
        }
        
        actionSheetController.addAction(nextAction)
        
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            inputTextField = textField
        }
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = gestureReconizer.locationInView(self.collectionView)
        let indexPath = self.collectionView.indexPathForItemAtPoint(p)
        
        if let index = indexPath {
            self.editMenu(index)
        }
    }
    
    func editMenu(c : NSIndexPath)
    {
        let cell = self.collectionView.cellForItemAtIndexPath(c) as! RoomCell
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Room Options", message: String(cell.name.text!), preferredStyle: .ActionSheet)
        
        
        let editNameAction: UIAlertAction = UIAlertAction(title: "Edit Name", style: .Default) { action -> Void in
            
            self.editAlert(c)
            
        }
        
        
        let deleteRoomAction: UIAlertAction = UIAlertAction(title: "Delete Room", style: .Default) { action -> Void in
            
            let tempCell = self.collectionView.cellForItemAtIndexPath(c) as! RoomCell
            
            let tempString = "Are you sure you want to delete \"" + String(tempCell.name.text!) + "\"?"
            
            let deleteAlert: UIAlertController = UIAlertController(title: "Confirm Delete", message: tempString, preferredStyle:  .Alert)
            
            let confirmDelete: UIAlertAction = UIAlertAction(title: "Confirm", style: .Default) { action ->
                Void in
                
                let tempDevicesURL = self.link+"/devices?owner="+String(self.filteredData[c.row]["owner"]) + "&room=" + String(self.filteredData[c.row]["id"])
                
                print(tempDevicesURL)
                
                Alamofire.request(.GET, tempDevicesURL)
                    .responseJSON { response in
                        
                        if let JSON1 = response.result.value
                        {
                            for(_,rm) in JSON(JSON1)
                            {
                                let tempRoomURL = self.link+"/devices/destroy/"+String(rm["id"])
                                print(tempRoomURL)
                                Alamofire.request(.POST, tempRoomURL)
                                    .response { request, response, data, error in
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.collectionView.reloadData()
                                            
                                        }
                                }
                            }
                        }
                }
                
                
                let myURL = self.link+"/rooms/destroy/" + tempCell.roomID!
                
                Alamofire.request(.POST, myURL)
                    .response { request, response, data, error in
                        
                        self.displayMessage("Room has been deleted.")
                        
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView.reloadData()
                            self.viewWillAppear(true)

                        }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.rooms.removeAtIndex(c.row)
                    self.filteredData.removeAtIndex(c.row)
                    self.collectionView.reloadData()
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
        actionSheetController.addAction(deleteRoomAction)
        actionSheetController.addAction(cancelAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
        
    }
    
    func editAlert(c : NSIndexPath)
    {
        
        var nameTextField: UITextField!
        
        let alertController = UIAlertController(title: "Edit Room Name", message: "Please enter new name for the room.", preferredStyle: .Alert)
        
        let submit = UIAlertAction(title: "Submit", style: .Default, handler: { (action) -> Void in
            
            let newName = nameTextField.text
            var allow = true
            
            if (String(newName).isEmpty)
            {
                self.displayMessage("Text Field can not be empty!")
                allow = false
                return
            }
            
            for tempRooms in self.filteredData
            {
                if(String(tempRooms["name"]) == newName)
                {
                    allow = false
                    return
                }
            }
            
            if(allow)
            {
                
                let tempCell = self.collectionView.cellForItemAtIndexPath(c) as! RoomCell
                
                
                let myURL = self.link+"/rooms/update/" + tempCell.roomID! + "/?name=" + String(newName!)
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
        
        if searchText.isEmpty {
            filteredData = rooms
        } else {
            
            filteredData = rooms.filter({(dataItem : JSON ) -> Bool in
                if String(dataItem["name"]).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    print(dataItem["name"], " has been inserted")
                    return true
                } else {
                    return false
                }
            })
            self.collectionView.reloadData()
        }
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
        
        if (segue.identifier == "toDevices")
        {
            let dest1 = self.collectionView!.indexPathsForSelectedItems()!
            
            let indexPath : NSIndexPath =  dest1[0] as NSIndexPath
            
            //let dest = segue.destinationViewController as! DevicesCollection
            let dest = segue.destinationViewController as! DevicesCollection
            
            dest.user = self.user
            dest.house = self.house
            dest.room = self.filteredData[indexPath.row]
            dest.link = self.link
        }
    }
}