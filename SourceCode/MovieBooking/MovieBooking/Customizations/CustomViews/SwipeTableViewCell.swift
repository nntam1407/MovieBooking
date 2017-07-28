//
//  SwipeTableViewCell.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 12/5/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

// Defince default value
let kSwipeCellThresholdPositionLeft: CGFloat = 0
let kSwipeCellThresholdPositionRight: CGFloat = 0
let kSwipeCellJumpDistance: CGFloat = 0
let kSwipeCellMaxAnimatedDuration: Double = 0.75

enum SwipeCellDirection: Int {
    case none = 0
    case left = 1
    case right = 2
}

class SwipeTableViewCell: UITableViewCell {
    
    // Main view use for swipe cell
    @IBOutlet weak var swipeView: UIView?
    
    var thresholdPositionLeft = kSwipeCellThresholdPositionLeft
    var thresholdPositionRight = kSwipeCellThresholdPositionRight
    var maxAnimatedDuration = kSwipeCellMaxAnimatedDuration
    var jumpPaddingDistance = kSwipeCellJumpDistance
    
    var enableJumpEffect = false
    var enableSlideToLeft = false
    var enableSlideToRight = false
    
    private var swipeDirection = SwipeCellDirection.none
    private var startTouchPoint = CGPoint.zero
    private var startOriginX: CGFloat = 0
    private var durationTime = kSwipeCellMaxAnimatedDuration

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Create base UI
        self.createBaseUI()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        // Create base UI
        self.createBaseUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Private methods
    
    // Base init UI
    private func createBaseUI() {
        // Create pan gesture to handle slide events
        autoreleasepool { () -> () in
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(SwipeTableViewCell.handlePanGestureEvent(_:)))
            panGesture.maximumNumberOfTouches = 1
            panGesture.cancelsTouchesInView = true
            panGesture.delegate = self
            self.addGestureRecognizer(panGesture)
        }
    }
    
    @objc internal func handlePanGestureEvent(_ panGesture: UIPanGestureRecognizer) {
        // We will handle and process pan gesture in here
        
        if (!self.canSwipeCell() || self.swipeView == nil) {
            return
        }
        
        let currentTouchPoint = panGesture.location(in: self)
        
        if (panGesture.state == UIGestureRecognizerState.began) {
            
            self.startTouchPoint = currentTouchPoint
            self.startOriginX = self.swipeView!.frame.origin.x
            
            // Call method handle
            self.eventBeginSwipe()
            
        } else if (panGesture.state == UIGestureRecognizerState.changed) {
            
            let panAmount = self.startTouchPoint.x - currentTouchPoint.x
            var newOriginX = self.startOriginX - panAmount
            
            // Detect slide UI direction
            if (panAmount < 0 && newOriginX > 0) {
                
                if (!self.enableSlideToRight) {
                    self.swipeDirection = SwipeCellDirection.none
                    return
                }
                
                self.swipeDirection = SwipeCellDirection.right
                
            } else if (panAmount > 0 && newOriginX < 0) {
                
                if (!self.enableSlideToLeft) {
                    self.swipeDirection = SwipeCellDirection.none
                    return
                }
                
                self.swipeDirection = SwipeCellDirection.left
                
            } else {
                self.swipeDirection = SwipeCellDirection.none
            }
            
            // if new origin x is larger than left threshold, set it to left threshold
            if (newOriginX > self.thresholdPositionLeft) {
                newOriginX = self.thresholdPositionLeft
            } else if (newOriginX < -self.thresholdPositionRight) {
                // if new origin x is less than right threshold, set it to right threshold
                newOriginX = -self.thresholdPositionRight
            }
            
            // Slide cell
            var newFrame = self.swipeView!.frame
            newFrame.origin.x = newOriginX
            self.swipeView!.frame = newFrame
            
        } else if (panGesture.state == UIGestureRecognizerState.ended ||
            panGesture.state == UIGestureRecognizerState.cancelled) {
            
                if (self.swipeDirection == SwipeCellDirection.none) {
                    self.swipeToHideView(true)
                } else {
                    self.swipeToShowView(true)
                }
                
        }
    }
    
    private func swipeToShowView(_ animated: Bool) {
        if (!self.canSwipeCell() || self.swipeView == nil) {
            return
        }
        
        var destFrame = self.swipeView!.frame
        var maxPositionX: CGFloat = 0
        
        // Check if current position can show jump effect
        if (self.swipeDirection == SwipeCellDirection.right) {
            maxPositionX = self.thresholdPositionLeft
        } else {
            maxPositionX = -self.thresholdPositionRight
        }
        
        // And calculate animation duration with base on the length view will move
        self.durationTime = fabs(Double((maxPositionX - destFrame.origin.x) / self.frame.size.width)) * self.maxAnimatedDuration
        let hasJumpEffect = ((self.enableJumpEffect && self.swipeView!.frame.origin.x != maxPositionX) ? true : false)
        
        if (animated) {
            if (hasJumpEffect) {
                destFrame.origin.x = maxPositionX + (maxPositionX >= 0 ? self.jumpPaddingDistance : -self.jumpPaddingDistance)
            } else {
                destFrame.origin.x = maxPositionX
            }
            
            UIView.animate(withDuration: self.durationTime,
                delay: 0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    
                    self.swipeView!.frame = destFrame
                    
                }) { (finished) -> Void in
                    
                    if (hasJumpEffect) {
                        UIView.animate(withDuration: 0.1,
                            delay: 0,
                            options: UIViewAnimationOptions(),
                            animations: { () -> Void in
                                
                                destFrame.origin.x = maxPositionX
                                self.swipeView!.frame = destFrame
                                
                            }) { (finished) -> Void in

                        }
                    }
                    
                    if (self.swipeDirection == SwipeCellDirection.left) {
                        self.eventDidSwipeToLeft()
                    } else {
                        self.eventDidSwipeToRight()
                    }
            }
        } else {
            
            destFrame.origin.x = maxPositionX
            self.swipeView!.frame = destFrame
            
            if (self.swipeDirection == SwipeCellDirection.left) {
                self.eventDidSwipeToLeft()
            } else {
                self.eventDidSwipeToRight()
            }
        }
    }
    
    private func swipeToHideView(_ animated: Bool) {
        if (self.swipeView == nil) {
            return
        }
        
        if (animated) {
            let currentFrame = self.swipeView!.frame
            self.durationTime = fabs(Double(currentFrame.origin.x / self.frame.size.width)) * self.maxAnimatedDuration
            
            UIView.animate(withDuration: self.durationTime,
                delay: 0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    
                    self.swipeView!.frame = self.bounds
                    
                }) { (finished) -> Void in
                    
                    self.eventDidSwipeToNormal()
                    
            }
            
        } else {
            self.swipeView!.frame = self.bounds
            self.eventDidSwipeToNormal()
        }
    }
    
    // MARK: Gesture's delegates
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if ((gestureRecognizer as? UILongPressGestureRecognizer) != nil) {
            return false
        } else {
            let cell = gestureRecognizer.view as? SwipeTableViewCell
            
            if (cell != nil && (gestureRecognizer as? UIPanGestureRecognizer) != nil) {
                let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: cell!)
                return fabs(translation.x) > fabs(translation.y) ? true : false
            }
        }
        
        return true
    }
    
    // MARK: Abstract methods, these methods below should be overrided in subclass
    
    internal func canSwipeCell() -> Bool {
        // Should be implemented in subclass
        return true
    }
    
    internal func eventBeginSwipe() {
        // Should implemented in subclass
    }
    
    internal func eventDidSwipeToNormal() {
        // Should implemented in subclass
    }
    
    internal func eventDidSwipeToLeft() {
        // Should implemented in subclass
    }
    
    internal func eventDidSwipeToRight() {
        // Should implemented in subclass
    }
    
    // MARK: Public methods
    
    func swipeCellToLeft(_ animated: Bool) {
        if (self.enableSlideToLeft) {
            self.swipeDirection = SwipeCellDirection.left
            self.swipeToShowView(animated)
        }
    }
    
    func swipeCellToRight(_ animated: Bool) {
        if (self.enableSlideToRight) {
            self.swipeDirection = SwipeCellDirection.right
            self.swipeToShowView(animated)
        }
    }
    
    func swipeCellToNormal(_ animated: Bool) {
        self.swipeDirection = SwipeCellDirection.none
        self.swipeToHideView(animated)
    }
}
