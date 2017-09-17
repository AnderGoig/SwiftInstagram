//
//  InstagramComment.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

public struct InstagramComment: Decodable {
    public let id: String
    public let text: String
    public let createdTime: String
    public let from: InstagramUser

    private enum CodingKeys: String, CodingKey {
        case id, text, from
        case createdTime = "created_time"
    }
}
