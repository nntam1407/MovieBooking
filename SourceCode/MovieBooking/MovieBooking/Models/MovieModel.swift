//
//  MovieModel.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

let kMovieReleaseDateStringFormat = "yyyy-MM-dd"

class MovieModel: BaseModel {
    
    var movieId = 0
    
    var voteCount = 0
    var voteAverage = 0.0
    var isVideo = false
    var popularity = 0.0
    var isAdult = false
    
    var title: String?
    var originalTitle: String?
    var overview: String?
    var homePageURL: String?
    
    var posterPath: String?
    var backdropPath: String?
    
    var originalLanguage: String?
    var spokenLanguages = [SpokenLanguageModel]()
    
    var genres = [GenresModel]()
    
    var durationInMinutes = 0
    var releaseDate: Date?
    
    // MARK:
    // MARK: Initialization methods
    
    override init(fromDict dict: NSDictionary?) {
        super.init(fromDict: dict)
        
        if dict != nil {
            self.movieId = dict!.intValueForKey("id")
            
            self.voteCount = dict!.intValueForKey("vote_count")
            self.voteAverage = dict!.doubleValue("vote_average")
            self.isVideo = dict!.boolValueForKey("video")
            self.popularity = dict!.doubleValue("popularity")
            self.isAdult = dict!.boolValueForKey("adult")
            self.durationInMinutes = dict!.intValueForKey("runtime")
            
            self.title = dict!.stringValueForKey("title")
            self.originalTitle = dict!.stringValueForKey("original_title")
            self.overview = dict!.stringValueForKey("overview")
            self.homePageURL = dict!.stringValueForKey("homepage")
            
            self.posterPath = dict!.stringValueForKey("poster_path")
            self.backdropPath = dict!.stringValueForKey("backdrop_path")
            
            self.originalLanguage = dict!.stringValueForKey("original_language")
            
            // For spoken languages
            if let spokenLangDicts = dict!.arrayForKey("spoken_languages") as? [NSDictionary] {
                for langDict in spokenLangDicts {
                    let lang = SpokenLanguageModel(fromDict: langDict)
                    self.spokenLanguages.append(lang)
                }
            }
            
            // For genres
            if let genreDicts = dict!.arrayForKey("genres") as? [NSDictionary] {
                for genreDict in genreDicts {
                    let genre = GenresModel(fromDict: genreDict)
                    self.genres.append(genre)
                }
            }
            
            // For release date
            if let releaseDateString = dict!.stringValueForKey("release_date") {
                self.releaseDate = Date.fromDateString(dateString: releaseDateString, format: kMovieReleaseDateStringFormat)
            }
        }
    }
    
    // MARK:
    // MARK: Some support methods
    
    func getDisplayTitle() -> String? {
        if self.title != nil {
            return self.title
        }
        
        return self.originalTitle
    }
}
