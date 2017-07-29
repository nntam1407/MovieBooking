//
//  NSDictionaryExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/22/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension NSDictionary {
    
    // Convert to Json string
    func toJsonString() -> String? {
        let jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions())
        } catch _ {
            jsonData = nil
        }
        
        if (jsonData == nil) {
            return nil
        } else {
            return NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }
    
    func stringValueForKey(_ key: String) -> String? {
        let rawValue = self[key]
        
        return (rawValue as? String)
    }
    
    /**
     * Return not null String value
     * If value = nil, return ""
     */
    func stringValueNotNull(_ key: String) -> String {
        let rawValue = self.value(forKey: key)
        
        if (rawValue == nil) {
            return ""
        } else {
            if ((rawValue as? String) != nil) {
                return (rawValue! as! String)
            } else {
                return ""
            }
        }
    }
    
    func numberValueNotNull(_ key: String) -> NSNumber {
        let rawValue = self[key]
        
        if (rawValue == nil) {
            return NSNumber(value: 0)
        } else {
            if ((rawValue as? NSNumber) != nil) {
                return (rawValue! as! NSNumber)
            } else {
                return NSNumber(value: 0)
            }
        }
    }
    
    func numberValueForKey(_ key: String, defaultValue: NSNumber?) -> NSNumber? {
        let rawValue = self[key]
        let numberValue = rawValue as? NSNumber
        
        if numberValue == nil {
            return defaultValue
        }
        
        return numberValue
    }
    
    /// Method get intValue from dictionary
    ///
    /// - Parameter key: Key of value in dictionary
    /// - Returns: 0 if does not contain int value with this key
    func intValueForKey(_ key: String) -> Int {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.intValue
        }
        
        return 0
    }
    
    func intValueForKey(_ key: String, defaultValue: Int) -> Int {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.intValue
        }
        
        return defaultValue
    }
    
    func doubleValue(_ key: String) -> Double {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.doubleValue
        } else if let rawValue = self[key] as? String {
            if let doubleValue = Double(rawValue) {
                return doubleValue
            }
        }
        
        return 0.0
    }
    
    func doubleValue(_ key: String, defaultValue: Double) -> Double {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.doubleValue
        } else if let rawValue = self[key] as? String {
            if let doubleValue = Double(rawValue) {
                return doubleValue
            }
        }
        
        return defaultValue
    }
    
    func boolValueForKey(_ key: String) -> Bool {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.boolValue
        }
        
        return false
    }
    
    func boolValueForKey(_ key: String, defaultValue: Bool) -> Bool {
        if let rawValue = self[key] as? NSNumber {
            return rawValue.boolValue
        }
        
        return defaultValue
    }
    
    func dateValueNotNull(_ key: String) -> Date {
        let rawValue = self[key]
        
        if (rawValue == nil) {
            return Date()
        } else {
            if ((rawValue as? Date) != nil) {
                return (rawValue! as! Date)
            } else if (rawValue as? String) != nil {
                let date: Date? = Date.dateFromDotNetTimeString(rawValue as! String)
                
                return date != nil ?  date! : Date()
            } else {
                return Date()
            }
        }
    }
    
    func dateValueNotNull(_ key: String, format: String) -> Date {
        let rawValue = self[key]
        
        if (rawValue == nil) {
            return Date()
        } else {
            if ((rawValue as? Date) != nil) {
                return (rawValue! as! Date)
            } else if (rawValue as? String) != nil {
                let dateFomatter = DateFormatter()
                dateFomatter.dateFormat = format
                let date: Date? = dateFomatter.date(from: rawValue as! String)
                
                return date != nil ?  date! : Date()
            } else {
                return Date()
            }
        }
    }
    
    func dateValueWithEpochTime(_ key: String) -> Date? {
        let numberValue = self.numberValueForKey(key, defaultValue: nil)
        
        if numberValue == nil {
            return nil
        } else {
            return Date(timeIntervalSince1970: numberValue!.doubleValue / 1000.0)
        }
    }
    
    func dictionaryForKey(_ key: String) -> NSDictionary? {
        let rawValue = self[key]
        
        return (rawValue as? NSDictionary)
    }
    
    func arrayForKey(_ key: String) -> NSArray? {
        let rawValue = self[key]
        
        return (rawValue as? NSArray)
    }
}
