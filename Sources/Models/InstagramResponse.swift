//
//  InstagramResponse.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

struct InstagramResponse<T: Decodable>: Decodable {

    // MARK: - Properties

    let data: T?
    let meta: Meta
    let pagination: Pagination?

    // MARK: - Types

    struct Meta: Decodable {
        let code: Int
        let errorType: String?
        let errorMessage: String?
    }

    struct Pagination: Decodable {
        let nextUrl: String?
        let nextMaxId: String?
    }
}

/// Dummy struct used for empty Instagram API data responses
public struct InstagramEmptyResponse: Decodable { }
