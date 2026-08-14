# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Require Ruby 3.2 or later
- Moved CI from Travis CI to GitHub Actions
- Replaced coveralls with SimpleCov for coverage reporting

## [0.5.2] - 2022-11-09

### Fixed

- Handle nonsense values in `ATDIS::Feed.base_url_from_url`

## [0.5.1] - 2022-11-01

### Fixed

- Compatibility with newer versions of ActiveModel, which removed
  `ActiveModel::Errors#keys`

## [0.5.0] - 2020-08-03

### Added

- Option to ignore SSL certificate errors when fetching feeds

## [0.4.1] - 2019-05-28

Earlier releases predate this changelog. See the
[commit history](https://github.com/openaustralia/atdis/commits/main) for
details.

[Unreleased]: https://github.com/openaustralia/atdis/compare/v0.5.2...HEAD
[0.5.2]: https://github.com/openaustralia/atdis/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/openaustralia/atdis/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/openaustralia/atdis/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/openaustralia/atdis/releases/tag/v0.4.1
