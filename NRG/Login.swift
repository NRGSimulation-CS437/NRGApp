//
//  Login.swift
//  NRG
//
//  Created by kevin on 1/15/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//abdias test

import Foundation
import UIKit
import Alamofire

class Login: UIViewController {
    
    var user : JSON!
    var link : String = "http://ignacio.kevinhuynh.net:1337"
  
//    var link : String = "http://localhost:1337"

    //fields for the login view
    @IBOutlet var usName: UITextField!
    @IBOutlet var usPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if NSUserDefaults.standardUserDefaults().valueForKey("username") != nil
        {
            if(NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn"))
            {
                if NSUserDefaults.standardUserDefaults().valueForKey("id") != nil
                {
                    self.view.hidden = true
                    let tempString = String(NSUserDefaults.standardUserDefaults().valueForKey("username")!)
                    let tempPass = String(NSUserDefaults.standardUserDefaults().valueForKey("password")!)
                    let tempID = String(NSUserDefaults.standardUserDefaults().valueForKey("id")!)
                    let tempUser = ["username" : tempString, "password" : tempPass, "id" : tempID]
                    self.user = JSON(tempUser)
                    
                    self.performSegueWithIdentifier("toLogin", sender: self)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("toLogin", sender: self) })
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    //login Button
    @IBAction func loginAction(sender: AnyObject) {
        //grabs data that user input in the fields.
        let uName = String(usName.text!)
        let uPassword = String(usPassword.text!)
        var confirmUser = true
        
        //If either field is empty, display alert.
        if(uName.isEmpty || uPassword.isEmpty)
        {
            self.displayAlertMessage("The fields are empty!")
            return
        }
        
        let myURL = self.link + "/user/"
        
        let parameters = ["username": uName, "password": uPassword]
        
        Alamofire.request(.GET, myURL, parameters: parameters)
            .responseJSON { response in
                if let JSON1 = response.result.value
                {
                    for(_,usr) in JSON(JSON1)
                    {
                        if(String(usr["username"]) == uName && uPassword == String(usr["password"]))
                        {
                            self.user = usr
                            
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn");
                            NSUserDefaults.standardUserDefaults().setValue(String(self.user["username"]), forKey: "username")
                            NSUserDefaults.standardUserDefaults().setValue(String(self.user["password"]), forKey: "password")
                            NSUserDefaults.standardUserDefaults().setValue(String(self.user["id"]), forKey: "id")
                            NSUserDefaults.standardUserDefaults().synchronize();
                            confirmUser = false
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

                    if(confirmUser)
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
    
    //removes keyboard when tapping elsewhere on screen
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "toLogin")
        {
            
            let navDest = segue.destinationViewController as! UINavigationController
            
            let houseCollect = navDest.viewControllers.first as! HouseCollectionView
            
            houseCollect.user =  self.user
            houseCollect.link = self.link
        }
        
    }
}