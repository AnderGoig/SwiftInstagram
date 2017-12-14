//
//  Operator++.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 12/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

infix operator ??= : AssignmentPrecedence

extension Optional {

    static func ??= (lhs: inout Optional, rhs: Optional) {
        guard let rhs = rhs else {
            return
        }
        lhs = rhs
    }

}
