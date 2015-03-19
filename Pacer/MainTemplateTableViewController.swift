//
//  MainTemplateTableViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 3/12/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class MainTemplateTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    private struct Storyboard {
        // Order of the rows:
        //  - Pace
        //  - Pace Picker
        //  - Duration
        //  - Duration Picker
        //  - Distance
        struct Pace {
            static let Row    = 0          // Row position of the pace
            static let CellID = "paceCell" // Will hold the pace information
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
        }
    }
    
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
    
    // Variables to hold pace, duration, and distance data
    var paceValue     = PaceTimeFormat()
    var durationValue = DurationTimeFormat()
    var distance      = 0.0
    
    var mainTableData: [[String: AnyObject]] = []
    var willShowPacePicker = false
    var willShowDurationPicker = false
    
    var pickerIndexPath: NSIndexPath?
    
    // Flags indicating whether there is a new variable to be calculated
    var newPaceValue     = false
    var newDurationValue = false
    var newDistanceValue = false
    
    @IBOutlet weak var navTitleBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rowOne = [kTitleKey: "Pace", Storyboard.Pace.Picker.Key: " "]
        let rowTwo = [kTitleKey: "Duration", Storyboard.Duration.Picker.Key: " "]
        let rowThree = [kTitleKey: "Distance"]
        
        mainTableData = [rowOne, rowTwo, rowThree]
        
        // Create picker data sources
        arrayBaseSixty = createArray(60)
        pacePickerData = [arrayBaseSixty, arrayBaseSixty]
        durationPickerData = [createArray(80), arrayBaseSixty, arrayBaseSixty]
    }
    
    private func createArray(numberOfElements: Int) -> [Int] {
        var array = [Int]()
        for (var i = 0; i < numberOfElements; i++) {
            array.append(i)
        }
        return array
    }
    
    private func resetNewVariables() {
        // Reset the new variable flags
        newPaceValue = false
        newDurationValue = false
        newDistanceValue = false
    }
    
    private func calculate() {
        // Do calculations
        if newPaceValue {
            if newDurationValue {
                // Pace is in minutes per mile, so enter the inverse into the formula
                var result = PacingCalculations().distanceFormula(1/Double(paceValue.TotalSeconds), time: Double(durationValue.TotalSeconds))
                navTitleBar.title = "\(result)"
                // Update distance row
                var distanceRow = Storyboard.Distance.Row
                if pickerIndexPath != nil {
                    distanceRow += 1
                }
                var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: distanceRow, inSection: 0))
                cell?.detailTextLabel?.text = "\(result)"
                // Reset new variable flags
                resetNewVariables()
            } else if newDistanceValue {
//                PacingCalculations().timeFormula(Double(paceValue.TotalSeconds), distance: Double(distanceValue.TotalSeconds))
            }
        }
    }
    
    // MARK: - Utilities
    private func hasInlinePicker() -> Bool {
        return pickerIndexPath? != nil
    }
    
    private func removePickerRow() {
        if self.hasInlinePicker() {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: pickerIndexPath!.row, inSection: 0)], withRowAnimation: .Fade)
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
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else {
            // Didn't find a picker below it, so we should insert it
            if reuseIdentifier == Storyboard.Pace.CellID {
                willShowPacePicker = true
            } else if reuseIdentifier == Storyboard.Duration.CellID {
                willShowDurationPicker = true
            }
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        tableView.endUpdates()
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
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: pickerIndexPath!.row, inSection: 0)], withRowAnimation: .Fade)
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
        var isPace = false
        
        if (indexPath.row == Storyboard.Pace.Row) {
            isPace = true
        }
        return isPace
    }
    
    /*! Determines if the given indexPath points to the cell that contains the duration
    
    @param indexPath The indexPath to check if it represents the duration cell.
    */
    func indexPathIsDuration(indexPath: NSIndexPath) -> Bool {
        var isDuration = false
        
        if (indexPath.row == Storyboard.Duration.Row) {
            isDuration = true
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
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            return NSAttributedString(string: pacePickerData[component][row].description)
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return NSAttributedString(string: durationPickerData[component][row].description)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            switch component {
            case Storyboard.Pace.Picker.MinuteComponent:
                paceValue.Minutes = row
                println("Pace Minute: \(row.description)")
            case Storyboard.Pace.Picker.SecondComponent:
                paceValue.Seconds = row
                println("Pace Second \(row.description)")
            default:
                break
            }
            mainTableData[self.pickerIndexPath!.row - 1][Storyboard.Pace.Picker.Key] = paceValue.description()
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: pickerIndexPath!.row - 1, inSection: 0))
            cell?.detailTextLabel?.text = paceValue.description()
            
            // New value, so set pace flag
            newPaceValue = true
            
            // Calculate with new pace value
            calculate()
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            switch component {
            case Storyboard.Duration.Picker.HourComponent:
                durationValue.Hours = row
                println("Pace Hour: \(row.description)")
            case Storyboard.Duration.Picker.MinuteComponent:
                durationValue.Minutes = row
                println("Pace Minute: \(row.description)")
            case Storyboard.Duration.Picker.SecondComponent:
                durationValue.Seconds = row
                println("Pace Second \(row.description)")
            default:
                break
            }
            mainTableData[self.pickerIndexPath!.row - 1][Storyboard.Duration.Picker.Key] = durationValue.description()
            var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: pickerIndexPath!.row - 1, inSection: 0))
            cell?.detailTextLabel?.text = durationValue.description()
            
            // New value, so set duration flag
            newDurationValue = true
            
            // Calculate with new duration value
            calculate()
        }
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
        var cell: UITableViewCell?
        
        var cellID = Storyboard.Distance.CellID
        
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
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell
        
        // If we have a picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (pickerIndexPath != nil && pickerIndexPath?.row <= indexPath.row) {
            modelRow--
        }
        
        let itemData = mainTableData[modelRow]
        
        if cellID == Storyboard.Pace.CellID {
            // Populate pace field
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = itemData[Storyboard.Pace.Picker.Key] as? String
        } else if cellID == Storyboard.Duration.CellID {
            // Populate duration field
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            cell?.detailTextLabel?.text = itemData[Storyboard.Duration.Picker.Key] as? String
        } else if cellID == Storyboard.Distance.CellID {
            cell?.textLabel?.text = itemData[kTitleKey] as? String
        }
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}
