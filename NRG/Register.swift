//
//  Register.swift
//  NRG
//
//  Created by kevin on 1/15/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//


import Alamofire
import Foundation


class Register: UIViewController {
    
    //fields displayed in the registration menu
    @IBOutlet var userName: UITextField!
    @IBOutlet var userPassword: UITextField!
    @IBOutlet var repeatUserPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButton(sender: AnyObject) {
        //grabs information input into fields
        let rUsername = String(userName.text!)
        let rUPassword = String(userPassword.text!)
        let rRPassword = String(repeatUserPassword.text!)
        
        //if any field is empty then display alert
        if(rUsername.isEmpty || rUPassword.isEmpty || rRPassword.isEmpty)
        {
            displayAlertMessage("All Fields Are Required.")
            return
        }
        
        //passwords do no match, display alert
        if(rUPassword != rRPassword)
        {
            displayAlertMessage("Passwords Do Not Match.")
            return
        }
        
        
        let myURL = "http://172.249.231.197:1337/user/create?"
        
        let parameters = ["username": rUsername, "password": rUPassword]
        

        //post request will create the user and input username/password into database
        Alamofire.request(.POST, myURL, parameters: parameters)
            .response { request, response, data, error in
                print("Response_-------\(response!.statusCode)")
                
                if(response!.statusCode != 400)
                {
                    let alert = UIAlertController(title: "Congratulations!", message: "You have been registered!", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default)
                        {
                            action in self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else
                {
                    self.displayAlertMessage("The username is already taken")
                }
        }
    }
    
    //changes display to login menu.
    @IBAction func Login(sender: AnyObject) {
        
        self.performSegueWithIdentifier("toLogin", sender: self)
    }
    
    
    //displays alert with a certain message.
    func displayAlertMessage(uMessage: String)
    {
        let myAlert = UIAlertController(title:"Alert", message: uMessage, preferredStyle: UIAlertControllerStyle.Alert);
        
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okButton)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
}