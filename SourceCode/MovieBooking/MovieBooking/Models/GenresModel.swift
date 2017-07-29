//
//  GenresModel.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

class GenresModel: BaseModel {
    
    var genresId = 0
    var name: String?
    
    override init(fromDict dict: NSDictionary) {
        super.init(fromDict: dict)
        
        self.genresId = dict.intValueForKey("id")
        self.name = dict.stringValueForKey("name")
    }
}
