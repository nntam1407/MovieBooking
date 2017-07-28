//
//  CoreDataHelper+AhachoBusiness.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 5/16/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import Foundation
import CoreData

let kCoreDataEntityStore = "Store"

extension CoreDataHelper {
    
    @nonobjc static let sharedInstance : CoreDataHelper = {
       let instance = CoreDataHelper(modelFileName: kCoreDataModelFileName, modelFileExtension: kCoreDataModelFileExtension, sqlFileName: kCoreDataSQLFileName)
        
        return instance
    }()
    
    // MARK:
    // MARK: Method for Store entity
    // MARK: Methods for category
    
//    func createNewStore() -> Store {
//        let entity = NSEntityDescription.entity(forEntityName: kCoreDataEntityStore, in: self.managedObjectContext!)
//        
//        return Store(entity: entity!, insertInto: self.managedObjectContext!)
//    }
//    
//    func getStore(_ storeId: String) -> Store? {
//        if (storeId.characters.count == 0) {
//            return nil
//        }
//        
//        // Create fetch request
//        let fetchRequest = NSFetchRequest<Store>(entityName: kCoreDataEntityStore)
//        fetchRequest.predicate = NSPredicate(format: "storeId == %@", argumentArray: [storeId])
//        fetchRequest.fetchLimit = 1;
//        
//        // Start fetch
//        let resultArray: [Store]
//        
//        do {
//            resultArray = try self.managedObjectContext!.fetch(fetchRequest)
//        } catch let e as NSError {
//            // Write error to log
//            NSLog(e.debugDescription)
//            
//            resultArray = [Store]()
//        }
//        
//        return resultArray.last
//    }
//    
//    func getAllStores() -> [Store] {
//        var stores = [Store]()
//        
//        // We will fetch list categories from core data
//        let fetchRequest = NSFetchRequest<Store>(entityName: kCoreDataEntityStore)
//        var fetchResult: [Store]
//        
//        do {
//            fetchResult = try self.managedObjectContext!.fetch(fetchRequest)
//        } catch let e as NSError {
//            // Write error to log
//            NSLog(e.debugDescription)
//            
//            fetchResult = [Store]()
//        }
//        
//        // We will collect list user from list fetch result
//        for item in fetchResult {
//            stores.append(item)
//        }
//        
//        return stores
//    }
//    
//    func getAllStore(_ userId: String?) -> [Store] {
//        if userId == nil || (userId != nil && userId!.characters.count == 0) {
//            return [Store]()
//        }
//        
//        // Create fetch request
//        let fetchRequest = NSFetchRequest<Store>(entityName: kCoreDataEntityStore)
//        fetchRequest.predicate = NSPredicate(format: "userId == %@", argumentArray: [userId!])
//        
//        // Start fetch
//        let resultArray: [Store]
//        
//        do {
//            resultArray = try self.managedObjectContext!.fetch(fetchRequest)
//        } catch let e as NSError {
//            // Write error to log
//            NSLog(e.debugDescription)
//            
//            resultArray = [Store]()
//        }
//        
//        return resultArray
//    }
//    
//    func deleteAllStore() {
//        self.clearAllData([kCoreDataEntityStore])
//    }
//    
//    func deleteAllStore(_ userId: String?, saveContext: Bool) {
//        if userId == nil || (userId != nil && userId!.characters.count == 0) {
//            return
//        }
//        
//        // Create fetch request
//        let fetchRequest = NSFetchRequest<Store>(entityName: kCoreDataEntityStore)
//        fetchRequest.predicate = NSPredicate(format: "userId == %@", argumentArray: [userId!])
//        fetchRequest.includesPropertyValues = false
//        
//        // Start fetch
//        let resultArray: [Store]
//        
//        do {
//            resultArray = try self.managedObjectContext!.fetch(fetchRequest)
//        } catch let e as NSError {
//            // Write error to log
//            NSLog(e.debugDescription)
//            
//            resultArray = [Store]()
//        }
//        
//        // Delete all in result array
//        for object in resultArray {
//            self.managedObjectContext!.delete(object)
//        }
//        
//        if saveContext {
//            self.saveContext()
//        }
//    }
}
