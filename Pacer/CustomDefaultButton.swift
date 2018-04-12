//
//  CustomDefaultButton.swift
//  Pacer
//
//  Created by Alex Robinson on 10/9/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit

@IBDesignable class CustomDefaultButton: UIButton {
    
    convenience init(borderWidth:CGFloat, borderColor:UIColor, cornerRadius:CGFloat, frame:CGRect) {
        self.init(frame: frame)
        
        self.borderWidth = borderWidth
        self.radius = cornerRadius
        self.borderColor = borderColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Defaults for the Storyboard render
        self.borderWidth = 0
        self.radius = 4
//        self.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.15)
//        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Defaults for the build render
        self.borderWidth = 0
        self.radius = 4
//        self.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.15)
//        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15)
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.5
    }


    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var radius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var buttonBackgroundColor: UIColor {
        get {
            return UIColor(cgColor: layer.backgroundColor!)
        }
        set {
            layer.backgroundColor = newValue.cgColor
        }
    }

}
