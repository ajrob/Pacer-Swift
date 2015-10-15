//
//  InputsViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 10/9/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit

class InputsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var inputsStackView:   UIStackView!
    @IBOutlet weak var distanceInputView: UIView!
    @IBOutlet weak var durationInputView: UIView!
    @IBOutlet weak var paceInputView:     UIView!
    
    @IBOutlet weak var heroStackView: UIStackView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var durationTextField: DurationTextField!
    @IBOutlet weak var distanceTextField: CustomDefaultTextField!
    @IBOutlet weak var paceTextField:     CustomDefaultTextField!
        
    var willHideDuration = false
    var willHideDistance = false
    var willHidePace     = false
    
    var durationPickerView = UIPickerView()
    var pacePickerView     = UIPickerView()
    
    var arrayOfSixty: [Int] = []
    var durationPickerData  = [[Int]]()
    var pacePickerData      = [[Int]]()
    var durationValue:DurationTimeFormat = DurationTimeFormat() {
        didSet(newDuration) {
            durationTextField.text = newDuration.Print
            if willHideDistance {
                solveForDistance()
            } else if willHidePace {
                solveForPace()
            }
        }
    }
    var paceValue:PaceTimeFormat = PaceTimeFormat() {
        didSet(newPace) {
            paceTextField.text = newPace.Print
            if willHideDistance {
                solveForDistance()
            } else if willHideDuration {
                solveForDuration()
            }
        }
    }
    var distanceValue:Double = 0.0 {
        didSet(newDuration) {
            if willHideDuration {
                solveForDuration()
            } else if willHidePace {
                solveForPace()
            }
        }
    }
    var previousTranslationPoint = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if willHideDistance {
            inputsStackView.removeArrangedSubview(distanceInputView)
            solveForDistance()
        }
        if willHideDuration {
            inputsStackView.removeArrangedSubview(durationInputView)
            solveForDuration()
        }
        if willHidePace {
            inputsStackView.removeArrangedSubview(paceInputView)
            solveForPace()
        }
        
        heroStackView.addArrangedSubview(resultLabel)
        
        titleLabel.text = titleSaying
        
        //Distance Textfield setup
        distanceTextField.addTarget(self, action: Selector("textFieldChanged:"), forControlEvents: UIControlEvents.EditingChanged)
        distanceTextField.delegate = self
        
        /*** Pickers Setup ***/
        // Duration Picker
        durationPickerView.delegate = self
        durationPickerView.dataSource = self
        durationTextField.inputView = durationPickerView
        arrayOfSixty = createSequentialIntArray(60)
        durationPickerData = [createSequentialIntArray(80), arrayOfSixty, arrayOfSixty]
        durationTextField.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("incrementDurationByFiveMinutes:")))

        // Pace Picker
        pacePickerView.delegate = self
        durationPickerView.dataSource = self
        paceTextField.inputView = pacePickerView
        pacePickerData = [arrayOfSixty, arrayOfSixty]
        paceTextField.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("incrementPaceByFiveMinutes:")))
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard")))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func incrementDurationByFiveMinutes(panGesture:UIPanGestureRecognizer) {
        durationValue.TotalSeconds = incrementByFiveMinutes(panGesture, target: durationTextField, totalSeconds: durationValue.TotalSeconds)
        durationTextField.text = durationValue.Print
        updateDurationPicker()
    }
    
    func incrementPaceByFiveMinutes(panGesture:UIPanGestureRecognizer) {
        paceValue.TotalSeconds = incrementByFiveMinutes(panGesture, target: paceTextField, totalSeconds: paceValue.TotalSeconds)
        if paceValue.TotalSeconds > 3599 {
            paceValue.TotalSeconds = 3599
        }
        paceTextField.text = paceValue.Print
        updatePacePicker()
    }
    
    func incrementByFiveMinutes(panGesture:UIPanGestureRecognizer, target: UIView, totalSeconds: Int) -> Int {
        let translatedPoint = panGesture.translationInView(target)
        let velocity = panGesture.velocityInView(target)
        var totalSeconds = totalSeconds
        if panGesture.state == UIGestureRecognizerState.Began {
            previousTranslationPoint = translatedPoint.y
        }
        let movement = abs(previousTranslationPoint - translatedPoint.y)
        if Int(movement) >= Increment.Points {
            if velocity.y < 0 {
                totalSeconds += (Int(movement) / Increment.Points) * Increment.Seconds
            } else {
                if totalSeconds >= Increment.Seconds {
                    totalSeconds -= (Int(movement) / Increment.Points) * Increment.Seconds
                } else {
                    totalSeconds = 0
                }
            }
            previousTranslationPoint = translatedPoint.y
        }
        return totalSeconds
    }
    
    // MARK: - UITextFieldDelegate
    func endEditingNow() {
        self.view.endEditing(true)
    }
    func textFieldChanged(textField: UITextField) {
        distanceValue = (textField.text! as NSString).doubleValue
    }
    
    @IBOutlet var distanceEvents: UIScrollView!
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        // Create button bar for the keyboard
        let keyboardDoneButtonBar = UIToolbar()
        keyboardDoneButtonBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: Selector("endEditingNow"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let toolbarButtons = [flexibleSpace, doneButton]
        keyboardDoneButtonBar.setItems(toolbarButtons, animated: false)
        
        //        textField.inputAccessoryView = keyboardDoneButtonBar
        textField.inputAccessoryView = distanceEvents
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.resignFirstResponder()
    }

    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView.isEqual(durationPickerView) {
            return durationPickerData.count
        } else {
            return pacePickerData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(durationPickerView) {
            return durationPickerData[component].count
        } else {
            return pacePickerData[component].count
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.isEqual(durationPickerView) {
            switch component {
            case 0:
                durationValue.Hours = durationPickerData[component][row]
            case 1:
                durationValue.Minutes = durationPickerData[component][row]
            case 2:
                durationValue.Seconds = durationPickerData[component][row]
            default:
                break
            }
            durationTextField.text = "\(durationValue.Print)"
        } else if pickerView.isEqual(pacePickerView) {
            switch component {
            case 0:
                paceValue.Minutes = pacePickerData[component][row]
            case 1:
                paceValue.Seconds = pacePickerData[component][row]
            default:
                break
            }
            paceTextField.text = "\(paceValue.Print)"
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.isEqual(durationPickerView) {
            return "\(durationPickerData[component][row])"
        } else {
            return "\(pacePickerData[component][row])"
        }
    }
    
    // MARK: - Private functions
    private func createSequentialIntArray(numberOfElements: Int) -> [Int] {
        var array = [Int]()
        for (var i = 0; i < numberOfElements; i++) {
            array.append(i)
        }
        return array
    }
    
    private func updateDurationPicker() {
        durationPickerView.selectRow(durationValue.Hours, inComponent: 0, animated: true)
        durationPickerView.selectRow(durationValue.Minutes, inComponent: 1, animated: true)
        durationPickerView.selectRow(durationValue.Seconds, inComponent: 2, animated: true)
    }
    
    private func updatePacePicker() {
        pacePickerView.selectRow(paceValue.Minutes, inComponent: 0, animated: true)
        pacePickerView.selectRow(paceValue.Seconds, inComponent: 1, animated: true)
    }
    
    func dismissKeyboard() {
        if durationTextField.editing {
            durationTextField.resignFirstResponder()
        }
        if paceTextField.editing {
            paceTextField.resignFirstResponder()
        }
        if distanceTextField.editing {
            distanceTextField.resignFirstResponder()
        }
    }
    
    private func solveForDistance() {
        if paceValue.TotalSeconds == 0 {
            distanceValue = PacingCalculations().distanceFormula(Double(paceValue.TotalSeconds), time: Double(durationValue.TotalSeconds))
        } else {
            distanceValue = PacingCalculations().distanceFormula(1/Double(paceValue.TotalSeconds), time: Double(durationValue.TotalSeconds))
        }
        resultLabel.text = "\(round(distanceValue * Storyboard.Distance.Rounding) / Storyboard.Distance.Rounding) mi"
    }
    
    private func solveForDuration() {
        var result: Double
        let effectiveDistance = distanceValue
//        if isPaceMetric && !isDistanceMetric {
//            effectiveDistance = PacingCalculations.Conversion.Length().milesToKilometers(distanceValue)
//        } else if !isPaceMetric && isDistanceMetric {
//            effectiveDistance = PacingCalculations.Conversion.Length().kilometersToMiles(distanceValue)
//        }
        if paceValue.TotalSeconds == 0 {
            result = PacingCalculations().timeFormula(Double(paceValue.TotalSeconds), distance: Double(effectiveDistance))
        } else {
            result = PacingCalculations().timeFormula(1/Double(paceValue.TotalSeconds), distance: Double(effectiveDistance))
        }
        let formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(result))
        
        durationValue.Hours = formattedResult.hours
        durationValue.Minutes = formattedResult.minutes
        durationValue.Seconds = formattedResult.seconds
        
        resultLabel.text = durationValue.description()
    }
    
    private func solveForPace() {
        var result = 0.0
        let effectiveDistance = distanceValue
//        if isPaceMetric && !isDistanceMetric {
//            effectiveDistance = PacingCalculations.Conversion.Length().milesToKilometers(distanceValue)
//        } else if !isPaceMetric && isDistanceMetric {
//            effectiveDistance = PacingCalculations.Conversion.Length().kilometersToMiles(distanceValue)
//        }
        result = PacingCalculations().rateFormula(effectiveDistance, time: Double(durationValue.TotalSeconds))
        
        var formattedResult: (hours: Int, minutes: Int, seconds: Int)
        if result == 0 {
            formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(result))
        } else {
            formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(1/result))
        }
        paceValue.Minutes = formattedResult.minutes
        paceValue.Seconds = formattedResult.seconds
        
        resultLabel.text = "\(paceValue.description()) min/mi"
    }
    
    var titleSaying = "I haven't been set yet"
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
