//
//  TaggingLabel.swift
//  
//
//  Created by Tam Nguyen on 7/27/15.
//
//

import UIKit

@objc protocol RichTextLabelDelegate {
    @objc optional func richTextLabelDidTouchOnHashtag(_ label: RichTextLabel, hashtag: String, range: NSRange)
    @objc optional func richTextLabelDidTouchHyperlink(_ label: RichTextLabel, hyperlink: String, range: NSRange)
    @objc optional func richTextLabelDidTouchEmail(_ label: RichTextLabel, email: String, range: NSRange)
    @objc optional func richTextLabelDidTouchClickableText(_ label: RichTextLabel, text: String, range: NSRange)
}

class RichTextLabel: UILabel {
    
    private var hashtagData = [(String, NSRange)]()
    private var hyperlinkData = [(String, NSRange)]()
    private var emailData = [(String, NSRange)]()
    private var clickableTextData = [(String, NSRange)]() // normal text can clickable
    
    /**
        Return all hashtags value after parse input text.
        This is read only propertiy
    */
    var hashtags: [(String, NSRange)] {
        return self.hashtagData
    }
    
    var hashtagTextColor: UIColor? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var hashtagBackgroundColor: UIColor? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var hastagFont: UIFont? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var hyperlinks: [(String, NSRange)] {
        return self.hyperlinkData
    }
    
    var hyperlinkTextColor: UIColor? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var hyperlinkBackgroundColor: UIColor? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var hyperlinkFont: UIFont? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var emails: [(String, NSRange)] {
        return self.hyperlinkData
    }
    
    var emailTextColor: UIColor? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var emailBackgroundColor: UIColor? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var emailFont: UIFont? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    // For clickable text
    var clickableTexts: [(String, NSRange)] {
        set {
            self.clickableTextData = newValue
            
            // Refresh UI
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        } get {
            return self.clickableTextData
        }
    }
    
    var clickableTextColor: UIColor? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var clickableTextBackgroundColor: UIColor? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    var clickableTextFont: UIFont? {
        didSet {
            self.attributedText = self.parseAndCreateAttributeText(self.text)
        }
    }
    
    // Padding insets
    var textInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    // Delegate
    weak var delegate: RichTextLabelDelegate?
    
    // Enable or disbale rich label
    @IBInspectable var disableRichLabelMode: Bool = false

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK: Override methods
    
    override var text: String? {
        get {
            return super.attributedText?.string
        }
        set {
            self.attributedText = self.parseAndCreateAttributeText(newValue)
            
            // Parse text value and create attribute string to display hashtag
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
//                let attrText = self.parseAndCreateAttributeText(newValue)
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.attributedText = attrText
//                })
//            }
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, self.textInsets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        
        contentSize.width += self.textInsets.left + self.textInsets.right
        contentSize.height += self.textInsets.top + self.textInsets.bottom
        
        return contentSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initHashtagLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initHashtagLabel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initHashtagLabel()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if (self.hashtagData.count == 0 && self.emailData.count == 0 && self.hyperlinkData.count == 0 && self.clickableTextData.count == 0) || self.attributedText == nil {
            return false;
        }
        
        // Create textContainer
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: self.bounds.size)
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        if self.text != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.textAlignment
            textStorage.addAttributes([
                    NSParagraphStyleAttributeName: paragraphStyle
                ], range: NSMakeRange(0, self.text!.characters.count))
        }
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        
        /**
            Now we will calculator character at touch point
        */
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        // Calculator text container offset
        var textContainerOffset = CGPoint(x: 0, y: (self.bounds.size.height - textBoundingBox.height) * 0.5 - textBoundingBox.origin.y)
        
        if (self.textAlignment == NSTextAlignment.center) {
            textContainerOffset.x = (self.bounds.size.width - textBoundingBox.width) * 0.5 - textBoundingBox.origin.x;
        } else if (self.textAlignment == NSTextAlignment.right) {
            textContainerOffset.x = self.bounds.size.width - textBoundingBox.width - textBoundingBox.origin.x;
        }
        
        let locationTouchInTextContainer = CGPoint(x: point.x - textContainerOffset.x, y: point.y - textContainerOffset.y)
        
        if (textBoundingBox.contains(locationTouchInTextContainer)) {
            
            // Get character index at touch point
            let indexOfCharacter = layoutManager.characterIndex(for: locationTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            // Now check all range is contain this indexOfCharacter
            for hashtag in self.hashtagData {
                if (NSLocationInRange(indexOfCharacter, hashtag.1)) {
                    
                    return true
                }
            }
            
            // Now check email
            for email in self.emailData {
                if (NSLocationInRange(indexOfCharacter, email.1)) {
                    
                    return true
                }
            }
            
            // Now check hyperlink
            for hyperlink in self.hyperlinks {
                if (NSLocationInRange(indexOfCharacter, hyperlink.1)) {
                    
                    return true
                }
            }
            
            for clickableText in self.clickableTextData {
                if NSLocationInRange(indexOfCharacter, clickableText.1) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: Support methods
    
    private func initHashtagLabel() {
        if (self.hashtagTextColor == nil) {
            self.hashtagTextColor = self.textColor
        }
        
        if (self.hashtagBackgroundColor == nil) {
            self.hashtagBackgroundColor = UIColor.clear
        }
        
        if (self.hastagFont == nil) {
            self.hastagFont = self.font
        }
        
        // Add tap gesture for this label
        self.isUserInteractionEnabled = true;
        
        autoreleasepool { () -> () in
            let gesture = UITapGestureRecognizer(target: self, action: #selector(RichTextLabel.handleTapGesture(_:)))
            gesture.cancelsTouchesInView = true
            self.addGestureRecognizer(gesture)
        }
    }
    
    private func parseAndCreateAttributeText(_ text: String?) -> NSAttributedString? {
        
        if self.disableRichLabelMode {
            if text == nil {
                return nil
            } else {
                return NSAttributedString(string: text!)
            }
        }
        
        // Remove all hashtag data first
        self.hashtagData.removeAll(keepingCapacity: false)
        self.emailData.removeAll(keepingCapacity: false)
        self.hyperlinkData.removeAll(keepingCapacity: false)
        
        if (text != nil) {
            let result = NSMutableAttributedString(string: text!)
            
            // Add default font for whole text
            result.addAttribute(NSFontAttributeName, value: self.font, range: NSMakeRange(0, text!.characters.count))
            
            // Create hashtag attributes
            var textAttrs: [String: Any] = [
                NSFontAttributeName: self.hastagFont == nil ? self.font! : self.hastagFont!,
                NSForegroundColorAttributeName: self.hashtagTextColor == nil ? (self.textColor == nil ? UIColor.black : self.textColor!) : self.hashtagTextColor!,
                NSBackgroundColorAttributeName: self.hashtagBackgroundColor == nil ? UIColor.clear : self.hashtagBackgroundColor!
            ]
            
            // Create hashtag regex
            var regex: NSRegularExpression?
            
            do {
                regex = try NSRegularExpression(pattern: "((?:#){1}[\\w\\d]{1,140})", options: NSRegularExpression.Options.caseInsensitive)
            } catch (_) {
                DLog("Regex error")
            }
            
            regex?.enumerateMatches(in: text!,
                options: NSRegularExpression.MatchingOptions.reportProgress,
                range: NSMakeRange(0, text!.characters.count),
                using: { (checkingResult: NSTextCheckingResult?, matchingFlags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    
                    if (checkingResult == nil) {
                        return;
                    }
                    
                    let matchRange = checkingResult!.rangeAt(0)
                    result.addAttributes(textAttrs, range: matchRange)
                    
                    // Store hashtag text in array
                    let range = text!.rangeFromNSRange(matchRange)
                    self.hashtagData.append((text!.substring(with: range!), matchRange))
            })
            
            /**
                Parse email data
            */
            textAttrs = [
                NSFontAttributeName: self.emailFont == nil ? self.font! : self.emailFont!,
                NSForegroundColorAttributeName: self.emailTextColor == nil ? (self.textColor == nil ? UIColor.black : self.textColor!) : self.emailTextColor!,
                NSBackgroundColorAttributeName: self.emailBackgroundColor == nil ? UIColor.clear : self.emailBackgroundColor!
            ]
            
            // Create hashtag regex
            do {
                regex = try NSRegularExpression(pattern: "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", options: NSRegularExpression.Options.caseInsensitive)
            } catch (_) {
                DLog("Regex error")
            }
            
            regex?.enumerateMatches(in: text!,
                options: NSRegularExpression.MatchingOptions.reportProgress,
                range: NSMakeRange(0, text!.characters.count),
                using: { (checkingResult: NSTextCheckingResult?, matchingFlags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    
                    if (checkingResult == nil) {
                        return;
                    }
                    
                    let matchRange = checkingResult!.rangeAt(0)
                    result.addAttributes(textAttrs, range: matchRange)
                    
                    // Store hashtag text in array
                    let range = text!.rangeFromNSRange(matchRange)
                    self.emailData.append((text!.substring(with: range!), matchRange))
            })
            
            /**
                Parse hyperlink data
            */
            textAttrs = [
                NSFontAttributeName: self.hyperlinkFont == nil ? self.font! : self.hyperlinkFont!,
                NSForegroundColorAttributeName: self.hyperlinkTextColor == nil ? (self.textColor == nil ? UIColor.black : self.textColor!) : self.hyperlinkTextColor!,
                NSBackgroundColorAttributeName: self.hyperlinkBackgroundColor == nil ? UIColor.clear : self.hyperlinkBackgroundColor!
            ]
            
            // Create hashtag regex
            do {
                regex = try NSRegularExpression(pattern: "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+", options: NSRegularExpression.Options.caseInsensitive)
            } catch (_) {
                DLog("Regex error")
            }
            
            regex?.enumerateMatches(in: text!,
                options: NSRegularExpression.MatchingOptions.reportProgress,
                range: NSMakeRange(0, text!.characters.count),
                using: { (checkingResult: NSTextCheckingResult?, matchingFlags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    
                    if (checkingResult == nil) {
                        return;
                    }
                    
                    let matchRange = checkingResult!.rangeAt(0)
                    result.addAttributes(textAttrs, range: matchRange)
                    
                    // Store hashtag text in array
                    let range = text!.rangeFromNSRange(matchRange)
                    self.hyperlinkData.append((text!.substring(with: range!), matchRange))
            })
            
            // Display attribute text for clickable text
            textAttrs = [
                NSFontAttributeName: self.clickableTextFont == nil ? self.font! : self.clickableTextFont!,
                NSForegroundColorAttributeName: self.clickableTextColor == nil ? (self.textColor == nil ? UIColor.black : self.textColor!) : self.clickableTextColor!,
                NSBackgroundColorAttributeName: self.clickableTextBackgroundColor == nil ? UIColor.clear : self.clickableTextBackgroundColor!
            ]
            
            for item in self.clickableTextData {
                result.addAttributes(textAttrs, range: item.1)
            }
            
            // Return final attribute text
            return result
        }
        
        return nil
    }
    
    // MARK: Handle events
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer?) {
        
        if (gesture == nil || (self.hashtagData.count == 0 && self.emailData.count == 0 && self.hyperlinkData.count == 0 && self.clickableTextData.count == 0) || self.attributedText == nil) {
            return;
        }
        
        // Create textContainer
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: self.bounds.size)
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        if self.text != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.textAlignment
            
            textStorage.addAttributes([
                NSParagraphStyleAttributeName: paragraphStyle
                ], range: NSMakeRange(0, self.text!.characters.count))
        }
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        
        /**
            Now we will calculator character at touch point
        */
        let locationTouchOnLabel = gesture!.location(in: gesture!.view)
        let labelSize = gesture!.view!.bounds.size
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        // Calculator text container offset
        var textContainerOffset = CGPoint(x: 0, y: (labelSize.height - textBoundingBox.height) * 0.5 - textBoundingBox.origin.y)
        
        if (self.textAlignment == NSTextAlignment.center) {
            textContainerOffset.x = (labelSize.width - textBoundingBox.width) * 0.5 - textBoundingBox.origin.x;
        } else if (self.textAlignment == NSTextAlignment.right) {
            textContainerOffset.x = labelSize.width - textBoundingBox.width - textBoundingBox.origin.x;
        }

        let locationTouchInTextContainer = CGPoint(x: locationTouchOnLabel.x - textContainerOffset.x, y: locationTouchOnLabel.y - textContainerOffset.y)
        
        if (textBoundingBox.contains(locationTouchInTextContainer)) {
            
            // Get character index at touch point
            let indexOfCharacter = layoutManager.characterIndex(for: locationTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

            // Now check all range is contain this indexOfCharacter
            for hashtag in self.hashtagData {
                if (NSLocationInRange(indexOfCharacter, hashtag.1)) {
                    
                    // Call delegate
                    self.delegate?.richTextLabelDidTouchOnHashtag?(self, hashtag: hashtag.0, range: hashtag.1)
                    
                    return
                }
            }
            
            // Now check email
            for email in self.emailData {
                if (NSLocationInRange(indexOfCharacter, email.1)) {
                    
                    // Call delegate
                    self.delegate?.richTextLabelDidTouchEmail?(self, email: email.0, range: email.1)
                    
                    return
                }
            }
            
            // Now check hyperlink
            for hyperlink in self.hyperlinks {
                if (NSLocationInRange(indexOfCharacter, hyperlink.1)) {
                    
                    // Call delegate
                    self.delegate?.richTextLabelDidTouchHyperlink?(self, hyperlink: hyperlink.0, range: hyperlink.1)
                    
                    return
                }
            }
            
            // Now check click able text
            for clickableText in self.clickableTextData {
                if NSLocationInRange(indexOfCharacter, clickableText.1) {
                    self.delegate?.richTextLabelDidTouchClickableText?(self, text: clickableText.0, range: clickableText.1)
                    
                    return
                }
            }
        }
    }
    
}
