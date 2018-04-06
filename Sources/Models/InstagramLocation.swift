//
//  InstagramLocation.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

import CoreLocation

/// The struct containing an Instagram location.
public struct InstagramLocation<T: Decodable>: Decodable {

    // MARK: - Properties

    /// The location identifier.
    public let id: T

    /// The location name.
    public let name: String

    /// The location address.
    public let streetAddress: String?

    /// The location coordinates (latitude and longitude).
    public let coordinates: CLLocationCoordinate2D

    // MARK: - Types

    private enum CodingKeys: String, CodingKey {
        case id, name, streetAddress, latitude, longitude
    }

    // MARK: - Initializers

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(T.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        streetAddress = try container.decodeIfPresent(String.self, forKey: .streetAddress)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
