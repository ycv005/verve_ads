# Changelog

All notable changes to the Verve Ads Flutter Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-01-20

### Added

- **Initial Release** - Comprehensive Verve (HyBid) SDK wrapper for Flutter
- Full support for Android and iOS platforms
- **Core Features**:
  - SDK initialization with configurable parameters
  - Ad request and display functionality
  - Multiple ad formats: Banner, Medium Rectangle, Leaderboard, Interstitial, Rewarded, Native
  - User targeting with age, gender, and keywords
  - Custom user data for advanced targeting
  - COPPA compliance support
  - GDPR consent management
  - Location tracking control
  - Device identification
  - Test mode for development
  - Ad cache management
  
- **Advanced Features**:
  - Generic response wrapper with HTTP status codes
  - Comprehensive error handling
  - Detailed diagnostics and debugging information
  - Retry logic with configurable parameters
  - Custom timeout settings for ad requests
  - Metadata support for advanced analytics
  
- **Models & Enums**:
  - `VerveConfig` - SDK configuration model
  - `VerveResponse<T>` - Generic response wrapper
  - `HttpStatusCode` - Standard HTTP status codes
  - `AdRequest` - Ad request parameters
  - `AdFormat` - Supported ad formats enum
  - `VerveAd` - Ad data model
  - `NativeAdAsset` - Native ad assets model
  
- **Platform Implementations**:
  - Android: Kotlin implementation with HyBid SDK integration
  - iOS: Swift implementation with HyBid SDK integration
  
- **Example App**: Complete working example with all features demonstrated
  
- **Documentation**:
  - Comprehensive README with usage examples
  - Integration guide with platform-specific setup
  - API reference for all public classes
  - Best practices and troubleshooting guide
  - State management integration examples
  - Performance optimization guide

### Technical Details

- **Flutter Support**: Flutter 3.3.0+
- **Dart Support**: Dart 3.10.1+
- **Android**: Min SDK 21, Target SDK 34, Kotlin, HyBid SDK 3.7.1
- **iOS**: iOS 12.0+, Swift 5.0+, HyBid SDK 3.7.1+

### Known Limitations

- Web platform not yet supported
- Advanced HyBid features may require direct SDK access

### Security

- GDPR and COPPA compliant
- Proper sensitive data handling
- ProGuard/R8 configuration included

---

## Future Roadmap

### v0.1.0 (Planned)
- Web platform support
- Enhanced ad analytics
- Advanced bidding features

### v1.0.0 (Target)
- Production-ready release
- Full feature parity with native SDKs
