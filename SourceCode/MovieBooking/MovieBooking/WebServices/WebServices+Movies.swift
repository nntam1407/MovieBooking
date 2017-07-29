//
//  WebServices+Movies.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import Foundation

enum DiscoverMovieSortBy: Int {
    case releaseDateASC = 0
    case releaseDateDESC = 1
    
    case primaryReleaseDateASC = 2
    case primaryReleaseDateDESC = 3
}

extension WebServices {
    
    func discoverMovies(primaryReleaseDateBefore: Date?,
                        primaryReleaseDateAfter: Date?,
                        sortBy: DiscoverMovieSortBy,
                        pageIndex: Int,
                        success:((_ movies: [MovieModel], _ canLoadMore: Bool) -> Void)?,
                        failed:((_ error: NSError) -> Void)?) {
        
        var urlPath = API_ENDPOINTS.getMovies.path
        
        // Page index must be greater than 0
        if pageIndex <= 0 {
            urlPath += "?page=1"
        } else {
            urlPath += "?page=\(pageIndex)"
        }
        
        // For releaseDate
        if primaryReleaseDateBefore != nil {
            urlPath += "&primary_release_date.lte=\(primaryReleaseDateBefore!.toString(kMovieReleaseDateStringFormat))"
        }
        
        if primaryReleaseDateAfter != nil {
            urlPath += "&primary_release_date.gte=\(primaryReleaseDateAfter!.toString(kMovieReleaseDateStringFormat))"
        }
        
        // For sortBy
        switch sortBy {
        case .releaseDateASC:
            urlPath += "&sort_by=release_date.asc"
            break
        case .releaseDateDESC:
            urlPath += "&sort_by=release_date.desc"
            break
        case .primaryReleaseDateASC:
            urlPath += "&sort_by=primary_release_date.asc"
            break
        case .primaryReleaseDateDESC:
            urlPath += "&sort_by=primary_release_date.desc"
            break
        }
        
        
        self.callRequest(urlPath,
                         params: nil,
                         identifer: nil,
                         httpMethod: API_ENDPOINTS.getMovies.method,
                         success: { (url, response: NSDictionary?) in
                            
                            let totalPage = response!.intValueForKey("total_pages")
                            let canLoadMore = pageIndex < totalPage
                            
                            // Get result list
                            var result = [MovieModel]()
                            
                            if let resultDicts = response!.arrayForKey("results") as? [NSDictionary] {
                                for dict in resultDicts {
                                    let movie = MovieModel(fromDict: dict)
                                    result.append(movie)
                                }
                            }
                            
                            // Callback
                            success?(result, canLoadMore)
                            
        }) { (url, error, isCancelled) in
            failed?(error)
        }
    }
    
    func getMovieDetail(movieId: Int,
                        success:((_ movie: MovieModel) -> Void)?,
                        failed:((_ error: NSError) -> Void)?) {
        
        let urlPath = String(format: API_ENDPOINTS.getMovieDetail.path, movieId)
        
        self.callRequest(urlPath,
                         params: nil,
                         identifer: nil,
                         httpMethod: API_ENDPOINTS.getMovieDetail.method,
                         success: { (url, response: NSDictionary?) in
                            
                            // Get result movie
                            let result = MovieModel(fromDict: response!)
                            
                            // Callback
                            success?(result)
                            
        }) { (url, error, isCancelled) in
            failed?(error)
        }
    }
}
