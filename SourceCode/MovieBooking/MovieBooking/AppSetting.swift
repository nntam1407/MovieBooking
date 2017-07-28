//
//  AppSetting.swift
//  AskApp
//
//  Created by Tam Nguyen Ngoc on 9/3/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

class AppSetting: NSObject {
    
    /// Main setting dictionary, we don't need to access alot of key in NSUserDefault. Instead of, just update value in this dictionary, then save all in UserDefault
    private var userSettings = [String: Any]()
    
    var currentCountry: CountryData? {
        get {
            return CountryManager.sharedInstance.currentCountry
        }
        set {
            CountryManager.sharedInstance.currentCountry = newValue
        }
    }
    
    // MARK:
    // MARK: Override methods
    
    override init() {
        super.init()
        
        // Get all previous settings
        self.getAllUserSettings()
    }
    
    // MARK:
    // MARK: Class methods
    
    static let sharedInstance : AppSetting = {
        let instance = AppSetting()
        
        return instance
    } ()
    
    // MARK:
    // MARK: Private methods
    
    private func saveAllUserSettings() {
        Utils.saveInUserDefault("UserSettings", value: self.userSettings)
    }
    
    private func getAllUserSettings() {
        if let settings = Utils.getFromUserDefault("UserSettings") as? [String: Any] {
            self.userSettings = settings
        } else {
            self.userSettings.removeAll()
        }
    }
}
