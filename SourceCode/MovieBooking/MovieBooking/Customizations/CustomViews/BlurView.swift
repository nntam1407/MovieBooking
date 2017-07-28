//
//  BlurView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/4/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

let kUIVisualEffectViewClassName = "UIVisualEffectView"

@available(iOS 8.0, *)
class BlurView: UIView {
    
    private var toolBar: UIToolbar? // Trick code for iOS 7
    private var visualEffectView: UIVisualEffectView? // Only for iOS >= 8

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK: Override methods
    
    init () {
        super.init(frame: CGRect.zero)
        self.createBaseUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createBaseUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createBaseUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.createBaseUI()
    }
    
    override var tintColor: UIColor! {
        get {
            if (NSClassFromString(kUIVisualEffectViewClassName) == nil) {
                return self.toolBar != nil ? self.toolBar!.barTintColor : super.tintColor
            } else {
                return self.visualEffectView != nil ? self.visualEffectView!.tintColor : super.tintColor
            }
        }
        set {
            if (NSClassFromString(kUIVisualEffectViewClassName) == nil) {
                if (self.toolBar == nil) {
                    super.tintColor = newValue
                } else {
                    self.toolBar!.barTintColor = newValue
                }
            } else {
                if (self.visualEffectView == nil) {
                    super.tintColor = newValue
                } else {
                    self.visualEffectView!.tintColor = newValue
                }
            }
        }
    }
    
    // MARK: Private methods
    
    private func createBaseUI() {
        self.backgroundColor = UIColor.clear
        
        if (NSClassFromString(kUIVisualEffectViewClassName) == nil) {
            // For iOS 7, does not support UIVisualEffectView

            if (self.toolBar == nil) {
                self.toolBar = UIToolbar(frame: self.bounds)
                self.toolBar!.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
                self.toolBar!.barStyle = UIBarStyle.black
                
                // Add toolbar layer as sublayer
                self.insertSubview(self.toolBar!, at: 0)
            }
        } else {
            // Support UIVisualEffectView, >= iOS 8
            
            if (self.visualEffectView == nil) {
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
                self.visualEffectView = UIVisualEffectView(effect: blurEffect)
                self.visualEffectView!.frame = self.bounds
                self.visualEffectView!.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
                
                // Add visule effect view to view
                self.insertSubview(self.visualEffectView!, at: 0)
            }
        }
    }

}
