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


class AddHouse: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    var user : JSON!
    var houses = [String]()
    var link = String()
    var url = String()
    
    var houseImages = ["Apartment", "Beach House", "Cabin in the Woods", "RV", "Upload Image"]
    
    var hImage = "Apartment"
    
    let downloadGroup = dispatch_group_create()
    
    @IBOutlet weak var imageUploadProgressView: UIProgressView!
    
    var image : UIImage!
    
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
        
        self.imageUploadProgressView.hidden = true
        
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
        
        if(hName.isEmpty || zip.isEmpty)
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
                        for house in self.houses
                        {
                            if(hName == house)
                            {
                                self.displayMessage("You already have a house with that name")
                                return
                            }
                        }
                        
                        if(self.houseImages.contains(self.hImage))
                        {
                            self.url = "/images/GivenHouses/"+self.hImage+".png"
                            
                            let myURL = self.link+"/house/create?"
                            
                            let owner = String(self.user["id"])
                            
                            let parameters = ["name": String(self.name.text!), "owner": owner, "image": self.hImage, "zipCode": zip, "url": self.url]
                            
                            print(self.link+self.url)
                            
                            Alamofire.request(.POST, myURL, parameters: parameters)
                                .response { request, response, data, error in
                                    
                                    if(response!.statusCode != 400)
                                    {
                                        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "A new house has been added", preferredStyle: .Alert)
                                        
                                        
                                        let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default)
                                            { action -> Void in
                                                
                                                self.navigationController?.popViewControllerAnimated(true)
                                        }
                                        
                                        actionSheetController.addAction(nextAction)
                                        
                                        
                                        self.presentViewController(actionSheetController, animated: true, completion: nil)
                                    }
                            }                            
                        }
                        else
                        {
                            Alamofire.upload(
                                .POST,
                                self.link+"/upload/upload",
                                multipartFormData: {
                                    multipartFormData in
                                    multipartFormData.appendBodyPart(data: UIImageJPEGRepresentation(self.image, 0.5)!, name: "avatar", fileName: "house.jpg",mimeType: "image/jpg")
                                },
                                encodingCompletion: {
                                    encodingResult in
                                    switch encodingResult {
                                    case .Success(let upload, _, _ ):
                                        upload.responseJSON { response in
                                            
                                            if let tempJSON = response.result.value
                                            {
                                                let obj = JSON(tempJSON)["uploadedFiles"]
                                                
                                                let stringURL = String(obj[0]["fd"])
                                                let fullStringArray = stringURL.characters.split{$0 == "/"}.map(String.init)
                                                
                                                self.url = "/images/house/"+fullStringArray.last!
                                                print(self.link+self.url)
                                                
                                                let owner = String(self.user["id"])
                                                
                                                let parameters = ["name": String(self.name.text!), "owner": owner, "image": self.hImage, "zipCode": String(self.zipCode.text!), "url": self.url]
                                                
                                                
                                                
                                                Alamofire.request(.POST, self.link+"/house/create?", parameters: parameters)
                                                    .response
                                                    { request, response, data, error in
                                                        
                                                        if(response!.statusCode != 400)
                                                        {
                                                                dispatch_async(dispatch_get_main_queue())
                                                                    {
                                                                        self.dLoadImage(self.link+self.url)
                                                            }
                                                        }
                                                }
                                            }
                                        }
                                    case .Failure(let encodingError):
                                        print("Failure")
                                        print(encodingError)
                                    }
                                }
                            )
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
        
        if(self.houseImages[row] == "Upload Image")
        {
            let myAlert: UIAlertController = UIAlertController(title: "Upload Image", message: "Would you like to select image from Gallery?", preferredStyle:  .Alert)
            
            let confirmAction: UIAlertAction = UIAlertAction(title: "Confirm", style: .Default) { action ->
                Void in
                
                self.hImage = "customImage"
                self.uploadPic()
                
            }
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                self.picker.selectRow(0, inComponent: 0, animated: true)
            }
            
            myAlert.addAction(confirmAction)
            myAlert.addAction(cancelAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
        else
        {
            self.hImage = String(houseImages[row])
            self.image = UIImage(named: String(houseImages[row]))
            self.imageView.image = self.image
            self.hImage = houseImages[row]
        }
    }
    
    func dLoadImage(timage : String)
    {
        
        
        dispatch_group_enter(downloadGroup) //Begin a download. Make a "group enter"
        
        self.imageView.kf_setImageWithURL(NSURL(string: timage)!, placeholderImage: nil, optionsInfo: nil,
            progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                
                //Leave the group after downloaded (or error)
                dispatch_group_leave(self.downloadGroup)
                
                if var _ = image {
                    print("PDownload Completed")
                    
                    let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "A new House has been added!", preferredStyle: .Alert)
                    
                    let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default)
                        { action -> Void in
                            
                            self.navigationController?.popViewControllerAnimated(true)
                    }
                    
                    actionSheetController.addAction(nextAction)
                    
                    dispatch_async(dispatch_get_main_queue())
                        {
                            self.imageUploadProgressView.progress = 1
                            self.imageUploadProgressView.tintColor = UIColor.greenColor()
                            self.presentViewController(actionSheetController, animated: true, completion: nil)
                            
                    }
                    
                    //println(self.images)
                } else {
                    self.dLoadImage(timage)
                    self.imageUploadProgressView.hidden = false
                    if(0.93 >= self.imageUploadProgressView.progress)
                    {
                        self.imageUploadProgressView.progress += 0.01
                    }
                }
        })
        
    }

    
    func uploadPic()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = self.image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
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