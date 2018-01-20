//
//  Optional+SwiftInstagram.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 12/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

infix operator ??= : AssignmentPrecedence

extension Optional {

    /// Asigns an optional value to a variable only if the value is not nil.
    static func ??= (lhs: inout Optional, rhs: Optional) {
        guard let rhs = rhs else { return }
        lhs = rhs
    }
}
