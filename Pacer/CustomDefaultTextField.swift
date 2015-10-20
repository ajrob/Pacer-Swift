//
//  CustomDefaultTextField.swift
//  Pacer
//
//  Created by Alex Robinson on 10/9/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit

@IBDesignable class CustomDefaultTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Defaults for the Storyboard render
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 4
        self.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.15)
        if let placeholderString = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [
                NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.25)
                ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Defaults for the build render
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 4
        self.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.15)
        if let placeholderString = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [
                NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.25)
                ])
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
