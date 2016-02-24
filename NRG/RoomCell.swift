//
//  RoomCell.swift
//  NRG
//
//  Created by Kevin Argumedo on 2/18/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit

class RoomCell : UICollectionViewCell
{
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var watts: UILabel!
    
    var roomID : String!
}