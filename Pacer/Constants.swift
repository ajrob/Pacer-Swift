//
//  Constants.swift
//  Pacer
//
//  Created by Alex Robinson on 2/21/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import Foundation
import UIKit

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

// Units key
let kMetricPaceKey = "metricPaceUnitsKey"
let kMetricDistanceKey = "metricDistanceUnitsKey"

let kDidLaunchBeforeKey = "didLaunchBefore"

// Layout structure for the 3 main variables
struct Storyboard {
    // Order of the rows:
    //  - Pace
    //  - Pace Picker
    //  - Duration
    //  - Duration Picker
    //  - Distance
    struct Pace {
        static let Row    = 0          // Row position of the pace
        static let CellID = "paceCell" // Will hold the pace information
        static let Tag    = 1          // Identifier for pace
        struct UnitLabel {
            static let Imperial = "min/mi"
            static let Metric = "min/km"
        }
        
        struct Picker {
            static let CellID          = "pacePickerCell" // Will contain the pace picker values
            static let Key             = "pace"           // Key for obtaining the data source item's pace picker value
            static let Tag             = 20               // Tag identifying the pace picker view
            static let MinuteComponent = 0
            static let SecondComponent = 1
        }
    }
    struct Duration {
        static let Row    = 1              // Row position of the duration
        static let CellID = "durationCell" // Will hold the duration information
        static let Tag    = 2          // Identifier for duration
        
        struct Picker {
            static let CellID          = "durationPickerCell" // Will contain the duration picker values
            static let Key             = "duration"           // Key for obtaining the data source item's duration picker value
            static let Tag             = 30                   // Tag identifying the duration picker view
            static let HourComponent   = 0
            static let MinuteComponent = 1
            static let SecondComponent = 2
        }
    }
    struct Distance {
        static let Row    = 2              // Row position of the distance
        static let CellID = "distanceCell" // Will hold the distance information
        static let Tag = 10                // Tag identifying the distance UITextField
        static let Key = "distance"        // Key for obtaining the data source item's distance value
        static let Rounding = 10.0           // Rounding factor (e.g. 10 = nearest tenth)
        struct UnitLabel {
            static let Imperial = "mi"
            static let Metric = "km"
        }
    }
    static let RowHeight: CGFloat = 55.0
    static let PickerComponentWidth = CGFloat(100.0)              // General width of all components in every picker
    static let PickerStaticLabelPadding = CGFloat(30.0)           // Padding of the labels
    static let PickerDefaultSpaceBetweenComponents = CGFloat(4.0) // Approximate default spacing between components
    static let SettingsSegue = "settingsSegue"  // Setting view segue identifier
}

struct DurationTimeFormat {
    var Hours:   Int = 0
    var Minutes: Int = 0
    var Seconds: Int = 0
    
    var TotalSeconds: Int {
        get {
            return ((Hours * 3600) + (Minutes * 60) + Seconds)
        }
        set
        {
            var total = newValue
            Hours = total / 3600
            total = total - (Hours * 3600)
            Minutes = total / 60
            total = total - (Minutes * 60)
            Seconds = total
        }
    }
    
    var Print: String {
        get {
            return description()
        }
    }
    
    func description() -> String {
        var minFormatted = Minutes.description
        var secFormatted = Seconds.description
        
        // Apply zero padding if needed
        if Minutes < 10 { minFormatted = "0\(minFormatted)" }
        if Seconds < 10 { secFormatted = "0\(secFormatted)" }
        return "\(Hours):\(minFormatted):\(secFormatted)"
    }
}

struct PaceTimeFormat {
    var Minutes: Int = 0
    var Seconds: Int = 0
    
    var TotalSeconds: Int {
        get {
            return ((Minutes * 60) + Seconds)
        }
        set
            {
                var total = newValue
                Minutes = total / 60
                total = total - (Minutes * 60)
                Seconds = total
        }
    }
    
    var Print: String {
        get {
            return description()
        }
    }
    
    func description() -> String {
        var secFormatted = Seconds.description
        
        // Apply zero padding if needed
        if Seconds < 10 { secFormatted = "0\(secFormatted)" }
        return "\(Minutes):\(secFormatted)"
    }
}

struct Increment {
    static let Points = 50
    static let Seconds = 300
}

struct Colors {
    static let Tint: UIColor = UIColor(red: CGFloat(57.0 / 255.0), green: CGFloat(149.0 / 255.0), blue: CGFloat(148.0 / 255.0), alpha: CGFloat(1.0)) // #399594
    static let DarkTint: UIColor = UIColor(red: 58 / 255.0, green: 51 / 255.0, blue: 53 / 255.0, alpha: 1.0) // #3A3335
}