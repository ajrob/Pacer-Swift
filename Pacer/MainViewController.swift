//
//  MainViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 10/9/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Colors.Tint
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        //TODO:
//        //Launch help screen the first time the application is launched
//        if !NSUserDefaults.standardUserDefaults().boolForKey(kDidLaunchBeforeKey) {
//            let helpNavigationController = UINavigationController()
//            helpNavigationController.viewControllers = [InstructionViewController()]
//            self.presentViewController(helpNavigationController, animated: true, completion: nil)
//        } else {
//            NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidLaunchBeforeKey)
//        }
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var durationButton: CustomDefaultButton!
    @IBOutlet weak var distanceButton: CustomDefaultButton!
    @IBOutlet weak var rateButton: CustomDefaultButton!

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let inputsVC = segue.destinationViewController as? InputsViewController {
            if segue.identifier == "durationSegue" {
                
                inputsVC.titleSaying = (self.durationButton.titleLabel?.text)!
                
                inputsVC.willHideDuration = true
                inputsVC.willHidePace     = false
                inputsVC.willHideDistance = false
                
            } else if segue.identifier == "distanceSegue" {
                
                inputsVC.titleSaying = (self.distanceButton.titleLabel?.text)!
                
                inputsVC.willHideDistance = true
                inputsVC.willHideDuration = false
                inputsVC.willHidePace     = false
                                
            } else if segue.identifier == "rateSegue" {
                
                inputsVC.titleSaying = (self.rateButton.titleLabel?.text)!
                
                inputsVC.willHidePace     = true
                inputsVC.willHideDistance = false
                inputsVC.willHideDuration = false
            }
        }
    }

}
