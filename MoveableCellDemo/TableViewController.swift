//
//  TableViewController.swift
//  MoveableCellDemo
//
//  Created by Xu, Jay on 8/11/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var testTableView: UITableView!
    var contentArr = ["Hello world","Hi there", "Terminate", "launch"]
    var snapshot:UIView?
    var sourceIndex:NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        testTableView.addGestureRecognizer(longPress)
        title = "TableView"
    }
    
    func longPressHandler(sender:UILongPressGestureRecognizer){
        let location = sender.locationInView(testTableView)
        let indexPath = testTableView.indexPathForRowAtPoint(location)
        switch sender.state {
        case .Began:
            if indexPath != nil {
                sourceIndex = indexPath
                let cell = testTableView.cellForRowAtIndexPath(indexPath!)
                snapshot = extractSnapshotFromView(cell!)
                snapshot!.center = (cell?.center)!
                snapshot!.alpha = 0.0
                testTableView.addSubview(snapshot!)
                UIView.animateWithDuration(0.25, animations: { 
                    self.snapshot!.center.y = location.y
                    self.snapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    self.snapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                    }, completion: { (success) in
                        cell?.hidden = true
                })
            }
        case .Changed:
            var center = snapshot!.center
            center.y = location.y
            snapshot!.center = center
            if indexPath != nil && indexPath != sourceIndex {
                swap(&contentArr[indexPath!.row], &contentArr[sourceIndex!.row])
                testTableView.moveRowAtIndexPath(sourceIndex!, toIndexPath: indexPath!)
                sourceIndex = indexPath
            }
        default:
            let cell = testTableView.cellForRowAtIndexPath(sourceIndex!)
            cell?.hidden = false
            cell?.alpha = 0.0
            UIView.animateWithDuration(0.25, animations: { 
                self.snapshot!.center = cell!.center
                self.snapshot!.transform = CGAffineTransformIdentity
                self.snapshot!.alpha = 0.0
                cell?.alpha = 1.0
                }, completion: { (success) in
                    self.sourceIndex = nil
                    self.snapshot!.removeFromSuperview()
                    self.snapshot = nil
            })
        }
    }
    
    func extractSnapshotFromView(originView:UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(originView.bounds.size, false, 0)
        originView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: snapshotImage)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        cell.textLabel?.text = contentArr[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
