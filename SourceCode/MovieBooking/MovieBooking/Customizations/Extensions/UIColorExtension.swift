//
//  UIColorExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 12/17/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

var UIColorNSCache: NSCache<AnyObject, AnyObject>?

extension UIColor {
    class func colorFromHexValue(_ hexValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)((hexValue & 0xFF)))/255.0, alpha: 1.0)
    }
    
    class func colorFromHexValue(_ hexValue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)((hexValue & 0xFF)))/255.0, alpha: alpha)
    }
    
    class func colorFromHexValue(_ hexValue: Int, cache: Bool) -> UIColor {
        // Try to get from cache first, with hexValue is key
        var color = UIColorNSCache?.object(forKey: ("\(hexValue)" as AnyObject)) as? UIColor
        
        if (color != nil) {
            
        } else {
            color = UIColor.colorFromHexValue(hexValue)
            
            if (cache) {
                if (UIColorNSCache == nil) {
                    UIColorNSCache = NSCache()
                    UIColorNSCache!.countLimit = 100 // Only cache 100 color to reduce memory
                }
                
                UIColorNSCache!.setObject(color!, forKey: ("\(hexValue)" as AnyObject))
            }
        }
        
        return color!
    }
    
    var hexString: String {
        let colorRef = self.cgColor.components
        
        let r:CGFloat = colorRef![0]
        let g:CGFloat = colorRef![1]
        let b:CGFloat = colorRef![2]
        
        return NSString(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255))) as String
    }
}
