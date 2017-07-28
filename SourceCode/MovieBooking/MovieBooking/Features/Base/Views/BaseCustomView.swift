//
//  AhaBaseCustomView.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 4/23/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import UIKit

class BaseCustomView: UIView {
    
    private var alreadyRegisteredUpdateLocalizedTextNotif = false

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Sould update localized text for first time
        self.updateAllLocalizedText()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        Utils.removeNotif(self, name: kNotificationUpdateLocalizedText, object: nil)
        self.alreadyRegisteredUpdateLocalizedTextNotif = false
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if self.superview != nil && !self.alreadyRegisteredUpdateLocalizedTextNotif {
            // Register other notifications
            Utils.regNotif(self, selector: #selector(BaseCustomView.updateAllLocalizedText), name: kNotificationUpdateLocalizedText, object: nil)
            self.alreadyRegisteredUpdateLocalizedTextNotif = true
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        Utils.removeNotif(self, name: kNotificationUpdateLocalizedText, object: nil)
        self.alreadyRegisteredUpdateLocalizedTextNotif = false
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.superview != nil && !self.alreadyRegisteredUpdateLocalizedTextNotif {
            // Register other notifications
            Utils.regNotif(self, selector: #selector(BaseCustomView.updateAllLocalizedText), name: kNotificationUpdateLocalizedText, object: nil)
            self.alreadyRegisteredUpdateLocalizedTextNotif = true
        }
    }
    
    deinit {
        DLog("Custom view dealloc!")
    }
    
    // MARK: Methods
    
    @objc func updateAllLocalizedText() {
        // Should override in subclass
    }

}
