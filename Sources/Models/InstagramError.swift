//
//  InstagramError.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

public struct InstagramError: Error {
    public enum ErrorKind {
        case errorDecodingJSON
        case errorStoringAccessToken
        case invalidRequest
    }

    public let kind: ErrorKind
    public let message: String
}
