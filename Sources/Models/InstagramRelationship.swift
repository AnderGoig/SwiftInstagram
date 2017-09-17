//
//  InstagramRelationship.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

public struct InstagramRelationship: Decodable {
    public let outgoingStatus: String
    public let incomingStatus: String?

    private enum CodingKeys: String, CodingKey {
        case outgoingStatus = "outgoing_status"
        case incomingStatus = "incoming_status"
    }
}
