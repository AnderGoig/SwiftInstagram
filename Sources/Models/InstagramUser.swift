//
//  InstagramUser.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// The struct containing an Instagram user.
public struct InstagramUser: Decodable {

    // MARK: - Properties

    /// The user identifier.
    public let id: String

    /// The user's username.
    public let username: String

    /// The URL of the user's profile picture.
    public let profilePicture: URL

    /// The user's full name.
    public let fullName: String

    /// The text of the user's biography.
    public let bio: String?

    /// The user's website.
    public let website: String?

    /// A Boolean value that indicates whether the user has a business profile.
    public let isBusiness: Bool?

    /// A Counts object that contains the number of followers, following and media of a user.
    public let counts: Counts?

    // MARK: - Types

    /// The struct containing the number of followers, following and media of a user.
    public struct Counts: Decodable {

        /// The number of media uploaded by the user.
        public let media: Int

        /// The number os users followed by the user.
        public let follows: Int

        /// The number of followers of the user.
        public let followedBy: Int
    }
}
