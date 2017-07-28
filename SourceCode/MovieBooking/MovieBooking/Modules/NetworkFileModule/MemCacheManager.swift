//
//  MemCacheManager.swift
//  ChatApp
//
//  Created by Tam Nguyen on 2/3/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

let kMemCacheDefaultCountLimit = 100 // 100 items
let kMemCacheDefaultTotalCostLimit = 1024 * 1024 * 100 // 10Mb

class MemCacheManager: NSObject {
    
    // Private mem cache object
    private var memCache: NSCache<AnyObject, UIImage> = NSCache()
    
    var countLimit: Int {
        get {
            return self.memCache.countLimit
        } set {
            self.memCache.countLimit = newValue
        }
    }
    
    var totalCostLimit: Int {
        get {
            return self.memCache.totalCostLimit
        } set {
            self.memCache.totalCostLimit = newValue
        }
    }
    
    var clearWhenAppInBackgroundMode: Bool = true {
        didSet {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            
            if self.clearWhenAppInBackgroundMode {
                NotificationCenter.default.addObserver(self, selector: #selector(MemCacheManager.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            }
        }
    }
    
    // MARK: Init methods
    
    override init() {
        super.init()
        
        // Set default limit and handle events
        self.memCache.countLimit = kMemCacheDefaultCountLimit
        self.memCache.totalCostLimit = kMemCacheDefaultTotalCostLimit
        
        // Default, when app goto backgound we should clear all memcache to reduce memory. Because if in background, app uses too much memory, iOS system can kill app any time
        NotificationCenter.default.addObserver(self, selector: #selector(MemCacheManager.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        // Register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(MemCacheManager.applicationDidReceivedMemoryWarning(_:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    static let sharedInstance : MemCacheManager = {
        let instance = MemCacheManager()
        
        // Can do some code here
        
        return instance
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Public methods
    
    func getCacheImage(_ key: String) -> UIImage? {
        return self.memCache.object(forKey: key as AnyObject)
    }
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4) // 4 is 4 byte per pixel
        self.memCache.setObject(image, forKey: key as AnyObject, cost: cost)
    }
    
    func removeCacheImage(_ key: String) {
        self.memCache.removeObject(forKey: key as AnyObject)
    }
    
    func cleanMemoryCache() {
        self.memCache.removeAllObjects()
    }
    
    // MARK: Handle notification events
    
    @objc func applicationDidReceivedMemoryWarning(_ notif: Notification?) {
        // Clean all memory cache
        self.cleanMemoryCache()
    }
    
    @objc func applicationDidEnterBackground(_ notif: Notification?) {
        self.cleanMemoryCache()
    }
}
