# Verve Ads Flutter Plugin

A comprehensive, production-ready Flutter plugin for integrating Verve (HyBid) SDK. This plugin provides a configurable and scalable wrapper with full support for native ad formats, real-time ad tracking, and complete monetization capabilities.

## Features

✅ **Comprehensive SDK Wrapper** - Full coverage of Verve SDK functionality
✅ **Configurable & Scalable** - Enterprise-grade configuration system
✅ **Status Code Handling** - Standard HTTP status codes with detailed responses
✅ **Multiple Ad Formats** - Banner, Medium Rectangle, Interstitial, Rewarded, Native
✅ **Advanced Targeting** - Age, gender, keywords, and custom user data
✅ **Privacy Compliant** - COPPA compliance and user consent management
✅ **Location Tracking** - Optional location-based targeting
✅ **Test Mode** - Development and testing without revenue impact
✅ **Error Handling** - Comprehensive error responses with status codes
✅ **Diagnostics** - Built-in SDK diagnostics for debugging

## Platform Support

- ✅ Android (Kotlin)
- ✅ iOS (Swift)
- 🔜 Web (Coming Soon)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  verve_ads:
    git:
      url: https://github.com/ycv005/verve_ads.git
      ref: main
```

## Getting Started

### 1. Prerequisites

Get your **App Token** from the [Verve Publisher Dashboard](https://publishers.verve.com)

### 2. Basic Initialization

```dart
import 'package:verve_ads/verve_ads.dart';

void main() async {
  // Initialize Verve SDK
  final verveAds = VerveAds();
  
  final config = VerveConfig(
    appToken: 'YOUR_APP_TOKEN',
    testMode: true, // Set to false in production
  );
  
  final response = await verveAds.initialize(config);
  
  if (response.isSuccess) {
    print('✓ Verve SDK initialized');
  } else {
    print('✗ Initialization failed: ${response.errorMessage}');
  }
  
  runApp(const MyApp());
}
```

### 3. Request and Display Ads

```dart
// Request an ad
final adRequest = AdRequest(
  placementId: 'placement_123',
  adFormat: AdFormat.native,
);

final adResponse = await verveAds.requestAd(adRequest);

if (adResponse.isSuccess && adResponse.data != null) {
  final ad = adResponse.data!;
  print('✓ Ad received: ${ad.title}');
  
  // Show the ad
  await verveAds.showAd('placement_123');
} else {
  print('✗ Failed to get ad: ${adResponse.errorMessage}');
  print('Status Code: ${adResponse.statusCode.code}');
}
```

## Advanced Usage

### Configuration Options

```dart
final config = VerveConfig(
  appToken: 'YOUR_APP_TOKEN',
  
  // Development & Testing
  testMode: true,  // Prevent revenue counting during testing
  
  // Location Services
  locationTrackingEnabled: true,      // Use location for targeting
  locationUpdatesEnabled: true,       // Refresh location after each request
  
  // Privacy & Compliance
  coppaEnabled: false,                // Enable for COPPA compliance
  
  // User Targeting
  age: '28',
  gender: 'male',
  keywords: 'sports,gaming,tech',
  
  // Custom Parameters
  customParameters: {
    'publisher_id': 'pub_123',
    'app_version': '1.0.0',
  },
);

await verveAds.initialize(config);
```

### User Targeting

```dart
// Set individual targeting parameters
await verveAds.setTargetingParams(
  age: '25',
  gender: 'female',
  keywords: 'fashion,lifestyle',
);

// Set advanced custom user data
await verveAds.setCustomUserData({
  'user_type': 'premium',
  'subscription_status': 'active',
  'lifetime_value': '250.00',
});
```

### Privacy & Consent

```dart
// Set COPPA compliance
await verveAds.setCoppaEnabled(true);

// Handle user consent (GDPR)
bool hasConsent = await verveAds.getUserConsentStatus();

if (!hasConsent) {
  // Show consent dialog to user
  await verveAds.setUserConsentStatus(true);
}
```

### Ad Request with Custom Parameters

```dart
final adRequest = AdRequest(
  placementId: 'placement_456',
  adFormat: AdFormat.interstitial,
  timeoutMs: 15000,  // 15 second timeout
  customParameters: {
    'zone_id': 'zone_premium',
    'inventory_type': 'highvalue',
  },
  retryEnabled: true,
  maxRetries: 3,
);

final response = await verveAds.requestAd(adRequest);
```

### Response Handling

```dart
final response = await verveAds.requestAd(adRequest);

// Check success
if (response.isSuccess) {
  print('✓ Request succeeded');
} else {
  print('✗ Request failed');
}

// Access status code
switch (response.statusCode) {
  case HttpStatusCode.ok:
    print('Request succeeded');
    break;
  case HttpStatusCode.noFill:
    print('No ads available');
    break;
  case HttpStatusCode.badRequest:
    print('Invalid parameters provided');
    break;
  case HttpStatusCode.unauthorized:
    print('Invalid app token');
    break;
  case HttpStatusCode.tooManyRequests:
    print('Rate limited - wait before retrying');
    break;
  case HttpStatusCode.internalServerError:
    print('Server error');
    break;
  default:
    print('Unknown error: ${response.statusCode.code}');
}

// Access error message
if (!response.isSuccess) {
  print('Error: ${response.errorMessage}');
}

// Access metadata
print('Request ID: ${response.metadata?['requestId']}');
```

### Diagnostics & Debugging

```dart
// Get SDK diagnostics
final diagnostics = await verveAds.getDiagnostics();
print('SDK Version: ${diagnostics['sdkVersion']}');
print('Device ID: ${diagnostics['deviceId']}');
print('Is Initialized: ${diagnostics['isInitialized']}');
print('Test Mode: ${diagnostics['testMode']}');

// Check SDK version
final version = await verveAds.getSdkVersion();
print('Verve SDK Version: $version');

// Get device ID
final deviceId = await verveAds.getDeviceId();
print('Device ID: $deviceId');
```

### Ad Cache Management

```dart
// Clear cached ads
final response = await verveAds.clearAdCache();
if (response.isSuccess) {
  print('✓ Ad cache cleared');
}
```

## Status Codes

The plugin uses standard HTTP status codes for all operations:

| Code | Name | Meaning |
|------|------|---------|
| 200 | OK | Request succeeded |
| 201 | Created | Resource created successfully |
| 204 | No Content | Request succeeded, no content |
| 400 | Bad Request | Invalid parameters |
| 401 | Unauthorized | Invalid/expired token |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Resource not found |
| 429 | Too Many Requests | Rate limited |
| 500 | Internal Server Error | Server error |
| 502 | Bad Gateway | Invalid gateway response |
| 503 | Service Unavailable | Server temporarily unavailable |

## Models & Enums

### `VerveConfig`
Configuration for SDK initialization.

**Properties:**
- `appToken` (String, required) - App token from Verve Dashboard
- `testMode` (bool) - Enable test mode
- `locationTrackingEnabled` (bool) - Enable location tracking
- `locationUpdatesEnabled` (bool) - Refresh location after each request
- `coppaEnabled` (bool) - COPPA compliance
- `age` (String?) - User age
- `gender` (String?) - User gender
- `keywords` (String?) - Comma-separated keywords
- `customParameters` (Map?) - Custom parameters

### `AdRequest`
Parameters for requesting an ad.

**Properties:**
- `placementId` (String) - Unique placement identifier
- `adFormat` (AdFormat) - Ad format type
- `timeoutMs` (int) - Request timeout in milliseconds
- `customParameters` (Map?) - Custom parameters
- `retryEnabled` (bool) - Enable retry on failure
- `maxRetries` (int) - Maximum retry attempts

### `VerveAd`
Represents a received ad.

**Properties:**
- `adId` - Unique ad identifier
- `format` - Ad format
- `title` - Ad title
- `description` - Ad description
- `clickUrl` - Click destination URL
- `imageUrl` - Ad image URL
- `iconUrl` - Ad icon URL
- `campaignId` - Campaign identifier
- `creativeId` - Creative identifier
- `advertiserId` - Advertiser identifier
- `rating` - Ad rating
- `ctaText` - Call-to-action text
- `assets` - Native ad assets
- `metadata` - Additional metadata

### `AdFormat`
Enum for ad formats:
- `banner` - Banner ad
- `mediumRectangle` - 300x250 rectangle
- `leaderboard` - 728x90 leaderboard
- `interstitial` - Full-screen interstitial
- `rewarded` - Rewarded video
- `native` - Native ad format

### `HttpStatusCode`
Enum for HTTP status codes with numeric values.

### `VerveResponse<T>`
Generic response wrapper for all operations.

**Properties:**
- `statusCode` - HTTP status code
- `isSuccess` - Operation success indicator
- `data` - Response payload
- `errorMessage` - Error description
- `metadata` - Additional metadata
- `rawResponse` - Raw platform response

## Example Application

See the `example/` directory for a complete working example with:
- Initialization
- Ad requests and display
- User targeting
- Privacy settings
- Error handling
- Diagnostics

Run the example:
```bash
cd example
flutter run
```

## Platform-Specific Setup

### Android

1. Add Verve Maven repository to `build.gradle`:
```gradle
allprojects {
    repositories {
        maven { url 'https://verve.jfrog.io/artifactory/verve-gradle-release' }
    }
}
```

2. The plugin automatically adds required permissions:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS

1. The plugin automatically handles CocoaPods setup
2. Ensure deployment target is iOS 12.0 or higher

## Best Practices

1. **Initialize Early** - Call `initialize()` before requesting ads
2. **Use Test Mode** - Enable `testMode` during development
3. **Handle Responses** - Always check `isSuccess` and status codes
4. **Respect Rate Limits** - Implement backoff for HTTP 429 responses
5. **Set Targeting** - Provide user data for better ad relevance
6. **Privacy First** - Always get user consent before tracking
7. **Error Handling** - Implement proper error handling and logging
8. **Cache Management** - Periodically clear ad cache in long-running apps

## Troubleshooting

### "Invalid app token" (401)
- Verify your app token in Verve Dashboard
- Check token is correctly set in VerveConfig

### "No fill" (No ads available)
- Check if test mode is enabled
- Verify placement ID is correct
- Ensure app is in an approved geography

### "Rate limited" (429)
- Implement exponential backoff
- Reduce ad request frequency
- Contact Verve support if limits are too restrictive

### Initialization fails
- Check internet connection
- Verify app token format
- Review device logs for platform-specific errors

## Support & Documentation

- [Verve Developer Docs](https://developers.verve.com)
- [HyBid Android Wiki](https://github.com/pubnative/pubnative-hybid-android-sdk/wiki)
- [HyBid iOS Wiki](https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki)
- [GAM Mediation Setup](https://developers.verve.com/reference/google-ad-manager-adops-mediation-setup)

## License

This plugin follows the same license as the Verve SDK. See LICENSE file for details.

## Contributing

Contributions are welcome! Please follow the standard Flutter plugin development guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.
