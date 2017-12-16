//
//  ModalFromRightSegue.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/15/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

class ModalFromRightSegue: UIStoryboardSegue {

    override func perform() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        source.view.window!.layer.add(transition, forKey: kCATransition)
        source.present(destination, animated: false, completion: nil)
    }
}
