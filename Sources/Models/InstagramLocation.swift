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

    let latitude: Double
    let longitude: Double
    public let id: String
    public let name: String
    public let streetAddress: String?

    public var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

    private enum CodingKeys: String, CodingKey {
        case latitude, longitude, id, name
        case streetAddress = "street_address"
    }

}
