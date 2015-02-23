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
        var index = 0
        var elapsedTime = 0
        var splits: [(lap: Int, lapType: LapType, cumulativeSeconds: Int)] = []
        var cumulativeSeconds = 0
        
        for (var i = 1; i <= Int(distance); i++){
            cumulativeSeconds += Int(rate)
            let split = (lap: i, lapType: lapType, cumulativeSeconds: cumulativeSeconds)
            splits.append(split)
        }
        if distance % 1 != 0 {
            //There was a fraction of a distance
            
        }
        //DEBUG
        for split in splits {
            println("\(split.lapType.description) \(split.lap): \(split.cumulativeSeconds) seconds")
        }
        //ENDDEBUG
        
        return splits
    }
    
    struct Conversion {
        struct Time {
            func secondsToMinutes(seconds: Double) -> Double {
                return seconds / 60
            }
            
            func secondsToHours(seconds: Double) -> Double {
                return seconds / 3600
            }
            
            func hoursToSeconds(hours: Double) -> Double {
                return hours * 3600
            }
            
            func minutesToSeconds(minutes: Double) -> Double {
                return minutes * 60
            }
            
            func secondsInHoursMinutesSeconds(var seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
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
        }
    }
}