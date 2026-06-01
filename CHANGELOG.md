# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Multi-contact emergency support with drag & drop reordering.
- Automatic Bluetooth reconnection logic (3 retries).
- Advanced location management with auto-enable.
- Modernized Login Screen with animations and Dark Mode.
- Real-time Bluetooth status card on the home screen.
- Background service for persistent monitoring.

### Changed
- Refactored `emergency_contact_screen.dart` to support priority levels.
- Improved error handling in `bluetooth_provider.dart`.

### Fixed
- Fixed location timeout issues during background execution.
