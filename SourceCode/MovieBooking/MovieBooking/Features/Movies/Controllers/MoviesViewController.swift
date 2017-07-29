//
//  MoviesViewController.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

class MoviesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: MaterialIndicatorView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    // For pull refresh and load more data
    var refreshControl: MaterialRefreshControl?
    var loadmoreControl: MaterialInfiniteScrollingControl?
    
    // Movies data
    var movies = [MovieModel]()
    var pageIndex = 1
    var isLoadingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = NSLocalizedString("Movies", comment: "")
        
        // Init table view
        self.initForTableView()
        
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
    // MARK: Handle events on UI
    
    // MARK:
    // MARK: Custom events
    
    func refreshControlValueChanged(control: MaterialRefreshControl) {
        self.pageIndex = 1
        self.loadMoviesData(clearAllData: false)
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
            self.pageIndex = 1
        }
        
        if self.movies.count == 0 && !self.refreshControl!.isRefreshing {
            self.loadingIndicatorView.startAnimating()
        }
        
        self.noDataLabel.isHidden = true
        
        // Start fetch data from API
        self.isLoadingData = true
        
        WebServices.sharedInstance.discoverMovies(primaryReleaseDateBefore: Date.lastDateOfThisYear(),
                                                  primaryReleaseDateAfter: nil,
                                                  sortBy: .primaryReleaseDateDESC,
                                                  pageIndex: self.pageIndex,
                                                  success: { [weak self] (movies, canLoadMore) in
                                                    
                                                    // For sure self will not be nil while processing anything
                                                    guard let strongSelf = self else {
                                                        return
                                                    }
                                                    
                                                    // In-case pull to reload the list, we should remove all old data before add new items to the list
                                                    if strongSelf.pageIndex == 1 {
                                                        strongSelf.movies = movies
                                                        strongSelf.mainTableView.reloadData()
                                                    } else {
                                                        // Append data
                                                        strongSelf.appendMovieDataAndUpdateTableView(appendingMovies: movies)
                                                    }
                                                    
                                                    if strongSelf.movies.count == 0 {
                                                        strongSelf.noDataLabel.isHidden = false
                                                        strongSelf.noDataLabel.text = NSLocalizedString("No movies", comment: "")
                                                    }
                                                    
                                                    strongSelf.loadingIndicatorView.stopAnimating()
                                                    strongSelf.isLoadingData = false
                                                    strongSelf.refreshControl?.endRefreshing()
                                                    strongSelf.loadmoreControl?.endInfiniteLoading()
                                                    
                                                    // Can load more data or not
                                                    strongSelf.pageIndex += 1
                                                    strongSelf.loadmoreControl?.canLoading = canLoadMore
        
        }) { [weak self] (error) in
            
            // For sure self will not be nil while processing anything
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.movies.count > 0 {
                AlertUtils.showAlert(title: NSLocalizedString("Getting data failed", comment: ""),
                                     message: error.localizedDescription,
                                     okButtonTitle: NSLocalizedString("OK", comment: ""),
                                     onViewController: strongSelf)
            } else {
                // Show error and and try again button on main screen
                strongSelf.noDataLabel.isHidden = false
                strongSelf.noDataLabel.text = error.localizedDescription
            }
            
            strongSelf.loadingIndicatorView.stopAnimating()
            strongSelf.isLoadingData = false
            strongSelf.refreshControl?.endRefreshing()
            strongSelf.loadmoreControl?.endInfiniteLoading()
        }
    }
    
    func appendMovieDataAndUpdateTableView(appendingMovies: [MovieModel]) {
        if appendingMovies.count == 0 {
            return
        }
        
        let appendingIndex = self.movies.count
        var appendingIndexPaths = [IndexPath]()
        
        // Start append in movie list
        self.movies.append(contentsOf: appendingMovies)
        
        // Update table view
        for rowIndex in appendingIndex...self.movies.count - 1 {
            appendingIndexPaths.append(IndexPath(row: rowIndex, section: 0))
        }
        
        self.mainTableView.insertRows(at: appendingIndexPaths, with: .fade)
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Move to movie detail
        let movieData = self.movies[indexPath.row]
        self.performSegue(withIdentifier: "MovieDetailViewController", sender: movieData)
    }
}
