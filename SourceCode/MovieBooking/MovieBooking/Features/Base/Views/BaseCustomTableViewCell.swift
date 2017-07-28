//
//  AhaBaseCustomTableViewCell.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 6/1/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import UIKit

class BaseCustomTableViewCell: UITableViewCell {

    private var alreadyRegisteredUpdateLocalizedTextNotif = false
    
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
    
    func updateAllLocalizedText() {
        // Should override in subclass
    }

}
