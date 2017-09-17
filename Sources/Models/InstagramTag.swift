//
//  InstagramTag.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

public struct InstagramTag: Decodable {
    public let mediaCount: Int
    public let name: String

    private enum CodingKeys: String, CodingKey {
        case mediaCount = "media_count"
        case name
    }
}
