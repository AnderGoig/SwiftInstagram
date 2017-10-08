//
//  InstagramError.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// The struct containing an Instagram error.

public struct InstagramError: Error {

    enum ErrorKind: CustomStringConvertible {
        case invalidRequest
        case jsonParseError
        case keychainError(code: OSStatus)
        case missingClient

        var description: String {
            switch self {
            case .invalidRequest:
                return "invalidRequest"
            case .jsonParseError:
                return "jsonParseError"
            case .keychainError(let code):
                return "keychainError(code: \(code)"
            case .missingClient:
                return "missingClient"
            }
        }
    }

    let kind: ErrorKind
    let message: String

    public var localizedDescription: String {
        return "[\(kind.description)] - \(message)"
    }

}
