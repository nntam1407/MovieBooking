//
//  SpokenLanguageModel.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

class SpokenLanguageModel: BaseModel {
    
    var languageCode: String?
    var name: String?
    
    override init(fromDict dict: NSDictionary?) {
        super.init(fromDict: dict)
        
        if dict != nil {
            self.languageCode = dict!.stringValueForKey("iso_639_1")
            self.name = dict!.stringValueForKey("name")
        }
    }
}
