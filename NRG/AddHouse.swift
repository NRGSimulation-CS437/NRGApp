//
//  AddHouse.swift
//  NRG
//
//  Created by Kevin Argumedo on 1/28/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class AddHouse: UIViewController {
    
    var user = [JSON]()
    var houses = [String]()
    
    @IBOutlet var name: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addHouse(sender: AnyObject)
    {
        let hName = String(name.text!)
        
        if(hName.isEmpty)
        {
            displayMessage("All Fields Required")
            return
        }
        
        for house in self.houses
        {
            if(hName == house)
            {
                self.displayMessage("You already have a house with that name")
                return
            }
        }
        
        
        let myURL = "http://172.249.231.197:1337/house/create?"
        
        let currentUser = self.user[0]
        let owner = String(currentUser["username"])
        
        let parameters = ["name": String(name.text!), "owner": owner]
        
        
        //post request will create the user and input username/password into database
        Alamofire.request(.POST, myURL, parameters: parameters)
            .response { request, response, data, error in
                print("Response_-------\(response!.statusCode)")
                
                if(response!.statusCode != 400)
                {
                    self.displayMessage("A new house has been added!")
                    
                    self.performSegueWithIdentifier("toCollectionView", sender: self)
                }
        }
    }
    
    func displayMessage(message: String){
        let myAlert = UIAlertController(title:"Alert", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated:true, completion: nil);
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
                if(segue.identifier == "toCollectionView")
                {
                    let dest = segue.destinationViewController as! HouseCollectionView
                    dest.user = self.user
                }
    }
}

