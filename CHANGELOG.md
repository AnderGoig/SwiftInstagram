# Changelog

## [Unreleased]

## [1.0.5] (2017-10-18)
[Full Changelog](https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.4...v1.0.5)
### Changed
- The `Success` and `Failure` handlers, for all the API endpoints, are no longer nullable.
### Fixed
- Fixed the bug parsing `InstagramMedia` objects with a `location` property (#7).

## [1.0.4] (2017-10-10)
[Full Changelog](https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.3...v1.0.4)
### Added
- 100% documented code.
### Changed
- Now, the redirection URI must be defined in the Info.plist file. See [wiki](https://github.com/AnderGoig/SwiftInstagram/wiki/Authentication).
- The `createdTime` attribute of the classes `InstagramComment` and `InstagramMedia` has been renamed to `createdDate` and returns an object of type `Date`.
- Improves [Codebeat](https://codebeat.co/projects/github-com-andergoig-swiftinstagram-master) GBA.
### Fixed
- Fixed the type of the returned errors.

## [1.0.3] (2017-10-08)
[Full Changelog](https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.2...v1.0.3)
### Changed
- Improved documentation.
- `InstagramAuthScope` renamed to `InstagramScope`.

## [1.0.2] (2017-10-07)
[Full Changelog](https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.1...v1.0.2)
### Added
- `InstagramLoginViewController` hides automatically when concludes.
- `@discardableResult` to `logout()` method.
### Changed
- Better code organization, especially for networking.
### Fixed
- Authorization process errors are now correctly captured.
- Travis CI build error.

## [1.0.1] (2017-10-03)
[Full Changelog](https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.0...v1.0.1)
### Added
- Use of `DispatchQueue` for parsing JSON and calling callback functions.
### Changed
- The source code is now a little simpler thanks to the use of `typealias`.
- The structure of the functions has changed, there are two callbacks now (`success` and `failure`) instead of just one.
### Fixed
- Login page `WKWebView` now fits correctly when rotating device.

## [1.0.0] (2017-09-30)
### Added
- Initial release.

[Unreleased]: https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.5...develop
[1.0.5]: https://github.com/AnderGoig/SwiftInstagram/tree/v1.0.5
[1.0.4]: https://github.com/AnderGoig/SwiftInstagram/tree/v1.0.4
[1.0.3]: https://github.com/AnderGoig/SwiftInstagram/tree/v1.0.3
[1.0.2]: https://github.com/AnderGoig/SwiftInstagram/tree/v1.0.2
[1.0.1]: https://github.com/AnderGoig/SwiftInstagram/tree/v1.0.1
[1.0.0]: https://github.com/AnderGoig/SwiftInstagram/tree/v1.0.0
