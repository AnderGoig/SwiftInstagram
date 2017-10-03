//
//  Instagram.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 15/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

import UIKit

/// A set of helper functions to make the Instagram API easier to use.

public class Instagram {

    // MARK: - Types

    public typealias EmptySuccessHandler = () -> Void
    public typealias SuccessHandler<T> = (_ data: T) -> Void
    public typealias FailureHandler = (_ error: Error) -> Void

    // MARK: - Properties

    private let keychain = KeychainSwift()
    private var clientId: String?

    // MARK: - Initializers

    public static let shared = Instagram()

    private init() {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let clientId = dict["InstagramClientId"] as? String {
                self.clientId = clientId
            }
        }
    }

    // MARK: - Authentication

    /// Starts an authentication process.
    ///
    /// Shows a custom `UIViewController` with Intagram's login page.
    ///
    /// - Parameter navController: Your current `UINavigationController`.
    /// - Parameter authScope: The scope of the access you are requesting from the user. Basic access by default.
    /// - Parameter redirectURI: Your Instagram API client redirection URI.
    /// - Parameter success: The callback called after a correct login.
    /// - Parameter failure: The callback called after an incorrect login.
    ///
    /// - Note: More information about the login permissions (scope)
    ///   [here](https://www.instagram.com/developer/authorization/).

    public func login(navController: UINavigationController, authScope: String = "basic", redirectURI: String, success: EmptySuccessHandler? = nil, failure: FailureHandler? = nil) {
        let vc = InstagramLoginViewController(clientId: self.clientId!, authScope: authScope, redirectURI: redirectURI, success: { accessToken in
            if !self.keychain.set(accessToken, forKey: "accessToken") {
                failure?(InstagramError(kind: .keychainError(code: self.keychain.lastResultCode), message: "Error storing access token into keychain."))
            } else {
                success?()
            }
        }, failure: failure)

        navController.show(vc, sender: nil)
    }

    /// Returns whether a session is currently available or not.
    ///
    /// - Returns: True if a session is currently available, false otherwise.

    public func isSessionValid() -> Bool {
        return self.keychain.get("accessToken") != nil
    }

    /// Ends the current session.
    ///
    /// - Returns: True if the user was successfully logged out, false otherwise.

    public func logout() -> Bool {
        return self.keychain.delete("accessToken")
    }

    // MARK: -

    private let decoder = JSONDecoder()

    private func dataTask<T: Decodable>(url: URL, method: String, success: SuccessHandler<T>? = nil, failure: FailureHandler? = nil) {
        var request = URLRequest(url: url)
        request.httpMethod = method

        let session = URLSession(configuration: .default)

        session.dataTask(with: request) { (data, _ response, error) in
            if let data = data {
                DispatchQueue.global(qos: .utility).async {
                    do {
                        let object = try self.decoder.decode(InstagramResponse<T>.self, from: data)
                        if let errorMessage = object.meta.errorMessage {
                            DispatchQueue.main.async {
                                failure?(InstagramError(kind: .invalidRequest, message: errorMessage))
                            }
                        } else {
                            DispatchQueue.main.async {
                                success?(object.data!)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            failure?(InstagramError(kind: .jsonParseError, message: error.localizedDescription))
                        }
                    }
                }
            }
        }.resume()
    }

    private func get<T: Decodable>(_ url: URL, success: SuccessHandler<T>? = nil, failure: FailureHandler? = nil) {
        dataTask(url: url, method: "GET", success: success, failure: failure)
    }

    private func post<T: Decodable>(_ url: URL, success: SuccessHandler<T>? = nil, failure: FailureHandler? = nil) {
        dataTask(url: url, method: "POST", success: success, failure: failure)
    }

    private func delete<T: Decodable>(_ url: URL, success: SuccessHandler<T>? = nil, failure: FailureHandler? = nil) {
        dataTask(url: url, method: "DELETE", success: success, failure: failure)
    }

    private func buildURL(for endpoint: String, withParams params: [String: String] = [String: String]()) -> URL {
        var urlComps = URLComponents(string: InstagramURL.api + endpoint)

        var items = [URLQueryItem]()

        let accessToken = self.keychain.get("accessToken")
        items.append(URLQueryItem(name: "access_token", value: accessToken ?? ""))

        for (key, value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }

        urlComps?.queryItems = items

        return urlComps!.url!
    }

    // MARK: - User Endpoints

    /// Get information about a user.
    ///
    /// - Parameter userId: User identifier or `"self"`.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope when getting information about a user other than yours.
    ///
    /// - Note: Use `"self"` in the `userId` parameter in order to get information about your own user.

    public func user(_ userId: String, success: SuccessHandler<InstagramUser>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/users/\(userId)")

        get(url, success: success, failure: failure)
    }

    /// Get the most recent media published by a user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter maxId: Return media earlier than this `maxId`.
    /// - Parameter minId: Return media later than this `minId`.
    /// - Parameter count: Count of media to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope when getting recent media published by a user other than yours.
    ///
    /// - Note: Use *"self"* in the *userId* parameter in order to get the most recent media published by your own user.

    public func recentMedia(fromUser userId: String, maxId: String = "", minId: String = "", count: Int = 0, success: SuccessHandler<[InstagramMedia]>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        if !maxId.isEmpty { params["max_id"] = maxId }
        if !minId.isEmpty { params["min_id"] = minId }
        if count != 0 { params["count"] = String(count) }

        let url = buildURL(for: "/users/\(userId)/media/recent", withParams: params)

        get(url, success: success, failure: failure)
    }

    /// Get the list of recent media liked by your own user.
    ///
    /// - Parameter maxLikeId: Return media liked before this id.
    /// - Parameter count: Count of media to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func userLikedMedia(maxLikeId: String = "", count: Int = 0, success: SuccessHandler<[InstagramMedia]>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        if !maxLikeId.isEmpty { params["max_like_id"] = maxLikeId }
        if count != 0 { params["count"] = String(count) }

        let url = buildURL(for: "/users/self/media/liked", withParams: params)

        get(url, success: success, failure: failure)
    }

    /// Get a list of users matching the query.
    ///
    /// - Parameter query: A query string.
    /// - Parameter count: Number of users to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func search(user query: String, count: Int = 0, success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        params["q"] = query
        if count != 0 { params["count"] = String(count) }

        let url = buildURL(for: "/users/search", withParams: params)

        get(url, success: success, failure: failure)
    }

    // MARK: - Relationship Endpoints

    /// Get the list of users this user follows.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userFollows(success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/users/self/follows")

        get(url, success: success, failure: failure)
    }

    /// Get the list of users this user is followed by.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userFollowers(success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/users/self/followed-by")

        get(url, success: success, failure: failure)
    }

    /// List the users who have requested this user's permission to follow.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userRequestedBy(success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/users/self/requested-by")

        get(url, success: success, failure: failure)
    }

    /// Get information about a relationship to another user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userRelationship(withUser userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/users/\(userId)/relationship")

        get(url, success: success, failure: failure)
    }

    /// Modify the relationship between the current user and the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter action: follow | unfollow | approve | ignore
    /// - Parameter success: The callback called after a correct modification.
    /// - Parameter failure: The callback called after an incorrect modification.
    ///
    /// - Important: It requires *relationships* scope.

    private func modifyUserRelationship(withUser userId: String, action: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        params["action"] = action

        let url = buildURL(for: "/users/\(userId)/relationship", withParams: params)

        post(url, success: success, failure: failure)
    }

    /// Follows the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct follow.
    /// - Parameter failure: The callback called after an incorrect follow.
    ///
    /// - Important: It requires *relationships* scope.

    public func follow(user userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        modifyUserRelationship(withUser: userId, action: "follow", success: success, failure: failure)
    }

    /// Unfollows the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct unfollow.
    /// - Parameter failure: The callback called after an incorrect unfollow.
    ///
    /// - Important: It requires *relationships* scope.

    public func unfollow(user userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        modifyUserRelationship(withUser: userId, action: "unfollow", success: success, failure: failure)
    }

    /// Approve the target user's request.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct approve.
    /// - Parameter failure: The callback called after an incorrect approve.
    ///
    /// - Important: It requires *relationships* scope.

    public func approveRequest(fromUser userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        modifyUserRelationship(withUser: userId, action: "approve", success: success, failure: failure)
    }

    /// Ignore the target user's request.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct ignore.
    /// - Parameter failure: The callback called after an incorrect ignore.
    ///
    /// - Important: It requires *relationships* scope.

    public func ignoreRequest(fromUser userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        modifyUserRelationship(withUser: userId, action: "ignore", success: success, failure: failure)
    }

    // MARK: - Media Endpoints

    /// Get information about a media object.
    ///
    /// - Parameter id: Media identifier.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func media(withId id: String, success: SuccessHandler<InstagramMedia>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/media/\(id)")

        get(url, success: success, failure: failure)
    }

    /// Get information about a media object.
    ///
    /// - Parameter shortcode: Media shortcode.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.
    ///
    /// - Note: A media object's shortcode can be found in its shortlink URL.
    ///   An example shortlink is http://instagram.com/p/tsxp1hhQTG/. Its corresponding shortcode is tsxp1hhQTG.

    public func media(withShortcode shortcode: String, success: SuccessHandler<InstagramMedia>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/media/shortcode/\(shortcode)")

        get(url, success: success, failure: failure)
    }

    /// Search for recent media in a given area.
    ///
    /// - Parameter lat: Latitude of the center search coordinate. If used, `lng` is required.
    /// - Parameter lng: Longitude of the center search coordinate. If used, `lat` is required.
    /// - Parameter distance: Default is 1km (1000m), max distance is 5km.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func searchMedia(lat: Double = 0, lng: Double = 0, distance: Int = 0, success: SuccessHandler<[InstagramMedia]>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        if lat != 0 { params["lat"] = String(lat) }
        if lng != 0 { params["lng"] = String(lng) }
        if distance != 0 { params["distance"] = String(distance) }

        let url = buildURL(for: "/media/search", withParams: params)

        get(url, success: success, failure: failure)
    }

    // MARK: - Comment Endpoints

    /// Get a list of recent comments on a media object.
    ///
    /// - Parameter Parameter mediaId: Media identifier.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope for media that does not belong to your own user.

    public func comments(fromMedia mediaId: String, success: SuccessHandler<[InstagramComment]>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/media/\(mediaId)/comments")

        get(url, success: success, failure: failure)
    }

    /// Create a comment on a media object.
    ///
    /// - Parameter mediaId: Media identifier.
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

    public func createComment(onMedia mediaId: String, text: String, failure: FailureHandler? = nil) {
        var params = [String: String]()

        params["text"] = text

        let url = buildURL(for: "/media/\(mediaId)/comments", withParams: params)

        post(url, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
    }

    /// Remove a comment either on the authenticated user's media object or authored by the authenticated user.
    ///
    /// - Parameter commentId: Comment identifier.
    /// - Parameter mediaId: Media identifier.
    /// - Parameter failure: The callback called after an incorrect deletion.
    ///
    /// - Important: It requires *comments* scope. Also, *public_content* scope is required for media that does not
    ///   belong to your own user.

    public func deleteComment(_ commentId: String, onMedia mediaId: String, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/media/\(mediaId)/comments/\(commentId)")

        delete(url, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
    }

    // MARK: - Like Endpoints

    /// Get a list of users who have liked this media.
    ///
    /// - Parameter mediaId: Media identifier.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope for media that does not belong to your own user.

    public func likes(inMedia mediaId: String, success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/media/\(mediaId)/likes")

        get(url, success: success, failure: failure)
    }

    /// Set a like on this media by the currently authenticated user.
    ///
    /// - Parameter mediaId: Media identifier.
    /// - Parameter failure: The callback called after an incorrect like.
    ///
    /// - Important: It requires *likes* scope. Also, *public_content* scope is required for media that does not belong
    ///   to your own user.

    public func like(media mediaId: String, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/media/\(mediaId)/likes")

        post(url, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
    }

    /// Remove a like on this media by the currently authenticated user.
    ///
    /// - Parameter Parameter mediaId: Media identifier.
    /// - Parameter failure: The callback called after an incorrect deletion.
    ///
    /// - Important: It requires *likes* scope. Also, *public_content* scope is required for media that does not belong
    ///   to your own user.

    public func unlike(media mediaId: String, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/media/\(mediaId)/likes")

        delete(url, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
    }

    // MARK: - Tag Endpoints

    /// Get information about a tag object.
    ///
    /// - Parameter tagName: Tag name.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func tag(_ tagName: String, success: SuccessHandler<InstagramTag>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/tags/\(tagName)")

        get(url, success: success, failure: failure)
    }

    /// Get a list of recently tagged media.
    ///
    /// - Parameter tagName: Tag name.
    /// - Parameter maxTagId: Return media after this `maxTagId`.
    /// - Parameter minTagId: Return media before this `minTagId`.
    /// - Parameter count: Count of tagged media to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func recentMedia(withTag tagName: String, maxTagId: String = "", minTagId: String = "", count: Int = 0, success: SuccessHandler<[InstagramMedia]>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        if !maxTagId.isEmpty { params["max_tag_id"] = maxTagId }
        if !minTagId.isEmpty { params["min_tag_id"] = minTagId }
        if count != 0 { params["count"] = String(count) }

        let url = buildURL(for: "/tags/\(tagName)/media/recent", withParams: params)

        get(url, success: success, failure: failure)
    }

    /// Search for tags by name.
    ///
    /// - Parameter query: A valid tag name without a leading #. (eg. snowy, nofilter)
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func search(tag query: String, success: SuccessHandler<[InstagramTag]>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        params["q"] = query

        let url = buildURL(for: "/tags/search", withParams: params)

        get(url, success: success, failure: failure)
    }

    // MARK: - Location Endpoints

    /// Get information about a location.
    ///
    /// - Parameter Parameter locationId: Location identifier.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func location(_ locationId: String, success: SuccessHandler<InstagramLocation>? = nil, failure: FailureHandler? = nil) {
        let url = buildURL(for: "/locations/\(locationId)")

        get(url, success: success, failure: failure)
    }

    /// Get a list of recent media objects from a given location.
    ///
    /// - Parameter locationId: Location identifier.
    /// - Parameter maxId: Return media after this `maxId`.
    /// - Parameter minId: Return media before this `mindId`.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func recentMedia(forLocation locationId: String, maxId: String = "", minId: String = "", success: SuccessHandler<[InstagramMedia]>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        if !maxId.isEmpty { params["max_id"] = maxId }
        if !minId.isEmpty { params["min_id"] = minId }

        let url = buildURL(for: "/locations/\(locationId)/media/recent", withParams: params)

        get(url, success: success, failure: failure)
    }

    /// Search for a location by geographic coordinate.
    ///
    /// - Parameter lat: Latitude of the center search coordinate. If used, `lng` is required.
    /// - Parameter lng: Longitude of the center search coordinate. If used, `lat` is required.
    /// - Parameter distance: Default is 500m, max distance is 750.
    /// - Parameter facebookPlacesId: Returns a location mapped off of a Facebook places id.
    ///   If used, `lat` and `lng` are not required.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func searchLocation(lat: Double = 0, lng: Double = 0, distance: Int = 0, facebookPlacesId: String = "", success: SuccessHandler<[InstagramLocation]>? = nil, failure: FailureHandler? = nil) {
        var params = [String: String]()

        if lat != 0 { params["lat"] = String(lat) }
        if lng != 0 { params["lng"] = String(lng) }
        if distance != 0 { params["distance"] = String(distance) }
        if !facebookPlacesId.isEmpty { params["facebook_places_id"] = facebookPlacesId }

        let url = buildURL(for: "/locations/search", withParams: params)

        get(url, success: success, failure: failure)
    }

}
