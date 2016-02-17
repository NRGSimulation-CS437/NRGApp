//
//  HouseCollectionView.swift
//  NRG
//
//  Created by Kevin Argumedo on 1/28/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class HouseCollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user : JSON!
    
    var houses = [JSON]()
    var houseNames = [String]()
    var house = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
            
            let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
            lpgr.minimumPressDuration = 0.5
            lpgr.delaysTouchesBegan = true
            lpgr.delegate = self
            self.collectionView.addGestureRecognizer(lpgr)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        house.removeAll()
        houses.removeAll()
        houseNames.removeAll()
        
        let myURL = "http://172.249.231.197:1337/house/"
        
        let parameters = ["owner": String(self.user["id"])]
        
        Alamofire.request(.GET, myURL, parameters: parameters)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,hse) in JSON(JSON1)
                    {
                        self.houses.append(hse)
                        self.houseNames.append(String(hse["name"]))
                        
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.houses.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
            as! HouseCell
        
        cell.textDisplay.text = String(houses[indexPath.row]["name"])
        cell.imageView.image = UIImage(named: String(houses[indexPath.row]["image"]))
        cell.houseID = String(houses[indexPath.row]["id"])
        let myURL = "http://ignacio.kevinhuynh.net:1337/devices/"
        
        var counter : Double = 0
        
        let parameters = ["trigger" : "on", "owner": String(self.user["id"]), "house": String(self.houses[indexPath.row]["id"])]
        
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
                    cell.watts?.text = "Watts:  " + String(counter)
                }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        self.performSegueWithIdentifier("toHouse", sender: self)
    }
    
    @IBAction func logoutButton(sender: AnyObject)
    {
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("toLogin", sender: self)
        }
    }

    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = gestureReconizer.locationInView(self.collectionView)
        let indexPath = self.collectionView.indexPathForItemAtPoint(p)
        
        if let index = indexPath {
     //       let cell = self.collectionView.cellForItemAtIndexPath(index)
            self.editMenu(index)
        }
    }
    
    
    func editMenu(c : NSIndexPath)
    {
        let cell = self.collectionView.cellForItemAtIndexPath(c) as! HouseCell
        
        let actionSheetController: UIAlertController = UIAlertController(title: "House Options", message: String(cell.textDisplay.text!), preferredStyle: .ActionSheet)
        

        let editNameAction: UIAlertAction = UIAlertAction(title: "Edit Name", style: .Default) { action -> Void in
            
            self.editAlert(c)
        
        }

        
        let deleteHouseAction: UIAlertAction = UIAlertAction(title: "Delete House", style: .Default) { action -> Void in
            
            let tempCell = self.collectionView.cellForItemAtIndexPath(c) as! HouseCell
            
            let tempString = "Are you sure you want to delete \"" + String(tempCell.textDisplay.text!) + "\"?"
            
            let deleteAlert: UIAlertController = UIAlertController(title: "Confirm Delete", message: tempString, preferredStyle:  .Alert)
            
            let confirmDelete: UIAlertAction = UIAlertAction(title: "Confirm", style: .Default) { action ->
                Void in
                
                let tempRoomsURL = "http://ignacio.kevinhuynh.net:1337/rooms?owner="+String(self.houses[c.row]["owner"])+"&house=" + String(self.houses[c.row]["id"])
                
                Alamofire.request(.GET, tempRoomsURL)
                    .responseJSON { response in
                        
                        if let JSON1 = response.result.value
                        {
                            for(_,rm) in JSON(JSON1)
                            {
                                let tempRoomURL = "http://ignacio.kevinhuynh.net:1337/rooms/destroy/"+String(rm["id"])
                                Alamofire.request(.POST, tempRoomURL)
                                    .response { request, response, data, error in
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.collectionView.reloadData()
                                        }
                                }
                            }
                        }
                }
                
                Alamofire.request(.GET, tempRoomsURL)
                    .responseJSON { response in
                        
                        if let JSON1 = response.result.value
                        {
                            for(_,rm) in JSON(JSON1)
                            {
                                let tempRoomURL = "http://ignacio.kevinhuynh.net:1337/rooms/destroy/"+String(rm["id"])
                                Alamofire.request(.POST, tempRoomURL)
                                    .response { request, response, data, error in
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.collectionView.reloadData()
                                        }
                                }
                            }
                        }
                }
                
                let tempDevicesURL = "http://ignacio.kevinhuynh.net:1337/devices?owner="+String(self.houses[c.row]["owner"]) + "&house=" + String(self.houses[c.row]["id"])
                
                Alamofire.request(.GET, tempDevicesURL)
                    .responseJSON { response in
                        
                        if let JSON1 = response.result.value
                        {
                            for(_,rm) in JSON(JSON1)
                            {
                                let tempRoomURL = "http://ignacio.kevinhuynh.net:1337/devices/destroy/"+String(rm["id"])
                                Alamofire.request(.POST, tempRoomURL)
                                    .response { request, response, data, error in
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.collectionView.reloadData()
                                        }
                                }
                            }
                        }
                }
                
                
                let myURL = "http://ignacio.kevinhuynh.net:1337/house/destroy/" + tempCell.houseID!

                Alamofire.request(.POST, myURL)
                    .response { request, response, data, error in
                        
                        self.displayMessage("House has been deleted.")
                        
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView.reloadData()
                        }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.houses.removeAtIndex(c.row)
                    self.houseNames.removeAtIndex(c.row)
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
        actionSheetController.addAction(deleteHouseAction)
        actionSheetController.addAction(cancelAction)
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
        
    }
    
    func editAlert(c : NSIndexPath)
    {
      //  http://ignacio.kevinhuynh.net:1337/house/update/26/?name=beach
//        let cell = self.collectionView.cellForItemAtIndexPath(c) as! HouseCell

        var nameTextField: UITextField!
        
        let alertController = UIAlertController(title: "Edit House Name", message: "Please enter new name for your house.", preferredStyle: .Alert)
        
        let submit = UIAlertAction(title: "Submit", style: .Default, handler: { (action) -> Void in
            
            let newName = nameTextField.text
            var allow = true
            
            if (String(newName).isEmpty)
            {
                self.displayMessage("Text Field can not be empty!")
                allow = false
                return
            }
            
            for tempNames in self.houseNames
            {
                if(tempNames == newName)
                {
                    allow = false
                    return
                }
            }
            
            if(allow)
            {
                
                let tempCell = self.collectionView.cellForItemAtIndexPath(c) as! HouseCell
                
                
                let myURL = "http://ignacio.kevinhuynh.net:1337/house/update/" + tempCell.houseID! + "/?name=" + String(newName!)
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

    
    func displayMessage(message: String)
    {
        let myAlert = UIAlertController(title:"Alert", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated:true, completion: nil);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "toHouseAddition")
        {
            let dest = segue.destinationViewController as! AddHouse
            
            dest.user = self.user
            dest.houses = self.houseNames
        }
        
        if(segue.identifier == "toHouse")
        {
            var dest = self.collectionView!.indexPathsForSelectedItems()!
            
            let indexPath = dest[0] as NSIndexPath
        
            let roomView = segue.destinationViewController as! HouseRooms
            
            roomView.user = self.user
            roomView.house.append(self.houses[indexPath.row])
            
        }
    }
    
}

