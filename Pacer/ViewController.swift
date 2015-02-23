//
//  ViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 2/19/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        conversion()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func conversion(){
        if let seconds = totalSeconds.text.toInt()  {
            let time = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(seconds)
//            hour.text = time.hours.description
//            minute.text = time.minutes.description
//            second.text = time.seconds.description
            
            println("Hours: \(time.hours), Minutes: \(time.minutes), Seconds: \(time.seconds)")
        }
    }

    @IBOutlet weak var totalSeconds: UITextField!
    
    @IBAction func convert(sender: UIButton) {
        conversion()
        PacingCalculations().calculateSplits(480, distance: 5, time: 2400, lapType: LapType.Mile)
    }
}

