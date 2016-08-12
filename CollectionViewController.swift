//
//  CollectionViewController.swift
//  MoveableCellDemo
//
//  Created by Xu, Jay on 8/12/16.
//  Copyright © 2016 Xu, Jay. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var testCollectionView: UICollectionView!
    var contentArr = ["Hello world","Hi there", "Terminate", "launch"]
    var snapshot:UIView?
    var sourceIndex:NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        testCollectionView.addGestureRecognizer(longPress)
        title = "CollectionView"
    }
    
    func longPressHandler(sender:UILongPressGestureRecognizer){
        let location = sender.locationInView(testCollectionView)
        let indexPath = testCollectionView.indexPathForItemAtPoint(location)
        switch sender.state {
        case .Began:
            if indexPath != nil {
                sourceIndex = indexPath
                let cell = testCollectionView.cellForItemAtIndexPath(indexPath!)
                snapshot = extractSnapshotFromView(cell!)
                snapshot!.center = (cell?.center)!
                snapshot!.alpha = 0.0
                testCollectionView.addSubview(snapshot!)
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
            center.x = location.x
            snapshot!.center = center
            if indexPath != nil && indexPath != sourceIndex {
                swap(&contentArr[indexPath!.item], &contentArr[sourceIndex!.item])
                testCollectionView.moveItemAtIndexPath(sourceIndex!, toIndexPath: indexPath!)
                sourceIndex = indexPath
            }
        default:
            let cell = testCollectionView.cellForItemAtIndexPath(sourceIndex!)
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentArr.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.blueColor()
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
