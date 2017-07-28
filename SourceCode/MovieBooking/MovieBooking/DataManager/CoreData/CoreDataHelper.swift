//
//  CoreDataHelper.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 10/5/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    private var modelFileName: String?
    private var modelFileExtension: String?
    private var sqlFileName: String?
    
    required init(modelFileName: String, modelFileExtension: String, sqlFileName: String) {
        super.init()
        
        self.modelFileName = modelFileName
        self.modelFileExtension = modelFileExtension
        self.sqlFileName = sqlFileName
    }
   
    // MARK: Private properties
    
    // Using lazy mask for
    private lazy var manageObjectModel: NSManagedObjectModel = {
        let modelURL: URL = Bundle.main.url(forResource: self.modelFileName!, withExtension: self.modelFileExtension!)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    } ()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.manageObjectModel)
        
        // Try to create persistentStore
        let url = FileUtils.applicationDocumentDirectory().appendingPathComponent(self.sqlFileName!);
        var error: NSError? = nil
        
        do {
            try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            
            // Report any error we got.
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "Ahacho", code: 999, userInfo: dict)
            
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
        } catch {
            fatalError()
        }
        
        return coordinator
    } ()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        
        if coordinator == nil {
            return nil
        }

        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    } ()
    
    func saveContext() {
        if self.managedObjectContext != nil && self.managedObjectContext!.hasChanges {
            do {
                try self.managedObjectContext!.save()
            } catch let error as NSError {
                NSLog("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func clearAllData(_ entityNames: [String]) {
        for entityName in entityNames {
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
            fetchRequest.includesPropertyValues = false // We don't fetch properties values for reduce memory
            
            // Start fetch
            let resultArray: [NSManagedObject]
            
            do {
                resultArray = try self.managedObjectContext!.fetch(fetchRequest)
            } catch _ {
                resultArray = [NSManagedObject]()
            }
            
            for object in resultArray {
                self.managedObjectContext!.delete(object)
            }
        }
        
        // Finally, save context
        self.saveContext()
    }
    
    func deleteObject(_ object: NSManagedObject, saveImmediately: Bool) {
        self.managedObjectContext!.delete(object)
        
        if (saveImmediately) {
            self.saveContext()
        }
    }
}
