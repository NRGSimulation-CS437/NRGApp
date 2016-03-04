//
//  AddDevice.swift
//  NRG
//
//  Created by Kevin Argumedo on 2/11/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//
import UIKit
import Alamofire
import Gifu

class AddDevice: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    
    var user : JSON!
    var house : JSON!
    var room : JSON!
    var devices = [JSON]()
    var link  = String()
        
    var deviceObject = [JSON]()
    
    var dImage = "Laptop"
    
    var wattage = "80"
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet var name: UITextField!
    @IBOutlet weak var watt: UITextField!
    
    @IBOutlet weak var imageView: AnimatableImageView!

//    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        picker.delegate = self
        picker.dataSource = self
        
        imageView.image = UIImage(named: "Laptop")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
                
        let tap2: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap2)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.picker.reloadAllComponents()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        let myURL = self.link+"/deviceList/"
        
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
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(self.deviceObject[row]["image"]), attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    @IBAction func addHouse(sender: AnyObject)
    {
        let dName = String(name.text!)
        var dWatts = String(watt.text!)
        
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
        
        if let doubleWatt = Double(dWatts)
        {
            let tempWatts = Double(round(doubleWatt*100)/100)
            dWatts = String(tempWatts)
        }
        else
        {
            self.displayMessage("Watts input must be a number!")
            return
        }
        
        let myURL = self.link+"/devices/create?"
        
        let owner = String(self.user["id"])
        
        let parameters = ["name": dName, "owner": owner, "image": self.dImage, "room": String(self.room["id"]), "house": String(self.house["id"]), "watts": dWatts, "trigger": "Off"]
        
        Alamofire.request(.POST, myURL, parameters: parameters)
            .response { request, response, data, error in
                
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
        
        if(self.deviceObject[row]["image"] == "Phone Charger")
        {
            self.imageView.animateWithImage(named: "Phone_Charger.gif")
            self.imageView.startAnimatingGIF()
        }
        else
        {
            self.imageView.image = UIImage(named: String(deviceObject[row]["image"]))
        }
        self.dImage = String(deviceObject[row]["image"])
        self.watt.text = String(deviceObject[row]["watts"])
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

