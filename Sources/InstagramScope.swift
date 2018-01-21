//
//  InstagramScope.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 5/10/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

/// Login permissions ([scopes](https://www.instagram.com/developer/authorization/)) currently supported by Instagram.
public enum InstagramScope: String {

    /// To read a user’s profile info and media.
    case basic

    /// To read any public profile info and media on a user’s behalf.
    case publicContent = "public_content"

    /// To read the list of followers and followed-by users.
    case followerList = "follower_list"

    /// To post and delete comments on a user’s behalf.
    case comments

    /// To follow and unfollow accounts on a user’s behalf.
    case relationships

    /// To like and unlike media on a user’s behalf.
    case likes

    /// To get all permissions.
    case all = "basic+public_content+follower_list+comments+relationships+likes"
}
