//
//  ViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 2/19/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Have the fields been edited?
    private var isPaceDirty: Bool = false {
        didSet {
            println("isPaceDirty: \(isPaceDirty)")
        }
    }
    private var isTimeDirty: Bool = false
    private var isDistanceDirty: Bool = false
    
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

    @IBOutlet weak var timeHourTextField: InputUITextField!
    @IBOutlet weak var timeMinuteTextField: InputUITextField!
    @IBOutlet weak var timeSecondTextField: InputUITextField!
    @IBOutlet weak var paceMinuteTextField: InputUITextField!
    @IBOutlet weak var paceSecondTextField: InputUITextField!
    @IBOutlet weak var distanceTextField: InputUITextField!
    
    @IBOutlet weak var totalSeconds: UITextField!
    
    @IBAction func convert(sender: UIButton) {
        conversion()
        PacingCalculations().calculateSplits(480, distance: 5, time: 2400, lapType: LapType.Mile)
    }
    
    /***** Input Validation/Text field logic *****/
    
    @IBAction func distanceEditingChanged(sender: UITextField) {
        if (sender.text == "") {
            isDistanceDirty = false
            enableAllTextFields()
        } else {
            isDistanceDirty = true
            if (isPaceDirty) {
                disableTimeTextFields()
            } else if (isTimeDirty) {
                disablePaceTextFields()
            }
        }
    }
    @IBAction func paceEditingChanged(sender: UITextField) {
        if (paceMinuteTextField.text == "" && paceSecondTextField.text == "") {
            isPaceDirty = false
            enableAllTextFields()
        } else {
            isPaceDirty = true
            if (isDistanceDirty) {
                disableTimeTextFields()
            } else if (isTimeDirty) {
                distanceTextField.enabled = false
            }
        }
    }
    
    @IBAction func timeEditingChanged(sender: UITextField) {
        if (timeHourTextField.text == "" && timeMinuteTextField.text == "" && timeSecondTextField.text == "") {
            isTimeDirty = false
            enableAllTextFields()
        } else {
            isTimeDirty = true
            if (isDistanceDirty) {
                disablePaceTextFields()
            } else if (isPaceDirty) {
                distanceTextField.enabled = false
            }
        }
        
    }
    
    private func disableTimeTextFields() {
        timeHourTextField.enabled = false
        timeMinuteTextField.enabled = false
        timeSecondTextField.enabled = false
    }
    
    private func disablePaceTextFields() {
        paceMinuteTextField.enabled = false
        paceSecondTextField.enabled = false
    }
    
    private func enableTimeTextFields() {
        timeHourTextField.enabled = true
        timeMinuteTextField.enabled = true
        timeSecondTextField.enabled = true
    }
    
    private func enablePaceTextFields() {
        paceMinuteTextField.enabled = true
        paceSecondTextField.enabled = true
    }
    
    private func enableAllTextFields() {
        enablePaceTextFields()
        enableTimeTextFields()
        distanceTextField.enabled = true
    }
}

class InputUITextField: UITextField {
    override var enabled: Bool {
        willSet {
            if (newValue == false) {
                super.backgroundColor = UIColor.grayColor()
                return
            }
            super.backgroundColor = nil
        }
    }
}