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

class RoomsCollection : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    var rooms = [JSON]()
    var user : JSON!
    var house = [JSON]()
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.rooms.removeAll()
        
        let parameters  = ["owner" : String(self.user["id"]), "house": String(self.house[0]["id"])]
        
        Alamofire.request(.GET, "http://ignacio.kevinhuynh.net:1337/rooms/", parameters: parameters)
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
                    self.collectionView.reloadData()
                }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! RoomCell
        
        let myURL = "http://ignacio.kevinhuynh.net:1337/devices/"
        
        var counter : Double = 0
        
        let parameters = ["trigger" : "On", "room": String(self.rooms[indexPath.row]["id"]), "owner": String(self.user["id"]), "house": String(self.house[0]["id"])]
        
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
                    
                    if(String(self.rooms[indexPath.row]["name"]) == "You have not added any rooms!")
                    {
                        cell.name.text = String(self.rooms[indexPath.row]["name"])
                        cell.userInteractionEnabled = false
                    }
                    else
                    {
                        cell.name.text = String(self.rooms[indexPath.row]["name"])
                        let tempString = "Power Consumption : " + String(counter) + " Watts"
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
                
                let myURL = "http://172.249.231.197:1337/rooms/create?"
                
                let owner = String(self.user["id"])
                let cHouse = String(self.house[0]["id"])
                
                let parameters = ["name": String(rName!), "owner": owner, "house": cHouse]
                
                Alamofire.request(.POST, myURL, parameters: parameters, encoding: .JSON)
                    .responseJSON { response in
                        
                        print(response)
                        
                        if let object = response.result.value
                        {
                            self.displayMessage("A new Room has been added!")
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                if(self.rooms.count == 1)
                                {
                                    if(self.rooms[0]["name"] == "You have not added any rooms!")
                                    {
                                        self.rooms.removeAll()
                                    }
                                }
                                
                                self.rooms.append(JSON(object))
                                
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
            dest.house = self.house[0]
            dest.room = self.rooms[indexPath.row]
        }
    }
}