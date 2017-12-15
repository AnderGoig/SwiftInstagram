//
//  String+SwiftInstagram.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 14/12/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension String {

    /// Creates a string from the given numeric.

    init?<T: Numeric>(_ numeric: T?) {
        guard let numeric = numeric else { return nil }
        self.init(numeric)
    }

}
