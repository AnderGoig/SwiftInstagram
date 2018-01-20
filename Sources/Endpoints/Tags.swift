//
//  Tags.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    // MARK: - Tag Endpoints

    /// Get information about a tag object.
    ///
    /// - parameter tagName: The name of the tag to reference.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
    public func tag(_ tagName: String, success: SuccessHandler<InstagramTag>?, failure: FailureHandler?) {
        request("/tags/\(tagName)", success: { data in success?(data!) }, failure: failure)
    }

    /// Get a list of recently tagged media.
    ///
    /// - parameter tagName: The name of the tag to reference.
    /// - parameter maxTagId: Return media after this `maxTagId`.
    /// - parameter minTagId: Return media before this `minTagId`.
    /// - parameter count: Count of tagged media to return.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
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

        request("/tags/\(tagName)/media/recent", parameters: parameters, success: { data in success?(data!) }, failure: failure)
    }

    /// Search for tags by name.
    ///
    /// - parameter query: A valid tag name without a leading #. (eg. snowy, nofilter)
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
    public func search(tag query: String, success: SuccessHandler<[InstagramTag]>?, failure: FailureHandler?) {
        request("/tags/search", parameters: ["q": query], success: { data in success?(data!) }, failure: failure)
    }
}
