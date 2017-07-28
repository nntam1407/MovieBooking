//
//  NotificationBarView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/2/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

typealias notificationBarViewBlock = () -> Void

let kNotificationBarViewAnimatedDuration: Double = 0.3
let kNotificationBarViewAutoHideDelay: Double = 7 // 7 seconds

enum NotificationBarDragDirection: Int {
    case none = 0
    case up = 1
    case down = 2
}

class NotificationBarView: UIView, UIGestureRecognizerDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var avatarImageView: TextAvatarImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    
    // Properties
    private var callbackBlock: notificationBarViewBlock?
    private var timer: Timer?
    
    // Properties for drag and swipe up and down
    var startOriginY: CGFloat = 0
    var startPoint: CGPoint = CGPoint.zero
    var dragDirection: NotificationBarDragDirection = .none
    var isDragging = false
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mainView.layer.cornerRadius = 4.0
        self.mainView.layer.shadowColor = UIColor.black.cgColor
        self.mainView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.mainView.layer.shadowRadius = 2.5
        self.mainView.layer.shadowOpacity = 0.3
        
        self.avatarImageView.layerCircle(false)
        self.avatarImageView.font = UIFont.systemFont(ofSize: 24)
        self.bottomLineView.layer.cornerRadius = 2.5
        
        // Add gesture
        autoreleasepool { () -> () in
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(NotificationBarView.handlePanGesture(gesture:)))
            panGesture.cancelsTouchesInView = true
            panGesture.delegate = self
            self.addGestureRecognizer(panGesture)
            
//            let swipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
//            swipeGesture.cancelsTouchesInView = true
//            swipeGesture.direction = UISwipeGestureRecognizerDirection.Up
//            self.addGestureRecognizer(swipeGesture)
        }
    }
    
    // MARK:
    // MARK: Class's methods
    
    static let sharedInstance: NotificationBarView = {
        let instance = Utils.loadView("NotificationBarView") as! NotificationBarView
        
        // Setup some code here
        
        // Return
        return instance
    }()
    
    // Gesture's delegates
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UILongPressGestureRecognizer) {
            return false
        } else if (gestureRecognizer is UIPanGestureRecognizer) {
            // We only process drag up and down
            let panGesture = gestureRecognizer as! UIPanGestureRecognizer
            let translation = panGesture.translation(in: self.superview)
            
            return fabs(translation.x) < fabs(translation.y)
        }
        
        return true
    }
    
    // MARK: Handle events
    
    @IBAction func didTouchOnNotificationBar(sender: AnyObject) {
        // Hide this bar view
        self.hideNotificationBar(animated: true)
        
        if (self.callbackBlock != nil) {
            self.callbackBlock!()
        }
    }
    
    func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
        }
        
        self.callbackBlock = nil
        
        // Hide this view
        self.hideNotificationBar(animated: true)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let currentTouchPoint = gesture.location(in: self.superview)
        
        if (gesture.state == UIGestureRecognizerState.began) {
            self.startPoint = currentTouchPoint
            self.startOriginY = self.frame.origin.y
            self.isDragging = true
            self.dragDirection = NotificationBarDragDirection.none
            
            if (self.timer != nil) {
                self.timer!.invalidate()
                self.timer = nil
            }
        } else if (gesture.state == UIGestureRecognizerState.changed) {
            
            let panAmount = self.startPoint.y - currentTouchPoint.y
            var newOriginY = self.startOriginY - panAmount
            
            // Detect direction
            let velocity = gesture.velocity(in: gesture.view)
            let isVerticalDragging = fabs(velocity.y) > fabs(velocity.x)
            
            if (isVerticalDragging) {
                if (velocity.y > 0) {
                    self.dragDirection = NotificationBarDragDirection.down
                } else {
                    self.dragDirection = NotificationBarDragDirection.up
                }
            }
            
            if (newOriginY > 0) {
                newOriginY = 0
            } else if (newOriginY < -self.frame.size.height) {
                newOriginY = -self.frame.size.height
            }
            
            // Drag view
            var frame = self.frame
            frame.origin.y = newOriginY
            self.frame = frame
            
        } else if (gesture.state == UIGestureRecognizerState.ended || gesture.state == UIGestureRecognizerState.cancelled) {
            self.isDragging = false
            
            // Hanlde auto slide after user release their finger
            if (self.dragDirection == NotificationBarDragDirection.up) {
                if (self.timer != nil) {
                    self.timer!.invalidate()
                    self.timer = nil
                }

                self.callbackBlock = nil
                
                // Hide this bar
                self.hideNotificationBar(animated: true)
            } else {
                self.showNotificationBar(animated: true)
            }
        }
    }
    
    // MARK: Public methods
    
    func setCallbackBlock(block: notificationBarViewBlock?) {
        self.callbackBlock = block
    }
    
    func showNotificationBar(message: String, animated: Bool) {
        // Set notification info
        self.contentLabel.text = message
        self.avatarImageView.image = UIImage(named: "app_icon_60")
        
        // Show notification bar
        self.showNotificationBar(animated: animated)
    }
    
    private func showNotificationBar(animated: Bool) {
        if (self.isDragging) {
            return
        }
        
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
        }
        
        if (self.superview == nil) {
            // We will show it on top windows
            let topWindow = APP_DELEGATE.window
            topWindow!.addSubview(self)
            
            var frame = self.frame
            frame.origin.y = -frame.size.height
            frame.size.width = topWindow!.bounds.size.width
            self.frame = frame
        }
        
        // Calculate destination frame, then run animation
        var desFrame = self.frame
        desFrame.origin.y = 0
        
        // Show this view
        self.isHidden = false
        
        if (animated) {
            UIView.animate(withDuration: kNotificationBarViewAnimatedDuration, delay: 0.0, options: .curveEaseInOut, animations: { 
                self.frame = desFrame
            }, completion: { (finished) in
                // Auto hide this view after 5 second
                if (self.timer != nil) {
                    self.timer!.invalidate()
                    self.timer = nil
                }
                
                // Start new timer
                self.timer = Timer.scheduledTimer(timeInterval: kNotificationBarViewAutoHideDelay, target: self, selector: #selector(NotificationBarView.timerTicked), userInfo: nil, repeats: false)
            })
        } else {
            self.frame = desFrame
            
            // Auto hide this view after 5 second
            if (self.timer != nil) {
                self.timer!.invalidate()
                self.timer = nil
            }
            
            // Start new timer
            self.timer = Timer.scheduledTimer(timeInterval: kNotificationBarViewAutoHideDelay, target: self, selector: #selector(NotificationBarView.timerTicked), userInfo: nil, repeats: false)
        }
    }
    
    func hideNotificationBar(animated: Bool) {
        if (self.superview == nil || self.isDragging) {
            return
        }
        
        // Calculate destination frame, then run animation
        var desFrame = self.frame
        desFrame.origin.y = -desFrame.size.height
        
        if (animated) {
            UIView.animate(withDuration: kNotificationBarViewAnimatedDuration, delay: 0.0, options: .curveEaseInOut, animations: {
                self.frame = desFrame
            }, completion: { (finished) in
                self.isHidden = true
            })
        } else {
            self.frame = desFrame
            self.isHidden = true
        }
    }
    
    // Methods call for timer
    @objc func timerTicked() {
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
        }
        
        // Auto hide navigation bar
        self.hideNotificationBar(animated: true)
    }
}
