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


class AddHouse: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    
    var user : JSON!
    var houses = [String]()
    var link = String()
    
    var houseImages = ["Apartment", "Beach Cabin", "Beach House", "Cabin in the Woods", "Penthouse", "Winter Cabin", "RV"]
    
    var hImage = "Apartment"
    
    @IBOutlet weak var zipCode: UITextField!
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet var name: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        picker.delegate = self
        picker.dataSource = self
        
        imageView.image = UIImage(named: "Apartment")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

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
        let hName = String(name.text!)
        let zip = String(zipCode.text!)
        
        if(hName.isEmpty)
        {
            displayMessage("All Fields Required")
            return
        }
        
        if(zip.isEmpty)
        {
            displayMessage("All Fields Required")
            return
        }
        var returnThis = false
        let weatherAPI = "http://api.wunderground.com/api/99ac21f4c4a0ee76/conditions/q/"+zip+".json"
        Alamofire.request(.GET, weatherAPI)
            .responseJSON { response in
                if let JSON1 = response.result.value
                {
                    let JSON2 = JSON(JSON1)["response"]
                    
                    if JSON2["error"] != nil
                    {
                        returnThis = false
                    }
                    else
                    {
                        returnThis = true
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if(returnThis)
                    {
                        print("4")
                        
                        for house in self.houses
                        {
                            if(hName == house)
                            {
                                self.displayMessage("You already have a house with that name")
                                return
                            }
                        }
                        print("5")
                        
                        
                        let myURL = "http://172.249.231.197:1337/house/create?"
                        
                        let owner = String(self.user["id"])
                        
                        let parameters = ["name": String(self.name.text!), "owner": owner, "image": self.hImage, "zipCode": zip]
                        print("6")
                        
                        
                        Alamofire.request(.POST, myURL, parameters: parameters)
                            .response { request, response, data, error in
                                
                                if(response!.statusCode != 400)
                                {
                                    let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "A new house has been added", preferredStyle: .Alert)
                                    
                                    
                                    let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default)
                                        { action -> Void in
                                            
//                                            self.performSegueWithIdentifier("toCollectionView", sender: self)
                                            self.navigationController?.popViewControllerAnimated(true)
                                    }
                                    
                                    actionSheetController.addAction(nextAction)
                                    
                                    
                                    self.presentViewController(actionSheetController, animated: true, completion: nil)
                                }
                        }
                        
                    }
                }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.houseImages.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.imageView.image = UIImage(named: String(houseImages[row]))
        self.hImage = houseImages[row]
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.houseImages[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(self.houseImages[row]), attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
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
            let navDest = segue.destinationViewController as! UINavigationController
                    
            let dest = navDest.viewControllers.first as! HouseCollectionView
            dest.user = self.user
        }
    }
}

