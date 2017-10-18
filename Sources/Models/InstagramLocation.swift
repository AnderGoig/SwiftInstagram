//
//  InstagramLocation.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 16/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

import CoreLocation

/// The struct containing an Instagram location.

public struct InstagramLocation: Codable {

    /// The location identifier.
    public let id: String

    /// The location name.
    public let name: String

    /// The location address.
    public let streetAddress: String?

    /// The location coordinates (latitude and longitude).
    public var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private let latitude: Double
    private let longitude: Double

    private enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude
        case streetAddress = "street_address"
    }

}
