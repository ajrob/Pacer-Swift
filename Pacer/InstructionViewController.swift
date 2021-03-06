//
//  InstructionViewController.swift
//  Pacer
//
//  Created by Alex Robinson on 10/27/15.
//  Copyright © 2015 Alex Robinson. All rights reserved.
//

import UIKit

class InstructionViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    let instructions = [
        (title: "", body: "Pace Wrangler will tell you how fast you need to run for that 5k goal time, how long it will take you to run that 10 miles, or how far you can go in that hour of spare time you have."),
        (title: "How fast will I run?", body: "Figure out your pace based on a specified time and distance."),
        (title: "How long will it take me?", body: "Figure out your running duration based on a specified pace and distance."),
        (title: "How far will I go?", body: "Figure out a distance based on a specific pace and running duration."),
    ]
    
    var pageViewController: UIPageViewController!
    
    func reset() {
        /* Getting the page View controller */
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        let pageContentViewController = self.viewControllerAtIndex(index: 0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.Tint
        reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeView(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func close(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! InstructionContentViewController).pageIndex!
        if(index <= 0){
            return nil
        }
        index-=1
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! InstructionContentViewController).pageIndex!
        index+=1
        if(index >= self.instructions.count){
            return nil
        }
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((self.instructions.count == 0) || (index >= self.instructions.count)) {
            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "InstructionContentViewController") as! InstructionContentViewController
        
        pageContentViewController.titleText = self.instructions[index].title
        pageContentViewController.bodyText = self.instructions[index].body
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.instructions.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
}
