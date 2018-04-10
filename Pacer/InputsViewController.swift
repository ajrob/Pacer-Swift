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
    
    @IBOutlet weak var InputsView: UIView!
    
    @IBOutlet var distanceEvents: UIScrollView!
    
    @IBOutlet weak var heroStackView: UIStackView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startOver: UIButton!
    @IBOutlet weak var startOverArrow: UIButton!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startOver.alpha = 0.0
        startOverArrow.alpha = 0.0
        
        distanceInputView.bounds.origin.x -= view.bounds.width
        durationInputView.bounds.origin.x -= view.bounds.width
        paceInputView.bounds.origin.x     -= view.bounds.width
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        startOver.alpha = 0.0
        startOverArrow.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if willHideDistance {
            inputsStackView.removeArrangedSubview(distanceInputView)
            distanceInputView.isHidden = true
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations: { self.paceInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            UIView.animate(withDuration: 0.25, delay: 0.25, usingSpringWithDamping: 0.75, initialSpringVelocity: 40, options: [UIViewAnimationOptions.curveEaseInOut], animations: { self.durationInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            solveForDistance()
        } else if willHideDuration {
            inputsStackView.removeArrangedSubview(durationInputView)
            durationInputView.isHidden = true
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations: { self.paceInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            UIView.animate(withDuration: 0.25, delay: 0.25, usingSpringWithDamping: 0.75, initialSpringVelocity: 40, options: [UIViewAnimationOptions.curveEaseInOut], animations: { self.distanceInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            solveForDuration()
        } else if willHidePace {
            inputsStackView.removeArrangedSubview(paceInputView)
            paceInputView.isHidden = true
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations: { self.distanceInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            UIView.animate(withDuration: 0.25, delay: 0.25, usingSpringWithDamping: 0.75, initialSpringVelocity: 40, options: [UIViewAnimationOptions.curveEaseInOut], animations: { self.durationInputView.bounds.origin.x += self.view.bounds.width }, completion: nil)
            solveForPace()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.5, options: [UIViewAnimationOptions.curveEaseIn], animations: { () -> Void in
                self.startOver.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 1, delay: 1, options: [UIViewAnimationOptions.curveEaseIn], animations: { () -> Void in
            self.startOverArrow.alpha = 1.0
            }, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InputsView.backgroundColor = Colors.Tint
        
        heroStackView.removeArrangedSubview(resultTextView)
        
        resultTextView.text = ""

        if willHideDistance {
            inputsStackView.removeArrangedSubview(distanceInputView)
            distanceInputView.isHidden = true
            durationInputView.isHidden = false
            paceInputView.isHidden = false
            solveForDistance()
        }
        if willHideDuration {
            inputsStackView.removeArrangedSubview(durationInputView)
            distanceInputView.isHidden = false
            durationInputView.isHidden = true
            paceInputView.isHidden = false
            solveForDuration()
        }
        if willHidePace {
            inputsStackView.removeArrangedSubview(paceInputView)
            distanceInputView.isHidden = false
            durationInputView.isHidden = false
            paceInputView.isHidden = true
            solveForPace()
        }
        
        titleLabel.text = titleSaying
        
        //Distance Textfield setup
        distanceTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        distanceTextField.delegate = self
        
        /*** Pickers Setup ***/
        // Duration Picker
        durationTextField.delegate = self
        durationTextField.inputView = durationPickerViewContainer
        arrayOfSixty = createSequentialIntArray(numberOfElements: 60)
        durationPickerData = [createSequentialIntArray(numberOfElements: 80), arrayOfSixty, arrayOfSixty]
        durationTextField.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector(("incrementDurationByFiveMinutes:"))))

        // Pace Picker
        paceTextField.delegate = self
        paceTextField.inputView = pacePickerViewContainer
        pacePickerData = [arrayOfSixty, arrayOfSixty]
        paceTextField.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector(("incrementPaceByFiveMinutes:"))))
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InputsViewController.dismissKeyboard)))
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil);
        
        resultTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InputsViewController.switchLabelUnits)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardNotification(notification:NSNotification) {
        if let userInfo = notification.userInfo {
            guard let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            
            let convertedPoint = activeField.convert(CGPoint(x: activeField.frame.origin.x, y: activeField.frame.origin.y + activeField.frame.size.height), to: self.view)
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
            if endFrame.contains(convertedPoint) {
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
        durationValue.TotalSeconds = incrementByFiveMinutes(panGesture: panGesture, target: durationTextField, totalSeconds: durationValue.TotalSeconds)
        durationTextField.text = durationValue.Print
        updateDurationPicker()
    }
    
    func incrementPaceByFiveMinutes(panGesture:UIPanGestureRecognizer) {
        paceValue.TotalSeconds = incrementByFiveMinutes(panGesture: panGesture, target: paceTextField, totalSeconds: paceValue.TotalSeconds)
        if paceValue.TotalSeconds > 3599 {
            paceValue.TotalSeconds = 3599
        }
        paceTextField.text = paceValue.Print
        updatePacePicker()
    }
    
    func incrementByFiveMinutes(panGesture:UIPanGestureRecognizer, target: UIView, totalSeconds: Int) -> Int {
        let translatedPoint = panGesture.translation(in: target)
        let velocity = panGesture.velocity(in: target)
        var totalSeconds = totalSeconds
        if panGesture.state == UIGestureRecognizerState.began {
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

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // Create button bar for the keyboard
        let keyboardDoneButtonBar = UIToolbar()
        keyboardDoneButtonBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItemStyle.done,
            target: self,
            action: #selector(InputsViewController.endEditingNow))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let toolbarButtons: [UIBarButtonItem]
        doneButton.tintColor = Colors.Tint
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData.count
        } else {
            return pacePickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData[component].count
        } else {
            return pacePickerData[component].count
        }
    }
    
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return "\(durationPickerData[component][row])"
        } else {
            return "\(pacePickerData[component][row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var containerView = view
        let pickerLabel = UILabel()
        if view == nil {
            containerView = UIView()
            containerView!.addSubview(pickerLabel)
            pickerLabel.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                NSLayoutConstraint(
                    item: pickerLabel,
                    attribute: NSLayoutAttribute.leading,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: containerView,
                    attribute: NSLayoutAttribute.leading,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: pickerLabel,
                    attribute: NSLayoutAttribute.centerY,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: containerView,
                    attribute: NSLayoutAttribute.centerY,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: pickerLabel,
                    attribute: NSLayoutAttribute.trailing,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: containerView,
                    attribute: NSLayoutAttribute.centerX,
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
                NSFontAttributeName:UIFont.systemFont(ofSize: CGFloat(17.0)),
                NSForegroundColorAttributeName:UIColor.black,
            ])
        pickerLabel.attributedText = title
        pickerLabel.textAlignment = .right
        
//        pickerLabel.backgroundColor = UIColor.purpleColor()
        
        return containerView!
    }

    
    // MARK: - Metric to Imperial toggling
    @IBOutlet weak var paceUnitsButton: CustomDefaultButton!
    @IBAction func togglePaceUnits(sender: CustomDefaultButton) {
        isPaceMetric = !isPaceMetric
        if isPaceMetric {
            paceUnitsButton.setTitle("min/km", for: [])
        } else {
            paceUnitsButton.setTitle("min/mi", for: [])
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
            distanceUnitsButton.setTitle("km", for: [])
        } else {
            distanceUnitsButton.setTitle("mi", for: [])
        }
        if willHidePace {
            solveForPace()
        } else if willHideDuration {
            solveForDuration()
        }
    }
    
    private func createSequentialIntArray(numberOfElements: Int) -> [Int] {
        var array = [Int]()
        for i in 0...numberOfElements {
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
        if durationTextField.isEditing {
            durationTextField.resignFirstResponder()
        }
        if paceTextField.isEditing {
            paceTextField.resignFirstResponder()
        }
        if distanceTextField.isEditing {
            distanceTextField.resignFirstResponder()
        }
    }
    
    private func solveForDistance() {
        if paceValue.TotalSeconds == 0 {
            distanceValue = PacingCalculations().distanceFormula(rate: Double(paceValue.TotalSeconds), time: Double(durationValue.TotalSeconds))
        } else {
            distanceValue = PacingCalculations().distanceFormula(rate: 1/Double(paceValue.TotalSeconds), time: Double(durationValue.TotalSeconds))
        }
        if isPaceMetric && !isDistanceMetric {
            distanceValue = PacingCalculations.Conversion.Length().kilometersToMiles(kilometers: distanceValue)
        } else if !isPaceMetric && isDistanceMetric {
            distanceValue = PacingCalculations.Conversion.Length().milesToKilometers(miles: distanceValue)
        }
        
        let units = isDistanceMetric ? "km" : "mi"
        resultTextView.text = "\(round(distanceValue * Storyboard.Distance.Rounding) / Storyboard.Distance.Rounding) \(units)"
        toggleResultLabel(value: distanceValue)
    }
    
    private func solveForDuration() {
        var result: Double
        var effectiveDistance = distanceValue
        if isPaceMetric && !isDistanceMetric {
            effectiveDistance = PacingCalculations.Conversion.Length().milesToKilometers(miles: distanceValue)
        } else if !isPaceMetric && isDistanceMetric {
            effectiveDistance = PacingCalculations.Conversion.Length().kilometersToMiles(kilometers: distanceValue)
        }
        if paceValue.TotalSeconds == 0 {
            result = PacingCalculations().timeFormula(rate: Double(paceValue.TotalSeconds), distance: Double(effectiveDistance))
        } else {
            result = PacingCalculations().timeFormula(rate: 1/Double(paceValue.TotalSeconds), distance: Double(effectiveDistance))
        }
        let formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(seconds: Int(round(result)))
        
        durationValue.Hours = formattedResult.hours
        durationValue.Minutes = formattedResult.minutes
        durationValue.Seconds = formattedResult.seconds
        
        resultTextView.text = durationValue.description()
        toggleResultLabel(value: Double(durationValue.TotalSeconds))
    }
    
    private func solveForPace() {
        var result = 0.0
        var effectiveDistance = distanceValue
        if isPaceMetric && !isDistanceMetric {
            effectiveDistance = PacingCalculations.Conversion.Length().milesToKilometers(miles: distanceValue)
        } else if !isPaceMetric && isDistanceMetric {
            effectiveDistance = PacingCalculations.Conversion.Length().kilometersToMiles(kilometers: distanceValue)
        }
        result = PacingCalculations().rateFormula(distance: effectiveDistance, time: Double(durationValue.TotalSeconds))
        
        var formattedResult: (hours: Int, minutes: Int, seconds: Int)
        if result == 0 {
            formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(seconds: Int(result))
        } else {
            formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(seconds: Int(1/result))
        }
        paceValue.Minutes = formattedResult.minutes
        paceValue.Seconds = formattedResult.seconds
        
        let units = isPaceMetric ? "min/km" : "min/mi"
        resultTextView.text = "\(paceValue.description()) \(units)"
        toggleResultLabel(value: Double(paceValue.TotalSeconds))
    }
    
    private func toggleResultLabel(value:Double) {
        if value == 0 {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.resultTextView.isHidden = true
                self.heroStackView.removeArrangedSubview(self.resultTextView)
            }
        } else {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.heroStackView.addArrangedSubview(self.resultTextView)
                self.resultTextView.isHidden = false
            }
        }
    }
    
    @IBAction func restart(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
