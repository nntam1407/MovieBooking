//
//  UIViewExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/22/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation
import UIKit

var objc_association_popupIsVisibleKey: UInt8 = 0
var objc_association_popupOverlayViewKey: UInt8 = 1

extension UIView {
    
    func startFadeIn(_ duration: Double, minOpacity: CGFloat, maxOpacity: CGFloat) {
        self.alpha = minOpacity
        
        UIView.animate(withDuration: duration) { () -> Void in
            self.alpha = maxOpacity
        }
    }
    
    func startFadeReverseEffect(_ minOpacity : Double, maxOpacity: Double, durationTime: Double) {
        // First remove previous effect layer
        self.stopFadeReverseEffect()
        
        // Create new CABasicAnimation then add to layer
        let effectAnimation = CABasicAnimation(keyPath: "opacity")
        effectAnimation.duration = durationTime as CFTimeInterval
        effectAnimation.autoreverses = true
        effectAnimation.fromValue = NSNumber(value: minOpacity)
        effectAnimation.toValue = NSNumber(value: maxOpacity)
        effectAnimation.repeatCount = HUGE
        effectAnimation.fillMode = kCAFillModeBoth
        
        self.layer.add(effectAnimation, forKey: "FadeReverseAnimation")
    }
    
    func stopFadeReverseEffect() {
        self.layer.removeAnimation(forKey: "FadeReverseAnimation")
    }
    
    func layerCircle(_ maskToBound: Bool) {
        weak var weakSelf = self
        
        DispatchQueue.main.async {
            if weakSelf != nil {
                weakSelf!.layer.cornerRadius = weakSelf!.frame.size.width/2.0
                weakSelf!.layer.masksToBounds = maskToBound
            }
        }
    }
    
    func layerBorder(_ width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    // MARK: Popup extension methods
    
    // Addition properties for show popup
    private var isShowAsPopupVisiable: Bool {
        get {
            let value: Any? = objc_getAssociatedObject(self, &objc_association_popupIsVisibleKey)
            
            if (value == nil) {
                return false
            } else {
                return (value! as AnyObject).boolValue
            }
        }
        set (value) {
            // Set assoicated to popupIsVisibleKey key
            objc_setAssociatedObject(self, &objc_association_popupIsVisibleKey, NSNumber(value: value), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var showAsPopupOverlayView: UIView? {
        get {
            let value = objc_getAssociatedObject(self, &objc_association_popupOverlayViewKey) as! UIView?
            return value
        }
        set {
            objc_setAssociatedObject(self, &objc_association_popupOverlayViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    func showAsPopup(_ mainViewOpacity: Float, overlayOpacity: Float) {
        // First try to get top windows
        var topWindow: UIWindow? = nil
        let windows = Array(UIApplication.shared.windows.reversed()) as [UIWindow]
        
        for window: UIWindow in windows {
            if (window.windowLevel == UIWindowLevelNormal && !window.isHidden) {
                topWindow = window
                
                break
            }
        }
        
        if (topWindow == nil || UIDevice.current.userInterfaceIdiom == .pad) {
            topWindow = UIApplication.shared.keyWindow!
        }
        
        // Now we will try to show this will on windows
        if (self.isShowAsPopupVisiable) {
            return
        }
        
        self.isShowAsPopupVisiable = true
        
        // Init overlay view
        if (self.showAsPopupOverlayView == nil) {
            self.showAsPopupOverlayView = UIView(frame: topWindow!.bounds)
            self.showAsPopupOverlayView!.backgroundColor = UIColor.black
            self.showAsPopupOverlayView!.layer.opacity = 0
        }
        
        // Show on top window
        topWindow!.addSubview(self.showAsPopupOverlayView!)
        topWindow!.addSubview(self)
        self.center = CGPoint(x: topWindow!.bounds.size.width/2, y: topWindow!.bounds.size.height/2)
        
        self.layer.opacity = 0
        self.showAsPopupOverlayView!.layer.opacity = 0
        
        // Start fade animated
        UIView.animate(withDuration: 0.4,
            delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.layer.opacity = mainViewOpacity
                self.showAsPopupOverlayView!.layer.opacity = overlayOpacity
            })
            { (finished) -> Void in
                
        }
        
        // Zoom in out effect
        self.transform = CGAffineTransform.identity.scaledBy(x: 0.94, y: 0.94)
        UIView.animate(withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            })
            { (finished) -> Void in
                
        }
    }
    
    func hidePopup(_ animated: Bool) {
        self.isShowAsPopupVisiable = false
        
        if (self.superview != nil) {
            if animated {
                UIView.animate(withDuration: 0.3,
                    delay: 0.0,
                    options: UIViewAnimationOptions(),
                    animations: { () -> Void in
                        self.layer.opacity = 0
                        
                        if (self.showAsPopupOverlayView != nil) {
                            self.showAsPopupOverlayView!.layer.opacity = 0
                        }
                    })
                    { (finished) -> Void in
                        if finished {
                            self.removeFromSuperview()
                            
                            if (self.showAsPopupOverlayView != nil) {
                                self.showAsPopupOverlayView!.removeFromSuperview()
                            }
                        }
                }
            } else {
                self.removeFromSuperview()
                
                if (self.showAsPopupOverlayView != nil) {
                    self.showAsPopupOverlayView!.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: End popup extension methods
    
    // MARK: Methods support for snapshot view
    func takeSnapshotImage() -> UIImage {
        // Draw view in rect
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        // We can use this methods
        //        self.drawViewHierarchyInRect(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), afterScreenUpdates: true)
        
        let fullImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return fullImage!
    }
    
    func takeSnapshotImage(_ rect: CGRect) -> UIImage {
        let fullImage = self.takeSnapshotImage()
    
        // Now we will crop full image to get dest rect
        return fullImage.cropImage(rect)
    }
    
    // MARK: Extension for rotate
    func rotateView(_ degree: CGFloat, anchorPoint: CGPoint, animated: Bool, duration: Double) {
        if degree == 0 {
            if animated {
                UIView.animate(withDuration: duration,
                                           delay: 0,
                                           options: UIViewAnimationOptions(),
                                           animations: { () -> Void in
                                            self.transform = CGAffineTransform.identity
                    }, completion: { (finished) -> Void in
                })
            } else {
                self.transform = CGAffineTransform.identity
            }
        } else {
            // Calculate radians value
            let radian = degree / 180.0 * CGFloat(Double.pi)
            self.layer.anchorPoint = anchorPoint
            
            if (animated) {
                UIView.animate(withDuration: duration,
                                           delay: 0,
                                           options: UIViewAnimationOptions(),
                                           animations: { () -> Void in
                                            self.transform = self.transform.rotated(by: radian)
                    }, completion: { (finished) -> Void in
                })
            } else {
                self.transform = self.transform.rotated(by: radian)
            }
        }
    }
    
    // MARK: Function support for animation view
    
    func startRotateAnimation(_ duration: CFTimeInterval, repeatCount: Float) {
        let linearCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0;
        animation.toValue = NSNumber(value: Double.pi*2)
        animation.duration = duration;
        animation.timingFunction = linearCurve;
        animation.isRemovedOnCompletion = false;
        animation.repeatCount = repeatCount;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = false;
    
        self.layer.add(animation, forKey: "View.RotateAnimation")
    }
    
    func stopRotateAnimation() {
        self.layer.removeAnimation(forKey: "View.RotateAnimation")
    }
}
