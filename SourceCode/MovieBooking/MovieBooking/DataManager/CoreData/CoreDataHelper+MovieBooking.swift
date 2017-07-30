//
//  CoreDataHelper+AhachoBusiness.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 5/16/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import Foundation
import CoreData

let kCoreDataEntityMovie = "Movie"
let kCoreDataEntityFavoriteMovie = "FavoriteMovie"

extension CoreDataHelper {
    
    @nonobjc static let sharedInstance : CoreDataHelper = {
       let instance = CoreDataHelper(modelFileName: kCoreDataModelFileName, modelFileExtension: kCoreDataModelFileExtension, sqlFileName: kCoreDataSQLFileName)
        
        return instance
    }()
    
    // MARK:
    // MARK: Method for Movie entity
    
    func createNewMovie() -> Movie {
        let entity = NSEntityDescription.entity(forEntityName: kCoreDataEntityMovie, in: self.managedObjectContext!)
        
        return Movie(entity: entity!, insertInto: self.managedObjectContext!)
    }
    
    func getMovie(_ movieId: Int) -> Movie? {
        if (movieId <= 0) {
            return nil
        }
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<Movie>(entityName: kCoreDataEntityMovie)
        fetchRequest.predicate = NSPredicate(format: "movieId == %d", argumentArray: [movieId])
        fetchRequest.fetchLimit = 1;
        
        // Start fetch
        var resultArray: [Movie]?
        
        do {
            resultArray = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let e as NSError {
            // Write error to log
            NSLog(e.debugDescription)
        }
        
        return resultArray?.last
    }
    
    // MARK:
    // MARK: Methods for FavoriteMovie
    
    func createFavoriteMovie() -> FavoriteMovie {
        let entity = NSEntityDescription.entity(forEntityName: kCoreDataEntityFavoriteMovie, in: self.managedObjectContext!)
        
        return FavoriteMovie(entity: entity!, insertInto: self.managedObjectContext!)
    }
    
    func getFavoriteMovie(_ movieId: Int) -> FavoriteMovie? {
        if (movieId <= 0) {
            return nil
        }
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<FavoriteMovie>(entityName: kCoreDataEntityFavoriteMovie)
        fetchRequest.predicate = NSPredicate(format: "movie.movieId == %d", argumentArray: [movieId])
        fetchRequest.fetchLimit = 1;
        
        // Start fetch
        var resultArray: [FavoriteMovie]?
        
        do {
            resultArray = try self.managedObjectContext!.fetch(fetchRequest)
        } catch let e as NSError {
            // Write error to log
            NSLog(e.debugDescription)
        }
        
        return resultArray?.last
    }
    
    func getFavoriteMovies(fromTime: Date, limit: Int) -> [FavoriteMovie] {
        var result = [FavoriteMovie]()
        
        let fetchRequest = NSFetchRequest<FavoriteMovie>(entityName: kCoreDataEntityFavoriteMovie)
        fetchRequest.predicate = NSPredicate(format: "createdDate < %@", fromTime as NSDate)
        
        // Sort descrptor
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = limit
        
        // Start fetch data
        do {
            try result.append(contentsOf: self.managedObjectContext!.fetch(fetchRequest))
        } catch {
            DLog(error.localizedDescription)
        }
        
        return result
    }
}
