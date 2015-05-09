//
//  MainTemplateTableViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 3/12/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class MainTemplateTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var calculateBarButton: UIBarButtonItem!
    @IBOutlet weak var clearBarButton: UIBarButtonItem!
    
    func dismissKeyboard() {
        if textField.editing {
            textField.resignFirstResponder()
        }
    }
    
    var isMetric = false
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    
    struct DurationTimeFormat {
        var Hours:   Int = 0 {
            didSet { TotalSeconds = (Hours * 3600) + (Minutes * 60) + Seconds }
        }
        var Minutes: Int = 0 {
            didSet { TotalSeconds = (Hours * 3600) + (Minutes * 60) + Seconds }
        }
        var Seconds: Int = 0 {
            didSet { TotalSeconds = (Hours * 3600) + (Minutes * 60) + Seconds }
        }
        
        var TotalSeconds: Int = 0
        
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
        var Minutes: Int = 0 {
            didSet { TotalSeconds = (Minutes * 60) + Seconds }
        }
        var Seconds: Int = 0 {
            didSet { TotalSeconds = (Minutes * 60) + Seconds }
        }
        
        var TotalSeconds: Int = 0
        
        func description() -> String {
            var secFormatted = Seconds.description
            
            // Apply zero padding if needed
            if Seconds < 10 { secFormatted = "0\(secFormatted)" }
            return "\(Minutes):\(secFormatted)"
        }
    }
    
    var arrayBaseSixty = [Int]()
    let pickerCellRowHeight: CGFloat = 216
    
    var pacePickerData = [[Int]]()
    var durationPickerData = [[Int]]()
    
    // Labels
    let paceUnitsLabel = UILabel()
    var paceUnitsAttributedText = NSAttributedString()
    let distanceUnitsLabel = UILabel()
    var distanceUnitsAttributedText = NSAttributedString()

    
    // Variables to hold pace, duration, and distance data
    var paceValue = PaceTimeFormat() {
        didSet {
            let value = paceValue.description().stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if !value.isEmpty && paceValue.TotalSeconds > 0 {
                paceUnitsLabel.hidden = false
            } else {
                paceUnitsLabel.hidden = true
            }
        }
    }
    var durationValue = DurationTimeFormat()
    var distanceValue = 0.0 {
        didSet {
            let value = distanceValue.description.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if !value.isEmpty && distanceValue > 0 {
                distanceUnitsLabel.hidden = false
            } else {
                distanceUnitsLabel.hidden = true
            }
        }
    }
    
    var mainTableData: [[String: AnyObject]] = []
    var willShowPacePicker = false
    var willShowDurationPicker = false
    
    var pickerIndexPath: NSIndexPath?
    
    private struct VariablesTracker {
        var Pace = Variable()
        var Distance = Variable()
        var Duration = Variable()
    }
    
    // Container to hold the IsModified flag of each variable
    private var modifiedVariables = VariablesTracker()
    
    // Array to keep track of the 2 most recently modified variables
    private var modifiedList: [Variable] = [] {
        didSet {
            if modifiedList.count == 2 {
                // Enable calculate button
                calculateBarButton.enabled = true
            } else {
                calculateBarButton.enabled = false
            }
        }
    }
    
    var textField = UITextField()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let rowOne = [kTitleKey: "Pace", Storyboard.Pace.Picker.Key: " "]
        let rowTwo = [kTitleKey: "Duration", Storyboard.Duration.Picker.Key: " "]
        let rowThree = [kTitleKey: "Distance", Storyboard.Distance.Key: " "]
        
        mainTableData = [rowOne, rowTwo, rowThree]
        
        // Create picker data sources
        arrayBaseSixty = createArray(60)
        pacePickerData = [arrayBaseSixty, arrayBaseSixty]
        durationPickerData = [createArray(80), arrayBaseSixty, arrayBaseSixty]
        
        // Initialize flags indicating whether there is a new variable to be calculated
        modifiedVariables.Pace.TableViewController = self
        modifiedVariables.Pace.Row = Storyboard.Pace.Row
        modifiedVariables.Pace.IsModified = false
        modifiedVariables.Pace.RowSelectionButton.tag = Storyboard.Pace.Tag
        modifiedVariables.Pace.RowSelectionButton.addTarget(self, action: Selector("rowSelectionButtonPressed:"), forControlEvents: .TouchUpInside)
        
        modifiedVariables.Duration.TableViewController = self
        modifiedVariables.Duration.Row = Storyboard.Duration.Row
        modifiedVariables.Duration.IsModified = false
        modifiedVariables.Duration.RowSelectionButton.tag = Storyboard.Duration.Tag
        modifiedVariables.Duration.RowSelectionButton.addTarget(self, action: Selector("rowSelectionButtonPressed:"), forControlEvents: .TouchUpInside)
        
        modifiedVariables.Distance.TableViewController = self
        modifiedVariables.Distance.Row = Storyboard.Distance.Row
        modifiedVariables.Distance.IsModified = false
        modifiedVariables.Distance.RowSelectionButton.tag = Storyboard.Distance.Tag
        modifiedVariables.Distance.RowSelectionButton.addTarget(self, action: Selector("rowSelectionButtonPressed:"), forControlEvents: .TouchUpInside)
        
        var tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        tableView.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        // Adding a zero-sized footer prevents additional blank rows from being displayed.
//        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Header/Footer color
//        self.tableView.tableFooterView?.backgroundColor = Colors.Tint
        self.tableView.tableHeaderView?.backgroundColor = Colors.Tint
        
        // Set bar button color scheme
        calculateBarButton.tintColor = Colors.Tint
        clearBarButton.tintColor = Colors.Tint
        tableView.separatorColor = Colors.Tint
        
        // Set the rendering mode to AlwaysTemplate in order to ignore the image's color and change it's tint
        self.navigationItem.titleView = UIImageView(image: (UIImage(named: "shoeLogo"))?.imageWithRenderingMode(.AlwaysTemplate))
        self.navigationItem.titleView?.tintColor = Colors.DarkTint
        
        // Set unit labels
        let defaults = NSUserDefaults.standardUserDefaults()
        isMetric = defaults.boolForKey(kMetricKey)
        toggleMetric()
        paceUnitsLabel.hidden = true
        distanceUnitsLabel.hidden = true
    }
    
    var ucobserver: NSObjectProtocol?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Observe to see if units change
        observeUserDefaults()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = ucobserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    private func observeUserDefaults() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        ucobserver = center.addObserverForName(NSUserDefaultsDidChangeNotification,
            object: NSUserDefaults.standardUserDefaults(),
            queue: queue){ notification in
                let defaults = NSUserDefaults.standardUserDefaults()
                self.isMetric = defaults.boolForKey(kMetricKey)
                self.toggleMetric()
        }
    }
    
    private func toggleMetric() {
        // Change labels
        let paceUnitText = isMetric ? Storyboard.Pace.UnitLabel.Metric : Storyboard.Pace.UnitLabel.Imperial
        let distanceUnitText = isMetric ? Storyboard.Distance.UnitLabel.Metric : Storyboard.Distance.UnitLabel.Imperial
        paceUnitsLabel.attributedText = NSAttributedString(string: paceUnitText, attributes:
            [
//                NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2),
                NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(8.0)),
                NSForegroundColorAttributeName: UIColor.lightGrayColor()
            ]
        )
        distanceUnitsLabel.attributedText = NSAttributedString(string: distanceUnitText, attributes:
            [
                NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(8.0)),
                NSForegroundColorAttributeName: UIColor.lightGrayColor()
            ]
        )
        
        // Recalculate if needed
        calculateValues()
    }
    
    func rowSelectionButtonPressed(sender: UIButton!) {
        removePickerRow()
        if sender.tag == Storyboard.Pace.Tag {
            addModifiedVariable(modifiedVariables.Pace)
        } else if sender.tag == Storyboard.Duration.Tag {
            addModifiedVariable(modifiedVariables.Duration)
        } else if sender.tag == Storyboard.Distance.Tag {
            addModifiedVariable(modifiedVariables.Distance)
        }
    }
    
    private func createArray(numberOfElements: Int) -> [Int] {
        var array = [Int]()
        for (var i = 0; i < numberOfElements; i++) {
            array.append(i)
        }
        return array
    }
    
    private func resetNewVariables() {
        // Remove any picker cell if it exists
//        tableView.beginUpdates()
//        if self.hasInlinePicker() {
//            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: pickerIndexPath!.row, inSection: 0)], withRowAnimation: .Fade)
//            pickerIndexPath = nil
//        }
//        tableView.endUpdates()
        removePickerRow()
        
        // Clear variable values
        paceValue.Minutes = 0
        paceValue.Seconds = 0
        durationValue.Hours = 0
        durationValue.Minutes = 0
        durationValue.Seconds = 0
        distanceValue = 0
        
        mainTableData[0][Storyboard.Pace.Picker.Key] = " "
        mainTableData[1][Storyboard.Duration.Picker.Key] = " "
        mainTableData[2][Storyboard.Distance.Key] = " "
        
        // Reset variable array
        modifiedList = []
        
        // Reset the new variable flags
        modifiedVariables.Pace.IsModified = false
        modifiedVariables.Distance.IsModified = false
        modifiedVariables.Duration.IsModified = false
    }
    
    private func calculateValues() {
        // Do calculations
        if modifiedVariables.Pace.IsModified {
            if modifiedVariables.Duration.IsModified {
                // Pace is in minutes per mile, so enter the inverse into the formula
//                var distanceValue = 0.0
                if paceValue.TotalSeconds == 0 {
                    distanceValue = PacingCalculations().distanceFormula(Double(paceValue.TotalSeconds), time: Double(durationValue.TotalSeconds))
                } else {
                    distanceValue = PacingCalculations().distanceFormula(1/Double(paceValue.TotalSeconds), time: Double(durationValue.TotalSeconds))
                }
                
                if isMetric {
                    distanceValue = PacingCalculations.Conversion.Length().milesToKilometers(distanceValue)
                }
                
                // Update distance row
                var distanceRow = Storyboard.Distance.Row
                if pickerIndexPath != nil {
                    distanceRow += 1
                }
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: distanceRow, inSection: 0)) as? DistanceTableViewCell
////                cell?.detailTextLabel?.text = "\(result)"
//                (cell?.viewWithTag(Storyboard.Distance.Tag) as! UITextField).text = "\(round(Storyboard.Distance.Rounding * distanceValue) / Storyboard.Distance.Rounding)"
                cell?.distanceTextField.text = "\(round(Storyboard.Distance.Rounding * distanceValue) / Storyboard.Distance.Rounding)"
////                cell?.imageView?.image = UIImage(named: "arrowAnswer")
//                modifiedVariables.Distance.RowSelectionButton.rowState = .Calculated
////                // Reset new variable flags
////                resetNewVariables()
            } else if modifiedVariables.Distance.IsModified {
                // Pace is in minutes per mile/km, so enter the inverse into the formula
                var result = 0.0
                if paceValue.TotalSeconds == 0 {
                    result = PacingCalculations().timeFormula(Double(paceValue.TotalSeconds), distance: Double(distanceValue))
                } else {
                    result = PacingCalculations().timeFormula(1/Double(paceValue.TotalSeconds), distance: Double(distanceValue))
                }
                let formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(result))
                durationValue.Hours = formattedResult.hours
                durationValue.Minutes = formattedResult.minutes
                durationValue.Seconds = formattedResult.seconds
                
                //Update duration row
                var durationRow = Storyboard.Duration.Row
                if pickerIndexPath != nil {
                    durationRow += 1
                }
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: durationRow, inSection: 0)) as? DurationTableViewCell
                cell?.durationValueLabel.text = "\(durationValue.description())"
//                cell?.detailTextLabel?.text = "\(durationValue.description())"
////                cell?.imageView?.image = UIImage(named: "arrowAnswer")
                modifiedVariables.Duration.RowSelectionButton.rowState = .Calculated
            }
        } else if modifiedVariables.Duration.IsModified && modifiedVariables.Distance.IsModified {
            let result = PacingCalculations().rateFormula(distanceValue, time: Double(durationValue.TotalSeconds))
            var formattedResult: (hours: Int, minutes: Int, seconds: Int)
            if result == 0 {
                formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(result))
            } else {
                formattedResult = PacingCalculations.Conversion.Time().secondsInHoursMinutesSeconds(Int(1/result))
            }
            paceValue.Minutes = formattedResult.minutes
            paceValue.Seconds = formattedResult.seconds
            
            // Update pace row
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: Storyboard.Pace.Row, inSection: 0)) as? PaceTableViewCell
            cell?.paceValueLabel.text = "\(paceValue.description())"
//            cell?.detailTextLabel?.text = "\(paceValue.description())"
////            cell?.imageView?.image = UIImage(named: "arrowAnswer")
            modifiedVariables.Pace.RowSelectionButton.rowState = .Calculated
        }
    }
    
    // Adds a newly modified variable onto a stack. Keeps the 2 most recent variables and discards the oldest.
    // Only 2 variables are needed in order to perform a calculation
    private func addModifiedVariable(newVar: Variable) {
        // Add most recent to the top, move the previous top to the second, discard the last.
        switch (modifiedList.count) {
        case 0:
            // Just add the newest modified variable
            modifiedList.append(newVar)
            // Set the new value to true
            modifiedList[0].IsModified = true
            break
        case 1:
            // Check to see if it's the same variable
            if (modifiedList[0] !== newVar) {
                // Insert the newer variable into first element
                modifiedList.insert(newVar, atIndex: 0)
                // Set the new value to true
                modifiedList[0].IsModified = true
            }
            break
        case 2:
            // Check to see if it's the same variable
            if (modifiedList[0] !== newVar && modifiedList[1] !== newVar) {
                // Insert the newer variable into first element
                modifiedList.insert(newVar, atIndex: 0)
                // Set the new value to true
                modifiedList[0].IsModified = true
                
                // Reset the old value back to false
                modifiedList[2].IsModified = false
                // Remove the oldest variable
                modifiedList.removeLast()
            }
            break
        default:
            // If there's more than 2, clear the whole array
            modifiedList = []
            break
        }
    }
    
    // MARK: - Toggle Units
    func togglePaceUnits(sender: UIButton!) {
        println("Pace units toggled")
    }
    
    
    
    // MARK: - Utilities
    private func hasInlinePicker() -> Bool {
        return pickerIndexPath != nil
    }
    
    private func removePickerRow() {
        if self.hasInlinePicker() {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: pickerIndexPath!.row, inSection: 0)], withRowAnimation: .Middle)
            pickerIndexPath = nil
            tableView.endUpdates()
        }
    }
    
    /*! Determines if the given indexPath has a cell below it with a UIPickerView.
    
    @param indexPath The indexPath to check if its cell has a UIPickerView below it.
    */
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasPicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkPickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: 0))
        var checkPicker = checkPickerCell?.viewWithTag(Storyboard.Pace.Picker.Tag)
        checkPicker = checkPickerCell?.viewWithTag(Storyboard.Duration.Picker.Tag)
        
        hasPicker = checkPicker != nil
        return hasPicker
    }
    
    private func togglePickerForSelectedIndexPath(indexPath: NSIndexPath, reuseIdentifier: String) {
        tableView.beginUpdates()
        
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        // Check if 'indexPath' has an attached picker below it
        if hasPickerForIndexPath(indexPath) {
            // Found a picker below it, so remove it
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Middle)
        } else {
            // Didn't find a picker below it, so we should insert it
            if reuseIdentifier == Storyboard.Pace.CellID {
                willShowPacePicker = true
            } else if reuseIdentifier == Storyboard.Duration.CellID {
                willShowDurationPicker = true
            }
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Middle)
        }
        tableView.endUpdates()
    }
    
    private func updatePicker() {
        if let indexPath = pickerIndexPath {
            let associatedPickerCell = tableView.cellForRowAtIndexPath(indexPath)
            if let targetedPicker = associatedPickerCell?.viewWithTag(Storyboard.Pace.Picker.Tag) as! UIPickerView? {
                targetedPicker.selectRow(paceValue.Minutes, inComponent: 0, animated: false)
                targetedPicker.selectRow(paceValue.Seconds, inComponent: 1, animated: false)
            } else if let targetedPicker = associatedPickerCell?.viewWithTag(Storyboard.Duration.Picker.Tag) as! UIPickerView? {
                targetedPicker.selectRow(durationValue.Hours, inComponent: 0, animated: false)
                targetedPicker.selectRow(durationValue.Minutes, inComponent: 1, animated: false)
                targetedPicker.selectRow(durationValue.Seconds, inComponent: 2, animated: false)
            }
        }
    }
    
    // Reveals the inline picker below the row. Called by didSelectRowAtIndexPath()
    private func displayInlinePickerForRowAtPath(indexPath: NSIndexPath, reuseId: String) {
        // Display the picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // Indicates if the picker is below "indexPath", help us determine which row to reveal
        if hasInlinePicker() {
            before = pickerIndexPath?.row < indexPath.row
        }
        
        var sameCellClicked = (pickerIndexPath?.row == indexPath.row + 1)
        
        // Remove any picker cell if it exists
        if self.hasInlinePicker() {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: pickerIndexPath!.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Middle)
            pickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // Hide the old picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            
            togglePickerForSelectedIndexPath(indexPathToReveal, reuseIdentifier: reuseId)
            pickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        
        // Always deselect the row
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        tableView.endUpdates()
        
        updatePicker()
    }
    
    /*! Determines if the given indexPath points to a cell that contains a UIPickerView.
    
    @param indexPath The indexPath to check if it represents a cell with a UIPickerView.
    */
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return hasInlinePicker() && pickerIndexPath?.row == indexPath.row
    }
    
    /*! Determines if the given indexPath points to the cell that contains the pace
    
    @param indexPath The indexPath to check if it represents the pace cell.
    */
    func indexPathIsPace(indexPath: NSIndexPath) -> Bool {
        return indexPath.row == Storyboard.Pace.Row ? true : false
    }
    
    /*! Determines if the given indexPath points to the cell that contains the duration
    
    @param indexPath The indexPath to check if it represents the duration cell.
    */
    func indexPathIsDuration(indexPath: NSIndexPath) -> Bool {
        var isDuration = false
        
        if pickerIndexPath == nil {
            if indexPath.row == Storyboard.Duration.Row {
                isDuration = true
            }
        } else {
            if (indexPath.row - 1) == Storyboard.Duration.Row {
                isDuration = true
            }
        }
        
        return isDuration
    }
    
    
    // MARK: - UIPickerViewDataSource
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            return pacePickerData[component].count
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData[component].count
        } else {
            return 1
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            return pacePickerData.count
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData.count
        } else {
            return 1
        }
    }
    
//    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        if pickerView.tag == Storyboard.Pace.Picker.Tag {
//            return NSAttributedString(string: pacePickerData[component][row].description)
//        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
//            return NSAttributedString(string: durationPickerData[component][row].description)
//        } else {
//            return NSAttributedString(string: "")
//        }
//    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            switch component {
            case Storyboard.Pace.Picker.MinuteComponent:
                paceValue.Minutes = row
            case Storyboard.Pace.Picker.SecondComponent:
                paceValue.Seconds = row
            default:
                break
            }
            mainTableData[self.pickerIndexPath!.row - 1][Storyboard.Pace.Picker.Key] = paceValue.description()
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: pickerIndexPath!.row - 1, inSection: 0)) as? PaceTableViewCell
//            cell?.detailTextLabel?.text = paceValue.description()
            
            cell?.paceValueLabel.text = paceValue.description()
            
            // New value, so add the pace to the stack
            addModifiedVariable(modifiedVariables.Pace)
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            switch component {
            case Storyboard.Duration.Picker.HourComponent:
                durationValue.Hours = row
            case Storyboard.Duration.Picker.MinuteComponent:
                durationValue.Minutes = row
            case Storyboard.Duration.Picker.SecondComponent:
                durationValue.Seconds = row
            default:
                break
            }
            mainTableData[self.pickerIndexPath!.row - 1][Storyboard.Duration.Picker.Key] = durationValue.description()
            var pickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: pickerIndexPath!.row, inSection: 0))
            println("\(pickerCell?.frame.size)")
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: pickerIndexPath!.row - 1, inSection: 0)) as? DurationTableViewCell
//            cell?.detailTextLabel?.text = durationValue.description()
            cell?.durationValueLabel.text = durationValue.description()
            
            // New value, so add the duration to the stack
            addModifiedVariable(modifiedVariables.Duration)
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var containerView = view
        var pickerLabel = UILabel()
        if view == nil {
            containerView = UIView()
            containerView.addSubview(pickerLabel)
            pickerLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
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
            
            containerView.addConstraints(constraints)
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
        
        return containerView
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return Storyboard.PickerComponentWidth
    }
    

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (hasInlinePicker()) {
            var numRows = mainTableData.count
            return ++numRows
        }
        return mainTableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellID = ""
        
        if indexPathHasPicker(indexPath) {
            // The indexPath is the one containing the inline picker
            if willShowPacePicker {
                cellID = Storyboard.Pace.Picker.CellID
                // Reset pace flag
                willShowPacePicker = false
            } else if willShowDurationPicker {
                cellID = Storyboard.Duration.Picker.CellID
                // Reset duration flag
                willShowDurationPicker = false
            }
        } else if indexPathIsPace(indexPath) {
            // The indexPath is one that contains the pace information
            cellID = Storyboard.Pace.CellID
        } else if indexPathIsDuration(indexPath) {
            // The indexPath is one that contains the duration information
            cellID = Storyboard.Duration.CellID
        } else {
            cellID = Storyboard.Distance.CellID
        }
        
//        cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell
        
        //Add labels to pickers if needed
        if cellID == Storyboard.Pace.Picker.CellID {
            var cell: UITableViewCell?
            cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell
            
//            // Add blur effect
//            var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
//            visualEffectView.frame = cell!.bounds
//            cell?.backgroundView = visualEffectView
            
            let minuteLabel = UILabel()
            let secondLabel = UILabel()
            let minuteSubtext = UILabel()
            let secondSubtext = UILabel()
            
            let minuteLabelText = NSAttributedString(string: "min", attributes:
                [
                    NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(15.0)),
                    NSForegroundColorAttributeName: UIColor.darkGrayColor()
                ]
            )
            let secondLabelText = NSAttributedString(string: "sec", attributes:
                [
                    NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(15.0)),
                    NSForegroundColorAttributeName: UIColor.darkGrayColor()
                ]
            )
            
            minuteLabel.attributedText = minuteLabelText
            secondLabel.attributedText = secondLabelText
            
            minuteLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            secondLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            cell?.contentView.addSubview(minuteLabel)
            cell?.contentView.addSubview(secondLabel)
            
            let constraints = [
                NSLayoutConstraint(
                    item: minuteLabel,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: minuteLabel,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1,
                    constant: -(Storyboard.PickerComponentWidth / 2) + Storyboard.PickerDefaultSpaceBetweenComponents
                ),
                NSLayoutConstraint(
                    item: secondLabel,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: secondLabel,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1,
                    constant: Storyboard.PickerComponentWidth / 2 + Storyboard.PickerDefaultSpaceBetweenComponents * 2)
            ]
            cell?.contentView.addConstraints(constraints)
            return cell!
        } else if cellID == Storyboard.Duration.Picker.CellID {
            var cell: UITableViewCell?
            cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell
            
//            // Add blur effect
//            var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
//            visualEffectView.frame = cell!.bounds
//            cell?.backgroundView = visualEffectView
            
            let hourLabel   = UILabel()
            let minuteLabel = UILabel()
            let secondLabel = UILabel()
            
            let hourLabelText = NSAttributedString(string: "hour", attributes:
                [
                    NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(15.0)),
                    NSForegroundColorAttributeName: UIColor.darkGrayColor()
                ]
            )
            let minuteLabelText = NSAttributedString(string: "min", attributes:
                [
                    NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(15.0)),
                    NSForegroundColorAttributeName: UIColor.darkGrayColor()
                ]
            )
            let secondLabelText = NSAttributedString(string: "sec", attributes:
                [
                    NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(15.0)),
                    NSForegroundColorAttributeName: UIColor.darkGrayColor()
                ]
            )
            
            hourLabel.attributedText = hourLabelText
            minuteLabel.attributedText = minuteLabelText
            secondLabel.attributedText = secondLabelText
            
            hourLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            minuteLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            secondLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            cell?.contentView.addSubview(hourLabel)
            cell?.contentView.addSubview(minuteLabel)
            cell?.contentView.addSubview(secondLabel)
            
            let constraints = [
                NSLayoutConstraint(
                    item: hourLabel,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: hourLabel,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1,
                    constant: -Storyboard.PickerComponentWidth),
                NSLayoutConstraint(
                    item: minuteLabel,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: minuteLabel,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1,
                    constant: Storyboard.PickerDefaultSpaceBetweenComponents),
                NSLayoutConstraint(
                    item: secondLabel,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: secondLabel,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: cell?.contentView,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1,
                    constant: Storyboard.PickerComponentWidth + Storyboard.PickerDefaultSpaceBetweenComponents * 2)
            ]
            cell?.contentView.addConstraints(constraints)
            return cell!
        }
        
        // If we have a picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (pickerIndexPath != nil && pickerIndexPath?.row <= indexPath.row) {
            modelRow--
        }
        
        let itemData = mainTableData[modelRow]
        
        if cellID == Storyboard.Pace.CellID {
            var cell: PaceTableViewCell?
            cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? PaceTableViewCell
            
            // Add "select" image to the row
//            cell?.imageView?.image = UIImage(named: "arrowInactive")
            
//            modifiedVariables.Pace.RowSelectionButton.setTranslatesAutoresizingMaskIntoConstraints(false)
//            cell?.contentView.addSubview(modifiedVariables.Pace.RowSelectionButton)
//            let rowSelectionButtonConstraints = [
//                NSLayoutConstraint(
//                    item: modifiedVariables.Pace.RowSelectionButton,
//                    attribute: NSLayoutAttribute.Leading,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.contentView,
//                    attribute: NSLayoutAttribute.LeadingMargin,
//                    multiplier: 1,
//                    constant: 0
//                ),
//                NSLayoutConstraint(
//                    item: modifiedVariables.Pace.RowSelectionButton,
//                    attribute: NSLayoutAttribute.CenterY,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.textLabel,
//                    attribute: NSLayoutAttribute.CenterY,
//                    multiplier: 1,
//                    constant: 0
//                ),
//            ]
//            cell?.addConstraints(rowSelectionButtonConstraints)
//            cell?.indentationLevel = 4
            
            // Populate pace field
            cell?.paceValueLabel.text = itemData[Storyboard.Pace.Picker.Key] as? String
//            cell?.textLabel?.text = itemData[kTitleKey] as? String
//            cell?.detailTextLabel?.text = itemData[Storyboard.Pace.Picker.Key] as? String
            
            // Add the pace units label
//            paceUnitsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
//            
//            cell?.addSubview(paceUnitsLabel)
//            
//            let paceUnitsLabelConstraints = [
//                NSLayoutConstraint(
//                    item: paceUnitsLabel,
//                    attribute: NSLayoutAttribute.Top,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.detailTextLabel,
//                    attribute: NSLayoutAttribute.Bottom,
//                    multiplier: 1,
//                    constant: 0
//                ),
//                NSLayoutConstraint(
//                    item: paceUnitsLabel,
//                    attribute: NSLayoutAttribute.CenterX,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.detailTextLabel,
//                    attribute: NSLayoutAttribute.CenterX,
//                    multiplier: 1,
//                    constant: 0
//                ),
//            ]
//            cell?.addConstraints(paceUnitsLabelConstraints)
            return cell!
        } else if cellID == Storyboard.Duration.CellID {
            var cell: DurationTableViewCell?
            cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? DurationTableViewCell
            
            // Add "select" image to the row
//            cell?.imageView?.image = UIImage(named: "arrowInactive")
//            modifiedVariables.Duration.RowSelectionButton.setTranslatesAutoresizingMaskIntoConstraints(false)
//            cell?.contentView.addSubview(modifiedVariables.Duration.RowSelectionButton)
//            let rowSelectionButtonConstraints = [
//                NSLayoutConstraint(
//                    item: modifiedVariables.Duration.RowSelectionButton,
//                    attribute: NSLayoutAttribute.Leading,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.contentView,
//                    attribute: NSLayoutAttribute.LeadingMargin,
//                    multiplier: 1,
//                    constant: 0
//                ),
//                NSLayoutConstraint(
//                    item: modifiedVariables.Duration.RowSelectionButton,
//                    attribute: NSLayoutAttribute.CenterY,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.textLabel,
//                    attribute: NSLayoutAttribute.CenterY,
//                    multiplier: 1,
//                    constant: 0
//                ),
//            ]
//            cell?.addConstraints(rowSelectionButtonConstraints)
//            cell?.indentationLevel = 4

            // Populate duration field
//            cell?.textLabel?.text = itemData[kTitleKey] as? String
//            cell?.detailTextLabel?.text = itemData[Storyboard.Duration.Picker.Key] as? String
            cell?.durationValueLabel.text = itemData[Storyboard.Duration.Picker.Key] as? String
            
            return cell!
        } else if cellID == Storyboard.Distance.CellID {
            var cell: DistanceTableViewCell?
            cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? DistanceTableViewCell
            
            // Add the distance unit label
//            distanceUnitsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
//            
//            cell?.addSubview(distanceUnitsLabel)
//            
//            let distanceUnitsConstraints = [
//                NSLayoutConstraint(
//                    item: distanceUnitsLabel,
//                    attribute: NSLayoutAttribute.Top,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.detailTextLabel,
//                    attribute: NSLayoutAttribute.Bottom,
//                    multiplier: 1,
//                    constant: 0
//                ),
//                NSLayoutConstraint(
//                    item: distanceUnitsLabel,
//                    attribute: NSLayoutAttribute.Trailing,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.detailTextLabel,
//                    attribute: NSLayoutAttribute.Trailing,
//                    multiplier: 1,
//                    constant: 0),
//            ]
//            
//            cell?.addConstraints(distanceUnitsConstraints)
            
//            cell?.textLabel?.text = itemData[kTitleKey] as? String
//            cell?.detailTextLabel?.hidden = true
//            cell?.viewWithTag(Storyboard.Distance.Tag)?.removeFromSuperview()
//            textField = UITextField()
//            cell?.distanceTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
//            textField.textColor = UIColor.grayColor()
//            textField.tag = Storyboard.Distance.Tag
//            textField.setTranslatesAutoresizingMaskIntoConstraints(false)
            cell?.distanceTextField.keyboardType = UIKeyboardType.DecimalPad
            
            cell?.distanceTextField.addTarget(self, action: Selector("textFieldChanged:"), forControlEvents: UIControlEvents.EditingChanged)
            
//            cell?.contentView.addSubview(textField)
//            cell?.addConstraint(NSLayoutConstraint(
//                item: textField,
//                attribute: NSLayoutAttribute.Leading,
//                relatedBy: NSLayoutRelation.Equal,
//                toItem: cell?.textLabel,
//                attribute: NSLayoutAttribute.Trailing,
//                multiplier: 1,
//                constant: 8))
//            cell?.addConstraint(NSLayoutConstraint(
//                item: textField,
//                attribute: NSLayoutAttribute.Top,
//                relatedBy: NSLayoutRelation.Equal,
//                toItem: cell?.contentView,
//                attribute: NSLayoutAttribute.Top,
//                multiplier: 1,
//                constant: 8))
//            cell?.addConstraint(NSLayoutConstraint(
//                item: textField,
//                attribute: NSLayoutAttribute.Bottom,
//                relatedBy: NSLayoutRelation.Equal,
//                toItem: cell?.contentView,
//                attribute: NSLayoutAttribute.Bottom,
//                multiplier: 1,
//                constant: -8))
//            cell?.addConstraint(NSLayoutConstraint(
//                item: textField,
//                attribute: NSLayoutAttribute.Trailing,
//                relatedBy: NSLayoutRelation.Equal,
//                toItem: cell?.contentView,
//                attribute: NSLayoutAttribute.Trailing,
//                multiplier: 1,
//                constant: -16))
//            textField.textAlignment = .Right
            cell?.distanceTextField.delegate = self
            
            cell?.distanceTextField.text = itemData[Storyboard.Distance.Key] as? String
            
            // Add "select" image to the row
////            cell?.imageView?.image = UIImage(named: "arrowInactive")
//            modifiedVariables.Distance.RowSelectionButton.setTranslatesAutoresizingMaskIntoConstraints(false)
//            cell?.contentView.addSubview(modifiedVariables.Distance.RowSelectionButton)
//            let rowSelectionButtonConstraints = [
//                NSLayoutConstraint(
//                    item: modifiedVariables.Distance.RowSelectionButton,
//                    attribute: NSLayoutAttribute.Leading,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.contentView,
//                    attribute: NSLayoutAttribute.LeadingMargin,
//                    multiplier: 1,
//                    constant: 0
//                ),
//                NSLayoutConstraint(
//                    item: modifiedVariables.Distance.RowSelectionButton,
//                    attribute: NSLayoutAttribute.CenterY,
//                    relatedBy: NSLayoutRelation.Equal,
//                    toItem: cell?.textLabel,
//                    attribute: NSLayoutAttribute.CenterY,
//                    multiplier: 1,
//                    constant: 0
//                ),
//            ]
//            cell?.addConstraints(rowSelectionButtonConstraints)
//            cell?.indentationLevel = 4
            
            return cell!
        }

        return UITableViewCell()
    }
    
    // MARK: - UITextFieldDelegate
    func endEditingNow() {
        self.view.endEditing(true)
    }
    func textFieldChanged(textField: UITextField) {
        distanceValue = (textField.text as NSString).doubleValue
        mainTableData[2][Storyboard.Distance.Key] = textField.text
        addModifiedVariable(modifiedVariables.Distance)
//        distanceValue = (textField.text as NSString).doubleValue
//        mainTableData[2][Storyboard.Distance.Key] = textField.text
//        addModifiedVariable(modifiedVariables.Distance)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // Collapse any pickers
        if pickerIndexPath != nil {
            removePickerRow()
        }
        
        // Create button bar for the keyboard
        let keyboardDoneButtonBar = UIToolbar()
        keyboardDoneButtonBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: Selector("endEditingNow"))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        var toolbarButtons = [flexibleSpace, doneButton]
        keyboardDoneButtonBar.setItems(toolbarButtons, animated: false)
        
        textField.inputAccessoryView = keyboardDoneButtonBar
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.resignFirstResponder()
    }
    
    
    // MARK: - UITableViewDelegate
        
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : Storyboard.RowHeight)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let reuseID = cell?.reuseIdentifier {
            if reuseID == Storyboard.Pace.CellID || reuseID == Storyboard.Duration.CellID {
                displayInlinePickerForRowAtPath(indexPath, reuseId: reuseID)
            }
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.backgroundView?.backgroundColor = UIColor.clearColor()
//        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
//        visualEffectView.frame = cell.bounds
//        cell.backgroundView = visualEffectView
//        cell.backgroundView?.addSubview(visualEffectView)
//        cell.backgroundColor = UIColor.redColor()
//        if ((indexPath.row == modifiedVariables.Pace.Row && modifiedVariables.Pace.IsModified && indexPath.row != pickerIndexPath?.row) ||
//            (indexPath.row == modifiedVariables.Duration.Row && modifiedVariables.Duration.IsModified && indexPath.row != pickerIndexPath?.row) ||
//            (indexPath.row == modifiedVariables.Distance.Row && modifiedVariables.Distance.IsModified && indexPath.row != pickerIndexPath?.row)) {
////            cell.backgroundColor = UIColor.greenColor()
//                cell.imageView?.image = UIImage(named: "arrow_right.png")
//        } else if ((indexPath.row == modifiedVariables.Pace.Row && !modifiedVariables.Pace.IsModified) ||
//            (indexPath.row == modifiedVariables.Duration.Row && !modifiedVariables.Duration.IsModified) ||
//            (indexPath.row == modifiedVariables.Distance.Row && !modifiedVariables.Distance.IsModified)) {
////            cell.backgroundColor = UIColor.clearColor()
//                cell.imageView?.image = nil
//        }
        
    }

    
    // MARK: - Calculate
    @IBAction func calculate(sender: UIBarButtonItem) {
        removePickerRow()
        dismissKeyboard()
        calculateValues()
    }
    
    @IBAction func resetVariables(sender: UIBarButtonItem) {
        resetNewVariables()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.SettingsSegue {
            if let settingsViewController = segue.destinationViewController.contentViewController as? SettingsTableViewController {
                settingsViewController.isMetric = self.isMetric
            }
        }
    }
}

// Extension to deal with embedded navigation view controllers in segues
extension UIViewController {
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController
        } else {
            return self
        }
    }
}

// Class which represents the 3 main variables: Pace, Duration, and Distance
class Variable : NSObject {
    var Row: Int = 0
    var TableViewController: MainTemplateTableViewController? = nil
    var RowSelectionButton = SelectRowButton()
    var IsModified: Bool = false {
        didSet {
            var selectedRow = self.Row
            if self.IsModified {
                let cell = TableViewController?.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
//                cell?.imageView?.image = UIImage(named: "arrowActive")
                RowSelectionButton.rowState = .Active
            } else {
                if self.TableViewController?.pickerIndexPath != nil && self.Row >= self.TableViewController?.pickerIndexPath?.row {
                    selectedRow++
                }
                let cell = TableViewController?.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
//                cell?.imageView?.image = UIImage(named: "arrowInactive")
                RowSelectionButton.rowState = .Inactive
                reloadRow(selectedRow)
            }
        }
    }
    
    private func reloadRow(row: Int) {
        self.TableViewController?.tableView.beginUpdates()
        self.TableViewController?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: .None)
        self.TableViewController?.tableView.endUpdates()
    }
}