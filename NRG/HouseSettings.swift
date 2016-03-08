//
//  HouseSettings.swift
//  NRG
//
//  Created by Kevin Argumedo on 3/2/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class HouseSettings: UIViewController {
    
    var user : JSON!
    var houseNames = [String]()
    var house : JSON!

    
    @IBOutlet weak var zipCode: UILabel!
    @IBOutlet weak var zipButton: UIButton!
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var newName: UITextField!
    
    var link = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        zipButton.layer.cornerRadius = 10
        zipCode.text = String(house["zipCode"])
        newName.text = String(house["name"])
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        let weatherAPI = "http://api.wunderground.com/api/99ac21f4c4a0ee76/conditions/q/"+String(house["zipCode"])+".json"
        print(weatherAPI+"\n")
        Alamofire.request(.GET, weatherAPI)
            .responseJSON { response in
                if let JSON1 = response.result.value
                {
                    print(JSON1)
                    print("\n")
                    let JSON2 = JSON(JSON1)["current_observation"]
                    
                    self.city.text = String(JSON2["display_location"]["full"])
                    self.temperature.text = String(JSON2["temperature_string"])
                }
        }
    }

    @IBAction func updateName(sender: AnyObject) {
        
    }
    
    @IBAction func deleteHouse(sender: AnyObject) {
        
        
        let tempString = "Are you sure you want to delete \"" + String(self.house["name"]) + "\"?"
        
        let deleteAlert: UIAlertController = UIAlertController(title: "Confirm Delete", message: tempString, preferredStyle:  .Alert)
        
        let confirmDelete: UIAlertAction = UIAlertAction(title: "Confirm", style: .Default) { action ->
            Void in
            
            let tempRoomsURL = self.link+"/rooms?owner="+String(self.house["owner"])+"&house=" + String(self.house["id"])
            
            Alamofire.request(.GET, tempRoomsURL)
                .responseJSON { response in
                    
                    if let JSON1 = response.result.value
                    {
                        for(_,rm) in JSON(JSON1)
                        {
                            let tempRoomURL = self.link+"/rooms/destroy/"+String(rm["id"])
                            
                            Alamofire.request(.POST, tempRoomURL).response
                                { request , response, data, error in
                                    
                            }
                        }
                    }
            }

            
            let tempDevicesURL = self.link+"/devices?owner="+String(self.house["owner"]) + "&house=" + String(self.house["id"])
            
            Alamofire.request(.GET, tempDevicesURL)
                .responseJSON { response in
                    
                    if let JSON1 = response.result.value
                    {
                        for(_,rm) in JSON(JSON1)
                        {
                            let tempRoomURL = self.link+"/devices/destroy/"+String(rm["id"])
                            
                            Alamofire.request(.POST, tempRoomURL).response
                                { request, response, data, error in
                                    
                                    
                            }
                        }
                    }
            }
            
            
            let myURL = self.link+"/house/destroy/" + String(self.house["id"])
            
            Alamofire.request(.POST, myURL)
                .response { request, response, data, error in
                    
            }
            
            dispatch_async(dispatch_get_main_queue())
                {
                    let myAlert = UIAlertController(title:"Alert", message: "House has been deleted.", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    
                    myAlert.addAction(okAction);
                    self.presentViewController(myAlert, animated:true, completion: nil);
            }

        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            //do nnothing
        }

        deleteAlert.addAction(confirmDelete)
        deleteAlert.addAction(cancel)
        presentViewController(deleteAlert, animated: true, completion: nil)
    }
    
    
    func displayMessage(message: String)
    {
        let myAlert = UIAlertController(title:"Alert", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated:true, completion: nil);
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeZip(sender: AnyObject) {
        
        
        
    }
    
}