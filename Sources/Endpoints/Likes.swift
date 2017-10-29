//
//  Likes.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    /// Get a list of users who have liked this media.
    ///
    /// - Parameter mediaId: The ID of the media object to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope for media that does not belong to your own user.

    public func likes(inMedia mediaId: String, success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        request("/media/\(mediaId)/likes", success: success, failure: failure)
    }

    /// Set a like on this media by the currently authenticated user.
    ///
    /// - Parameter mediaId: The ID of the media object to reference.
    /// - Parameter failure: The callback called after an incorrect like.
    ///
    /// - Important: It requires *likes* scope. Also, *public_content* scope is required for media that does not belong
    ///   to your own user.

    public func like(media mediaId: String, failure: FailureHandler?) {
        request("/media/\(mediaId)/likes", method: .post, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
    }

    /// Remove a like on this media by the currently authenticated user.
    ///
    /// - Parameter Parameter mediaId: The ID of the media object to reference.
    /// - Parameter failure: The callback called after an incorrect deletion.
    ///
    /// - Important: It requires *likes* scope. Also, *public_content* scope is required for media that does not belong
    ///   to your own user.

    public func unlike(media mediaId: String, failure: FailureHandler?) {
        request("/media/\(mediaId)/likes", method: .delete, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
    }

}
