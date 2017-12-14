//
//  String+SwiftInstagram.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 14/12/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension String {

    init?(_ integer: Int?) {
        guard let integer = integer else { return nil }
        self.init(integer)
    }

    init?(_ double: Double?) {
        guard let double = double else { return nil }
        self.init(double)
    }

}
