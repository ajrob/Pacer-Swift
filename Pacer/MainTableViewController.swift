//
//  MainTableViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 2/27/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var pacePicker: UIPickerView!
    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet var mainTable: UITableView!
    
    private struct Storyboard {
        static let AttributeCellResuseIdentifier = "attributeCell"
        static let AttributePickerCellReuseIdentifier = "attributePicker"
        struct Pace {
            static let Row = 0
            struct Picker {
                static let Tag = 1
                static let Row = 1
                static let MinuteComponent = 0
                static let SecondComponent = 1
            }
        }
        struct Duration {
            static let Row = 2
            struct Picker {
                static let Tag = 2
                static let Row = 3
                static let HourComponent = 0
                static let MinuteComponent = 1
                static let SecondComponent = 2
            }
        }
        
    }
    
    enum TimePickerComponent: Int {
        case Pace = 0, Duration
    }
    
    let kPickerTag = 9 // View tag identifying the picker view
    let kAttributeCellID = "attributeCell" // the cells with the attribute (pace, distance, or duration)
    let kAttributePickerCellID = "attributePicker" // the cell containing the picker
    let kOtherCellID = "otherCell"
    
    let testArray = ["ksljd", "sldkjf", "jajaja", "bwoeklw"]
    
    var pickerIndexPath: NSIndexPath?
    
    var arrayBaseSixty = [Int]()
    
    var pickerCellRowHeight: CGFloat = 216
    
    var pacePickerData = [[Int]]()
    var durationPickerData = [[Int]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for (var i = 0; i < 59; i++) { arrayBaseSixty.append(i) }
        pacePicker.delegate = self
        pacePicker.dataSource = self
        durationPicker.delegate = self
        durationPicker.dataSource = self
        
        arrayBaseSixty = createArray(60)
        pacePickerData = [arrayBaseSixty, arrayBaseSixty]
        durationPickerData = [createArray(80), arrayBaseSixty, arrayBaseSixty]
        
        // Initially hide the data pickers
        hidePickerCell(Storyboard.Pace.Picker.Row)
        hidePickerCell(Storyboard.Duration.Picker.Row)

        // Obtain the picker view cell's height
//        let pickerViewCellToCheck = self.tableView.dequeueReusableCellWithIdentifier(Storyboard.AttributePickerCellReuseIdentifier) as UITableViewCell

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private func hidePickerCell(row: Int) {
        if let indexPath = NSIndexPath(forRow: row, inSection: 1) {
            if let cell = mainTable.cellForRowAtIndexPath(indexPath) {
                mainTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//                cell.hidden = true
                mainTable.reloadData()
            }
        }
    }

    private func createArray(numberOfElements: Int) -> [Int] {
        var array = [Int]()
        for (var i = 0; i < numberOfElements; i++) {
            array.append(i)
        }
        return array
    }
    
    // MARK: - UIPickerViewDataSource
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            return pacePickerData.count
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData.count
        } else {
            return 1
        }
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            return pacePickerData[component].count
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData[component].count
        } else {
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            return pacePickerData[component][row].description
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            return durationPickerData[component][row].description
        } else {
            return ""
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
//    // returns width of column and height of row for each component.
//    optional func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
//    optional func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == Storyboard.Pace.Picker.Tag {
            switch component {
            case Storyboard.Pace.Picker.MinuteComponent:
                println("Pace Minute: \(row.description)")
            case Storyboard.Pace.Picker.SecondComponent:
                println("Pace Second \(row.description)")
            default:
                break
            }
        } else if pickerView.tag == Storyboard.Duration.Picker.Tag {
            switch component {
            case Storyboard.Duration.Picker.HourComponent:
                println("Pace Hour: \(row.description)")
            case Storyboard.Duration.Picker.MinuteComponent:
                println("Pace Minute: \(row.description)")
            case Storyboard.Duration.Picker.SecondComponent:
                println("Pace Second \(row.description)")
            default:
                break
            }
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        return 4
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
        switch indexPath.row {
        case Storyboard.Pace.Row:
            println("Pace selected")
            var nextRowIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: 1)
            var pacePickerCell = tableView.cellForRowAtIndexPath(nextRowIndexPath)
            
        case Storyboard.Pace.Picker.Row:
            println("Pace picker selected")
        case Storyboard.Duration.Row:
            println("Duration selected")
        case Storyboard.Duration.Picker.Row:
            println("Duration picker selected")
        default:
            break
        }
    }
}
