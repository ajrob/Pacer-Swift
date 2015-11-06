//
//  InstructionContentViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 10/28/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit

class InstructionContentViewController: UIViewController {
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!

    var pageIndex: Int?
    var titleText : String!
    var bodyText : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.Tint
        
        self.heading.text = self.titleText
        self.bodyTextView.text = self.bodyText
        self.heading.alpha = 0
        self.bodyTextView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.heading.alpha = 1.0
        })
        
        UIView.animateWithDuration(0.75, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.bodyTextView.alpha = 1.0
            }, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.heading.alpha = 0.0
        })
        
        UIView.animateWithDuration(1, delay: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.bodyTextView.alpha = 0.0
            }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
