//
//  Dictionary+SwiftInstagram.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 14/12/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Dictionary {

    /// Returns a dictionary constructed by adding both dictionaries.
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }
}
