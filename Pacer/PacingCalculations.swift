//
//  PacingCalculations.swift
//  Pacer
//
//  Created by Alex Robinson on 2/19/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import Foundation

struct PacingCalculations
{
    func distanceFormula(rate: Double, time: Double) -> Double {
        let distance = rate * time
        return distance
    }
    
    func rateFormula(distance: Double, time: Double) -> Double {
        let rate = (time != 0 ? distance / time : 0)
        return rate
    }
    
    func timeFormula(rate: Double, distance: Double) -> Double {
        let time = (rate != 0 ? distance / rate : 0)
        return time
    }
    
    func calculateSplits(rate: Double, distance: Double, time: Double, lapType: LapType) -> [(lap: Int, lapType: LapType, cumulativeSeconds: Int)] {
        var splits: [(lap: Int, lapType: LapType, cumulativeSeconds: Int)] = []
        var cumulativeSeconds = 0
        
        for i in 1...Int(distance) {
//        for (var i = 1; i <= Int(distance); i++){
            cumulativeSeconds += Int(rate)
            let split = (lap: i, lapType: lapType, cumulativeSeconds: cumulativeSeconds)
            splits.append(split)
        }
        if remainder(distance, 1) != 0 {
//        if distance % 1 != 0 {
            //There was a fraction of a distance
            
        }
        //DEBUG
        for split in splits {
            print("\(split.lapType.description) \(split.lap): \(split.cumulativeSeconds) seconds", terminator: "")
        }
        //ENDDEBUG
        
        return splits
    }
    
    struct Conversion {
        struct Time {
            // Converts the given amount of seconds to minutes
            func secondsToMinutes(seconds: Double) -> Double {
                return seconds / 60
            }
            
            // Converts the given amount of seconds to hours
            func secondsToHours(seconds: Double) -> Double {
                return seconds / 3600
            }
            
            // Converts the given amount of hours to seconds
            func hoursToSeconds(hours: Double) -> Double {
                return hours * 3600
            }
            
            // Converts the given amount of minutes to seconds
            func minutesToSeconds(minutes: Double) -> Double {
                return minutes * 60
            }
            
            // Converts the given amount of seconds to a tuple containing hours, minutes, and seconds
            func secondsInHoursMinutesSeconds(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
                return (seconds / 3600, (seconds / 60) % 60, seconds % 60)
            }
        }
        
        struct Length {
            func metersToMiles(meters: Double) -> Double {
                return meters * 0.000621371
            }
            
            func kilometersToMiles(kilometers: Double) -> Double {
                return kilometers * 0.621371
            }
            
            func yardsToMiles(yards: Double) -> Double {
                return yards * 0.000568182
            }
            
            func milesToKilometers(miles: Double) -> Double {
                return miles * 1.60934
            }
        }
    }
}
