//
//  Locations.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    /// Get information about a location.
    ///
    /// - Parameter locationId: The ID of the location to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func location(_ locationId: String, success: SuccessHandler<InstagramLocation<String>>?, failure: FailureHandler?) {
        request("/locations/\(locationId)", success: success, failure: failure)
    }

    /// Get a list of recent media objects from a given location.
    ///
    /// - Parameter locationId: The ID of the location to reference.
    /// - Parameter maxId: Return media after this `maxId`.
    /// - Parameter minId: Return media before this `mindId`.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func recentMedia(forLocation locationId: String, maxId: String? = nil, minId: String? = nil, success: SuccessHandler<[InstagramMedia]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["max_id"] ??= maxId
        parameters["min_id"] ??= minId

        request("/locations/\(locationId)/media/recent", parameters: parameters, success: success, failure: failure)
    }

    /// Search for a location by geographic coordinate.
    ///
    /// - Parameter lat: Latitude of the center search coordinate. If used, `lng` is required.
    /// - Parameter lng: Longitude of the center search coordinate. If used, `lat` is required.
    /// - Parameter distance: Default is 500m, max distance is 750.
    /// - Parameter facebookPlacesId: Returns a location mapped off of a Facebook places id.
    ///   If used, `lat` and `lng` are not required.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func searchLocation(lat: Double? = nil, lng: Double? = nil, distance: Int? = nil, facebookPlacesId: String? = nil, success: SuccessHandler<[InstagramLocation<String>]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["lat"] ??= lat
        parameters["lng"] ??= lng
        parameters["distance"] ??= distance
        parameters["facebook_places_id"] ??= facebookPlacesId

        request("/locations/search", parameters: parameters, success: success, failure: failure)
    }

}
