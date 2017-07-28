//
//  RangeExtension.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/25/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import Foundation

extension Range {
    
    /**
        Return random value in range
    */
    var randomInt: Int {
        var offset = 0
        
        if (lowerBound as! Int) < 0   // allow negative ranges
        {
            offset = abs(lowerBound as! Int)
        }
        
        let mini = UInt32(lowerBound as! Int + offset)
        let maxi = UInt32(upperBound   as! Int + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}
