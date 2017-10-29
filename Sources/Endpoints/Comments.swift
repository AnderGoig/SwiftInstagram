//
//  Comments.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    /// Get a list of recent comments on a media object.
    ///
    /// - Parameter Parameter mediaId: The ID of the media object to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope for media that does not belong to your own user.

    public func comments(fromMedia mediaId: String, success: SuccessHandler<[InstagramComment]>?, failure: FailureHandler?) {
        request("/media/\(mediaId)/comments", success: success, failure: failure)
    }

    /// Create a comment on a media object.
    ///
    /// - Parameter mediaId: The ID of the media object to reference.
    /// - Parameter text: Text to post as a comment on the media object as specified in `mediaId`.
    /// - Parameter failure: The callback called after an incorrect creation.
    ///
    /// - Important: It requires *comments* scope. Also, *public_content* scope is required for media that does not
    ///   belong to your own user.
    ///
    /// - Note:
    ///     - The total length of the comment cannot exceed 300 characters.
    ///     - The comment cannot contain more than 4 hashtags.
    ///     - The comment cannot contain more than 1 URL.
    ///     - The comment cannot consist of all capital letters.

    public func createComment(onMedia mediaId: String, text: String, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["text"] = text

        request("/media/\(mediaId)/comments", method: .post, parameters: parameters, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
    }

    /// Remove a comment either on the authenticated user's media object or authored by the authenticated user.
    ///
    /// - Parameter commentId: The ID of the comment to delete.
    /// - Parameter mediaId: The ID of the media object to reference.
    /// - Parameter failure: The callback called after an incorrect deletion.
    ///
    /// - Important: It requires *comments* scope. Also, *public_content* scope is required for media that does not
    ///   belong to your own user.

    public func deleteComment(_ commentId: String, onMedia mediaId: String, failure: FailureHandler?) {
        request("/media/\(mediaId)/comments/\(commentId)", method: .delete, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
    }

}
