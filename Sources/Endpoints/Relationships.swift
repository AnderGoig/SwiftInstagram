//
//  Relationships.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 29/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

extension Instagram {

    /// Relationship actions currently supported by Instagram.

    private enum RelationshipAction: String {
        case follow, unfollow, approve, ignore
    }

    /// Get the list of users this user follows.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userFollows(success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        request("/users/self/follows", success: success, failure: failure)
    }

    /// Get the list of users this user is followed by.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userFollowers(success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        request("/users/self/followed-by", success: success, failure: failure)
    }

    /// List the users who have requested this user's permission to follow.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userRequestedBy(success: SuccessHandler<[InstagramUser]>?, failure: FailureHandler?) {
        request("/users/self/requested-by", success: success, failure: failure)
    }

    /// Get information about a relationship to another user.
    ///
    /// - Parameter userId: The ID of the user to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userRelationship(withUser userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        request("/users/\(userId)/relationship", success: success, failure: failure)
    }

    /// Modify the relationship between the current user and the target user.
    ///
    /// - Parameter userId: The ID of the user to reference.
    /// - Parameter action: Follow, unfollow, approve or ignore.
    /// - Parameter success: The callback called after a correct modification.
    /// - Parameter failure: The callback called after an incorrect modification.
    ///
    /// - Important: It requires *relationships* scope.

    private func modifyUserRelationship(withUser userId: String,
                                        action: RelationshipAction,
                                        success: SuccessHandler<InstagramRelationship>?,
                                        failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["action"] = action.rawValue

        request("/users/\(userId)/relationship", method: .post, parameters: parameters, success: success, failure: failure)
    }

    /// Follows the target user.
    ///
    /// - Parameter userId: The ID of the user to reference.
    /// - Parameter success: The callback called after a correct follow.
    /// - Parameter failure: The callback called after an incorrect follow.
    ///
    /// - Important: It requires *relationships* scope.

    public func follow(user userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        modifyUserRelationship(withUser: userId, action: .follow, success: success, failure: failure)
    }

    /// Unfollows the target user.
    ///
    /// - Parameter userId: The ID of the user to reference.
    /// - Parameter success: The callback called after a correct unfollow.
    /// - Parameter failure: The callback called after an incorrect unfollow.
    ///
    /// - Important: It requires *relationships* scope.

    public func unfollow(user userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        modifyUserRelationship(withUser: userId, action: .unfollow, success: success, failure: failure)
    }

    /// Approve the target user's request.
    ///
    /// - Parameter userId: The ID of the user to reference.
    /// - Parameter success: The callback called after a correct approve.
    /// - Parameter failure: The callback called after an incorrect approve.
    ///
    /// - Important: It requires *relationships* scope.

    public func approveRequest(fromUser userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        modifyUserRelationship(withUser: userId, action: .approve, success: success, failure: failure)
    }

    /// Ignore the target user's request.
    ///
    /// - Parameter userId: The ID of the user to reference.
    /// - Parameter success: The callback called after a correct ignore.
    /// - Parameter failure: The callback called after an incorrect ignore.
    ///
    /// - Important: It requires *relationships* scope.

    public func ignoreRequest(fromUser userId: String, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
        modifyUserRelationship(withUser: userId, action: .ignore, success: success, failure: failure)
    }

}
