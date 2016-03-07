//
//  testUpload.swift
//  NRG
//
//  Created by Kevin Argumedo on 3/6/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class testUpload: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var owner: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var link = "http://localhost:1337"
    
    var imageURL = String()
    
    var image : UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func takePicture(sender: AnyObject) {
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
    
    @IBAction func AddAction(sender: AnyObject) {
    
        
        Alamofire.upload(
            .POST,
            link+"/upload/upload",
            multipartFormData: {
                multipartFormData in
                print("1")
                multipartFormData.appendBodyPart(data: UIImageJPEGRepresentation(self.image, 0.5)!, name: "avatar", fileName: "house.jpg",mimeType: "image/jpg")
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
                          
                            self.imageURL = self.link + "/images/house/"+fullStringArray.last!
                            print(self.imageURL)
                            
                            let parameters = ["name": String(self.name.text!), "owner": String(self.owner.text!), "image": "RV", "zipCode": String(self.zipCode.text!), "url": self.imageURL]
                        
                            
                            
                            Alamofire.request(.POST, self.link+"/house/create?", parameters: parameters)
                                .response { request, response, data, error in
                                    
                                    print(response)
                                    
                                    if(response!.statusCode != 400)
                                    {
                                        
                                        
                                        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "A new house has been added", preferredStyle: .Alert)
                                        
                                        
                                        let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default)
                                            { action -> Void in
                                                
                                        }
                                        
                                        actionSheetController.addAction(nextAction)
                                        
                                        
                                        self.presentViewController(actionSheetController, animated: true, completion: nil)
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