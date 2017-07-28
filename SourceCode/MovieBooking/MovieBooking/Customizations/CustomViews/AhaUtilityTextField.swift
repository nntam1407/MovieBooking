//
//  AhaUtilityTextField.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 2/3/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import UIKit

extension UITextFieldDelegate {
    func utilityTextFieldDidTouchNextButton(_ textField: AhaUtilityTextField) {
        // Do nothing
    }
    
    func utilityTextFieldDidTouchBackButton(_ textField: AhaUtilityTextField) {
        // Do nothing
    }
}

class AhaUtilityTextField: UITextField {
    
    // Show or don't show toolbar. Default value is don't show
    var enableToolbar: Bool = false {
        didSet {
            if self.enableToolbar {
                self.initToolbar()
            } else {
                self.removeToolbar()
            }
        }
    }
    
    private var toolbar: UIToolbar?
    
    // Set up tool bar items. Default have 1 bar button is Done
    var toolbarItems: [UIBarButtonItem]? = nil {
        didSet {
            if self.toolbar != nil {
                self.toolbar?.items = self.toolbarItems
            }
        }
    }
    
    // Private done bar button item
    private var _doneBarItem: UIBarButtonItem?
    
    /**
     * If we don't enable toolbar, done button will be nil
     * You can set target and action manually for this button. But default it will call resignFirstResponder and call delegate textFieldShouldReturn
     */
    var doneBarItem: UIBarButtonItem? {
        get {
            return _doneBarItem
        } set {
            // Do nothing
        }
    }
    
    /**
     * If this been enabled, we will display next and back button on tool bar
     */
    var enableNextBackBarButtons: Bool = false {
        didSet {
            if self.enableNextBackBarButtons && self.nextButtonItem == nil && self.backButtonItem == nil {
                self.enableToolbar = true
                
                self.backButtonItem = UIBarButtonItem(image: UIImage(named: "ico_back"), style: .plain, target: self, action: #selector(AhaUtilityTextField.didTouchBackButton))
                self.backButtonItem!.width = 30
                self.backButtonItem!.tintColor = UIColor.colorFromHexValue(kDefaultButtonTintColor)
                
                self.nextButtonItem = UIBarButtonItem(image: UIImage(named: "ico_next"), style: .plain, target: self, action: #selector(AhaUtilityTextField.didTouchNextButton))
                self.nextButtonItem!.width = 30
                self.nextButtonItem!.tintColor = UIColor.colorFromHexValue(kDefaultButtonTintColor)
                
                let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
                if self.toolbarItems == nil {
                    self.toolbarItems = []
                }

                self.toolbarItems!.insert(flexibleItem, at: 0)
                self.toolbarItems!.insert(self.nextButtonItem!, at: 0)
                self.toolbarItems!.insert(self.backButtonItem!, at: 0)
                
                // Set to toolbar
                self.toolbar!.items = self.toolbarItems
            }
        }
    }
    
    private var nextButtonItem: UIBarButtonItem?
    private var backButtonItem: UIBarButtonItem?

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    deinit {
        DLog("Utility textfield dealloc")
    }

    // MARK: Support methods
    
    private func initToolbar() {
        if self.toolbar == nil {
            self.toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 44))
            self.toolbar!.barStyle = .default
            self.inputAccessoryView = self.toolbar
            self.toolbar!.backgroundColor = UIColor.white
            
            self.toolbar!.layer.shadowOpacity = 0.3
            self.toolbar!.layer.shadowRadius = 2.0
            self.toolbar!.layer.shadowColor = UIColor.black.cgColor
            self.toolbar!.layer.shadowOffset = CGSize(width: 0, height: -1.0)
            
            // Create default done button
            self._doneBarItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button title"), style: .plain, target: self, action: #selector(AhaUtilityTextField.didTouchDoneBarButton(_:)))
            self._doneBarItem!.tintColor = UIColor.colorFromHexValue(kDefaultButtonTintColor)
            
            // Create flexible item to push done button to right side
            let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            // Should display toolbar items if have set before
            if self.toolbarItems != nil {
                self.toolbarItems!.append(flexibleItem)
                self.toolbarItems!.append(self._doneBarItem!)
            } else {
                self.toolbarItems = [flexibleItem, self._doneBarItem!];
            }
            
            self.toolbar!.items = self.toolbarItems
        }
    }
    
    private func removeToolbar() {
        if self.inputAccessoryView == self.toolbar {
            self.toolbar?.removeFromSuperview()
            self.toolbar = nil;
            self.inputAccessoryView = nil;
        }
    }
    
    // MARK: Handle events
    
    @objc func didTouchDoneBarButton(_ doneButton: UIBarButtonItem) {
        if self.delegate != nil && self.delegate!.responds(to: #selector(UITextFieldDelegate.textFieldShouldReturn(_:))) {
            if self.delegate!.textFieldShouldReturn!(self) {
                self.resignFirstResponder()
            }
        } else {
            self.resignFirstResponder()
        }
    }
    
    @objc func didTouchNextButton() {
        self.delegate?.utilityTextFieldDidTouchNextButton(self)
    }
    
    @objc func didTouchBackButton() {
        self.delegate?.utilityTextFieldDidTouchBackButton(self)
    }
}
