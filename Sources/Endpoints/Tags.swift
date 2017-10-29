//
//  Tags.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    /// Get information about a tag object.
    ///
    /// - Parameter tagName: The name of the tag to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func tag(_ tagName: String, success: SuccessHandler<InstagramTag>?, failure: FailureHandler?) {
        request("/tags/\(tagName)", success: success, failure: failure)
    }

    /// Get a list of recently tagged media.
    ///
    /// - Parameter tagName: The name of the tag to reference.
    /// - Parameter maxTagId: Return media after this `maxTagId`.
    /// - Parameter minTagId: Return media before this `minTagId`.
    /// - Parameter count: Count of tagged media to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func recentMedia(withTag tagName: String,
                            maxTagId: String? = nil,
                            minTagId: String? = nil,
                            count: Int? = nil,
                            success: SuccessHandler<[InstagramMedia]>?,
                            failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["max_tag_id"] ??= maxTagId
        parameters["min_tag_id"] ??= minTagId
        parameters["count"] ??= count

        request("/tags/\(tagName)/media/recent", parameters: parameters, success: success, failure: failure)
    }

    /// Search for tags by name.
    ///
    /// - Parameter query: A valid tag name without a leading #. (eg. snowy, nofilter)
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func search(tag query: String, success: SuccessHandler<[InstagramTag]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["q"] = query

        request("/tags/search", parameters: parameters, success: success, failure: failure)
    }

}
