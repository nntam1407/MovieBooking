//
//  MovieDetailViewController.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit
import SafariServices

let kBackdropImageRatio: CGFloat = 16.0 / 9.0

class MovieDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MovieDetailSectionHeaderViewDelegates {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropImageViewTopConstraint: NSLayoutConstraint!
    
    /// This is movie information section view, we only create this view once during lifetime
    var sectionHeaderView: MovieDetailSectionHeaderView?
    weak var backdropShadowLayer: CAGradientLayer?
    
    /// Main movie data
    var movieData: MovieModel?
    var displayInformation = [(title: String, content: String)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.mainTableView.register(UINib(nibName: "MovieDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieDetailTableViewCell")
        self.mainTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Display information at first time
        self.displayMovieInformation()
        self.refreshMovieDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.mainTableView.tableHeaderView != nil {
            // Resize header view
            var size = self.tableHeaderView.frame.size
            size.width = self.view.bounds.size.width
            size.height = size.width / kBackdropImageRatio
            self.tableHeaderView.frame.size = size
            
            self.tableHeaderView.layoutIfNeeded()
            self.mainTableView.tableHeaderView = self.tableHeaderView
            
            // display shadow
            self.displayShadowLayerOnBackdropImage()
        }
    }
    
    // MARK:
    // MARK: View's events
    
    @IBAction func didTouchOnBackdropImageButton(_ sender: Any) {
        if let backdropImageURL = WebServices.backdropImageURL(imagePath: self.movieData?.backdropPath) {
            MediaPlayerManager.sharedInstance.displayImageFromURL(backdropImageURL)
        }
    }
    
    // MARK:
    // MARK: Methods
    
    func displayShadowLayerOnBackdropImage() {
        guard self.movieData?.backdropPath != nil else {
            return
        }
        
        if self.backdropShadowLayer == nil {
            let shadowLayer = CAGradientLayer()
            shadowLayer.colors = [UIColor(white: 0, alpha: 0).cgColor,
                                                UIColor.colorFromHexValue(0x1C1C1C).cgColor]
            
            self.tableHeaderView.layer.addSublayer(shadowLayer)
            self.backdropShadowLayer = shadowLayer
        }
        
        // Layout shadow
        var frame = self.tableHeaderView.frame
        frame.size.height = 50.0
        frame.origin.x = 0
        frame.origin.y = self.tableHeaderView.frame.size.height - frame.size.height
        self.backdropShadowLayer?.frame = frame
    }
    
    func displayMovieInformation() {
        guard self.movieData != nil else {
            return
        }
        
        // don't display header view if there is no backdrop image
        if self.movieData!.backdropPath == nil {
            self.tableHeaderView = nil
            self.mainTableView.tableHeaderView = nil
        } else {
            let backdropImageURL = WebServices.backdropImageURL(imagePath: self.movieData!.backdropPath!)
            self.backdropImageView.setImageURL(backdropImageURL, defaultImage: #imageLiteral(resourceName: "ic_default_backdrop"))
            
            // display shadow
            self.displayShadowLayerOnBackdropImage()
        }
        
        // Generate all display information
        self.displayInformation.removeAll()
        
        // Synopsis
        if self.movieData!.overview != nil {
            self.displayInformation.append((NSLocalizedString("Overview", comment: ""), self.movieData!.overview!))
        } else {
            self.displayInformation.append((NSLocalizedString("Overview", comment: ""), "-"))
        }
        
        // Genres
        var genresDisplayString: String?
        
        for genre in self.movieData!.genres where genre.name != nil {
            if genresDisplayString == nil {
                genresDisplayString = genre.name!
            } else {
                genresDisplayString!.append(", " + genre.name!)
            }
        }
        
        if genresDisplayString != nil {
            self.displayInformation.append((NSLocalizedString("Genres", comment: ""), genresDisplayString!))
        } else {
            self.displayInformation.append((NSLocalizedString("Genres", comment: ""), "-"))
        }
        
        // Languages
        var langDisplayString: String?
        
        for lang in self.movieData!.spokenLanguages where lang.name != nil {
            if langDisplayString == nil {
                langDisplayString = lang.name!
            } else {
                langDisplayString!.append(", " + lang.name!)
            }
        }
        
        if langDisplayString != nil {
            self.displayInformation.append((NSLocalizedString("Spoken Languages", comment: ""), langDisplayString!))
        } else {
            self.displayInformation.append((NSLocalizedString("Spoken Languages", comment: ""), "-"))
        }
        
        // Duration
        if self.movieData!.durationInMinutes == 0 {
            self.displayInformation.append((NSLocalizedString("Duration", comment: ""), "-"))
        } else {
            var durationDisplayString = ""
            let durationHours = self.movieData!.durationInMinutes / 60
            let durationMinutes = self.movieData!.durationInMinutes % 60
            
            if durationHours > 0 {
                durationDisplayString += "\(durationHours)h "
            }
            
            durationDisplayString += "\(durationMinutes)m"
            
            self.displayInformation.append((NSLocalizedString("Duration", comment: ""), durationDisplayString))
        }
        
        // Reload table view
        self.mainTableView.reloadData()
    }
    
    func refreshMovieDetail() {
        guard self.movieData != nil else {
            return
        }
        
        WebServices.sharedInstance.getMovieDetail(movieId: self.movieData!.movieId,
                                                  success: { [weak self] (movie) in
        
                                                    // For sure self will not be nil while processing anything
                                                    guard let strongSelf = self else {
                                                        return
                                                    }
                                                    
                                                    strongSelf.movieData = movie
                                                    strongSelf.displayMovieInformation()
        
        }) { [weak self] (error) in
            
            // For sure self will not be nil while processing anything
            guard let strongSelf = self else {
                return
            }
            
            AlertUtils.showAlert(title: NSLocalizedString("Loading video detail failed", comment: ""),
                                 message: error.localizedDescription,
                                 okButtonTitle: NSLocalizedString("OK", comment: ""),
                                 onViewController: strongSelf)
        }
    }
    
    // MARK:
    // MARK: UITableView's datasource and delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayInformation.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kMovieDetailSectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sectionHeaderView == nil {
            self.sectionHeaderView = Utils.loadView("MovieDetailSectionHeaderView") as? MovieDetailSectionHeaderView
        }
        
        self.sectionHeaderView!.movieData = self.movieData
        self.sectionHeaderView!.delegate = self
        
        return self.sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailTableViewCell") as! MovieDetailTableViewCell
        
        let displayData = self.displayInformation[indexPath.row]
        cell.mainTitleLabel.text = displayData.title
        cell.contentLabel.text = displayData.content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableHeaderView != nil {
            var topConstraint = scrollView.contentOffset.y + scrollView.contentInset.top
            
            if topConstraint > 0 {
               topConstraint = 0
            }
            
            self.backdropImageViewTopConstraint.constant = topConstraint
            self.tableHeaderView.layoutIfNeeded()
        }
    }
    
    // MARK:
    // MARK: MovieDetailSectionHeaderViewDelegates
    
    func movieDetailSectionHeaderDidTouchOnBuyButton(sender: MovieDetailSectionHeaderView) {
        // Open webview
        if #available(iOS 9.0, *) {
            let safariVC = SFSafariViewController(url: URL(string: kBookingTicketSiteURL)!)
            self.present(safariVC, animated: true, completion: nil)
        } else {
            // Display internal webView
        }
    }
    
    func movieDetailSectionHeaderDidTouchOnPosterImage(sender: MovieDetailSectionHeaderView) {
        if let posterImageURL = WebServices.posterImageURL(imagePath: sender.movieData?.posterPath) {
            MediaPlayerManager.sharedInstance.displayImageFromURL(posterImageURL)
        }
    }

}
