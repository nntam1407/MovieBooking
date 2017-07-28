//
//  NSNumberExtension.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 4/24/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import Foundation

extension NSNumber {
    func localizedCurrencyWithCurrencySymbol(_ symbol: String) -> String {
        let formater = NumberFormatter()
        formater.formatterBehavior = .behavior10_4
        formater.numberStyle = .currency
        formater.locale = Locale.current
        formater.maximumFractionDigits = 0
        formater.currencySymbol = symbol
        
        return formater.string(from: self)!
    }
}
