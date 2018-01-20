//
//  Data+SwiftInstagram.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 20/1/18.
//  Copyright © 2018 Ander Goig. All rights reserved.
//

import Foundation

extension Data {

    init(parameters: Parameters) {
        self = parameters.map { "\($0.key)=\($0.value)&" }.joined().data(using: .utf8)!
    }
}
