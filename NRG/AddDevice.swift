//
//  AddDevice.swift
//  NRG
//
//  Created by Kevin Argumedo on 2/11/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//
import UIKit
import Alamofire


class AddDevice: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    
    var user : JSON!
    var house : JSON!
    var room : JSON!
    var devices = [JSON]()
        
    var deviceObject = [JSON]()
    
    var dImage = "Laptop"
    
    var wattage = "80"
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet var name: UITextField!
    @IBOutlet weak var watts: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        picker.delegate = self
        picker.dataSource = self
        
        imageView.image = UIImage(named: "Laptop")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.picker.reloadAllComponents()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let myURL = "http://ignacio.kevinhuynh.net:1337/deviceList/"
        
        Alamofire.request(.GET, myURL)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,jso) in JSON(JSON1)
                    {
                        self.deviceObject.append(jso)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.picker.reloadAllComponents()
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func addHouse(sender: AnyObject)
    {
        let dName = String(name.text!)
        let dWatts = String(watts.text!)
        
        if(dName.isEmpty)
        {
            displayMessage("Please input device name!")
            return
        }
        
        if(dWatts.isEmpty)
        {
            displayMessage("Please input amount of watts device uses")
        }
        
        for device in self.devices
        {
            if(dName == String(device["name"]))
            {
                self.displayMessage("You already have a device with that name")
                return
            }
        }
        
        if let _ = Double(dWatts)
        {
        }
        else
        {
            self.displayMessage("Watts input must be a number!")
            return
        }
        
        
        let myURL = "http://ignacio.kevinhuynh.net:1337/devices/create?"
        
        let owner = String(self.user["username"])
        
        let parameters = ["name": dName, "owner": owner, "image": self.dImage, "room": String(self.room["name"]), "house": String(self.house["name"]), "watts": dWatts, "trigger": "Off"]
        
        
        Alamofire.request(.POST, myURL, parameters: parameters)
            .response { request, response, data, error in
                print("Response_-------\(response!.statusCode)")
                
                if(response!.statusCode != 400)
                {
                    let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "A new Device has been added!", preferredStyle: .Alert)
                    
                    
                    let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default)
                        { action -> Void in
                            
                            self.navigationController?.popViewControllerAnimated(true)
                    }
                    
                    actionSheetController.addAction(nextAction)
                    
                    
                    self.presentViewController(actionSheetController, animated: true, completion: nil)
                }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.deviceObject.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.imageView.image = UIImage(named: String(deviceObject[row]["image"]))
        self.dImage = String(deviceObject[row]["image"])
        self.watts.text = String(deviceObject[row]["watts"])
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(self.deviceObject[row]["image"])
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
            let dest = segue.destinationViewController as! DevicesCollection
            dest.user = self.user
            dest.room = self.room
            dest.house = self.house
        }
    }
}

