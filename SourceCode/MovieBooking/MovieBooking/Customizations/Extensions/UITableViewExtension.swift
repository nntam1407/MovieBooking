//
//  UITableViewExtension.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 5/16/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func reloadData(pushAnimated animated: Bool, duration: TimeInterval) {
        if !animated {
            self.layer.removeAnimation(forKey: "UITableViewReloadDataAnimationKey")
            self.reloadData()
        } else {
            let transition = CATransition()
            transition.type = kCATransitionPush
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.fillMode = kCAFillModeForwards
            transition.duration = duration
            transition.subtype = kCATransitionFromRight
            self.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
            
            // Update your data source here
            self.reloadData()
        }
    }
    
    func reloadData(popAnimated animated: Bool, duration: TimeInterval) {
        if !animated {
            self.layer.removeAnimation(forKey: "UITableViewReloadDataAnimationKey")
            self.reloadData()
        } else {
            let transition = CATransition()
            transition.type = kCATransitionPush
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.fillMode = kCAFillModeForwards
            transition.duration = duration
            transition.subtype = kCATransitionFromLeft
            self.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
            
            // Update your data source here
            self.reloadData()
        }
    }
    
    func reloadData(dropAnimated animated: Bool, dropSectionHeaders: Bool) {
        if !animated {
            self.reloadData()
            return
        }
        
        // Start dismiss animated
        let visibleCells = self.visibleCells
        let visibleSectionHeaders = dropSectionHeaders ? self.visbleSectionHeaderViews() : [UIView]()
        
        if visibleCells.count > 0 {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                for cell in visibleCells {
                    cell.alpha = 0.0
                    
                    var frame = cell.frame
                    frame.origin.y += 5
                    cell.frame = frame;
                }
                
                for view in visibleSectionHeaders {
                    view.alpha = 0.0
                    
                    var frame = view.frame
                    frame.origin.y += 5
                    view.frame = frame;
                }
                
                }, completion: { (finished: Bool) in
                    
                    // Should re-set all cell alpha = 1.0
                    for cell in visibleCells {
                        cell.alpha = 1.0
                    }
                    
                    for view in visibleSectionHeaders {
                        view.alpha = 1.0
                    }
                    
                    // Now start animated for new data
                    self.reloadData()
                    
                    let visibleCells = self.visibleCells
                    let visibleSectionHeaders = dropSectionHeaders ? self.visbleSectionHeaderViews() : [UIView]()
                    
                    if visibleCells.count > 0 {
                        for cell in visibleCells {
                            cell.alpha = 0.0
                            
                            var frame = cell.frame
                            frame.origin.y += 10
                            cell.frame = frame;
                        }
                        
                        for view in visibleSectionHeaders {
                            view.alpha = 0.0
                            
                            var frame = view.frame
                            frame.origin.y += 10
                            view.frame = frame;
                        }
                        
                        UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                            for cell in visibleCells {
                                cell.alpha = 1.0
                                
                                var frame = cell.frame
                                frame.origin.y -= 10
                                cell.frame = frame;
                            }
                            
                            for view in visibleSectionHeaders {
                                view.alpha = 1.0
                                
                                var frame = view.frame
                                frame.origin.y -= 10
                                view.frame = frame;
                            }
                            
                            }, completion: nil)
                    }
            })
        } else {
            // Now start animated
            self.reloadData()
            
            let visibleCells = self.visibleCells
            let visibleSectionHeaders = dropSectionHeaders ? self.visbleSectionHeaderViews() : [UIView]()
            
            if visibleCells.count > 0 {
                for cell in visibleCells {
                    cell.alpha = 0.0
                    
                    var frame = cell.frame
                    frame.origin.y += 10
                    cell.frame = frame;
                }
                
                for view in visibleSectionHeaders {
                    view.alpha = 0.0
                    
                    var frame = view.frame
                    frame.origin.y += 10
                    view.frame = frame;
                }
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    for cell in visibleCells {
                        cell.alpha = 1.0
                        
                        var frame = cell.frame
                        frame.origin.y -= 10
                        cell.frame = frame;
                    }
                    
                    for view in visibleSectionHeaders {
                        view.alpha = 1.0
                        
                        var frame = view.frame
                        frame.origin.y -= 10
                        view.frame = frame;
                    }
                    
                    }, completion: nil)
            }
        }
    }
    
    // MARK:
    // MARK: Support methods
    
    /**
        Get all visible indexes of section header view
     */
    func indexesOfVisibleSectionHeaders() -> [Int] {
        var result = [Int]()
        
        for i in 0...self.numberOfSections {
            var headerRect: CGRect? = nil
            let sectionHeaderView = self.headerView(forSection: i)
            
            if sectionHeaderView != nil {
                if self.style == .plain {
                    headerRect = self.rect(forSection: i)
                } else {
                    headerRect = self.rectForHeader(inSection: i)
                }
                
                let visibleRectOfTableView = CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.bounds.width, height: self.bounds.height)
                
                if visibleRectOfTableView.intersects(headerRect!) {
                    result.append(i)
                }
            }
        }
        
        return result
    }
    
    /**
        Get all visible section header view
    */
    func visbleSectionHeaderViews() -> [UIView] {
        var result = [UIView]()
        
        let visibleSectionIndex = self.indexesOfVisibleSectionHeaders()
        
        for index in visibleSectionIndex {
            let sectionHeader = self.headerView(forSection: index)
            
            if sectionHeader != nil {
                result.append(sectionHeader!)
            }
        }
        
        return result
    }
}
