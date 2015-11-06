//
//  InfoTableViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 11/4/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit
import MessageUI

class InfoTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var footerView: UIView!
    
    @IBAction func tweet(sender: UIButton) {
    }
    @IBOutlet weak var contactTableCell: UITableViewCell!
    
    @IBAction func closeView(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = footerView
        footerView.frame.size.height = self.tableView.frame.size.height - (self.navigationController?.navigationBar.frame.size.height)! - self.tableView.tableFooterView!.frame.origin.y
        
//        let blurEffect = UIBlurEffect(style: .Dark)
//        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
//        vibrancyEffectView.frame = tableView.bounds
//        vibrancyEffectView.contentView.addSubview(tableView)
//        blurView.contentView.addSubview(vibrancyEffectView)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectedCell: UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        if selectedCell == contactTableCell {
            sendSupportEmail()
        }
    }
    
    private func sendSupportEmail() {
        let composer: MFMailComposeViewController = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        if MFMailComposeViewController.canSendMail() {
            composer.setToRecipients(["example@example.com"])
            composer.setSubject("The subject")
            composer.setMessageBody("This is the body", isHTML: false)
            composer.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            self.presentViewController(composer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        if (error != nil) {
            let alert:UIAlertController = UIAlertController(title: "Error", message: NSString(format: "Oops: %@", (error?.description)!) as String, preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)            
        }
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
