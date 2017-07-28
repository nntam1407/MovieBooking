//
//  Utils.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 9/7/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

class Utils: NSObject {
    // MARK: Util for notifications
    
    class func removeAllNotif(_ targetObject: AnyObject) {
        NotificationCenter.default.removeObserver(targetObject)
    }
    
    class func removeNotif(_ targetObject: AnyObject, name: String, object: AnyObject?) {
        NotificationCenter.default.removeObserver(targetObject, name: Notification.Name(rawValue: name), object: object)
    }
    
    class func regNotif(_ target: AnyObject, selector: Selector, name: String, object: AnyObject?) {
        NotificationCenter.default.addObserver(target, selector: selector, name: Notification.Name(rawValue: name), object: object)
    }
    
    class func notifPost(_ name: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil)
    }
    
    class func notifPost(_ name: String, object: AnyObject?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object)
    }
    
    // MARK: Utils for dispatch
    class func dispatchAfterDelay(_ delay: TimeInterval, queue: DispatchQueue, block: @escaping () -> Void) {
        let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        queue.asyncAfter(deadline: time, execute: block)
    }
    
    // MARK: NSUserDefault helper
    
    class func getFromUserDefault(_ key: String) -> Any? {
        let userDefault = UserDefaults.standard
        return userDefault.value(forKey: key)
    }
    
    class func saveInUserDefault(_ key: String, value: Any?) {
        let userDefault = UserDefaults.standard
        
        // If value = nil, we will delete key, else insert to 
        if (value == nil) {
            userDefault.removeObject(forKey: key)
        } else {
            userDefault.setValue(value, forKey: key)
        }
        
        userDefault.synchronize()
    }
    
    // MARK: Util for Interface Builder
    
    class func loadView(_ viewXIBName: String) -> UIView? {
        var xibs = Bundle.main.loadNibNamed(viewXIBName, owner: nil, options: nil)
        
        if (xibs != nil && xibs!.count > 0) {
            return (xibs![0] as! UIView)
        }
        
        return nil
    }
    
    class func loadViewController(_ controllerName: String, storyBoardName: String?) -> UIViewController? {
        if (storyBoardName == nil) {
            // Try to get from XIB file
            return UIViewController(nibName: controllerName, bundle: nil)
        } else {
            let storyBoard = UIStoryboard(name: storyBoardName!, bundle: nil)
            return (storyBoard.instantiateViewController(withIdentifier: controllerName) as UIViewController?)
        }
    }
    
    // MARK: Other untils
    
    class func uuid() -> String {
        let uuid = UUID()
        return uuid.uuidString.lowercased()
    }
    
    class func shortAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        
        return ""
    }
    
    class func fullAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return version
        }
        
        return ""
    }
}

// MARK: Method without class Utils

func DLog(_ format: String, _ args: CVarArg...) {
    #if DEBUG
        let logMessage = String(format: format, arguments: args)
        NSLog(logMessage)
    #endif
    
    // Do nothing if this is not debug mode
}
