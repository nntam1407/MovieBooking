//
//  Movie+CoreDataProperties.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var movieId: Int32
    @NSManaged public var title: String?
    @NSManaged public var popularity: Double
    @NSManaged public var releaseDate: NSDate?
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var overview: String?
    @NSManaged public var favoriteMovie: FavoriteMovie?

}
