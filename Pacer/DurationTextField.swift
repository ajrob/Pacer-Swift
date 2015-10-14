//
//  DurationTextField.swift
//  Pacer
//
//  Created by Alex Robinson on 10/11/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit

class DurationTextField: CustomDefaultTextField {

    //TODO: Figure out how to do fixed label
    
    var previousTranslationPoint = CGFloat()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Defaults for the Storyboard render
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Defaults for the build render
        
    }
}
