//
//  FadeSegue.swift
//  Flicker
//
//  Created by Siraj Zaneer on 11/21/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class FadeSegue: UIStoryboardSegue {

    override func perform() {
        var firstVCView = self.source.view as! UIView
        var secondVCView = self.destination.view as! UIView
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        secondVCView.alpha = 0.0
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            firstVCView.alpha = 0.0
            self.source.tabBarController?.viewControllers![(self.source.tabBarController?.selectedIndex)!] = self.destination
            secondVCView.alpha = 1.0
        }) { (Finished) -> Void in
            self.source.removeFromParentViewController()
        }
    }
}
