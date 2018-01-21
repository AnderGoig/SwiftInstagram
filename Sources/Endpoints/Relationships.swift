//
//  Relationships.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    // MARK: - Relationship Endpoints

    /// Relationship actions currently supported by Instagram.
    private enum RelationshipAction: String {
        case follow, unfollow, approve, ignore
    }

    /// Get the list of users this user follows.
    ///
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *follower_list* scope.
    public func userFollows(success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        request("/users/self/follows", success: { data in success?(data!) }, failure: failure)
    }

    /// Get the list of users this user is followed by.
    ///
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *follower_list* scope.
    public func userFollowers(success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        request("/users/self/followed-by", success: { data in success?(data!) }, failure: failure)
    }

    /// List the users who have requested this user's permission to follow.
    ///
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *follower_list* scope.
    public func userRequestedBy(success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        request("/users/self/requested-by", success: { data in success?(data!) }, failure: failure)
    }

    /// Get information about a relationship to another user.
    ///
    /// - parameter userId: The ID of the user to reference.
    /// - parameter success: The callback called after a correct retrieval.
    /// - parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - important: It requires *follower_list* scope.
    public func userRelationship(withUser userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        request("/users/\(userId)/relationship", success: { data in success?(data!) }, failure: failure)
    }

    /// Modify the relationship between the current user and the target user.
    ///
    /// - parameter userId: The ID of the user to reference.
    /// - parameter action: Follow, unfollow, approve or ignore.
    /// - parameter success: The callback called after a correct modification.
    /// - parameter failure: The callback called after an incorrect modification.
    ///
    /// - important: It requires *relationships* scope.
    private func modifyUserRelationship(withUser userId: String,
                                        action: RelationshipAction,
                                        success: SuccessHandler<InstagramRelationship>?,
                                        failure: FailureHandler?) {

        request("/users/\(userId)/relationship", method: .post, parameters: ["action": action.rawValue], success: { data in success?(data!) }, failure: failure)
    }

    /// Follows the target user.
    ///
    /// - parameter userId: The ID of the user to reference.
    /// - parameter success: The callback called after a correct follow.
    /// - parameter failure: The callback called after an incorrect follow.
    ///
    /// - important: It requires *relationships* scope.
    public func follow(user userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        modifyUserRelationship(withUser: userId, action: .follow, success: success, failure: failure)
    }

    /// Unfollows the target user.
    ///
    /// - parameter userId: The ID of the user to reference.
    /// - parameter success: The callback called after a correct unfollow.
    /// - parameter failure: The callback called after an incorrect unfollow.
    ///
    /// - important: It requires *relationships* scope.
    public func unfollow(user userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        modifyUserRelationship(withUser: userId, action: .unfollow, success: success, failure: failure)
    }

    /// Approve the target user's request.
    ///
    /// - parameter userId: The ID of the user to reference.
    /// - parameter success: The callback called after a correct approve.
    /// - parameter failure: The callback called after an incorrect approve.
    ///
    /// - important: It requires *relationships* scope.
    public func approveRequest(fromUser userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        modifyUserRelationship(withUser: userId, action: .approve, success: success, failure: failure)
    }

    /// Ignore the target user's request.
    ///
    /// - parameter userId: The ID of the user to reference.
    /// - parameter success: The callback called after a correct ignore.
    /// - parameter failure: The callback called after an incorrect ignore.
    ///
    /// - important: It requires *relationships* scope.
    public func ignoreRequest(fromUser userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        modifyUserRelationship(withUser: userId, action: .ignore, success: success, failure: failure)
    }
}
