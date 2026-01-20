# Verve Ads Flutter Plugin - API Reference

## Main Class: VerveAds

Singleton-pattern class providing all plugin functionality.

### Initialization

```dart
Future<VerveResponse<void>> initialize(VerveConfig config)
```

Initializes the Verve SDK with provided configuration. Must be called before any other operations.

**Parameters:**
- `config` (VerveConfig) - SDK configuration including app token and settings

**Returns:**
- `VerveResponse<void>` - Response indicating success/failure with status code

**Example:**
```dart
final response = await VerveAds().initialize(
  VerveConfig(appToken: 'token', testMode: true),
);
if (response.isSuccess) { /* ... */ }
```

---

### Status Checks

```dart
Future<bool> isInitialized()
```

Check if SDK has been initialized.

**Returns:** `bool` - true if initialized

---

```dart
Future<String?> getSdkVersion()
```

Get the version of the HyBid SDK.

**Returns:** `String?` - Version number or null if error

---

```dart
Future<String?> getPlatformVersion()
```

Get platform version information.

**Returns:** `String?` - Platform version (e.g., "Android 13", "iOS 16.1")

---

### Ad Operations

```dart
Future<VerveResponse<VerveAd>> requestAd(AdRequest adRequest)
```

Request an ad for the given placement and format.

**Parameters:**
- `adRequest` (AdRequest) - Ad request with placement and format

**Returns:**
- `VerveResponse<VerveAd>` - Ad data or error

**Status Codes:**
- 200: Success - Ad received
- 204: No Content - Request succeeded but no ad available
- 400: Bad Request - Invalid parameters
- 429: Too Many Requests - Rate limited
- 500+: Server Error

**Example:**
```dart
final response = await VerveAds().requestAd(
  AdRequest(
    placementId: 'placement_123',
    adFormat: AdFormat.native,
    timeoutMs: 10000,
  ),
);

if (response.isSuccess) {
  print('Ad: ${response.data?.title}');
} else if (response.statusCode == HttpStatusCode.noFill) {
  print('No ads available');
}
```

---

```dart
Future<bool> isAdReady(String placementId)
```

Check if an ad is ready to display for the given placement.

**Parameters:**
- `placementId` (String) - Placement identifier

**Returns:** `bool` - true if ad is ready

---

```dart
Future<VerveResponse<void>> showAd(String placementId)
```

Display an ad for the given placement.

**Parameters:**
- `placementId` (String) - Placement identifier

**Returns:**
- `VerveResponse<void>` - Result of show operation

**Example:**
```dart
final response = await VerveAds().showAd(ad.adId);
if (response.isSuccess) {
  print('Ad displayed');
}
```

---

### User Targeting

```dart
Future<VerveResponse<void>> setTargetingParams({
  String? age,
  String? gender,
  String? keywords,
})
```

Set user targeting parameters for better ad relevance.

**Parameters:**
- `age` (String?) - User age (e.g., "25", "30")
- `gender` (String?) - User gender ("male", "female")
- `keywords` (String?) - Comma-separated keywords

**Returns:** `VerveResponse<void>` - Success/failure

**Example:**
```dart
await VerveAds().setTargetingParams(
  age: '28',
  gender: 'male',
  keywords: 'sports,tech,finance',
);
```

---

```dart
Future<VerveResponse<void>> setCustomUserData(Map<String, dynamic> userData)
```

Set advanced custom user data for targeting.

**Parameters:**
- `userData` (Map) - Custom data key-value pairs

**Returns:** `VerveResponse<void>` - Success/failure

**Example:**
```dart
await VerveAds().setCustomUserData({
  'user_type': 'premium',
  'subscription_level': 'gold',
  'lifetime_value': '500.00',
  'interests': ['tech', 'sports'],
});
```

---

### Configuration Control

```dart
Future<VerveResponse<void>> setTestMode(bool enabled)
```

Enable/disable test mode. Use true during development.

**Parameters:**
- `enabled` (bool) - true to enable test mode

**Returns:** `VerveResponse<void>` - Success/failure

---

```dart
Future<VerveResponse<void>> setLocationTrackingEnabled(bool enabled)
```

Enable/disable location tracking for targeting.

**Parameters:**
- `enabled` (bool) - true to enable location tracking

**Returns:** `VerveResponse<void>` - Success/failure

---

```dart
Future<VerveResponse<void>> setCoppaEnabled(bool enabled)
```

Enable COPPA compliance for children's apps.

**Parameters:**
- `enabled` (bool) - true to enable COPPA mode

**Returns:** `VerveResponse<void>` - Success/failure

---

### Privacy & Consent

```dart
Future<bool> getUserConsentStatus()
```

Get current user consent status.

**Returns:** `bool` - true if user has consented

---

```dart
Future<VerveResponse<void>> setUserConsentStatus(bool consent)
```

Set user consent status (for GDPR compliance).

**Parameters:**
- `consent` (bool) - true if user consented

**Returns:** `VerveResponse<void>` - Success/failure

---

### Device & Utilities

```dart
Future<String?> getDeviceId()
```

Get device identifier.

**Returns:** `String?` - Device ID or null

---

```dart
Future<VerveResponse<void>> clearAdCache()
```

Clear all cached ads.

**Returns:** `VerveResponse<void>` - Success/failure

---

```dart
Future<Map<String, dynamic>> getDiagnostics()
```

Get SDK diagnostics information.

**Returns:** `Map<String, dynamic>` - Diagnostics data

**Includes:**
- isInitialized: bool
- sdkVersion: String
- testMode: bool
- platform: String
- deviceId: String
- osVersion: String (iOS) / Build.VERSION.RELEASE (Android)

**Example:**
```dart
final diag = await VerveAds().getDiagnostics();
print('SDK Version: ${diag['sdkVersion']}');
print('Test Mode: ${diag['testMode']}');
```

---

## Data Models

### VerveConfig

Configuration model for SDK initialization.

**Properties:**
- `appToken` (String, required) - App token from Verve Dashboard
- `testMode` (bool, default: false) - Enable test mode
- `locationTrackingEnabled` (bool, default: true) - Enable location tracking
- `locationUpdatesEnabled` (bool, default: true) - Refresh location after each request
- `coppaEnabled` (bool, default: false) - COPPA compliance
- `age` (String?) - User age
- `gender` (String?) - User gender
- `keywords` (String?) - Comma-separated keywords
- `customParameters` (Map?) - Custom server parameters

**Constructor:**
```dart
const VerveConfig({
  required String appToken,
  bool testMode = false,
  bool locationTrackingEnabled = true,
  bool locationUpdatesEnabled = true,
  bool coppaEnabled = false,
  String? age,
  String? gender,
  String? keywords,
  Map<String, dynamic>? customParameters,
})
```

---

### VerveResponse<T>

Generic response wrapper for all operations.

**Properties:**
- `statusCode` (HttpStatusCode) - HTTP status code
- `isSuccess` (bool) - Operation success indicator
- `data` (T?) - Response payload
- `errorMessage` (String?) - Error description if failed
- `metadata` (Map?) - Additional metadata
- `rawResponse` (dynamic) - Raw platform response

**Static Methods:**
```dart
VerveResponse.success({
  T? data,
  HttpStatusCode statusCode = HttpStatusCode.ok,
  Map<String, dynamic>? metadata,
  dynamic rawResponse,
})

VerveResponse.error({
  required String errorMessage,
  HttpStatusCode statusCode = HttpStatusCode.internalServerError,
  Map<String, dynamic>? metadata,
  dynamic rawResponse,
})
```

---

### AdRequest

Parameters for ad request.

**Properties:**
- `placementId` (String, required) - Placement identifier
- `adFormat` (AdFormat, required) - Ad format type
- `timeoutMs` (int, default: 10000) - Request timeout in milliseconds
- `customParameters` (Map?) - Custom parameters
- `retryEnabled` (bool, default: true) - Enable retry on failure
- `maxRetries` (int, default: 2) - Maximum retry attempts

**Constructor:**
```dart
AdRequest({
  required String placementId,
  required AdFormat adFormat,
  int timeoutMs = 10000,
  Map<String, dynamic>? customParameters,
  bool retryEnabled = true,
  int maxRetries = 2,
})
```

---

### VerveAd

Received ad data.

**Properties:**
- `adId` (String) - Unique ad identifier
- `format` (String) - Ad format
- `title` (String?) - Ad title
- `description` (String?) - Ad description
- `clickUrl` (String?) - Click destination URL
- `imageUrl` (String?) - Ad image URL
- `iconUrl` (String?) - Ad icon URL
- `campaignId` (String?) - Campaign identifier
- `creativeId` (String?) - Creative identifier
- `advertiserId` (String?) - Advertiser identifier
- `rating` (double?) - Ad rating
- `ctaText` (String?) - Call-to-action text
- `assets` (List<NativeAdAsset>?) - Native ad assets
- `metadata` (Map?) - Additional metadata

---

### NativeAdAsset

Individual native ad asset.

**Properties:**
- `id` (String) - Asset ID
- `text` (String?) - Text content
- `imageUrl` (String?) - Image URL
- `clickUrl` (String?) - Click URL
- `data` (Map?) - Additional data

---

## Enums

### HttpStatusCode

HTTP status codes with numeric values.

```dart
enum HttpStatusCode {
  ok(200),                 // Request succeeded
  created(201),            // Resource created
  noContent(204),          // No content
  badRequest(400),         // Invalid parameters
  unauthorized(401),       // Invalid/expired token
  forbidden(403),          // Access denied
  notFound(404),           // Resource not found
  tooManyRequests(429),    // Rate limited
  internalServerError(500),// Server error
  badGateway(502),         // Invalid gateway response
  serviceUnavailable(503), // Server unavailable
  unknown(-1),             // Unknown error
}
```

**Static Method:**
```dart
static HttpStatusCode fromCode(int code)
```

---

### AdFormat

Supported ad formats.

```dart
enum AdFormat {
  banner('banner'),                    // Banner ad
  mediumRectangle('medium_rectangle'), // 300x250
  leaderboard('leaderboard'),          // 728x90
  interstitial('interstitial'),        // Full-screen
  rewarded('rewarded'),                // Rewarded video
  native('native'),                    // Native format
}
```

---

### AdRequestStatus

Ad request status codes.

```dart
enum AdRequestStatus {
  success(0),                  // Success
  noFill(1),                   // No ads available
  invalidParameters(2),        // Invalid parameters
  networkError(3),             // Network error
  timeout(4),                  // Timeout
  serverError(5),              // Server error
  unsupportedAdFormat(6),      // Unsupported format
  invalidAppToken(7),          // Invalid token
  rateLimited(8),              // Rate limited
  internalError(99),           // Internal error
}
```

---

## Singleton Access

```dart
// Access singleton instance
final verveAds = VerveAds();

// All methods are then available on this instance
await verveAds.initialize(config);
final response = await verveAds.requestAd(request);
```

---

## Error Handling

All methods return either:
1. `VerveResponse<T>` - with detailed status codes and errors
2. Plain `bool` or `String` for simple queries

Always check `response.isSuccess` and `response.statusCode`:

```dart
final response = await verveAds.requestAd(request);

if (!response.isSuccess) {
  switch (response.statusCode) {
    case HttpStatusCode.badRequest:
      // Handle invalid request
      break;
    case HttpStatusCode.tooManyRequests:
      // Handle rate limiting - implement backoff
      break;
    default:
      print('Error: ${response.errorMessage}');
  }
}
```

---

## Threading & Async

All methods are async and should be called with `await`:

```dart
// Correct
final response = await verveAds.requestAd(request);

// Not recommended (fire and forget)
verveAds.requestAd(request);
```

Handle errors properly:

```dart
try {
  final response = await verveAds.requestAd(request);
  if (response.isSuccess) { /* ... */ }
} catch (e) {
  print('Exception: $e');
}
```

---

## Rate Limiting

When receiving `HttpStatusCode.tooManyRequests` (429):

```dart
// Implement exponential backoff
int delay = 1000; // 1 second
int retries = 0;
while (retries < maxRetries) {
  final response = await verveAds.requestAd(request);
  
  if (response.statusCode == HttpStatusCode.tooManyRequests) {
    await Future.delayed(Duration(milliseconds: delay));
    delay *= 2; // Exponential backoff
    retries++;
  } else {
    break;
  }
}
```

---

## Best Practices

1. **Always check isSuccess** before using data
2. **Handle all status codes** appropriately
3. **Use try-catch** for unexpected exceptions
4. **Implement retry logic** with exponential backoff
5. **Enable test mode** during development
6. **Disable test mode** for production
7. **Set targeting parameters** for better fill rates
8. **Manage user consent** for GDPR compliance
9. **Cache diagnostics** during development
10. **Monitor error rates** in production

---

**For complete examples, see example/lib/main.dart**
