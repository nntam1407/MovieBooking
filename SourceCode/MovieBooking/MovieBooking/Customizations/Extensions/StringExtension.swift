//
//  StringExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/22/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

extension String {
    
    func hashMD5() -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        
        // Convert to hex string
        var hexString = ""
        
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func toJsonObject() -> NSDictionary? {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        if (data == nil) {
            return nil
        }
        
        // Convert data to NSDictionary
        var error: NSError?
        
        let result: Any?
        do {
            result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
        } catch let error1 as NSError {
            error = error1
            result = nil
        }
        
        if (error != nil) {
            return nil
        } else {
            return (result as! NSDictionary)
        }
    }
    
    // Method check is valid email address
    
    func isValidEmailAddress() -> Bool {
        let regex: NSRegularExpression?
        
        do {
            regex = try NSRegularExpression(pattern: "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
                        options: .caseInsensitive)
        } catch _ {
            regex = nil
        }
        
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    func isValidPhoneNumber() -> Bool {
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: "^((((\\+)|(00))[0-9]{6,14})|([0-9]{6,14}))",
                options: .caseInsensitive)
        } catch _ {
            regex = nil
        }
        
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    func textSize(_ font: UIFont, maxWidth: CGFloat) -> CGSize {
        
        let limitSize = CGSize(width: maxWidth, height: CGFloat(MAXFLOAT))
        let  attributes = [NSFontAttributeName: font]
        
        var frame = (self as NSString).boundingRect(with: limitSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        frame.size.height = ceil(frame.size.height)
        frame.size.width = ceil(frame.size.width)
        
        if (frame.size.width > maxWidth) {
            frame.size.width = maxWidth
        }
        
        return frame.size
    }
    
    func textSize(_ font: UIFont, maxHeight: CGFloat) -> CGSize {
        
        let limitSize = CGSize(width: CGFloat(MAXFLOAT), height: maxHeight)
        let  attributes = [NSFontAttributeName:font]
        
        var frame = (self as NSString).boundingRect(with: limitSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        frame.size.height = ceil(frame.size.height)
        frame.size.width = ceil(frame.size.width)
        
        if (frame.size.height > maxHeight) {
            frame.size.height = maxHeight
        }
        
        return frame.size
    }
    
    func nsRangeFromRange(_ range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = range.lowerBound.samePosition(in: utf16view)
        let to = range.upperBound.samePosition(in: utf16view)
        return NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from),
                           utf16view.distance(from: from, to: to))
    }
    
    func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advanced(by: nsRange.location)
        let to16 = from16.advanced(by: nsRange.length)
        
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
            return from ..< to
        }
        return nil
    }
}
