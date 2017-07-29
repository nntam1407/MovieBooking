//
//  MovieDetailTableViewCell.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

class MovieDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
