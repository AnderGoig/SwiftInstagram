//
//  InstagramRelationship.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// The struct containing an Instagram relationship.
public struct InstagramRelationship: Decodable {

    // MARK: - Properties

    /// Your relationship to the user. It can be "follows", "requested" or "none".
    public let outgoingStatus: String

    /// A user's relationship to you. It can be "followed_by", "requested_by", "blocked_by_you" or "none".
    public let incomingStatus: String?
}
