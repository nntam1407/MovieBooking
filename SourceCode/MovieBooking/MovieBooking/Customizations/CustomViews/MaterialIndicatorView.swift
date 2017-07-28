//
//  MaterialIndicatorView.swift
//  AskApp
//
//  Created by Tam Nguyen on 8/7/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

class MaterialIndicatorView: CircleLoadingView {
    
    @IBInspectable var hideWhenStop: Bool = true
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupView()
    }
    
    // MARK: Private methods
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
        self.strokeBehindLayerColor = UIColor.clear
        self.strokeWidthPercent = 0.075
        self.color = UIColor.colorFromHexValue(0x4286F5)
        self.value = 0.8
        
        // Should top animating
        self.stopAnimating()
    }
    
    // MARK: Animating methods
    
    func startAnimating() {
        self.isHidden = false
        self.startRotateAnimation(1.0, repeatCount: Float.infinity)
    }
    
    func stopAnimating() {
        self.stopRotateAnimation()
        
        if (self.hideWhenStop) {
            self.isHidden = true
        }
    }

}
