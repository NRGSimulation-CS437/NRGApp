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
        
        return cell
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