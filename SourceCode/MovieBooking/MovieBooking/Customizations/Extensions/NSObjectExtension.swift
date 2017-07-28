//
//  NSObjectExtension.swift
//  ChatApp
//
//  Created by Tam Nguyen Ngoc on 2/28/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

extension NSObject {
    func memoryAddressString() -> String {
        return "\(unsafeBitCast(self, to: Int.self))"
    }
}
