//
//  InstagramComment.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// The struct containing an Instagram comment.

public struct InstagramComment: Decodable {

    /// The comment identifier.
    public let id: String

    /// The comment text.
    public let text: String

    /// The user who created the comment.
    public let from: InstagramUser

    /// The date and time when the comment was created.
    public var createdDate: Date {
        return Date(timeIntervalSince1970: Double(createdTime)!)
    }

    private let createdTime: String

    private enum CodingKeys: String, CodingKey {
        case id, text, from
        case createdTime = "created_time"
    }

}
