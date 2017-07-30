//
//  DataCacheManager+FavoriteMovies.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import Foundation

extension DataCacheManager {
    
    private func convertMovieModelToCoreDataModel(movie: MovieModel) -> Movie {
        var coreDataMovie = self.coreDataHelper!.getMovie(movie.movieId)
        
        if coreDataMovie == nil {
            coreDataMovie = self.coreDataHelper!.createNewMovie()
        }
        
        coreDataMovie?.movieId = Int32(movie.movieId)
        coreDataMovie?.title = movie.title
        coreDataMovie?.popularity = movie.popularity
        coreDataMovie?.releaseDate = movie.releaseDate as NSDate?
        coreDataMovie?.posterPath = movie.posterPath
        coreDataMovie?.backdropPath = movie.backdropPath
        coreDataMovie?.overview = movie.overview
        
        return coreDataMovie!
    }
    
    private func convertCoreDataMovieToMovieModel(coreDataMovie: Movie) -> MovieModel {
        let movie = MovieModel(fromDict: nil)
        
        movie.movieId = Int(coreDataMovie.movieId)
        movie.title = coreDataMovie.title
        movie.popularity = coreDataMovie.popularity
        movie.releaseDate = coreDataMovie.releaseDate as Date?
        movie.posterPath = coreDataMovie.posterPath
        movie.backdropPath = coreDataMovie.backdropPath
        movie.overview = coreDataMovie.overview
        
        return movie
    }
    
    // MARK:
    // MARK: Public methods
    
    func isFavoritedMovie(movie: MovieModel) -> Bool {
        if let _ = self.coreDataHelper?.getFavoriteMovie(movie.movieId) {
            return true
        }
        
        return false
    }
    
    func addFavoriteMovie(movie: MovieModel) {
        if self.isFavoritedMovie(movie: movie) {
            return
        }
        
        // Create new favorite movie and core data movie
        let coreDataMovie = self.convertMovieModelToCoreDataModel(movie: movie)
        let favoriteMovie = self.coreDataHelper?.createFavoriteMovie()
        
        favoriteMovie?.movie = coreDataMovie
        favoriteMovie?.createdDate = NSDate()
        
        // Save coredata
        self.coreDataHelper?.saveContext()
    }
    
    func removeFavoriteMovie(movie: MovieModel) {
        if let favoriteMovie = self.coreDataHelper?.getFavoriteMovie(movie.movieId) {
            self.coreDataHelper?.deleteObject(favoriteMovie, saveImmediately: true)
        }
    }
    
    func getFavoriteMovies(fromTime: Date, limit: Int) -> ([MovieModel], Date?) {
        var result = [MovieModel]()
        var nextTime: Date?
        
        if let coreDataFavorites = self.coreDataHelper?.getFavoriteMovies(fromTime: fromTime, limit: limit) {
            for favorite in coreDataFavorites where favorite.movie != nil {
                let movie = self.convertCoreDataMovieToMovieModel(coreDataMovie: favorite.movie!)
                result.append(movie)
            }
            
            nextTime = coreDataFavorites.last?.createdDate as Date?
        }
        
        return (result, nextTime)
    }
    
    func getFavoritedMoviesAsync(fromTime: Date,
                                 limit: Int,
                                 completed: @escaping (_ movies: [MovieModel], _ nextTime: Date?) -> Void) {
        
        DispatchQueue.global(qos: .default).async {
            let result = self.getFavoriteMovies(fromTime: fromTime, limit: limit)
            
            DispatchQueue.main.async {
                completed(result.0, result.1)
            }
        }
    }
}
