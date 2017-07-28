//
//  ArrayExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 12/1/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

extension Array {
    
    /**
     * Methods remove object in this array
     */
    mutating func removeObject<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        } 
        
        if((index) != nil) {
            self.remove(at: index!)
        }
    }
    
    mutating func removeObjects<U: Equatable>(_ objects: [U]) {
        for (_, objectToRemove) in objects.enumerated() {
            self.removeObject(objectToRemove)
        }
    }
    
    func combineStrings(sepatateString: String) -> String? {
        var result: String?
        
        if let strings = self as? [String] {
            if strings.count == 0 {
                result = ""
            } else {
                for subString in strings {
                    if result == nil {
                        result = subString
                    } else {
                        result! += String(format: "%@%@", sepatateString, subString)
                    }
                }
            }
        }
        
        return result
    }
}
