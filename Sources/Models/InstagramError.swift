//
//  InstagramError.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// A type representing an error value that can be thrown.
public enum InstagramError: Error {
    case badRequest
    case decoding(message: String)
    case invalidRequest(message: String)
    case keychainError(code: OSStatus)
    case missingClientIdOrRedirectURI
}
