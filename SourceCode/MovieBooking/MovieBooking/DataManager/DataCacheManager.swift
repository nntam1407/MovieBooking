//
//  DataCacheManager.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

// MARK: Define for core data

let kCoreDataSQLFileName = "moviebooking.sqlite"
let kCoreDataModelFileName = "moviebooking"
let kCoreDataModelFileExtension = "momd"

class DataCacheManager: NSObject {
    
    internal var coreDataHelper: CoreDataHelper?
    
    // MARK:
    // MARK: Override methods
    
    override init() {
        super.init()
        
        // Init coreDataHelper
        self.coreDataHelper = CoreDataHelper(modelFileName: kCoreDataModelFileName,
                                             modelFileExtension: kCoreDataModelFileExtension,
                                             sqlFileName: kCoreDataSQLFileName)
    }
    
    // MARK:
    // MARK: Static methods
    
    static let sharedInstance: DataCacheManager = {
        let instance = DataCacheManager()
        
        // Setup some code here
        
        // Return
        return instance
    }()
    
    // MARK:
    // MARK: Management methods
    
    func saveAllData() {
        // Save core data
        self.coreDataHelper?.saveContext()
    }
}
