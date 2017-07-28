//
//  AhaBaseModel.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 1/24/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import UIKit

class BaseModel: NSObject {
    var objectId: String?
    var createdDate: Date?
    var modifiedDate: Date?
    
    override init() {
        super.init()
    }
    
    init(fromDict dict: NSDictionary) {
        super.init()
        
        self.objectId = dict.stringValueForKey("id")
        self.createdDate = Date(timeIntervalSince1970: dict.numberValueNotNull("created_date").doubleValue / 1000.0)
        self.modifiedDate = Date(timeIntervalSince1970: dict.numberValueNotNull("modified_date").doubleValue / 1000.0)
    }
}
