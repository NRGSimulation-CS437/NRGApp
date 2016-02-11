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

class DevicesCollection : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
    var devices = [JSON]()
    var user = JSON!()
    var room = JSON!()
    var house = JSON!()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        let myURL = "http://172.249.231.197:1337/devices/"
        
        self.devices.removeAll()
        
        let parameters = ["owner": String(self.user["username"]), "room": String(self.room["name"]), "": String(self.house["name"])]
        
        Alamofire.request(.GET, myURL, parameters: parameters)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,dev) in JSON(JSON1)
                    {
                        self.devices.append(dev)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                    }
                }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DeviceCell
        
        cell.deviceName.text = String(devices[indexPath.row]["name"])
        cell.imageView.image = UIImage(named: String(devices[indexPath.row]["image"]))
        cell.watts.text = "Watts: " +  String(devices[indexPath.row]["watts"])
        
        if(String(devices[indexPath.row]["trigger"]) == "Off")
        {
            cell.trigger.setOn(false, animated: true)
            cell.on = false
//            self.postTrigger(String(self.devices[indexPath.row]["id"]), trigger: String("Off"))
        }
        else
        {
            cell.on = true;
            cell.trigger.setOn(true, animated: true)
//            self.postTrigger(String(self.devices[indexPath.row]["id"]), trigger: String("On"))
        }
        
        cell.trigger?.layer.setValue(indexPath, forKey: "sendIndex")
        cell.trigger?.layer.setValue(cell, forKey: "sendCell")
        print("here")
        cell.trigger?.addTarget(self, action: "changeTrigger:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func changeTrigger(sender: UISwitch)
    {
        print("2")
        let cell = sender.layer.valueForKey("sendCell") as! DeviceCell
        let index = sender.layer.valueForKey("sendIndex") as! NSIndexPath
        var trigger = "Off"
        
        if(cell.on!)
        {
            cell.on = false
            trigger = "Off"
        }
        else
        {
            cell.on = true
            trigger = "On"
        }
        
        Alamofire.upload(
            .POST,
            "http://ignacio.kevinhuynh.net:1337/devices/update/"+String(self.devices[index.row]["id"]),
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