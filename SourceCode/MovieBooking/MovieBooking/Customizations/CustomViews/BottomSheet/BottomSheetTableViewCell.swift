//
//  AhaBottomSheetTableViewCell.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 4/29/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import UIKit

let kBottomSheetCellDefaultHeight: CGFloat = 44.0

class BottomSheetTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var mainTitleLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var checkedImageView: UIImageView!
    
    /// Variable to set checked or not
    var isCellChecked: Bool = false {
        didSet {
            self.checkedImageView.isHidden = !self.isCellChecked
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
