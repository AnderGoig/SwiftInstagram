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

    /// The media identifier.
    public let id: String

    /// The owner of the media.
    public let user: InstagramUser

    /// The thumbnail, low and standard resolution images of the media.
    public let images: Images

    /// The date and time when the media was created.
    public var createdDate: Date {
        return Date(timeIntervalSince1970: Double(createdTime)!)
    }

    private let createdTime: String

    /// The headline of the media.
    public let caption: InstagramComment?

    /// A Boolean value that indicates whether the current logged-in user has liked the media.
    public let userHasLiked: Bool

    /// A Count object that contains the number of likes on the media.
    public let likes: Count

    /// A list of tags used in the media.
    public let tags: [String]

    /// The image filter used by the media.
    public let filter: String

    /// A Count object that contains the number of comments on the media.
    public let comments: Count

    /// The type of media. It can be "image" or "video".
    public let type: String

    /// The link of the media.
    public let link: String

    /// The location of the media.
    public let location: MediaLocation?

    /// A list of users and their position on the image.
    public let usersInPhoto: [UserInPhoto]

    /// The low and standard resolution videos of the media.
    public let videos: Videos?

    /// If the media is a carousel, this object contains all the images or videos inside it.
    public let carouselMedia: [CarouselMedia]?

    /// The distance to the location of media when it has been searched by location.
    public let distance: Double?

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
        public let url: String
    }

    /// A struct cointaining the thumbnail, low and high resolution images of the media.
    public struct Images: Decodable {

        /// A Resolution object that contains the width, height and URL of the thumbnail.
        public let thumbnail: Resolution

        /// A Resolution object that contains the width, height and URL of the low resolution image.
        public let lowResolution: Resolution

        /// A Resolution object that contains the width, height and URL of the standard resolution image.
        public let standardResolution: Resolution

        private enum CodingKeys: String, CodingKey {
            case thumbnail
            case lowResolution = "low_resolution"
            case standardResolution = "standard_resolution"
        }
    }

    /// A struct cointaining the low and standard resolution videos of the media.
    public struct Videos: Decodable {

        /// A Resolution object that contains the width, height and URL of the low resolution video.
        public let lowResolution: Resolution

        /// A Resolution object that contains the width, height and URL of the standard resolution video.
        public let standardResolution: Resolution

        /// A Resolution object that contains the width, height and URL of the low bandwidth video.
        public let lowBandwidth: Resolution?

        private enum CodingKeys: String, CodingKey {
            case lowResolution = "low_resolution"
            case standardResolution = "standard_resolution"
            case lowBandwidth = "low_bandwidth"
        }
    }

    /// A struct containing the location of the media.
    public struct MediaLocation: Codable {

        /// The location identifier.
        public let id: Int

        /// The location name.
        public let name: String

        /// The location coordinates (latitude and logitude).
        public var coordinates: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        private let latitude: Double
        private let longitude: Double

        private enum CodingKeys: String, CodingKey {
            case id, name, latitude, longitude
        }
    }

    /// A struct containing the user and its position on the image.
    public struct UserInPhoto: Decodable {

        /// The user that appears in the image.
        public let user: InstagramUser

        /// The position in points of the user in the image.
        public let position: Position

        /// A struct that containing the value of the coordinate axes, 'x' and 'y'.
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
