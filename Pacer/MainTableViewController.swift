//
//  MainTableViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 2/27/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    enum Time {
        case Pace
        case Duration
    }
    
    let kPickerTag = 9 // View tag identifying the picker view
    let kAttributeCellID = "attributeCell" // the cells with the attribute (pace, distance, or duration)
    let kAttributePickerCellID = "attributePicker" // the cell containing the picker
    let kOtherCellID = "otherCell"
    
    // keep track of which rows have date cells
    let kAttributeStartRow = 1
    let kAttributeEndRow   = 2
    
    let paceKey = "paceKey"
    let paceValueKey = "paceValueKey"
    
    var arrayBaseSixty = [Int]()
    
    var dataArray: [[String: AnyObject]] = []
    
    let testArray = ["ksljd", "sldkjf", "jajaja", "bwoeklw"]
    
    var pickerIndexPath: NSIndexPath?
    
    var pickerCellRowHeight: CGFloat = 216

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (var i = 0; i < 59; i++) { arrayBaseSixty.append(i) }
        
        let titleStructure = ["paceKey": "This is the title"]
        let paceStructure = ["paceKey": "Pace", "paceValueKey": "This is the pace"]
        let distanceStructure = ["distanceKey": "Distance", "distanceValueKey": "This is the distance"]
        let durationStructure = ["durationKey": "Duration", "durationValueKey": "This is the duration"]
        dataArray = [paceStructure, distanceStructure, durationStructure]
        
        // Obtain the picker view cell's height
        let pickerViewCellToCheck = self.tableView.dequeueReusableCellWithIdentifier(Storyboard.AttributePickerCellReuseIdentifier) as UITableViewCell

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Picker view data source
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return testArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return testArray[row]
    }
    
    // MARK: - Utilities
    
    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
    
    @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
    */
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasPicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkPickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: 0))
        let checkPicker = checkPickerCell?.viewWithTag(kPickerTag)
        
        hasPicker = checkPicker != nil
        return hasPicker
    }
    
    /*! Updates the UIPickerView's value to match with the date of the cell above it.
    !!!!! NOT FUNCTIONAL RIGHT NOW!!!!!!!!
    */
    func updatePicker() {
        if pickerIndexPath != nil {
            let associatedPickerCell = tableView.cellForRowAtIndexPath(pickerIndexPath!)
            
            if let targetedPicker = associatedPickerCell?.viewWithTag(kPickerTag) as UIPickerView? {
                // We found a UIPickerView in this cell, so update it's value
                let itemData = dataArray[self.pickerIndexPath!.row - 1]
//                targetedPicker.selectRow(<#row: Int#>, inComponent: <#Int#>, animated: <#Bool#>)
            }
        }
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIPickerView.
    
    @param indexPath The indexPath to check if it represents a cell with the UIPickerView.
    */
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return (hasInlinePicker() && pickerIndexPath?.row == indexPath.row)
    }
    
    /*! Determines if the given indexPath points to a cell that contains the attributes
    
    @param indexPath The indexPath to check if it represents attributes cell.
    */
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        var hasAttribute = false
        
        if (indexPath.row == kAttributeStartRow) || (indexPath.row == kAttributeEndRow || (hasInlinePicker() && (indexPath.row == kAttributeEndRow + 1))) {
            hasAttribute = true
        }
        return hasAttribute
    }

    // MARK: - UITableViewDataSource

    private struct Storyboard {
        static let AttributeCellResuseIdentifier = "attributeCell"
        static let AttributePickerCellReuseIdentifier = "attributePicker"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if hasInlinePicker() {
            // We have a picker, so allow for it in the number of rows in this section
            var numRows = dataArray.count
            return ++numRows
        }
        
        return dataArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        var cellID = kOtherCellID
        
        if indexPathHasPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kAttributePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kAttributeCellID       // the start/end date cells
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? UITableViewCell
        
        if indexPath.row == 0 {
            // we decide here that first cell in the table is not selectable (it's just an indicator)
            cell?.selectionStyle = .None;
        }
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (pickerIndexPath != nil && pickerIndexPath?.row <= indexPath.row) {
            modelRow--
        }
        
        let itemData = dataArray[modelRow]
        
        if cellID == kAttributeCellID {
            // we have either start or end date cells, populate their date field
            //
            cell?.textLabel?.text = itemData[paceKey] as? String
            cell?.detailTextLabel?.text = itemData[paceValueKey] as? String
        } else if cellID == kOtherCellID {
            // this cell is a non-date cell, just assign it's text label
            //
            cell?.textLabel?.text = itemData[paceKey] as? String
        }
        
        return cell!
    }
    
    /* Adds or removes a UIPickerView cell below the given indexPath
    @param indexPath The indexxPath to reveal the UIPickerView */
    func togglePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 0)]
        
        // Check if 'indexPath' has an attached picker below it
        if hasPickerForIndexPath(indexPath) {
            // Found a picker below it, so remove it
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Bottom)
        } else {
            // Didn't find a picker below it, so we should insert it
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        tableView.endUpdates()
    }
    
    
    /* Reveals the picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
    @param indexPath The indexPath to reveal the UIPickerView */
    func displayInlinePickerForRow(indexPath: NSIndexPath) {
        // Display the picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // Indicates if the picker is below "indexPath" to help determine which row to reveal
        if (hasInlinePicker()) {
            before = pickerIndexPath?.row < indexPath.row
        }
        
        var sameCellClicked = (pickerIndexPath?.row == indexPath.row + 1)
        
        // Remove any picker cell if it exists
        if self.hasInlinePicker() {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: pickerIndexPath!.row, inSection: 0)], withRowAnimation: .Top)
            pickerIndexPath = nil;
        }
        
        if !sameCellClicked {
            // Hide the old picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 0)
            
            self.togglePickerForSelectedIndexPath(indexPathToReveal)
            pickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 0)
        }
        
        // Always deselect the row containing the attribute ('Pace', 'Distance', or 'Duration')
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        tableView.endUpdates()
        
        // Inform our picker of the current attribute value to match the current cell
        updatePicker()
    }
    
    /* Determines if the UITableViewController has a UIPickerView in any of its cells */
    func hasInlinePicker() -> Bool {
        return pickerIndexPath != nil
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == kAttributeCellID {
            displayInlinePickerForRow(indexPath)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}
