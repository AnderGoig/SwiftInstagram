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

    private typealias Parameters = [String: String]

    public typealias EmptySuccessHandler = () -> Void
    public typealias SuccessHandler<T> = (_ data: T) -> Void
    public typealias FailureHandler = (_ error: Error) -> Void

    // MARK: - Properties

    private let urlSession = URLSession(configuration: .default)
    private let keychain = KeychainSwift()
    private let decoder = JSONDecoder()

    private var clientId: String?

    // MARK: - Initializers

    public static let shared = Instagram()

    private init() {
        let bundlePath = Bundle.main.path(forResource: "Info", ofType: "plist")

        if let path = bundlePath, let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            self.clientId = dict["InstagramClientId"] as? String
        }
    }

    // MARK: - Authentication

    /// Starts an authentication process.
    ///
    /// Shows a custom `UIViewController` with Intagram's login page.
    ///
    /// - Parameter navController: Your current `UINavigationController`.
    /// - Parameter scopes: The scope of the access you are requesting from the user. Basic access by default.
    /// - Parameter redirectURI: Your Instagram API client redirection URI.
    /// - Parameter success: The callback called after a correct login.
    /// - Parameter failure: The callback called after an incorrect login.

    public func login(navController: UINavigationController, scopes: [InstagramAuthScope] = [.basic], redirectURI: String, success: EmptySuccessHandler? = nil, failure: FailureHandler? = nil) {
        if let clientId = self.clientId {
            let vc = InstagramLoginViewController(clientId: clientId, scopes: scopes, redirectURI: redirectURI, success: { accessToken in
                if !self.keychain.set(accessToken, forKey: "accessToken") {
                    failure?(InstagramError(kind: .keychainError(code: self.keychain.lastResultCode), message: "Error storing access token into keychain."))
                } else {
                    navController.popViewController(animated: true)
                    success?()
                }
            }, failure: failure)

            navController.show(vc, sender: nil)
        } else {
            failure?(InstagramError(kind: .missingClientId, message: "Instagram Client ID not provided."))
        }
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

    @discardableResult
    public func logout() -> Bool {
        return self.keychain.delete("accessToken")
    }

    // MARK: -

    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    private func request<T: Decodable>(_ endpoint: String, method: HTTPMethod = .get, parameters: Parameters? = nil, success: SuccessHandler<T>? = nil, failure: FailureHandler? = nil) {
        var urlRequest = URLRequest(url: buildURL(for: endpoint, withParameters: parameters))
        urlRequest.httpMethod = method.rawValue

        self.urlSession.dataTask(with: urlRequest) { (data, _, error) in
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

    private func buildURL(for endpoint: String, withParameters parameters: Parameters? = nil) -> URL {
        var urlComps = URLComponents(string: "https://api.instagram.com/v1" + endpoint)

        var items = [URLQueryItem]()

        let accessToken = self.keychain.get("accessToken")
        items.append(URLQueryItem(name: "access_token", value: accessToken ?? ""))

        parameters?.forEach({ parameter in
            items.append(URLQueryItem(name: parameter.key, value: parameter.value))
        })

        urlComps!.queryItems = items

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
        request("/users/\(userId)", success: success, failure: failure)
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
        var parameters = Parameters()

        if !maxId.isEmpty { parameters["max_id"] = maxId }
        if !minId.isEmpty { parameters["min_id"] = minId }
        if count != 0 { parameters["count"] = String(count) }

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

    public func userLikedMedia(maxLikeId: String = "", count: Int = 0, success: SuccessHandler<[InstagramMedia]>? = nil, failure: FailureHandler? = nil) {
        var parameters = Parameters()

        if !maxLikeId.isEmpty { parameters["max_like_id"] = maxLikeId }
        if count != 0 { parameters["count"] = String(count) }

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

    public func search(user query: String, count: Int = 0, success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        var parameters = Parameters()

        parameters["q"] = query
        if count != 0 { parameters["count"] = String(count) }

        request("/users/search", parameters: parameters, success: success, failure: failure)
    }

    // MARK: - Relationship Endpoints

    /// Get the list of users this user follows.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userFollows(success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        request("/users/self/follows", success: success, failure: failure)
    }

    /// Get the list of users this user is followed by.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userFollowers(success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        request("/users/self/followed-by", success: success, failure: failure)
    }

    /// List the users who have requested this user's permission to follow.
    ///
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userRequestedBy(success: SuccessHandler<[InstagramUser]>? = nil, failure: FailureHandler? = nil) {
        request("/users/self/requested-by", success: success, failure: failure)
    }

    /// Get information about a relationship to another user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *follower_list* scope.

    public func userRelationship(withUser userId: String, success: SuccessHandler<InstagramRelationship>? = nil,
                                 failure: FailureHandler? = nil) {
        request("/users/\(userId)/relationship", success: success, failure: failure)
    }

    /// Relationship actions currently supported by Instagram.

    private enum RelationshipAction: String {
        case follow, unfollow, approve, ignore
    }

    /// Modify the relationship between the current user and the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter action: Follow, unfollow, approve or ignore.
    /// - Parameter success: The callback called after a correct modification.
    /// - Parameter failure: The callback called after an incorrect modification.
    ///
    /// - Important: It requires *relationships* scope.

    private func modifyUserRelationship(withUser userId: String, action: RelationshipAction, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        var parameters = Parameters()

        parameters["action"] = action.rawValue

        request("/users/\(userId)/relationship", method: .post, parameters: parameters, success: success, failure: failure)
    }

    /// Follows the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct follow.
    /// - Parameter failure: The callback called after an incorrect follow.
    ///
    /// - Important: It requires *relationships* scope.

    public func follow(user userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        modifyUserRelationship(withUser: userId, action: .follow, success: success, failure: failure)
    }

    /// Unfollows the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct unfollow.
    /// - Parameter failure: The callback called after an incorrect unfollow.
    ///
    /// - Important: It requires *relationships* scope.

    public func unfollow(user userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        modifyUserRelationship(withUser: userId, action: .unfollow, success: success, failure: failure)
    }

    /// Approve the target user's request.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct approve.
    /// - Parameter failure: The callback called after an incorrect approve.
    ///
    /// - Important: It requires *relationships* scope.

    public func approveRequest(fromUser userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        modifyUserRelationship(withUser: userId, action: .approve, success: success, failure: failure)
    }

    /// Ignore the target user's request.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter success: The callback called after a correct ignore.
    /// - Parameter failure: The callback called after an incorrect ignore.
    ///
    /// - Important: It requires *relationships* scope.

    public func ignoreRequest(fromUser userId: String, success: SuccessHandler<InstagramRelationship>? = nil, failure: FailureHandler? = nil) {
        modifyUserRelationship(withUser: userId, action: .ignore, success: success, failure: failure)
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
        request("/media/\(id)", success: success, failure: failure)
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
        request("/media/shortcode/\(shortcode)", success: success, failure: failure)
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
        var parameters = Parameters()

        if lat != 0 { parameters["lat"] = String(lat) }
        if lng != 0 { parameters["lng"] = String(lng) }
        if distance != 0 { parameters["distance"] = String(distance) }

        request("/media/search", parameters: parameters, success: success, failure: failure)
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
        request("/media/\(mediaId)/comments", success: success, failure: failure)
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
        var parameters = Parameters()

        parameters["text"] = text

        request("/media/\(mediaId)/comments", method: .post, parameters: parameters, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
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
        request("/media/\(mediaId)/comments/\(commentId)", method: .delete, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
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
        request("/media/\(mediaId)/likes", success: success, failure: failure)
    }

    /// Set a like on this media by the currently authenticated user.
    ///
    /// - Parameter mediaId: Media identifier.
    /// - Parameter failure: The callback called after an incorrect like.
    ///
    /// - Important: It requires *likes* scope. Also, *public_content* scope is required for media that does not belong
    ///   to your own user.

    public func like(media mediaId: String, failure: FailureHandler? = nil) {
        request("/media/\(mediaId)/likes", method: .post, success: { (_: InstagramResponse<Any?>) in return },
                failure: failure)
    }

    /// Remove a like on this media by the currently authenticated user.
    ///
    /// - Parameter Parameter mediaId: Media identifier.
    /// - Parameter failure: The callback called after an incorrect deletion.
    ///
    /// - Important: It requires *likes* scope. Also, *public_content* scope is required for media that does not belong
    ///   to your own user.

    public func unlike(media mediaId: String, failure: FailureHandler? = nil) {
        request("/media/\(mediaId)/likes", method: .delete, success: { (_: InstagramResponse<Any?>) in return }, failure: failure)
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
        request("/tags/\(tagName)", success: success, failure: failure)
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
        var parameters = Parameters()

        if !maxTagId.isEmpty { parameters["max_tag_id"] = maxTagId }
        if !minTagId.isEmpty { parameters["min_tag_id"] = minTagId }
        if count != 0 { parameters["count"] = String(count) }

        request("/tags/\(tagName)/media/recent", parameters: parameters, success: success, failure: failure)
    }

    /// Search for tags by name.
    ///
    /// - Parameter query: A valid tag name without a leading #. (eg. snowy, nofilter)
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func search(tag query: String, success: SuccessHandler<[InstagramTag]>? = nil, failure: FailureHandler? = nil) {
        var parameters = Parameters()

        parameters["q"] = query

        request("/tags/search", parameters: parameters, success: success, failure: failure)
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
        request("/locations/\(locationId)", success: success, failure: failure)
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
        var parameters = Parameters()

        if !maxId.isEmpty { parameters["max_id"] = maxId }
        if !minId.isEmpty { parameters["min_id"] = minId }

        request("/locations/\(locationId)/media/recent", parameters: parameters, success: success, failure: failure)
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
        var parameters = Parameters()

        if lat != 0 { parameters["lat"] = String(lat) }
        if lng != 0 { parameters["lng"] = String(lng) }
        if distance != 0 { parameters["distance"] = String(distance) }
        if !facebookPlacesId.isEmpty { parameters["facebook_places_id"] = facebookPlacesId }

        request("/locations/search", parameters: parameters, success: success, failure: failure)
    }

}
