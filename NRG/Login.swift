//
//  Login.swift
//  NRG
//
//  Created by kevin on 1/15/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Login: UIViewController {
    
    var user = [JSON]()
    
    //fields for the login view
    @IBOutlet var usName: UITextField!
    @IBOutlet var usPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //login Button
    @IBAction func loginAction(sender: AnyObject) {
        //grabs data that user input in the fields.
        let uName = String(usName.text!)
        let uPassword = String(usPassword.text!)
        
        //If either field is empty, display alert.
        if(uName.isEmpty || uPassword.isEmpty)
        {
            self.displayAlertMessage("The fields are empty!")
            return
        }
        let t = 2
        
        print(uName, " ", uPassword, t)
        
        let myURL = "http://172.249.231.197:1337/user/"
        
        let parameters = ["username": uName, "password": uPassword]
        
        Alamofire.request(.GET, myURL, parameters: parameters)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,usr) in JSON(JSON1)
                    {
                        if(String(usr["username"]) == uName && uPassword == String(usr["password"]))
                        {
                            self.user.append(usr)
                            self.performSegueWithIdentifier("toLogin", sender: self)
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue())
                            {
                                self.displayAlertMessage("Username and Password do not match")
                            }
                        }
                    }
                    
                    if(self.user.isEmpty)
                    {
                        dispatch_async(dispatch_get_main_queue())
                            {
                                self.displayAlertMessage("Username and Password do not match")
                        }
                    }
                }
        }
    }
    
    //sends user to registration view
    @IBAction func Register(sender: AnyObject) {
        
        self.performSegueWithIdentifier("toRegister", sender: self)
    }
    
    
    //display customized alert
    func displayAlertMessage(uMessage: String)
    {
        let myAlert = UIAlertController(title:"Alert", message: uMessage, preferredStyle: UIAlertControllerStyle.Alert);
        
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okButton)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toLogin")
        {
            
            let navDest = segue.destinationViewController as! UINavigationController
            
            let houseCollect = navDest.viewControllers.first as! HouseCollectionView
            
            houseCollect.user =  self.user
        }
    }
}