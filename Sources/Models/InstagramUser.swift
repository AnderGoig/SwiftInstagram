//
//  InstagramUser.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// The struct containing an Instagram user.
public struct InstagramUser: Decodable {

    public let id: String
    public let username: String
    public let profilePicture: String
    public let fullName: String
    public let bio: String?
    public let website: String?
    public let isBusiness: Bool?
    public let counts: Counts?

    public struct Counts: Decodable {
        public let media: Int
        public let follows: Int
        public let followedBy: Int

        private enum CodingKeys: String, CodingKey {
            case media, follows
            case followedBy = "followed_by"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, username, bio, website, counts
        case profilePicture = "profile_picture"
        case fullName = "full_name"
        case isBusiness = "is_business"
    }
    
}
