//
//  WebServices+Images.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import Foundation

extension WebServices {
    
    class func posterImageURL(imagePath path:String?) -> String? {
        if path != nil {
            let result = kWebServiceImageRootURL + "w500" + path!
            
            return result
        }
        
        return nil
    }
    
    class func backdropImageURL(imagePath path:String?) -> String? {
        if path != nil {
            let result = kWebServiceImageRootURL + "w1280" + path!
            
            return result
        }
        
        return nil
    }
}
