//
//  CountryData.swift
//  AskApp
//
//  Created by Tam Nguyen Ngoc on 9/1/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

class CountryData: NSObject {
    private var _countryCode: String?
    private var _phoneCode: String?
    private var _countryName: String?
    
    var countryCode: String? {
        return self._countryCode
    }
    
    var countryName: String? {
        return self._countryName
    }
    
    var phoneCode: String? {
        return self._phoneCode
    }
    
    var flagImage: UIImage? {
        return self.countryCode != nil ? UIImage(named: self.countryCode!.uppercased()) : nil
    }
    
    // MARK: Init methods
    
    init(countryCode: String, phoneCode: String) {
        super.init()
        
        self._countryCode = countryCode
        self._phoneCode = phoneCode
        
        self._countryName = Locale.current.localizedString(forRegionCode: self._countryCode!)
        
        if (self._countryName == nil) {
            self._countryName = Locale(identifier: "en_US").localizedString(forRegionCode: self._countryCode!)
        }
    }
}
