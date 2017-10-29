//
//  Media.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    /// Get information about a media object.
    ///
    /// - parameter id: The ID of the media object to reference.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.

    public func media(withId id: String, success: SuccessHandler<InstagramMedia>?, failure: FailureHandler?) {
        request("/media/\(id)", success: success, failure: failure)
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
        request("/media/shortcode/\(shortcode)", success: success, failure: failure)
    }

    /// Search for recent media in a given area.
    ///
    /// - parameter lat: Latitude of the center search coordinate. If used, `lng` is required.
    /// - parameter lng: Longitude of the center search coordinate. If used, `lat` is required.
    /// - parameter distance: Default is 1km (1000m), max distance is 5km.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.

    public func searchMedia(lat: Double? = nil,
                            lng: Double? = nil,
                            distance: Int? = nil,
                            success: SuccessHandler<[InstagramMedia]>?,
                            failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["lat"] ??= lat
        parameters["lng"] ??= lng
        parameters["distance"] ??= distance

        request("/media/search", parameters: parameters, success: success, failure: failure)
    }

}
