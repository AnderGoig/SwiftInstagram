# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2017-10-08
### Changed
- Improved documentation.
- InstagramAuthScope renamed to InstagramScope.

## [1.0.2] - 2017-10-07
### Added
- `InstagramLoginViewController` hides automatically when concludes.
- `@discardableResult` to `logout()` method.
### Changed
- Better code organization, especially for networking.
### Fixed
- Authorization process errors are now correctly captured.
- Travis CI build error.

## [1.0.1] - 2017-10-03
### Added
- Use of `DispatchQueue` for parsing JSON and calling callback functions.
### Changed
- The source code is now a little simpler thanks to the use of `typealias`.
- The structure of the functions has changed, there are two callbacks now (`success` and `failure`) instead of just one.
### Fixed
- Login page `WKWebView` now fits correctly when rotating device.

## 1.0.0 - 2017-09-30
### Added
- Initial release.

[Unreleased]: https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.3...develop
[1.0.3]: https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/AnderGoig/SwiftInstagram/compare/v1.0.0...v1.0.1
