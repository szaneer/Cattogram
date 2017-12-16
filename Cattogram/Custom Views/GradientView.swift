//
//  GradientView.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/15/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    var shape:Int = 0
    
    @IBInspectable var gradientStartColor: UIColor = .white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var gradientEndColor: UIColor = .white {
        didSet {
            updateGradient()
        }
    }
    
    override class var layerClass: Swift.AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateGradient() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)
    }
}


