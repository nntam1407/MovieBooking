//
//  CustomTextView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 12/17/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

class RichTextView: UITextView {

    private var placeholderLabel: UILabel?
    
    var placeholder: String? {
        didSet {
            self.placeholderLabel?.text = self.placeholder
            self.setNeedsDisplay()
        }
    }
    
    /**
     * Perperties for show custom emoji image icon inside of this text view
     * key: text map with image, ex: :) = smile icon image..
     * value: image name map with that key
     */
    var imageMapDictionary: NSMutableDictionary?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    // MARK: Override methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Register notification
        NotificationCenter.default.addObserver(self, selector: #selector(RichTextView.notificationTextDidChanged(_:)), name:NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func draw(_ rect: CGRect) {
        // Draw place holder text
        if (self.placeholder != nil && (self.placeholder!).characters.count > 0) {
            if (self.placeholderLabel == nil) {
                let linePadding = self.textContainer.lineFragmentPadding
                let placeholderRect = CGRect(x: self.textContainerInset.left + linePadding, y: self.textContainerInset.top, width: rect.size.width - self.textContainerInset.left - self.textContainerInset.right - 2 * linePadding, height: rect.size.height - self.textContainerInset.top - self.textContainerInset.bottom)
                
                self.placeholderLabel = UILabel(frame: placeholderRect)
                self.placeholderLabel!.font = self.font
                self.placeholderLabel!.textAlignment = self.textAlignment
                self.placeholderLabel!.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                self.placeholderLabel!.backgroundColor = UIColor.clear
                self.placeholderLabel!.numberOfLines = 0
                self.placeholderLabel?.lineBreakMode = .byWordWrapping
                self.addSubview(self.placeholderLabel!)
                
                self.placeholderLabel!.text = self.placeholder
                self.placeholderLabel!.sizeToFit()
            }
            
            // Check show or hide placeholder
            self.showOrHidePlaceholder()
        }
        
        // Draw image icon in text
        if (self.imageMapDictionary != nil && self.text.characters.count > 0) {
            for key in self.imageMapDictionary!.allKeys as! [String] {
                let imageName = self.imageMapDictionary![key] as! String
                
                // have to toggle selectable to YES to get _attributedText in UITextView (otherwise it's nil)
                let wasSelectable = self.isSelectable
                self.isSelectable = true
                var searchAttr = self.attributedText
                self.isSelectable = wasSelectable
                
                let finalString = NSMutableAttributedString()
                var range = ((searchAttr?.string)! as NSString).range(of: key)
                
                if (range.location == NSNotFound) {
                    continue
                }
                
                while (true) {
                    let attachment = NSTextAttachment()
                    let image = UIImage(named: imageName)
                    
                    // have to toggle selectable to YES to get NSFont in UITextView (otherwise it's nil)
                    let wasSelectable = self.isSelectable
                    self.isSelectable = true
                    let charAttrs = (searchAttr?.attributes(at: range.location, effectiveRange: nil))! as NSDictionary
                    let attrFont = charAttrs["NSFont"] as! UIFont?
                    let fontHeight = attrFont != nil ? attrFont!.capHeight : self.font!.capHeight
                    
                    let newSize = CGSize(width: image!.size.width * (fontHeight / image!.size.height), height: fontHeight)
                    self.isSelectable = wasSelectable
                    
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                    image!.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                    let newImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    attachment.image = newImage
                    let one = searchAttr?.attributedSubstring(from: NSMakeRange(0, range.location))
                    let two = searchAttr?.attributedSubstring(from: NSMakeRange(range.location + range.length, (searchAttr?.string.characters.count)! - (range.location + range.length)))
                    
                    let imageAttrString = NSAttributedString(attachment: attachment).mutableCopy() as! NSMutableAttributedString
                    
                    finalString.append(one!)
                    finalString.append(imageAttrString)
                    
                    searchAttr = two
                    range = ((searchAttr?.string)! as NSString).range(of: key)
                    
                    if (range.location == NSNotFound) {
                        finalString.append(two!)
                        break
                    }
                }
                
                // Set attribute string
                self.attributedText = finalString
            }
        }
        
        // Call super draw
        super.draw(rect)
    }
    
    override var text: String! {
        get {
            return super.text
        }
        set {
            super.text = newValue
            self.showOrHidePlaceholder()
        }
    }
    
    // MARK: Methods
    
    @objc func notificationTextDidChanged(_ notif: Notification) {
        if (self.placeholder == nil || (self.placeholder!).characters.count == 0) {
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.showOrHidePlaceholder()
        })
    }
    
    private func showOrHidePlaceholder() {
        if ((self.text!).characters.count == 0) {
            self.placeholderLabel?.alpha = 1.0
        } else {
            self.placeholderLabel?.alpha = 0
        }
    }
}
