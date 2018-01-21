//
//  Users.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    // MARK: - User Endpoints

    /// Get information about a user.
    ///
    /// - parameter userId: The ID of the user whose information to retrieve, or "self" to reference the currently authenticated user.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope when getting information about a user other than yours.
    public func user(_ userId: String, success: SuccessHandler<InstagramUser>?, failure: FailureHandler?) {
        request("/users/\(userId)", success: { data in success?(data!) }, failure: failure)
    }

    /// Get the most recent media published by a user.
    ///
    /// - parameter userId: The ID of the user whose recent media to retrieve, or "self" to reference the currently authenticated user.
    /// - parameter maxId: Return media earlier than this `maxId`.
    /// - parameter minId: Return media later than this `minId`.
    /// - parameter count: Count of media to return.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope when getting recent media published by a user other than yours.
    public func recentMedia(fromUser userId: String,
                            maxId: String? = nil,
                            minId: String? = nil,
                            count: Int? = nil,
                            success: SuccessHandler<[InstagramMedia]>?,
                            failure: FailureHandler?) {

        var parameters = Parameters()

        parameters["max_id"] ??= maxId
        parameters["min_id"] ??= minId
        parameters["count"] ??= count

        request("/users/\(userId)/media/recent", parameters: parameters, success: { data in success?(data!) }, failure: failure)
    }

    /// Get the list of recent media liked by the currently authenticated user.
    ///
    /// - parameter maxLikeId: Return media liked before this id.
    /// - parameter count: Count of media to return.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
    public func userLikedMedia(maxLikeId: String? = nil, count: Int? = nil, success: SuccessHandler<[InstagramMedia]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["max_like_id"] ??= maxLikeId
        parameters["count"] ??= count

        request("/users/self/media/liked", parameters: parameters, success: { data in success?(data!) }, failure: failure)
    }

    /// Get a list of users matching the query.
    ///
    /// - parameter query: A query string.
    /// - parameter count: Number of users to return.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope.
    public func search(user query: String, count: Int? = nil, success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["q"] = query
        parameters["count"] ??= count

        request("/users/search", parameters: parameters, success: { data in success?(data!) }, failure: failure)
    }
}
