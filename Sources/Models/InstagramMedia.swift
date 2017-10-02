//
//  InstagramMedia.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// The struct containing an Instagram media.
public struct InstagramMedia: Decodable {

    public let id: String
    public let user: InstagramUser
    public let images: Images
    public let createdTime: String
    public let caption: InstagramComment?
    public let userHasLiked: Bool
    public let likes: Count
    public let tags: [String]
    public let filter: String
    public let comments: Count
    public let type: String
    public let link: String
    public let location: InstagramLocation?
    public let usersInPhoto: [UserInPhoto]
    public let videos: Videos?
    public let carouselMedia: [CarouselMedia]?
    public let distance: Double?

    public struct Resolution: Decodable {
        public let width: Int
        public let height: Int
        public let url: String
    }

    public struct Images: Decodable {
        public let thumbnail: Resolution
        public let lowResolution: Resolution
        public let standardResolution: Resolution

        private enum CodingKeys: String, CodingKey {
            case thumbnail
            case lowResolution = "low_resolution"
            case standardResolution = "standard_resolution"
        }
    }

    public struct Count: Decodable {
        public let count: Int
    }

    public struct UserInPhoto: Decodable {
        public let user: InstagramUser
        public let position: Position

        public struct Position: Decodable {
            public let x: Double
            public let y: Double
        }
    }

    public struct Videos: Decodable {
        public let lowResolution: Resolution
        public let standardResolution: Resolution
        public let lowBandwidth: Resolution?

        private enum CodingKeys: String, CodingKey {
            case lowResolution = "low_resolution"
            case standardResolution = "standard_resolution"
            case lowBandwidth = "low_bandwidth"
        }
    }

    public struct CarouselMedia: Decodable {
        public let images: Images?
        public let videos: Videos?
        public let usersInPhoto: [UserInPhoto]
        public let type: String

        private enum CodingKeys: String, CodingKey {
            case images, videos, type
            case usersInPhoto = "users_in_photo"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, user, images, caption, likes, tags, filter, comments, type, link, location, videos, distance
        case createdTime = "created_time"
        case userHasLiked = "user_has_liked"
        case usersInPhoto = "users_in_photo"
        case carouselMedia = "carousel_media"
    }

}
