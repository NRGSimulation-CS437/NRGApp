//
//  AddDevice.swift
//  NRG
//
//  Created by Kevin Argumedo on 2/11/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//
import UIKit
import Alamofire
import Kingfisher

class AddDevice: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate
{
    
    var user : JSON!
    var house : JSON!
    var room : JSON!
    var link  = String()
    
    var image : UIImage!
    var dImage = "/images/GivenDevices/Laptop.png"
    
    @IBOutlet weak var addDeviceButton: UIButton!
    
    var deviceObject = [JSON]()
    
    let downloadGroup = dispatch_group_create()
    
    @IBOutlet weak var imageUploadProgressView: UIProgressView!
    var wattage = "80"
    
    @IBOutlet weak var scrollPicker: UIPickerView!
    
    @IBOutlet var name: UITextField!
    @IBOutlet weak var watt: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollPicker.delegate = self
        scrollPicker.dataSource = self
        
        imageView.image = UIImage(named: "Laptop")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
                
        let tap2: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap2)
        
        self.imageUploadProgressView.hidden = true
        
        dispatch_async(dispatch_get_main_queue()) {
            self.scrollPicker.reloadAllComponents()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.deviceObject.removeAll()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        let myURL = self.link+"/deviceList/"
        
        print(myURL)
        
        Alamofire.request(.GET, myURL)
            .responseJSON { response in
                
                if let JSON1 = response.result.value
                {
                    for(_,jso) in JSON(JSON1)
                    {
                        self.deviceObject.append(jso)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let t : JSON = ["name": "Custom Device", "watts": "0", "image": ""]
                        
                        self.deviceObject.append(t)
                        self.scrollPicker.reloadAllComponents()
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
        return NSAttributedString(string: String(self.deviceObject[row]["name"]), attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
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
        
        for device in self.deviceObject
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
        
        print(self.dImage)
        
        if(self.dImage == "customImage")
        {
            Alamofire.upload(
                .POST,
                self.link+"/upload/upload",
                multipartFormData: {
                    multipartFormData in
                    multipartFormData.appendBodyPart(data: UIImageJPEGRepresentation(self.image, 0.1)!, name: "avatar", fileName: "house.jpg",mimeType: "image/jpg")
                },
                encodingCompletion: {
                    encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _ ):
                        upload.responseJSON { response in
                            
                            print(response)
                            if let tempJSON = response.result.value
                            {
                                let obj = JSON(tempJSON)["uploadedFiles"]
                                
                                let stringURL = String(obj[0]["fd"])
                                let fullStringArray = stringURL.characters.split{$0 == "/"}.map(String.init)
                                
                                self.dImage = "/images/house/"+fullStringArray.last!
                                print(self.dImage)
                                
                                print("-----------\n"+self.link+self.dImage+"\n--------------")
                                
                                let owner = String(self.user["id"])
                                
                                let parameters = ["name": dName, "owner": owner, "image": self.dImage, "room": String(self.room["id"]), "house": String(self.house["id"]), "watts": dWatts, "trigger": "Off"]
                                
                                dispatch_async(dispatch_get_main_queue())
                                    {
                                        Alamofire.request(.POST, self.link+"/devices/create?", parameters: parameters)
                                            .response { request, response, data, error in
                                                
                                                if(response!.statusCode != 400)
                                                {
                                                    
                                                    dispatch_async(dispatch_get_main_queue())
                                                        {
                                                            self.dLoadImage(self.link+self.dImage)
                                                    }

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
        else
        {
            let myURL = self.link+"/devices/create?"
            
            print("fadfgagafdgdsgdsgdsg\n"+myURL+"\ndsfafaas")
            
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
                    
                    let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "A new Device has been added!", preferredStyle: .Alert)
                    
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

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.deviceObject.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(self.deviceObject[row]["name"] == "Custom Device")
        {
            let myAlert: UIAlertController = UIAlertController(title: "Upload Image", message: "Would you like to select image from Gallery?", preferredStyle:  .Alert)
            
            let confirmAction: UIAlertAction = UIAlertAction(title: "Confirm", style: .Default) { action ->
                Void in
                
                self.dImage = "customImage"
                self.uploadPic()
                
            }
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                self.scrollPicker.selectRow(0, inComponent: 0, animated: true)
            }
            
            myAlert.addAction(confirmAction)
            myAlert.addAction(cancelAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
        else
        {
            self.imageView.image = UIImage(named: String(deviceObject[row]["name"]))
            self.dImage = String(deviceObject[row]["image"])
            self.watt.text = String(deviceObject[row]["watts"])
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(self.deviceObject[row]["name"])
    }
    
    func uploadPic()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func uploadImage()
    {
        let imageData = UIImageJPEGRepresentation(self.image, 1)
        
        if(imageData == nil)
        {
            return
        }
        
        self.addDeviceButton.enabled = false
        
        let uploadScriptUrl = NSURL(string: "http://www.swiftdeveloperblog.com/http-post-example-script/")
        
        let request = NSMutableURLRequest(URL: uploadScriptUrl!)
        request.HTTPMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        let task = session.uploadTaskWithRequest(request, fromData: imageData!)
        task.resume()
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        self.displayMessage("Error Uploading Image. Please try again.")
        
        self.addDeviceButton.enabled = true
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress:Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
        
        self.imageUploadProgressView.progress = uploadProgress
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = self.image
        self.dismissViewControllerAnimated(true, completion: nil)
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
            dest.link = self.link
        }
    }
}

