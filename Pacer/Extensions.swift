//
//  Extensions.swift
//  Pacer
//
//  Created by Alex Robinson on 10/15/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import Foundation

//Conversion utility
extension Double {
    var mi: Double { return self }
    var km: Double { return self / 1.60934 }
    var m: Double { return self * 1609.34 }
    var ft: Double { return self * 5280 }
}