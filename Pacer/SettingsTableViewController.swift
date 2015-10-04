//
//  SettingsTableViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 4/26/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var metricPaceSwitch: UISwitch!
    @IBOutlet weak var metricDistanceSwitch: UISwitch!
    
    @IBAction func done(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var isPaceMetric = false
    var isDistanceMetric = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        isPaceMetric = defaults.boolForKey(kMetricPaceKey)
        isDistanceMetric = defaults.boolForKey(kMetricDistanceKey)
        metricPaceSwitch.on = isPaceMetric
        metricDistanceSwitch.on = isDistanceMetric
        
        // Adding a zero-sized footer prevents additional blank rows from being displayed.
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        // Color scheme
        doneButton.tintColor = Colors.Tint
        metricPaceSwitch.onTintColor = Colors.Tint
        metricDistanceSwitch.onTintColor = Colors.Tint
        
        // Background blur effect
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        tableView.backgroundView = visualEffectView
    }

    @IBAction func toggleUnits(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(metricPaceSwitch.on, forKey: kMetricPaceKey)
        isPaceMetric = metricPaceSwitch.on
    }
    
    @IBAction func toggleDistanceUnits(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(metricDistanceSwitch.on, forKey: kMetricDistanceKey)
        isDistanceMetric = metricDistanceSwitch.on
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
