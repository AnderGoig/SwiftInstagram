//
//  InstagramError.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// A type representing an error value that can be thrown.

public struct InstagramError: Error {

    // MARK: - Properties

    let kind: ErrorKind
    let message: String

    /// Retrieve the localized description for this error.
    public var localizedDescription: String {
        return "[\(kind.description)] - \(message)"
    }

    // MARK: - Types

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

}
