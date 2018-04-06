//
//  Comments.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    // MARK: - Comment Endpoints

    /// Get a list of recent comments on a media object.
    ///
    /// - parameter Parameter mediaId: The ID of the media object to reference.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *public_content* scope for media that does not belong to your own user.
    public func comments(fromMedia mediaId: String, success: SuccessHandler<[InstagramComment]>?, failure: FailureHandler?) {
        request("/media/\(mediaId)/comments", success: { data in success?(data!) }, failure: failure)
    }

    /// Create a comment on a media object.
    ///
    /// - parameter mediaId: The ID of the media object to reference.
    /// - parameter text: Text to post as a comment on the media object as specified in `mediaId`.
    /// - parameter failure: The callback called after an incorrect creation.
    ///
    /// - important: It requires *comments* scope. Also, *public_content* scope is required for media that does not belong to your own user.
    ///
    /// - note:
    ///     - The total length of the comment cannot exceed 300 characters.
    ///     - The comment cannot contain more than 4 hashtags.
    ///     - The comment cannot contain more than 1 URL.
    ///     - The comment cannot consist of all capital letters.
    public func createComment(onMedia mediaId: String, text: String, success: SuccessHandler<InstagramComment>?, failure: FailureHandler?) {
        request("/media/\(mediaId)/comments", method: .post, parameters: ["text": text], success: { data in success?(data!) }, failure: failure)
    }

    /// Remove a comment either on the authenticated user's media object or authored by the authenticated user.
    ///
    /// - parameter commentId: The ID of the comment to delete.
    /// - parameter mediaId: The ID of the media object to reference.
    /// - parameter failure: The callback called after an incorrect deletion.
    ///
    /// - important: It requires *comments* scope. Also, *public_content* scope is required for media that does not belong to your own user.
    public func deleteComment(_ commentId: String, onMedia mediaId: String, success: EmptySuccessHandler?, failure: FailureHandler?) {
        request("/media/\(mediaId)/comments/\(commentId)", method: .delete, success: { (_: InstagramEmptyResponse!) in success?() }, failure: failure)
    }
}
