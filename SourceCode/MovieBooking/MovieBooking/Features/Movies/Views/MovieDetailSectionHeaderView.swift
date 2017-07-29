//
//  MovieDetailSectionHeaderView.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

let kMovieDetailSectionHeaderHeight: CGFloat = 150.0

@objc protocol MovieDetailSectionHeaderViewDelegates {
    @objc optional func movieDetailSectionHeaderDidTouchOnBuyButton(sender: MovieDetailSectionHeaderView)
}

class MovieDetailSectionHeaderView: UIView {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var bookTicketButton: HightlightButton!
    
    weak var delegate: MovieDetailSectionHeaderViewDelegates?
    
    var movieData: MovieModel? {
        didSet {
            self.displayMovieInformation()
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bookTicketButton.layer.cornerRadius = 4.0
        self.bookTicketButton.layerBorder(1.0, color: UIColor.colorFromHexValue(0xe1cdab))
    }
    
    // MARK:
    // MARK: Events

    @IBAction func didTouchOnBookButton(_ sender: Any) {
        self.delegate?.movieDetailSectionHeaderDidTouchOnBuyButton?(sender: self)
    }
    
    // MARK:
    // MARK: Methods
    
    func displayMovieInformation() {
        guard self.movieData != nil else {
            return
        }
        
        self.titleLabel.text = self.movieData?.getDisplayTitle()
        self.popularityLabel.text = String(format: "Popularity: %.2f", self.movieData!.popularity)
        
        if self.movieData!.releaseDate != nil {
            self.releaseDateLabel.text = self.movieData!.releaseDate!.toString("MMM dd, yyyy")
        } else {
            self.releaseDateLabel.text = nil
        }
        
        // Set poster image
        let posterImageURL = WebServices.posterImageURL(imagePath: self.movieData?.posterPath)
        self.posterImageView.setImageURL(posterImageURL, defaultImage: #imageLiteral(resourceName: "ic_default_poster_small"))
    }
}
