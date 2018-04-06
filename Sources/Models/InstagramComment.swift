//
//  InstagramComment.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// The struct containing an Instagram comment.
public struct InstagramComment: Decodable {

    // MARK: - Properties

    /// The comment identifier.
    public let id: String

    /// The comment text.
    public let text: String

    /// The user who created the comment.
    public let from: InstagramUser

    /// The date and time when the comment was created.
    public let createdDate: Date

    // MARK: - Types

    private enum CodingKeys: String, CodingKey {
        case id, text, from, createdTime
    }

    // MARK: - Initializers

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        from = try container.decode(InstagramUser.self, forKey: .from)
        let createdTime = try container.decode(String.self, forKey: .createdTime)
        createdDate = Date(timeIntervalSince1970: Double(createdTime)!)
    }
}
