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

    private typealias Parameters = [String: Any]

    public typealias EmptySuccessHandler = () -> Void
    public typealias SuccessHandler<T> = (_ data: T) -> Void
    public typealias FailureHandler = (_ error: InstagramError) -> Void

    private enum API {
        static let authURL = "https://api.instagram.com/oauth/authorize"
        static let baseURL = "https://api.instagram.com/v1"
    }

    private enum Keychain {
        static let key = "accessToken"
    }

    // MARK: - Properties

    private let urlSession = URLSession(configuration: .default)
    private let keychain = KeychainSwift()
    private let decoder = JSONDecoder()

    private var client: InstagramClient?

    // MARK: - Initializers

    /// Returns a shared instance of Instagram.
    public static let shared = Instagram()

    private init() {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            let clientId = dict["InstagramClientId"] as? String
            let redirectURI = dict["InstagramRedirectURI"] as? String
            client = InstagramClient(clientId: clientId, redirectURI: redirectURI)
        }
    }

    // MARK: - Authentication

    /// Starts an authentication process.
    ///
    /// Shows a custom `UIViewController` with Intagram's login page.
    ///
    /// - Parameter controller: The `UINavigationController` from which the `InstagramLoginViewController` will be showed.
    /// - Parameter scopes: The scope of the access you are requesting from the user. Basic access by default.
    /// - Parameter success: The callback called after a correct login.
    /// - Parameter failure: The callback called after an incorrect login.

    public func login(from controller: UINavigationController, withScopes scopes: [InstagramScope] = [.basic], success: EmptySuccessHandler?, failure: FailureHandler?) {
        if let authURL = buildAuthURL(scopes: scopes) {
            let vc = InstagramLoginViewController(authURL: authURL, success: { accessToken in
                if !self.keychain.set(accessToken, forKey: Keychain.key) {
                    failure?(InstagramError(kind: .keychainError(code: self.keychain.lastResultCode), message: "Error storing access token into keychain."))
                } else {
                    controller.popViewController(animated: true)
                    success?()
                }
            }, failure: failure)

            controller.show(vc, sender: nil)
        } else {
            failure?(InstagramError(kind: .missingClient, message: "Error while reading your Info.plist file settings."))
        }
    }

    private func buildAuthURL(scopes: [InstagramScope]) -> URL? {
        if let client = client {
            var components = URLComponents(string: API.authURL)!
            components.queryItems = [
                URLQueryItem(name: "client_id", value: client.clientId),
                URLQueryItem(name: "redirect_uri", value: client.redirectURI),
                URLQueryItem(name: "response_type", value: "token"),
                URLQueryItem(name: "scope", value: scopes.map({ "\($0.rawValue)" }).joined(separator: "+"))
            ]
            return components.url
        }

        return nil
    }

    /// Returns whether a session is currently available or not.
    ///
    /// - Returns: True if a session is currently available, false otherwise.

    public func isSessionValid() -> Bool {
        return keychain.get(Keychain.key) != nil
    }

    /// Ends the current session.
    ///
    /// - Returns: True if the user was successfully logged out, false otherwise.

    @discardableResult
    public func logout() -> Bool {
        return keychain.delete(Keychain.key)
    }

    // MARK: -

    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    private func request<T: Decodable>(_ endpoint: String, method: HTTPMethod = .get, parameters: Parameters? = nil, success: SuccessHandler<T>?, failure: FailureHandler?) {
        var urlRequest = URLRequest(url: buildURL(for: endpoint, withParameters: parameters))
        urlRequest.httpMethod = method.rawValue

        urlSession.dataTask(with: urlRequest) { (data, _, error) in
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
        var urlComps = URLComponents(string: API.baseURL + endpoint)

        var items = [URLQueryItem]()

        let accessToken = keychain.get(Keychain.key)
        items.append(URLQueryItem(name: "access_token", value: accessToken ?? ""))

        parameters?.forEach({ parameter in
            items.append(URLQueryItem(name: parameter.key, value: "\(parameter.value)"))
        })

        urlComps!.queryItems = items

        return urlComps!.url!
    }

    // MARK: - User Endpoints

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

    // MARK: - Relationship Endpoints

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

    /// Relationship actions currently supported by Instagram.

    private enum RelationshipAction: String {
        case follow, unfollow, approve, ignore
    }

    /// Modify the relationship between the current user and the target user.
    ///
    /// - Parameter userId: The ID of the user to reference.
    /// - Parameter action: Follow, unfollow, approve or ignore.
    /// - Parameter success: The callback called after a correct modification.
    /// - Parameter failure: The callback called after an incorrect modification.
    ///
    /// - Important: It requires *relationships* scope.

    private func modifyUserRelationship(withUser userId: String, action: RelationshipAction, success: SuccessHandler<InstagramRelationship>?, failure: FailureHandler?) {
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

    // MARK: - Media Endpoints

    /// Get information about a media object.
    ///
    /// - Parameter id: The ID of the media object to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func media(withId id: String, success: SuccessHandler<InstagramMedia>?, failure: FailureHandler?) {
        request("/media/\(id)", success: success, failure: failure)
    }

    /// Get information about a media object.
    ///
    /// - Parameter shortcode: The shortcode of the media object to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.
    ///
    /// - Note: A media object's shortcode can be found in its shortlink URL.
    ///   An example shortlink is http://instagram.com/p/tsxp1hhQTG/. Its corresponding shortcode is tsxp1hhQTG.

    public func media(withShortcode shortcode: String, success: SuccessHandler<InstagramMedia>?, failure: FailureHandler?) {
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

    public func searchMedia(lat: Double? = nil, lng: Double? = nil, distance: Int? = nil, success: SuccessHandler<[InstagramMedia]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["lat"] ??= lat
        parameters["lng"] ??= lng
        parameters["distance"] ??= distance

        request("/media/search", parameters: parameters, success: success, failure: failure)
    }

    // MARK: - Comment Endpoints

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

    // MARK: - Like Endpoints

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

    // MARK: - Tag Endpoints

    /// Get information about a tag object.
    ///
    /// - Parameter tagName: The name of the tag to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func tag(_ tagName: String, success: SuccessHandler<InstagramTag>?, failure: FailureHandler?) {
        request("/tags/\(tagName)", success: success, failure: failure)
    }

    /// Get a list of recently tagged media.
    ///
    /// - Parameter tagName: The name of the tag to reference.
    /// - Parameter maxTagId: Return media after this `maxTagId`.
    /// - Parameter minTagId: Return media before this `minTagId`.
    /// - Parameter count: Count of tagged media to return.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func recentMedia(withTag tagName: String, maxTagId: String? = nil, minTagId: String? = nil, count: Int? = nil, success: SuccessHandler<[InstagramMedia]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["max_tag_id"] ??= maxTagId
        parameters["min_tag_id"] ??= minTagId
        parameters["count"] ??= count

        request("/tags/\(tagName)/media/recent", parameters: parameters, success: success, failure: failure)
    }

    /// Search for tags by name.
    ///
    /// - Parameter query: A valid tag name without a leading #. (eg. snowy, nofilter)
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func search(tag query: String, success: SuccessHandler<[InstagramTag]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["q"] = query

        request("/tags/search", parameters: parameters, success: success, failure: failure)
    }

    // MARK: - Location Endpoints

    /// Get information about a location.
    ///
    /// - Parameter locationId: The ID of the location to reference.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func location(_ locationId: String, success: SuccessHandler<InstagramLocation<String>>?, failure: FailureHandler?) {
        request("/locations/\(locationId)", success: success, failure: failure)
    }

    /// Get a list of recent media objects from a given location.
    ///
    /// - Parameter locationId: The ID of the location to reference.
    /// - Parameter maxId: Return media after this `maxId`.
    /// - Parameter minId: Return media before this `mindId`.
    /// - Parameter success: The callback called after a correct retrieval.
    /// - Parameter failure: The callback called after an incorrect retrieval.
    ///
    /// - Important: It requires *public_content* scope.

    public func recentMedia(forLocation locationId: String, maxId: String? = nil, minId: String? = nil, success: SuccessHandler<[InstagramMedia]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["max_id"] ??= maxId
        parameters["min_id"] ??= minId

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

    public func searchLocation(lat: Double? = nil, lng: Double? = nil, distance: Int? = nil, facebookPlacesId: String? = nil, success: SuccessHandler<[InstagramLocation<String>]>?, failure: FailureHandler?) {
        var parameters = Parameters()

        parameters["lat"] ??= lat
        parameters["lng"] ??= lng
        parameters["distance"] ??= distance
        parameters["facebook_places_id"] ??= facebookPlacesId

        request("/locations/search", parameters: parameters, success: success, failure: failure)
    }

}
