//
//  TipsViewController.swift
//  NRG
//
//  Created by Kevin Argumedo on 3/1/16.
//  Copyright © 2016 Kevin Argumedo. All rights reserved.
//

import Foundation
import UIKit

class TipsViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    var tipsPageController: TipsPageController? {
        didSet {
            tipsPageController?.tipDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.addTarget(self, action: "didChangePageControlValue", forControlEvents: .ValueChanged)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tipsPageController = segue.destinationViewController as? TipsPageController {
            self.tipsPageController = tipsPageController
        }
    }
    
    @IBAction func didTapNextButton(sender: UIButton) {
        tipsPageController?.scrollToNextViewController()
    }
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
        tipsPageController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension TipsViewController: TipsPageControllerDelegate {
    
    func tipsPageController(tipsPageController: TipsPageController,
        didUpdatePageCount count: Int) {
            pageControl.numberOfPages = count
    }
    
    func tipsPageController(tipsPageController: TipsPageController,
        didUpdatePageIndex index: Int) {
            pageControl.currentPage = index
    }
    
}