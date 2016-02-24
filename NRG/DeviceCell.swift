//
//  DeviceCell.swift
//  NRG
//
//  Created by Kevin Argumedo on 1/31/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit

class DeviceCell: UICollectionViewCell {
    
    var on : Bool!
    
    @IBOutlet weak var deviceName: UILabel!
    
    @IBOutlet weak var watts: UILabel!
    
    @IBOutlet weak var trigger: UISwitch!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var deviceID : String!
}
