//
//  Media.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

import CoreLocation

extension Instagram {

    // MARK: - Media Endpoints

    /// Get information about a media object.
    ///
    /// - parameter id: The ID of the media object to reference.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
    public func media(withId id: String, success: SuccessHandler<InstagramMedia>?, failure: FailureHandler?) {
        request("/media/\(id)", success: { data in success?(data!) }, failure: failure)
    }

    /// Get information about a media object.
    ///
    /// - parameter shortcode: The shortcode of the media object to reference.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
    ///
    /// - note: A media object's shortcode can be found in its shortlink URL.
    ///   An example shortlink is http://instagram.com/p/tsxp1hhQTG/. Its corresponding shortcode is tsxp1hhQTG.
    public func media(withShortcode shortcode: String, success: SuccessHandler<InstagramMedia>?, failure: FailureHandler?) {
        request("/media/shortcode/\(shortcode)", success: { data in success?(data!) }, failure: failure)
    }

    /// Search for recent media in a given area.
    ///
    /// - parameter latitude: Latitude of the center search coordinate. If used, `longitude` is required.
    /// - parameter longitude: Longitude of the center search coordinate. If used, `latitude` is required.
    /// - parameter distance: Default is 1km (1000m), max distance is 5km.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
    public func searchMedia(latitude: Double? = nil,
                            longitude: Double? = nil,
                            distance: Int? = nil,
                            success: SuccessHandler<[InstagramMedia]>?,
                            failure: FailureHandler?) {

        var parameters = Parameters()

        parameters["lat"] ??= latitude
        parameters["lng"] ??= longitude
        parameters["distance"] ??= distance

        request("/media/search", parameters: parameters, success: { data in success?(data!) }, failure: failure)
    }

    /// Search for recent media in a given area.
    ///
    /// - parameter coordinates: Latitude and longitude of the center search coordinates.
    /// - parameter distance: Default is 1km (1000m), max distance is 5km.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
    public func searchMedia(coordinates: CLLocationCoordinate2D? = nil,
                            distance: Int? = nil,
                            success: SuccessHandler<[InstagramMedia]>?,
                            failure: FailureHandler?) {

        searchMedia(latitude: coordinates?.latitude, longitude: coordinates?.longitude, distance: distance, success: success, failure: failure)
    }
}
