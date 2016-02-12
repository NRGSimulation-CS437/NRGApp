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

class HouseCollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
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
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        house.removeAll()
        houses.removeAll()
        houseNames.removeAll()
        
        let myURL = "http://172.249.231.197:1337/house/"
        
        let parameters = ["owner": String(self.user["username"])]
        
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
        
        let myURL = "http://ignacio.kevinhuynh.net:1337/devices/"
        
        var counter : Double = 0
        
        let parameters = ["trigger" : "on", "owner": String(self.user["username"]), "house": String(self.houses[indexPath.row]["name"])]
        
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
    
    @IBAction func logoutButton(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("toLogin", sender: self)
        }
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

