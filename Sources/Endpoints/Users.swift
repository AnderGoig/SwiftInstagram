//
//  Users.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    /// Get information about a user.
    ///
    /// - Parameter userId: The ID of the user whose information to retrieve, or "self" to reference the currently
    ///   logged-in user.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope when getting information about a user other than yours.

    public func user(_ userId: String, success: SuccessHandler<InstagramUser>?, failure: FailureHandler?) {
        request("/users/\(userId)", success: success, failure: failure)
    }

    /// Get the most recent media published by a user.
    ///
    /// - Parameter userId: The ID of the user whose recent media to retrieve, or "self" to reference the currently
    ///   logged-in user.
    /// - Parameter maxId: Return media earlier than this `maxId`.
    /// - Parameter minId: Return media later than this `minId`.
    /// - Parameter count: Count of media to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope when getting recent media published by a user other than yours.

    public func recentMedia(fromUser userId: String, maxId: String? = nil, minId: String? = nil, count: Int? = nil, success: SuccessHandler<[InstagramMedia]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["max_id"] ??= maxId
        parameters["min_id"] ??= minId
        parameters["count"] ??= count

        request("/users/\(userId)/media/recent", parameters: parameters, success: success, failure: failure)
    }

    /// Get the list of recent media liked by your own user.
    ///
    /// - Parameter maxLikeId: Return media liked before this id.
    /// - Parameter count: Count of media to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func userLikedMedia(maxLikeId: String? = nil, count: Int? = nil, success: SuccessHandler<[InstagramMedia]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["max_like_id"] ??= maxLikeId
        parameters["count"] ??= count

        request("/users/self/media/liked", parameters: parameters, success: success, failure: failure)
    }

    /// Get a list of users matching the query.
    ///
    /// - Parameter query: A query string.
    /// - Parameter count: Number of users to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func search(user query: String, count: Int? = nil, success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["q"] = query
        parameters["count"] ??= count

        request("/users/search", parameters: parameters, success: success, failure: failure)
    }

}
