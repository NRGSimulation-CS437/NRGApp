//
//  SplashScreen.swift
//  NRG
//
//  Created by Kevin Argumedo on 3/2/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit

class SplashScreen : UIViewController {
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "endSplash", userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func endSplash()
    {
        self.performSegueWithIdentifier("endSplash", sender: self)
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}