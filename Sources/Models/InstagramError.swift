//
//  InstagramError.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// A type representing an error value that can be thrown.
public enum InstagramError: Error {

    /// Error 400 on login
    case badRequest

    /// Error decoding JSON
    case decoding(message: String)

    /// Invalid API request
    case invalidRequest(message: String)

    /// Keychain error
    case keychainError(code: OSStatus)

    /// The client id or the redirect URI is missing inside the Info.plist file
    case missingClientIdOrRedirectURI
}
