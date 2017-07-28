//
//  TextAvatarImageView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/22/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

let textAvatarBackgroundColors = [
    "A": 0xe06055,
    "B": 0xed6192,
    "C": 0xba68c8,
    "D": 0x9575cd,
    "E": 0x7986cb,
    "F": 0x5e97f6,
    "G": 0x4fc3f7,
    "H": 0x58d0e1,
    "I": 0x4fb6ac,
    "J": 0x57bb8a,
    "K": 0x9ccc65,
    "L": 0xd4e157,
    "M": 0xfdd835,
    "N": 0xf6bf32,
    "O": 0xf5a631,
    "P": 0xf18864,
    "Q": 0xc2c2c2,
    "R": 0x90a4ae,
    "S": 0xa1887f,
    "T": 0xa3a3a3,
    "U": 0xafb6e0,
    "V": 0xb39ddb,
    "X": 0x80deea,
    "Y": 0xbcaaa4,
    "Z": 0xaed581
]

let textAvatarTextColors = [
    "A": 0xf4c7c3,
    "B": 0xf8c7d8,
    "C": 0xe6caeb,
    "D": 0xdaceed,
    "E": 0xc5cae9,
    "F": 0xc6dafb,
    "G": 0xc1eafc,
    "H": 0xc4eef4,
    "I": 0xc1e5e2,
    "J": 0xc4e7d6,
    "K": 0xdcedc9,
    "L": 0xeff4c4,
    "M": 0xfef1b8,
    "N": 0xfbe8b7,
    "O": 0xfbdfb7,
    "P": 0xfad5c8,
    "Q": 0xf1f1f1,
    "R": 0xd8dfe2,
    "S": 0xded5d2,
    "T": 0xdedede,
    "U": 0xe8eaf6,
    "V": 0xe4dcf2,
    "X": 0xe9f9fb,
    "Y": 0xe7e1df,
    "Z": 0xdcedc8
]

class TextAvatarImageView: UIImageView {
    
    private var userNameLabel: UILabel?
    
    var userName: String? {
        didSet {
            self.userNameLabel!.text = ""
            
            if (self.userName != nil || self.userName!.characters.count > 0) {
                let firstCharacter = (self.userName! as NSString).substring(to: 1).uppercased()
                self.userNameLabel!.text = firstCharacter
                
                // Set background color and text color
                var backgroundColorHex = textAvatarBackgroundColors[firstCharacter]
                var textColorHex = textAvatarTextColors[firstCharacter] as Int?
                
                if (backgroundColorHex == nil) {
                    backgroundColorHex = textAvatarBackgroundColors["A"]
                    textColorHex = textAvatarTextColors["A"]
                }
                
                self.backgroundColor = UIColor.colorFromHexValue(backgroundColorHex!)
                self.userNameLabel!.textColor = UIColor.colorFromHexValue(textColorHex!)
                self.userNameLabel!.setNeedsDisplay()
            }
        }
    }
    
    var font: UIFont? {
        didSet {
            if (self.font != nil && self.userNameLabel != nil) {
                self.userNameLabel!.font = self.font
            }
        }
    }
    
    // Override set image
    override var image: UIImage? {
        get {
            return super.image
        }
        set{
            self.userNameLabel?.isHidden = newValue != nil
            self.layer.masksToBounds = newValue != nil
            super.image = newValue
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        
        // Create base UI
        self.createBaseUI()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        // Create base UI
        self.createBaseUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Create base UI
        self.createBaseUI()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        // Create base UI
        self.createBaseUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Create base UI
        self.createBaseUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Check should clip to bound
        self.clipsToBounds = self.image != nil
        
        // Layout frame of label on this avatar
        var frame = self.bounds
        frame.size.height *= 0.7
        frame.size.width *= 0.7
        frame.origin.x = (self.bounds.size.width - frame.size.width) / 2.0
        frame.origin.y = (self.bounds.size.height - frame.size.height) / 2.0
        self.userNameLabel!.frame = frame
    }

    // MARK: Private methods
    
    private func createBaseUI() {
        if (self.userNameLabel == nil) {
            self.userNameLabel = UILabel(frame: self.frame)
            self.userNameLabel!.numberOfLines = 0
            self.userNameLabel!.backgroundColor = UIColor.clear
            self.userNameLabel!.textColor = UIColor.white
            self.userNameLabel!.textAlignment = NSTextAlignment.center
            
            self.userNameLabel!.font = UIFont.systemFont(ofSize: 100)
            self.userNameLabel!.adjustsFontSizeToFitWidth = true
            self.userNameLabel!.minimumScaleFactor = 0.1
            
            self.userNameLabel?.autoresizingMask = [.flexibleWidth]
            self.addSubview(self.userNameLabel!)
        }
        
        // Set default color
        self.backgroundColor = UIColor.colorFromHexValue(0x2F5E91)
    }
    
    // MARK: Public methods
    
    func randomBackgroundColor() {
        // Try to get random index in list color
        let randomIndex = (0 ..< textAvatarBackgroundColors.count - 1).randomInt
        let randomValue = ([String](textAvatarBackgroundColors.keys))[randomIndex]
        
        self.backgroundColor = UIColor.colorFromHexValue(textAvatarBackgroundColors[randomValue]!, cache: true)
        self.tintColor = UIColor.colorFromHexValue(textAvatarTextColors[randomValue]!, cache: true)
        self.userNameLabel?.textColor = UIColor.colorFromHexValue(textAvatarTextColors[randomValue]!, cache: true)
    }
}
