//
//  HouseCollectionView.swift
//  NRG
//
//  Created by Kevin Argumedo on 1/28/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit


class HouseCollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user = [JSON]()
    
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
        
        RestApiManager.sharedInstance.getHouses(String(self.user[0]["username"])){ json -> Void in
            
            //grabs the user returned with that username and password.
            print(json)
            for (_,house) in json
            {
                self.houses.append(house)
                self.houseNames.append(String(house["name"]))
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
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
        cell.textDisplay.text = houseNames[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        self.performSegueWithIdentifier("toHouse", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //when house is added, use the following segu
//        if(segue.identifier == "toHouse")
//        {
//            
//            var dest = self.collectionView!.indexPathsForSelectedItems()!
//            
//            let indexPath = dest[0] as NSIndexPath
//            
//            let houseView = segue.destinationViewController as! HouseView
//            
//            house.append(self.houses[indexPath.row])
//            
//            houseView.house = self.house
//            houseView.user = self.user
//        }
        
        
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

