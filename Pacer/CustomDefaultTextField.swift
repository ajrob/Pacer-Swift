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
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        if let placeholderString = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [
                NSForegroundColorAttributeName: UIColor.lightTextColor()
                ])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Defaults for the build render
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 4
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        if let placeholderString = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [
                NSForegroundColorAttributeName: UIColor.lightTextColor()
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
