//
//  Array+SwiftInstagram.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 22/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Array where Element == InstagramScope {

    /// Returns a String constructed by joining the array elements with the given `separator`.
    func joined(separator: String) -> String {
        return self.map { "\($0.rawValue)" }.joined(separator: separator)
    }
}
