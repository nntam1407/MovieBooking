//
//  FavoritedVideosViewController.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

let kFavoritedRequestLimit = 50

class FavoritedVideosViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MovieItemTableViewCellDelegates {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: MaterialIndicatorView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    // For pull refresh and load more data
    var refreshControl: MaterialRefreshControl?
    var loadmoreControl: MaterialInfiniteScrollingControl?
    
    // Movies data
    var movies = [MovieModel]()
    var isLoadingData = false
    var requestTime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = NSLocalizedString("Favorites", comment: "")
        
        // Init table view
        self.initForTableView()
        
        // Register all notifications
        Utils.regNotif(self,
                       selector: #selector(FavoritedVideosViewController.notificationDidAddFavorite(notification:)),
                       name: kNotificationDidAddFavorited,
                       object: nil)
        
        Utils.regNotif(self,
                       selector: #selector(FavoritedVideosViewController.notificationDidRemoveFavorite(notification:)),
                       name: kNotificationDidRemoveFavorited,
                       object: nil)
        
        // Load movies data at first time
        self.loadMoviesData(clearAllData: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "MovieDetailViewController" {
            if let vc = segue.destination as? MovieDetailViewController {
                vc.movieData = sender as? MovieModel
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK:
    // MARK: Init methods
    
    func initForTableView() {
        // Init pull to refresh and load more data
        self.refreshControl = MaterialRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(MoviesViewController.refreshControlValueChanged(control:)), for: .valueChanged)
        
        // This code will make pullToReload for table view smooth
        let tempTableVC = UITableViewController()
        tempTableVC.tableView = self.mainTableView
        tempTableVC.refreshControl = self.refreshControl!
        
        self.loadmoreControl = MaterialInfiniteScrollingControl()
        self.loadmoreControl!.addTarget(self, action: #selector(MoviesViewController.loadMoreControlValueChanged(control:)), for: .valueChanged)
        self.loadmoreControl!.canLoading = false // Don't allow load more for first time
        self.mainTableView.addSubview(self.loadmoreControl!)
        
        // Register cell for table view
        self.mainTableView.register(UINib(nibName: "MovieItemTableViewCell", bundle: nil),
                                    forCellReuseIdentifier: "MovieItemTableViewCell")
        
        // Remove addition lines below last cell of table view
        self.mainTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // MARK:
    // MARK: Handle notifications
    
    func notificationDidAddFavorite(notification: NSNotification?) {
        if let inserteddMovie = notification?.object as? MovieModel {
            self.movies.insert(inserteddMovie, at: 0)
            self.mainTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
    func notificationDidRemoveFavorite(notification: NSNotification?) {
        if let deletedMovie = notification?.object as? MovieModel {
            var foundIndex = NSNotFound
            
            for i in 0...self.movies.count - 1 {
                let movie = self.movies[i]
                
                if movie.movieId == deletedMovie.movieId {
                    foundIndex = i
                    break
                }
            }
            
            if foundIndex != NSNotFound && foundIndex < self.movies.count {
                self.movies.remove(at: foundIndex)
                
                let indexPath = IndexPath(row: foundIndex, section: 0)
                self.mainTableView.deleteRows(at: [indexPath], with: .fade)
                
                // Reload the list if there is no item remaining
                if self.movies.count == 0 {
                    self.requestTime = Date()
                    self.loadMoviesData(clearAllData: true)
                }
            }
        }
    }
    
    // MARK:
    // MARK: Custom events
    
    func refreshControlValueChanged(control: MaterialRefreshControl) {
        self.requestTime = Date()
        self.loadMoviesData(clearAllData: true)
    }
    
    func loadMoreControlValueChanged(control: MaterialInfiniteScrollingControl) {
        self.loadMoviesData(clearAllData: false)
    }
    
    // MARK:
    // MARK: Data methods
    
    func loadMoviesData(clearAllData: Bool) {
        if self.isLoadingData {
            return
        }
        
        if clearAllData {
            self.movies.removeAll()
            self.mainTableView.reloadData()
        }
        
        if self.movies.count == 0 && !self.refreshControl!.isRefreshing {
            self.loadingIndicatorView.startAnimating()
        }
        
        self.noDataLabel.isHidden = true
        self.isLoadingData = true
        
        DataCacheManager.sharedInstance.getFavoritedMoviesAsync(fromTime: self.requestTime,
                                                                limit: kFavoritedRequestLimit) { [weak self] (movies, nextTime) in
        
                                                                    // For sure self will not be nil while processing anything
                                                                    guard let strongSelf = self else {
                                                                        return
                                                                    }
                                                                    
                                                                    // Append data
                                                                    strongSelf.appendMovieDataAndUpdateTableView(appendingMovies: movies)
                                                                    
                                                                    if strongSelf.movies.count == 0 {
                                                                        strongSelf.noDataLabel.isHidden = false
                                                                    }
                                                                    
                                                                    strongSelf.loadingIndicatorView.stopAnimating()
                                                                    strongSelf.isLoadingData = false
                                                                    strongSelf.refreshControl?.endRefreshing()
                                                                    strongSelf.loadmoreControl?.endInfiniteLoading()
                                                                    
                                                                    // Can load more data or not
                                                                    strongSelf.requestTime  = nextTime != nil ? nextTime! : Date()
                                                                    strongSelf.loadmoreControl?.canLoading = movies.count == kFavoritedRequestLimit
        }
    }
    
    func appendMovieDataAndUpdateTableView(appendingMovies: [MovieModel]) {
        if appendingMovies.count == 0 {
            return
        }
        
        let appendingIndex = self.movies.count
        var appendingIndexPaths = [IndexPath]()
        
        // Start append in movie list
        if self.movies.count == 0 {
            
            self.movies = appendingMovies
            self.mainTableView.reloadData()
            
        } else {
            self.movies.append(contentsOf: appendingMovies)
            
            // Update table view
            for rowIndex in appendingIndex...self.movies.count - 1 {
                appendingIndexPaths.append(IndexPath(row: rowIndex, section: 0))
            }
            
            self.mainTableView.insertRows(at: appendingIndexPaths, with: .fade)
        }
    }
    
    // MARK:
    // MARK: UITableView's datasource and delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kMovieItemTableCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieItemTableViewCell") as! MovieItemTableViewCell
        
        let movieData = self.movies[indexPath.row]
        cell.movieData = movieData
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Move to movie detail
        let movieData = self.movies[indexPath.row]
        self.performSegue(withIdentifier: "MovieDetailViewController", sender: movieData)
    }
    
    // MARK:
    // MARK: MovieItemTableViewCellDelegates
    
    func movieItemCellDidTouchOnPosterImage(sender: MovieItemTableViewCell) {
        if let posterImageURL = WebServices.posterImageURL(imagePath: sender.movieData?.posterPath) {
            MediaPlayerManager.sharedInstance.displayImageFromURL(posterImageURL)
        }
    }
}
