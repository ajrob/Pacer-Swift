//
//  InputsViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 10/9/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit

class InputsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputsStackView:   UIStackView!
    @IBOutlet weak var distanceInputView: UIView!
    @IBOutlet weak var durationInputView: UIView!
    @IBOutlet weak var paceInputView:     UIView!
    
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
        willSet(newDuration) {
            durationTextField.text = newDuration.Print
        }
    }
    var paceValue:PaceTimeFormat = PaceTimeFormat() {
        willSet(newPace) {
            paceTextField.text = newPace.Print
        }
    }
    var previousTranslationPoint = CGFloat()
    
    //FOR DEBUGGING
    @IBOutlet weak var translationPoint: UILabel!
    var startingPoint = CGPoint()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if willHideDistance {
            inputsStackView.removeArrangedSubview(distanceInputView)
        }
        if willHideDuration {
            inputsStackView.removeArrangedSubview(durationInputView)
        }
        if willHidePace {
            inputsStackView.removeArrangedSubview(paceInputView)
        }
        
        titleLabel.text = titleSaying
        
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
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("printTranslation:")))
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
    
    func printTranslation(panGesture:UIPanGestureRecognizer) {
        if panGesture.state == UIGestureRecognizerState.Began {
            startingPoint = panGesture.translationInView(self.view)
        }
        let currentPoint = panGesture.translationInView(self.view)
        let velocity = panGesture.velocityInView(self.view)
        translationPoint.text = "X: \(currentPoint.x), Y: \(Int(abs(currentPoint.y)) / 50) | Velocity: x:\(round(velocity.x)), y: \(round(velocity.y))"
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
        durationTextField.resignFirstResponder()
        paceTextField.resignFirstResponder()
        distanceTextField.resignFirstResponder()
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
