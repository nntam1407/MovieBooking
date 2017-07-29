//
//  MovieItemTableViewCell.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

let kMovieItemTableCellHeight: CGFloat = 100.0

class MovieItemTableViewCell: BaseCustomTableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    var movieData: MovieModel? {
        didSet {
            self.updateUIInformation()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    // MARK:
    // MARK: Events
    
    @IBAction func didTouchOnAvatarButton(_ sender: Any) {
        if let posterImageURL = WebServices.posterImageURL(imagePath: self.movieData?.posterPath) {
            MediaPlayerManager.sharedInstance.displayImageFromURL(posterImageURL)
        }
    }
    
    // MARK:
    // MARK: Methods
    
    func updateUIInformation() {
        if self.movieData == nil {
            return
        }
        
        self.movieTitleLabel.text = self.movieData?.getDisplayTitle()
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
