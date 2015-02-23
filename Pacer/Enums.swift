//
//  Enums.swift
//  Pacer
//
//  Created by Alex Robinson on 2/21/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import Foundation

enum LapType: String {
    case Lap = "Lap"
    case Mile = "Mile"
    case Kilometer = "Km"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}