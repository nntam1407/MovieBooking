//
//  FavoriteMovie+CoreDataProperties.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import Foundation
import CoreData


extension FavoriteMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMovie> {
        return NSFetchRequest<FavoriteMovie>(entityName: "FavoriteMovie")
    }

    @NSManaged public var createdDate: NSDate?
    @NSManaged public var movie: Movie?

}
