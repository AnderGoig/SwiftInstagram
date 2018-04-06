//
//  InstagramMedia.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

import CoreLocation

/// The struct containing an Instagram media.
public struct InstagramMedia: Decodable {

    // MARK: - Properties

    /// The media identifier.
    public let id: String

    /// The owner of the media.
    public let user: InstagramUser

    /// The date and time when the media was created.
    public let createdDate: Date

    /// The type of media. It can be "image" or "video".
    public let type: String

    /// The thumbnail, low and standard resolution images of the media.
    public let images: Images

    /// The low and standard resolution videos of the media.
    public let videos: Videos?

    /// The headline of the media.
    public let caption: InstagramComment?

    /// A Count object that contains the number of comments on the media.
    public let comments: Count

    /// A Count object that contains the number of likes on the media.
    public let likes: Count

    /// A list of tags used in the media.
    public let tags: [String]

    /// A Boolean value that indicates whether the current logged-in user has liked the media.
    public let userHasLiked: Bool

    /// The image filter used by the media.
    public let filter: String

    /// The URL link of the media.
    public let link: URL

    /// The location of the media.
    public let location: InstagramLocation<Int>?

    /// A list of users and their position on the image.
    public let usersInPhoto: [UserInPhoto]?

    /// If the media is a carousel, this object contains all the images or videos inside it.
    public let carouselMedia: [CarouselMedia]?

    /// The distance to the location of media when it has been searched by location.
    public let distance: Double?

    // MARK: - Types

    /// A struct cointaing the number of elements.
    public struct Count: Decodable {

        /// The number of elements.
        public let count: Int
    }

    /// A struct containing the resolution of a video or image.
    public struct Resolution: Decodable {

        /// The width of the media.
        public let width: Int

        /// The height of the media.
        public let height: Int

        /// The URL to download the media.
        public let url: URL
    }

    /// A struct cointaining the thumbnail, low and high resolution images of the media.
    public struct Images: Decodable {

        /// A Resolution object that contains the width, height and URL of the thumbnail.
        public let thumbnail: Resolution

        /// A Resolution object that contains the width, height and URL of the low resolution image.
        public let lowResolution: Resolution

        /// A Resolution object that contains the width, height and URL of the standard resolution image.
        public let standardResolution: Resolution
    }

    /// A struct cointaining the low and standard resolution videos of the media.
    public struct Videos: Decodable {

        /// A Resolution object that contains the width, height and URL of the low resolution video.
        public let lowResolution: Resolution

        /// A Resolution object that contains the width, height and URL of the standard resolution video.
        public let standardResolution: Resolution

        /// A Resolution object that contains the width, height and URL of the low bandwidth video.
        public let lowBandwidth: Resolution?
    }

    /// A struct containing the user and its position on the image.
    public struct UserInPhoto: Decodable {

        /// The user that appears in the image.
        public let user: UserInPhotoUsername

        /// The position in points of the user in the image.
        public let position: Position

        /// A struct containing the username of the tagged user.
        public struct UserInPhotoUsername: Decodable {

            /// The value of the x-axis.
            public let username: String
        }

        /// A struct containing the value of the coordinate axes, 'x' and 'y'.
        public struct Position: Decodable {

            /// The value of the x-axis.
            public let x: Double

            /// The value of the y-axis.
            public let y: Double
        }
    }

    /// The struct containing the images or videos of the carousel.
    public struct CarouselMedia: Decodable {

        /// The images inside the carousel.
        public let images: Images?

        /// The videos inside the carousel.
        public let videos: Videos?

        /// A list of users and their position on the image.
        public let usersInPhoto: [UserInPhoto]

        /// The type of media. It can be "image" or "video".
        public let type: String
    }

    private enum CodingKeys: String, CodingKey {
        case id, user, createdTime, type, images, videos, caption, comments, likes, tags,
        userHasLiked, filter, link, location, usersInPhoto, carouselMedia, distance
    }

    // MARK: - Initializers

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        user = try container.decode(InstagramUser.self, forKey: .user)
        let createdTime = try container.decode(String.self, forKey: .createdTime)
        createdDate = Date(timeIntervalSince1970: Double(createdTime)!)
        type = try container.decode(String.self, forKey: .type)
        images = try container.decode(Images.self, forKey: .images)
        videos = try container.decodeIfPresent(Videos.self, forKey: .videos)
        caption = try container.decodeIfPresent(InstagramComment.self, forKey: .caption)
        comments = try container.decode(Count.self, forKey: .comments)
        likes = try container.decode(Count.self, forKey: .likes)
        tags = try container.decode([String].self, forKey: .tags)
        userHasLiked = try container.decode(Bool.self, forKey: .userHasLiked)
        filter = try container.decode(String.self, forKey: .filter)
        link = try container.decode(URL.self, forKey: .link)
        location = try container.decodeIfPresent(InstagramLocation<Int>.self, forKey: .location)
        usersInPhoto = try container.decodeIfPresent([UserInPhoto].self, forKey: .usersInPhoto)
        carouselMedia = try container.decodeIfPresent([CarouselMedia].self, forKey: .carouselMedia)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
    }
}
