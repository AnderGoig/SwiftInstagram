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
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Note: More information about the login permissions (scope)
    ///   [here](https://www.instagram.com/developer/authorization/).
    public func login(navController: UINavigationController, authScope: String = "basic", redirectURI: String, completion: @escaping (_ error: InstagramError?) -> Void) {
        let vc = InstagramLoginViewController(clientId: self.clientId!, authScope: authScope, redirectURI: redirectURI) { accessToken, error in
            if let error = error {
                completion(error)
                return
            }

            if self.keychain.set(accessToken!, forKey: "accessToken") {
                completion(nil)
            } else {
                completion(InstagramError(kind: .keychainError(code: self.keychain.lastResultCode), message: "Error storing access token into keychain."))
            }
        }

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

    private func dataTask<T>(url: URL, method: String, completion: @escaping (T?, InstagramError?) -> Void) where T: Decodable {
        var request = URLRequest(url: url)
        request.httpMethod = method

        let session = URLSession(configuration: .default)

        session.dataTask(with: request) { (data, _ response, error) in
            if let data = data {
                do {
                    let object = try self.decoder.decode(InstagramResponse<T>.self, from: data)
                    if let errorMessage = object.meta.errorMessage {
                        completion(nil, InstagramError(kind: .invalidRequest, message: errorMessage))
                    } else {
                        completion(object.data, nil)
                    }
                } catch {
                    completion(nil, InstagramError(kind: .jsonParseError, message: error.localizedDescription))
                }
            }
        }.resume()
    }

    private func get<T>(_ url: URL, completion: @escaping (T?, InstagramError?) -> Void) where T: Decodable {
        dataTask(url: url, method: "GET", completion: completion)
    }

    private func post<T>(_ url: URL, completion: @escaping (T?, InstagramError?) -> Void) where T: Decodable {
        dataTask(url: url, method: "POST", completion: completion)
    }

    private func delete<T>(_ url: URL, completion: @escaping (T?, InstagramError?) -> Void) where T: Decodable {
        dataTask(url: url, method: "DELETE", completion: completion)
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
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter user: An `InstagramUser` after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope when getting information about a user other than yours.
    ///
    /// - Note: Use `"self"` in the `userId` parameter in order to get information about your own user.
    public func user(_ userId: String, completion: @escaping (_ user: InstagramUser?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/users/\(userId)")

        get(url) { (object: InstagramUser?, error) in
            completion(object, error)
        }
    }

    /// Get the most recent media published by a user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter maxId: Return media earlier than this `maxId`.
    /// - Parameter minId: Return media later than this `minId`.
    /// - Parameter count: Count of media to return.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter mediaSet: A set of `InstagramMedia` after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope when getting recent media published by a user other than yours.
    ///
    /// - Note: Use *"self"* in the *userId* parameter in order to get the most recent media published by your own user.
    public func recentMedia(fromUser userId: String, maxId: String = "", minId: String = "", count: Int = 0, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        if !maxId.isEmpty { params["max_id"] = maxId }
        if !minId.isEmpty { params["min_id"] = minId }
        if count != 0 { params["count"] = String(count) }

        let url = buildURL(for: "/users/\(userId)/media/recent", withParams: params)

        get(url) { (object: [InstagramMedia]?, error) in
            completion(object, error)
        }
    }

    /// Get the list of recent media liked by your own user.
    ///
    /// - Parameter maxLikeId: Return media liked before this id.
    /// - Parameter count: Count of media to return.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter mediaSet: A set of `InstagramMedia` after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func userLikedMedia(maxLikeId: String = "", count: Int = 0, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        if !maxLikeId.isEmpty { params["max_like_id"] = maxLikeId }
        if count != 0 { params["count"] = String(count) }

        let url = buildURL(for: "/users/self/media/liked", withParams: params)

        get(url) { (object: [InstagramMedia]?, error) in
            completion(object, error)
        }
    }

    /// Get a list of users matching the query.
    ///
    /// - Parameter query: A query string.
    /// - Parameter count: Number of users to return.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter userSet: A set of `InstagramUser` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func search(user query: String, count: Int = 0, completion: @escaping (_ userSet: [InstagramUser]?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        params["q"] = query
        if count != 0 { params["count"] = String(count) }

        let url = buildURL(for: "/users/search", withParams: params)

        get(url) { (object: [InstagramUser]?, error) in
            completion(object, error)
        }
    }

    // MARK: - Relationship Endpoints

    /// Get the list of users this user follows.
    ///
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter userSet: A set of `InstagramUser` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *follower_list* scope.
    public func userFollows(completion: @escaping (_ userSet: [InstagramUser]?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/users/self/follows")

        get(url) { (object: [InstagramUser]?, error) in
            completion(object, error)
        }
    }

    /// Get the list of users this user is followed by.
    ///
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter userSet: A set of `InstagramUser` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *follower_list* scope.
    public func userFollowers(completion: @escaping (_ userSet: [InstagramUser]?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/users/self/followed-by")

        get(url) { (object: [InstagramUser]?, error) in
            completion(object, error)
        }
    }

    /// List the users who have requested this user's permission to follow.
    ///
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter userSet: A set of `InstagramUser` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *follower_list* scope.
    public func userRequestedBy(completion: @escaping (_ userSet: [InstagramUser]?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/users/self/requested-by")

        get(url) { (object: [InstagramUser]?, error) in
            completion(object, error)
        }
    }

    /// Get information about a relationship to another user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter relationship: A `InstagramRelationship` object after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *follower_list* scope.
    public func userRelationship(withUser userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/users/\(userId)/relationship")

        get(url) { (object: InstagramRelationship?, error) in
            completion(object, error)
        }
    }

    /// Modify the relationship between the current user and the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter action: follow | unfollow | approve | ignore
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter relationship: A `InstagramRelationship` object after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *relationships* scope.
    private func modifyUserRelationship(withUser userId: String, action: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        params["action"] = action

        let url = buildURL(for: "/users/\(userId)/relationship", withParams: params)

        post(url) { (object: InstagramRelationship?, error) in
            completion(object, error)
        }
    }

    /// Follows the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter relationship: A `InstagramRelationship` object after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *relationships* scope.
    public func follow(user userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void) {
        modifyUserRelationship(withUser: userId, action: "follow", completion: completion)
    }

    /// Unfollows the target user.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter relationship: A `InstagramRelationship` object after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *relationships* scope.
    public func unfollow(user userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void) {
        modifyUserRelationship(withUser: userId, action: "unfollow", completion: completion)
    }

    /// Approve the target user's request.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter relationship: A `InstagramRelationship` object after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *relationships* scope.
    public func approveRequest(fromUser userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void) {
        modifyUserRelationship(withUser: userId, action: "approve", completion: completion)
    }

    /// Ignore the target user's request.
    ///
    /// - Parameter userId: User identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter relationship: A `InstagramRelationship` object after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *relationships* scope.
    public func ignoreRequest(fromUser userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void) {
        modifyUserRelationship(withUser: userId, action: "ignore", completion: completion)
    }

    // MARK: - Media Endpoints

    /// Get information about a media object.
    ///
    /// - Parameter id: Media identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter media: A `InstagramMedia` object after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func media(withId id: String, completion: @escaping (_ media: InstagramMedia?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/media/\(id)")

        get(url) { (object: InstagramMedia?, error) in
            completion(object, error)
        }
    }

    /// Get information about a media object.
    ///
    /// - Parameter shortcode: Media shortcode.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter media: A `InstagramMedia` object after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    ///
    /// - Note: A media object's shortcode can be found in its shortlink URL.
    ///   An example shortlink is http://instagram.com/p/tsxp1hhQTG/. Its corresponding shortcode is tsxp1hhQTG.
    public func media(withShortcode shortcode: String, completion: @escaping (_ media: InstagramMedia?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/media/shortcode/\(shortcode)")

        get(url) { (object: InstagramMedia?, error) in
            completion(object, error)
        }
    }

    /// Search for recent media in a given area.
    ///
    /// - Parameter lat: Latitude of the center search coordinate. If used, `lng` is required.
    /// - Parameter lng: Longitude of the center search coordinate. If used, `lat` is required.
    /// - Parameter distance: Default is 1km (1000m), max distance is 5km.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter mediaSet: A set of `InstagramMedia` after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func searchMedia(lat: Double = 0, lng: Double = 0, distance: Int = 0, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        if lat != 0 { params["lat"] = String(lat) }
        if lng != 0 { params["lng"] = String(lng) }
        if distance != 0 { params["distance"] = String(distance) }

        let url = buildURL(for: "/media/search", withParams: params)

        get(url) { (object: [InstagramMedia]?, error) in
            completion(object, error)
        }
    }

    // MARK: - Comment Endpoints

    /// Get a list of recent comments on a media object.
    ///
    /// - Parameter Parameter mediaId: Media identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter comments: A set of `InstagramComment` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope for media that does not belong to your own user.
    public func comments(fromMedia mediaId: String, completion: @escaping (_ comments: [InstagramComment]?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/media/\(mediaId)/comments")

        get(url) { (object: [InstagramComment]?, error) in
            completion(object, error)
        }
    }

    /// Create a comment on a media object.
    ///
    /// - Parameter mediaId: Media identifier.
    /// - Parameter text: Text to post as a comment on the media object as specified in `mediaId`.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *comments* scope. Also, *public_content* scope is required for media that does not
    ///   belong to your own user.
    ///
    /// - Note:
    ///     - The total length of the comment cannot exceed 300 characters.
    ///     - The comment cannot contain more than 4 hashtags.
    ///     - The comment cannot contain more than 1 URL.
    ///     - The comment cannot consist of all capital letters.
    public func createComment(onMedia mediaId: String, text: String, completion: @escaping (_ error: InstagramError?) -> Void) {
        var params = [String: String]()

        params["text"] = text

        let url = buildURL(for: "/media/\(mediaId)/comments", withParams: params)

        post(url) { (_ object: InstagramResponse<String>?, error) in
            completion(error)
        }
    }

    /// Remove a comment either on the authenticated user's media object or authored by the authenticated user.
    ///
    /// - Parameter mediaId: Media identifier.
    /// - Parameter commentId: Comment identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *comments* scope. Also, *public_content* scope is required for media that does not
    ///   belong to your own user.
    public func deleteComment(_ commentId: String, onMedia mediaId: String, completion: @escaping (_ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/media/\(mediaId)/comments/\(commentId)")

        delete(url) { (_ object: InstagramResponse<String>?, error) in
            completion(error)
        }
    }

    // MARK: - Like Endpoints

    /// Get a list of users who have liked this media.
    ///
    /// - Parameter mediaId: Media identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter users: A set of `InstagramUser` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope for media that does not belong to your own user.
    public func likes(inMedia mediaId: String, completion: @escaping (_ users: [InstagramUser]?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/media/\(mediaId)/likes")

        get(url) { (object: [InstagramUser]?, error) in
            completion(object, error)
        }
    }

    /// Set a like on this media by the currently authenticated user.
    ///
    /// - Parameter mediaId: Media identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *likes* scope. Also, *public_content* scope is required for media that does not belong
    ///   to your own user.
    public func like(media mediaId: String, completion: @escaping (_ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/media/\(mediaId)/likes")

        post(url) { (_ object: InstagramResponse<String>?, error) in
            completion(error)
        }
    }

    /// Remove a like on this media by the currently authenticated user.
    ///
    /// - Parameter Parameter mediaId: Media identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *likes* scope. Also, *public_content* scope is required for media that does not belong
    ///   to your own user.
    public func unlike(media mediaId: String, completion: @escaping (_ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/media/\(mediaId)/likes")

        delete(url) { (_ object: InstagramResponse<String>?, error) in
            completion(error)
        }
    }

    // MARK: - Tag Endpoints

    /// Get information about a tag object.
    ///
    /// - Parameter tagName: Tag name.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter tag: An `InstagramTag` after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func tag(_ tagName: String, completion: @escaping (_ tag: InstagramTag?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/tags/\(tagName)")

        get(url) { (object: InstagramTag?, error) in
            completion(object, error)
        }
    }

    /// Get a list of recently tagged media.
    ///
    /// - Parameter tagName: Tag name.
    /// - Parameter maxTagId: Return media after this `maxTagId`.
    /// - Parameter minTagId: Return media before this `minTagId`.
    /// - Parameter count: Count of tagged media to return.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter mediaSet: A set of `InstagramMedia` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func recentMedia(withTag tagName: String, maxTagId: String = "", minTagId: String = "", count: Int = 0, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        if !maxTagId.isEmpty { params["max_tag_id"] = maxTagId }
        if !minTagId.isEmpty { params["min_tag_id"] = minTagId }
        if count != 0 { params["count"] = String(count) }

        let url = buildURL(for: "/tags/\(tagName)/media/recent", withParams: params)

        get(url) { (object: [InstagramMedia]?, error) in
            completion(object, error)
        }
    }

    /// Search for tags by name.
    ///
    /// - Parameter query: A valid tag name without a leading #. (eg. snowy, nofilter)
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter tags: A set of `InstagramTag` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func search(tag query: String, completion: @escaping (_ tags: [InstagramTag]?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        params["q"] = query

        let url = buildURL(for: "/tags/search", withParams: params)

        get(url) { (object: [InstagramTag]?, error) in
            completion(object, error)
        }
    }

    // MARK: - Location Endpoints

    /// Get information about a location.
    ///
    /// - Parameter Parameter locationId: Location identifier.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter location: An `InstagramLocation` after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func location(_ locationId: String, completion: @escaping (_ location: InstagramLocation?, _ error: InstagramError?) -> Void) {
        let url = buildURL(for: "/locations/\(locationId)")

        get(url) { (object: InstagramLocation?, error) in
            completion(object, error)
        }
    }

    /// Get a list of recent media objects from a given location.
    ///
    /// - Parameter locationId: Location identifier.
    /// - Parameter maxId: Return media after this `maxId`.
    /// - Parameter minId: Return media before this `mindId`.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter mediaSet: A set of `InstagramMedia` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func recentMedia(forLocation locationId: String, maxId: String = "", minId: String = "", completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        if !maxId.isEmpty { params["max_id"] = maxId }
        if !minId.isEmpty { params["min_id"] = minId }

        let url = buildURL(for: "/locations/\(locationId)/media/recent", withParams: params)

        get(url) { (object: [InstagramMedia]?, error) in
            completion(object, error)
        }
    }

    /// Search for a location by geographic coordinate.
    ///
    /// - Parameter lat: Latitude of the center search coordinate. If used, `lng` is required.
    /// - Parameter lng: Longitude of the center search coordinate. If used, `lat` is required.
    /// - Parameter distance: Default is 500m, max distance is 750.
    /// - Parameter facebookPlacesId: Returns a location mapped off of a Facebook places id.
    ///   If used, `lat` and `lng` are not required.
    /// - Parameter completion: The callback called after retrieval.
    /// - Parameter locations: A set of `InstagramTag` objects after a correct retrieval, `nil` otherwise.
    /// - Parameter error: An `InstagramError` after an incorrect retrieval, `nil` otherwise.
    ///
    /// - Important: It requires *public_content* scope.
    public func searchLocation(lat: Double = 0, lng: Double = 0, distance: Int = 0, facebookPlacesId: String = "", completion: @escaping (_ locations: [InstagramLocation]?, _ error: InstagramError?) -> Void) {
        var params = [String: String]()

        if lat != 0 { params["lat"] = String(lat) }
        if lng != 0 { params["lng"] = String(lng) }
        if distance != 0 { params["distance"] = String(distance) }
        if !facebookPlacesId.isEmpty { params["facebook_places_id"] = facebookPlacesId }

        let url = buildURL(for: "/locations/search", withParams: params)

        get(url) { (object: [InstagramLocation]?, error) in
            completion(object, error)
        }
    }

}
