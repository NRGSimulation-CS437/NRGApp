//
//  HouseSettings.swift
//  NRG
//
//  Created by Kevin Argumedo on 3/2/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class HouseSettings: UIViewController {
    
    var user : JSON!
    var houseNames = [String]()
    var house : JSON!

    
    @IBOutlet weak var zipCode: UILabel!
    @IBOutlet weak var zipButton: UIButton!
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var newName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        zipButton.layer.cornerRadius = 10
        zipCode.text = String(house["zipCode"])
        newName.text = String(house["name"])
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        let weatherAPI = "http://api.wunderground.com/api/99ac21f4c4a0ee76/conditions/q/"+String(house["zipCode"])+".json"
        print(weatherAPI+"\n")
        Alamofire.request(.GET, weatherAPI)
            .responseJSON { response in
                if let JSON1 = response.result.value
                {
                    print(JSON1)
                    print("\n")
                    let JSON2 = JSON(JSON1)["current_observation"]
                    
                    self.city.text = String(JSON2["display_location"]["full"])
                    self.temperature.text = String(JSON2["temperature_string"])
                }
        }
    }

    @IBAction func updateName(sender: AnyObject) {
        
    }
    
    @IBAction func deleteHouse(sender: AnyObject) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeZip(sender: AnyObject) {
        
        
        
    }
    
}