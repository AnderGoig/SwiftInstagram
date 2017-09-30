<p align="center">
    <img src="https://raw.githubusercontent.com/AnderGoig/SwiftInstagram/master/Images/SwiftInstagram-logo.png" alt="SwiftInstagram Logo" width="850" height="190">
</p>

[![Platforms](https://img.shields.io/cocoapods/p/SwiftInstagram.svg)](https://cocoapods.org/pods/SwiftInstagram)
[![License](https://img.shields.io/cocoapods/l/SwiftInstagram.svg)](https://raw.githubusercontent.com/AnderGoig/SwiftInstagram/master/LICENSE)

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/SwiftInstagram.svg)](https://cocoapods.org/pods/SwiftInstagram)

[![Travis](https://img.shields.io/travis/AnderGoig/SwiftInstagram/master.svg)](https://travis-ci.org/AnderGoig/SwiftInstagram/branches)
[![JetpackSwift](https://img.shields.io/badge/JetpackSwift-framework-red.svg)](http://github.com/JetpackSwift/Framework)

A Swift wrapper for the Instagram API.

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)
- [Author](#author)

## Requirements

- iOS 9.0+
- Xcode 9.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build SwiftInstagram 1.0.0+.

To integrate SwiftInstagram into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'SwiftInstagram', '~> 1.0.0'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SwiftInstagram into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "SwiftInstagram/SwiftInstagram" ~> 1.0.0
```
### Swift Package Manager

To use SwiftInstagram as a [Swift Package Manager](https://swift.org/package-manager/) package just add the following in your Package.swift file.

``` swift
import PackageDescription

let package = Package(
    name: "HelloSwiftInstagram",
    dependencies: [
        .Package(url: "https://github.com/AnderGoig/SwiftInstagram.git", "1.0.0")
    ]
)
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate SwiftInstagram into your project manually.

#### Git Submodules

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add SwiftInstagram as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/AnderGoig/SwiftInstagram.git
$ git submodule update --init --recursive
```

- Open the new `SwiftInstagram` folder, and drag the `SwiftInstagram.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `SwiftInstagram.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `SwiftInstagram.xcodeproj` folders each with two different versions of the `SwiftInstagram.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `SwiftInstagram.framework`.

- And that's it!

> The `SwiftInstagram.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

#### Embeded Binaries

- Download the latest release from https://github.com/AnderGoig/SwiftInstagram/releases
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Add the downloaded `SwiftInstagram.framework`.
- And that's it!

## Usage

SwiftInstagram uses client side (implicit) authentication, so you must **uncheck** the option "**Disable implicit OAuth**" from the _Security_ tab of your [Instagram client](https://www.instagr.am/developer/clients/manage/).

Also, copy the **Client ID** from your client and paste it inside your `Info.plist` file with `InstagramClientId` as the key.

<p align="center">
    <img src="https://raw.githubusercontent.com/AnderGoig/SwiftInstagram/master/Images/Info.plist-file.png" alt="Info.plist" width="585" height="21">
</p>

### Authentication - [SwiftInstagram docs](https://andergoig.github.io/SwiftInstagram/Classes/Instagram.html#/Authentication)

```swift
let api = Instagram.shared

// Login
api.login(navController: navigationController!, redirectURI: "YOUR REDIRECTION URI GOES HERE") { (error) in
    if let error = error {
        print(error)
    }

    DispatchQueue.main.async {
        self.navigationController?.popViewController(animated: true)

        // Do your stuff here ...
    }
}

// Returns whether a session is currently available or not
let _ = api.isSessionValid()

// Logout
let _ = api.logout()
```

You can also specify the [login permissions](https://www.instagram.com/developer/authorization/) with the optional parameter `authScope`, by default, it is set to basic access. To request multiple scopes at once, simply separate the scopes by a "+".

```swift
api.login(navController: ..., authScope: "likes+comments", redirectURI: ... ) { }
```

### Data retrieval

All of the following functions are very similar and straightforward, here's an example of retrieving recent media:

```swift
let api = Instagram.shared

api.recentMedia(fromUser: "self", count: 3, completion: { (mediaSet, error) in
    guard let mediaSet = mediaSet else {
        print(error!.message)
        return
    }

    // Do your stuff here ...
})
```

#### Users - [SwiftInstagram docs](https://andergoig.github.io/SwiftInstagram/Classes/Instagram.html#/User%20Endpoints) - [Official docs](http://instagr.am/developer/endpoints/users/)

```swift
api.user(_ userId: String, completion: @escaping (_ user: InstagramUser?, _ error: InstagramError?) -> Void)
api.recentMedia(fromUser userId: String, maxId: String = default, minId: String = default, count: Int = default, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void)
api.userLikedMedia(maxLikeId: String = default, count: Int = default, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void)
api.search(user query: String, count: Int = default, completion: @escaping (_ userSet: [InstagramUser]?, _ error: InstagramError?) -> Void)
```

#### Relationships - [SwiftInstagram docs](https://andergoig.github.io/SwiftInstagram/Classes/Instagram.html#/Relationship%20Endpoints) - [Official docs](http://instagr.am/developer/endpoints/relationships/)

```swift
api.userFollows(completion: @escaping (_ userSet: [InstagramUser]?, _ error: InstagramError?) -> Void)
api.userFollowers(completion: @escaping (_ userSet: [InstagramUser]?, _ error: InstagramError?) -> Void)
api.userRequestedBy(completion: @escaping (_ userSet: [InstagramUser]?, _ error: InstagramError?) -> Void)
api.userRelationship(withUser userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void)
api.follow(user userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void)
api.unfollow(user userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void)
api.approveRequest(fromUser userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void)
api.ignoreRequest(fromUser userId: String, completion: @escaping (_ relationship: InstagramRelationship?, _ error: InstagramError?) -> Void)
```

#### Media - [SwiftInstagram docs](https://andergoig.github.io/SwiftInstagram/Classes/Instagram.html#/Media%20Endpoints) - [Official docs](http://instagr.am/developer/endpoints/media/)

```swift
api.media(withId id: String, completion: @escaping (_ media: InstagramMedia?, _ error: InstagramError?) -> Void)
api.media(withShortcode shortcode: String, completion: @escaping (_ media: InstagramMedia?, _ error: InstagramError?) -> Void)
api.searchMedia(lat: Double = default, lng: Double = default, distance: Int = default, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void)
```

#### Comments - [SwiftInstagram docs](https://andergoig.github.io/SwiftInstagram/Classes/Instagram.html#/Comment%20Endpoints) - [Official docs](http://instagr.am/developer/endpoints/comments/)

```swift
api.comments(fromMedia mediaId: String, completion: @escaping (_ comments: [InstagramComment]?, _ error: InstagramError?) -> Void)
api.createComment(onMedia mediaId: String, text: String, completion: @escaping (_ error: InstagramError?) -> Void)
api.deleteComment(_ commentId: String, onMedia mediaId: String, completion: @escaping (_ error: InstagramError?) -> Void)
```

#### Likes - [SwiftInstagram docs](https://andergoig.github.io/SwiftInstagram/Classes/Instagram.html#/Like%20Endpoints) - [Official docs](http://instagr.am/developer/endpoints/likes/)

```swift
api.likes(inMedia mediaId: String, completion: @escaping (_ users: [InstagramUser]?, _ error: InstagramError?) -> Void)
api.like(media mediaId: String, completion: @escaping (_ error: InstagramError?) -> Void)
api.unlike(media mediaId: String, completion: @escaping (_ error: InstagramError?) -> Void)
```

#### Tags - [SwiftInstagram docs](https://andergoig.github.io/SwiftInstagram/Classes/Instagram.html#/Tag%20Endpoints) - [Official docs](http://instagr.am/developer/endpoints/tags/)

```swift
api.tag(_ tagName: String, completion: @escaping (_ tag: InstagramTag?, _ error: InstagramError?) -> Void)
api.recentMedia(withTag tagName: String, maxTagId: String = default, minTagId: String = default, count: Int = default, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void)
api.search(tag query: String, completion: @escaping (_ tags: [InstagramTag]?, _ error: InstagramError?) -> Void)
```

#### Locations - [SwiftInstagram docs](https://andergoig.github.io/SwiftInstagram/Classes/Instagram.html#/Location%20Endpoints) - [Official docs](http://instagr.am/developer/endpoints/locations/)

```swift
api.location(_ locationId: String, completion: @escaping (_ location: InstagramLocation?, _ error: InstagramError?) -> Void)
api.recentMedia(forLocation locationId: String, maxId: String = default, minId: String = default, completion: @escaping (_ mediaSet: [InstagramMedia]?, _ error: InstagramError?) -> Void)
api.searchLocation(lat: Double = default, lng: Double = default, distance: Int = default, facebookPlacesId: String = default, completion: @escaping (_ locations: [InstagramLocation]?, _ error: InstagramError?) -> Void)
```

## Contributing

If you have feature requests or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/AnderGoig/IGAuth/issues/new). Please take a moment to
review the guidelines written by [Nicolas Gallagher](https://github.com/necolas):

* [Bug reports](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#bugs)
* [Feature requests](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#features)
* [Pull requests](https://github.com/necolas/issue-guidelines/blob/master/CONTRIBUTING.md#pull-requests)

## Credits

SwiftInstagram is brought to you by [Ander Goig](https://github.com/AnderGoig) and [contributors to the project](https://github.com/AnderGoig/SwiftInstagram/contributors). If you're using SwiftInstagram in your project, attribution would be very appreciated.

## License

SwiftInstagram is released under the MIT license. See [LICENSE](https://github.com/AnderGoig/SwiftInstagram/blob/master/LICENSE) for details.

### Companion libraries

SwiftInstagram uses [keychain-swift](https://github.com/evgenyneu/keychain-swift) by [@evgenyneu](https://github.com/evgenyneu) to safely store the access token retrieved by the authentication process.

## Author

Ander Goig, [goig.ander@gmail.com](mailto:goig.ander@gmail.com)

[https://github.com/AnderGoig/SwiftInstagram](https://github.com/AnderGoig/SwiftInstagram)
