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
    @IBOutlet weak var units: UISegmentedControl!
    
    @IBAction func done(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding a zero-sized footer prevents additional blank rows from being displayed.
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        // Color scheme
        doneButton.tintColor = Colors.Tint
        units.tintColor = Colors.Tint
        
        // Background blur effect
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        tableView.backgroundView = visualEffectView
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
