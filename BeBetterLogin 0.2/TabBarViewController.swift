//
//  ViewController.swift
//  BeBetterLogin 0.2
//
//  Created by Samuel Hauptmann van Dam on 25/05/2020.
//  Copyright © 2020 BeBetter. All rights reserved.
//

import UIKit
import Toast_Swift

class TabBarViewController: UITabBarController {

    var nextViewNumber = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = 2

        if nextViewNumber == 4 {
            self.selectedIndex = 4
            self.view.makeToast("Uploading - Stop obsessing, over how you look. It's unhealthy. Stop preforming. Have fun!", duration: 10.0)
            
//            Reset
            nextViewNumber = 0
            
        }
        
        if nextViewNumber == 2 {
            
            self.view.makeToast("Experience sent! - Sit back and relax and remember, have fun!", duration: 10.0)
            
//            Reset
            nextViewNumber = 0
            
        }
        
        if nextViewNumber == 5 {
//            Reset
            nextViewNumber = 0
            self.view.makeToast("Name Updated", duration: 3.0)
            self.selectedIndex = 4
        }
    }
}
