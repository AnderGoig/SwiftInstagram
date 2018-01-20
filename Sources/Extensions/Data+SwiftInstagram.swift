//
//  Data+SwiftInstagram.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 20/1/18.
//  Copyright © 2018 Ander Goig. All rights reserved.
//

import Foundation

extension Data {

    /// Returns a Data constructed by appending the given parameters to self.
    func appendingQueryParameters(_ parameters: Parameters) -> Data {
        let string = parameters.map { "&\($0.key)=\($0.value)" }.joined()
        return string.data(using: .utf8)!
    }

    /// Modifies the current Data by appending the given parameters.
    mutating func appendQueryParameters(_ parameters: Parameters) {
        self = appendingQueryParameters(parameters)
    }
}
