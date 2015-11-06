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
    
    @IBOutlet var distanceEvents: UIScrollView!
    
    @IBOutlet weak var heroStackView: UIStackView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startOver: UIButton!

    @IBOutlet weak var durationTextField: DurationTextField!
    @IBOutlet weak var distanceTextField: CustomDefaultTextField!
    @IBOutlet weak var paceTextField:     CustomDefaultTextField!
        
    @IBOutlet var mainView: UIView!
    
    var activeField = UITextField()
    
    var willHideDuration = false
    var willHideDistance = false
    var willHidePace     = false
    
    var isPaceMetric     = false
    var isDistanceMetric = false
    
    @IBOutlet var durationPickerViewContainer: UIView!
    @IBOutlet weak var durationPickerView: UIPickerView!
    
    @IBOutlet var pacePickerViewContainer: UIView!
    @IBOutlet weak var pacePickerView: UIPickerView!
    
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
        didSet(newDistance) {
            if willHideDuration {
                solveForDuration()
            } else if willHidePace {
                solveForPace()
            }
        }
    }
    var previousTranslationPoint = CGFloat()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startOver.bounds.origin.y -= (view.bounds.height + startOver.bounds.height)
        
        distanceInputView.bounds.origin.x -= view.bounds.width
        durationInputView.bounds.origin.x -= view.bounds.width
        paceInputView.bounds.origin.x     -= view.bounds.width
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if willHideDistance {
            inputsStackView.removeArrangedSubview(distanceInputView)
            distanceInputView.hidden = true
            UIView.animateWithDuration(0.45, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.paceInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            UIView.animateWithDuration(0.25, delay: 0.25, usingSpringWithDamping: 0.75, initialSpringVelocity: 40, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.durationInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            solveForDistance()
        } else if willHideDuration {
            inputsStackView.removeArrangedSubview(durationInputView)
            durationInputView.hidden = true
            UIView.animateWithDuration(0.45, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.paceInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            UIView.animateWithDuration(0.25, delay: 0.25, usingSpringWithDamping: 0.75, initialSpringVelocity: 40, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.distanceInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            solveForDuration()
        } else if willHidePace {
            inputsStackView.removeArrangedSubview(paceInputView)
            paceInputView.hidden = true
            UIView.animateWithDuration(0.45, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.distanceInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            UIView.animateWithDuration(0.25, delay: 0.25, usingSpringWithDamping: 0.75, initialSpringVelocity: 40, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.durationInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            solveForPace()
        }
        
        UIView.animateWithDuration(0.25, delay: 1, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.startOver.hidden = false
                self.startOver.bounds.origin.y += (self.view.bounds.height + self.startOver.bounds.height)
            }, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroStackView.removeArrangedSubview(resultTextView)
        startOver.hidden = true
        
        resultTextView.text = ""

        if willHideDistance {
            inputsStackView.removeArrangedSubview(distanceInputView)
            distanceInputView.hidden = true
            durationInputView.hidden = false
            paceInputView.hidden = false
            solveForDistance()
        }
        if willHideDuration {
            inputsStackView.removeArrangedSubview(durationInputView)
            distanceInputView.hidden = false
            durationInputView.hidden = true
            paceInputView.hidden = false
            solveForDuration()
        }
        if willHidePace {
            inputsStackView.removeArrangedSubview(paceInputView)
            distanceInputView.hidden = false
            durationInputView.hidden = false
            paceInputView.hidden = true
            solveForPace()
        }
        
        titleLabel.text = titleSaying
        
        //Distance Textfield setup
        distanceTextField.addTarget(self, action: Selector("textFieldChanged:"), forControlEvents: UIControlEvents.EditingChanged)
        distanceTextField.delegate = self
        
        /*** Pickers Setup ***/
        // Duration Picker
        durationTextField.delegate = self
        durationTextField.inputView = durationPickerViewContainer
        arrayOfSixty = createSequentialIntArray(60)
        durationPickerData = [createSequentialIntArray(80), arrayOfSixty, arrayOfSixty]
        durationTextField.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("incrementDurationByFiveMinutes:")))

        // Pace Picker
        paceTextField.delegate = self
        paceTextField.inputView = pacePickerViewContainer
        pacePickerData = [arrayOfSixty, arrayOfSixty]
        paceTextField.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("incrementPaceByFiveMinutes:")))
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard")))
                
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillChangeFrameNotification, object: nil);
        
        resultTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("switchLabelUnits")))
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardNotification(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            guard let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else { return }
            
            let convertedPoint = activeField.convertPoint(CGPointMake(
                activeField.frame.origin.x,
                activeField.frame.origin.y + activeField.frame.size.height),
                toView: self.view)
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
            if CGRectContainsPoint(endFrame, convertedPoint) {
                print("Inside")
                self.view.frame.origin.y = self.view.frame.origin.y - (convertedPoint.y - endFrame.origin.y)
            }
        }
    }
    
    func switchLabelUnits() {
        if willHideDistance {
            isDistanceMetric = !isDistanceMetric
            solveForDistance()
//            let units = isDistanceMetric ? "km" : "mi"
//            if isDistanceMetric {
//                distanceValue = PacingCalculations.Conversion.Length().kilometersToMiles(distanceValue)
//            } else {
//                distanceValue = PacingCalculations.Conversion.Length().milesToKilometers(distanceValue)
//            }
//            resultTextView.text = "\(round(distanceValue * Storyboard.Distance.Rounding) / Storyboard.Distance.Rounding) \(units)"
        } else if willHidePace {
            isPaceMetric = !isPaceMetric
            solveForPace()
        }
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

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        // Create button bar for the keyboard
        let keyboardDoneButtonBar = UIToolbar()
        keyboardDoneButtonBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItemStyle.Done,
            target: self,
            action: Selector("endEditingNow"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let toolbarButtons: [UIBarButtonItem]
        if textField.isEqual(distanceTextField) {
            let distanceEventsBarButtonItem = UIBarButtonItem(customView: distanceEvents)
            toolbarButtons = [distanceEventsBarButtonItem, flexibleSpace, doneButton]
        } else {
            toolbarButtons = [flexibleSpace, doneButton]
        }
        
        keyboardDoneButtonBar.setItems(toolbarButtons, animated: true)
        
        textField.inputAccessoryView = keyboardDoneButtonBar
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData.count
        } else {
            return pacePickerData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData[component].count
        } else {
            return pacePickerData[component].count
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == Storyboard.Duration.Picker.Tag {
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
        } else if pickerView.tag == Storyboard.Pace.Picker.Tag {
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
        if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return "\(durationPickerData[component][row])"
        } else {
            return "\(pacePickerData[component][row])"
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var containerView = view
        let pickerLabel = UILabel()
        if view == nil {
            containerView = UIView()
            containerView!.addSubview(pickerLabel)
            pickerLabel.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                NSLayoutConstraint(
                    item: pickerLabel,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: containerView,
                    attribute: NSLayoutAttribute.Leading,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: pickerLabel,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: containerView,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: pickerLabel,
                    attribute: NSLayoutAttribute.Trailing,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: containerView,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1,
                    constant: 0),
            ]
            
            containerView!.addConstraints(constraints)
        }
        var titleData = " "
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            titleData = pacePickerData[component][row].description
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            titleData = durationPickerData[component][row].description
        } else {
            titleData = " "
        }
        let title = NSAttributedString(string: titleData, attributes:
            [
                NSFontAttributeName:UIFont.systemFontOfSize(CGFloat(17.0)),
                NSForegroundColorAttributeName:UIColor.blackColor(),
            ])
        pickerLabel.attributedText = title
        pickerLabel.textAlignment = .Right
        
//        pickerLabel.backgroundColor = UIColor.purpleColor()
        
        return containerView!
    }

    
    // MARK: - Metric to Imperial toggling
    @IBOutlet weak var paceUnitsButton: CustomDefaultButton!
    @IBAction func togglePaceUnits(sender: CustomDefaultButton) {
        isPaceMetric = !isPaceMetric
        if isPaceMetric {
            paceUnitsButton.setTitle("min/km", forState: .Normal)
        } else {
            paceUnitsButton.setTitle("min/mi", forState: .Normal)
        }
        if willHideDistance {
            solveForDistance()
        } else if willHideDuration {
            solveForDuration()
        }
    }
    
    @IBOutlet weak var distanceUnitsButton: CustomDefaultButton!
    @IBAction func toggleDistanceUnits(sender: CustomDefaultButton) {
        _toggleDistanceUnits()
    }
    
    // MARK: - Private functions
    private func _toggleDistanceUnits(){
        isDistanceMetric = !isDistanceMetric
        if isDistanceMetric {
            distanceUnitsButton.setTitle("km", forState: .Normal)
        } else {
            distanceUnitsButton.setTitle("mi", forState: .Normal)
        }
        if willHidePace {
            solveForPace()
        } else if willHideDuration {
            solveForDuration()
        }
    }
    
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
        if isPaceMetric && !isDistanceMetric {
            distanceValue = PacingCalculations.Conversion.Length().kilometersToMiles(distanceValue)
        } else if !isPaceMetric && isDistanceMetric {
            distanceValue = PacingCalculations.Conversion.Length().milesToKilometers(distanceValue)
        }
        
        let units = isDistanceMetric ? "km" : "mi"
        resultTextView.text = "\(round(distanceValue * Storyboard.Distance.Rounding) / Storyboard.Distance.Rounding) \(units)"
        toggleResultLabel(distanceValue)
    }
    
    private func solveForDuration() {
        var result: Double
        var effectiveDistance = distanceValue
        if isPaceMetric && !isDistanceMetric {
            effectiveDistance = PacingCalculations.Conversion.Length().milesToKilometers(distanceValue)
        } else if !isPaceMetric && isDistanceMetric {
            effectiveDistance = PacingCalculations.Conversion.Length().kilometersToMiles(distanceValue)
        }
        if paceValue.TotalSeconds == 0 {
            result = PacingCalculations().timeFormula(Double(paceValue.TotalSeconds), distance: Double(effectiveDistance))
        } else {
            result = PacingCalculations().timeFormula(1/Double(paceValue.TotalSeconds), distance: Double(effectiveDistance))
        }
        let formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(round(result)))
        
        durationValue.Hours = formattedResult.hours
        durationValue.Minutes = formattedResult.minutes
        durationValue.Seconds = formattedResult.seconds
        
        resultTextView.text = durationValue.description()
        toggleResultLabel(Double(durationValue.TotalSeconds))
    }
    
    private func solveForPace() {
        var result = 0.0
        var effectiveDistance = distanceValue
        if isPaceMetric && !isDistanceMetric {
            effectiveDistance = PacingCalculations.Conversion.Length().milesToKilometers(distanceValue)
        } else if !isPaceMetric && isDistanceMetric {
            effectiveDistance = PacingCalculations.Conversion.Length().kilometersToMiles(distanceValue)
        }
        result = PacingCalculations().rateFormula(effectiveDistance, time: Double(durationValue.TotalSeconds))
        
        var formattedResult: (hours: Int, minutes: Int, seconds: Int)
        if result == 0 {
            formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(result))
        } else {
            formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(1/result))
        }
        paceValue.Minutes = formattedResult.minutes
        paceValue.Seconds = formattedResult.seconds
        
        let units = isPaceMetric ? "min/km" : "min/mi"
        resultTextView.text = "\(paceValue.description()) \(units)"
        toggleResultLabel(Double(paceValue.TotalSeconds))
    }
    
    private func toggleResultLabel(value:Double) {
        if value == 0 {
            UIView.animateWithDuration(0.25) { () -> Void in
                self.resultTextView.hidden = true
                self.heroStackView.removeArrangedSubview(self.resultTextView)
            }
        } else {
            UIView.animateWithDuration(0.25) { () -> Void in
                self.heroStackView.addArrangedSubview(self.resultTextView)
                self.resultTextView.hidden = false
            }
        }
    }
    
    @IBAction func restart(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func fiveKmEvent(sender: UIButton) {
        if !isDistanceMetric {
            _toggleDistanceUnits()
        }
        distanceValue = 5
        distanceTextField.text = "\(distanceValue)"
    }
    
    @IBAction func tenKmEvent(sender: UIButton) {
        if !isDistanceMetric {
            _toggleDistanceUnits()
        }
        distanceValue = 10
        distanceTextField.text = "\(distanceValue)"
    }
    
    @IBAction func halfMarathonEvent(sender: UIButton) {
        if isDistanceMetric {
            _toggleDistanceUnits()
        }
        distanceValue = 13.1
        distanceTextField.text = "\(distanceValue)"
    }
    
    @IBAction func marathonEvent(sender: UIButton) {
        if isDistanceMetric {
            _toggleDistanceUnits()
        }
        distanceValue = 26.3
        distanceTextField.text = "\(distanceValue)"
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
