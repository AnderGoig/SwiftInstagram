//
//  InstagramRelationship.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// The struct containing an Instagram relationship.

public struct InstagramRelationship: Decodable {

    /// Your relationship to the user. Can be "follows", "requested", "none".
    public let outgoingStatus: String

    /// A user's relationship to you. Can be "followed_by", "requested_by", "blocked_by_you", "none".
    public let incomingStatus: String?

    private enum CodingKeys: String, CodingKey {
        case outgoingStatus = "outgoing_status"
        case incomingStatus = "incoming_status"
    }

}
