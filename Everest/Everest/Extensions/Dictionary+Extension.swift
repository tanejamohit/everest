//
//  Dictionary+Extension.swift
//  Everest
//
//  Created by Kavita Gaitonde on 10/22/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import Foundation

extension Dictionary {
    /// Merge and return a new dictionary
    func merge(with: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
        var copy = self
        for (k, v) in with {
            // If a key is already present it will be overritten
            copy[k] = v
        }
        return copy
    }
    
    /// Merge in-place
    mutating func append(with: Dictionary<Key,Value>) {
        for (k, v) in with {
            // If a key is already present it will be overritten
            self[k] = v
        }
    }
    
}
