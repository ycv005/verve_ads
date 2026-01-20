# Quick Start Guide

## 5-Minute Setup

### Step 1: Add to pubspec.yaml

```yaml
dependencies:
  verve_ads:
    git:
      url: https://github.com/yourusername/verve_ads.git
      ref: main
```

Run:
```bash
flutter pub get
```

### Step 2: Initialize SDK

```dart
import 'package:verve_ads/verve_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Verve SDK
  await VerveAds().initialize(
    VerveConfig(
      appToken: 'YOUR_APP_TOKEN_FROM_VERVE_DASHBOARD',
      testMode: true, // Set to false in production
    ),
  );
  
  runApp(MyApp());
}
```

### Step 3: Request an Ad

```dart
import 'package:verve_ads/verve_ads.dart';

final verveAds = VerveAds();

// Request native ad
final response = await verveAds.requestAd(
  AdRequest(
    placementId: 'placement_123',
    adFormat: AdFormat.native,
  ),
);

if (response.isSuccess && response.data != null) {
  final ad = response.data!;
  print('✓ Ad received: ${ad.title}');
  
  // Display the ad
  await verveAds.showAd(ad.adId);
} else {
  print('✗ Failed: ${response.errorMessage}');
}
```

### Step 4: Handle Errors

```dart
if (!response.isSuccess) {
  switch (response.statusCode) {
    case HttpStatusCode.noFill:
      print('No ads available');
    case HttpStatusCode.badRequest:
      print('Invalid parameters');
    case HttpStatusCode.tooManyRequests:
      print('Too many requests - rate limited');
    default:
      print('Error: ${response.errorMessage}');
  }
}
```

---

## Common Tasks

### Set User Targeting

```dart
await verveAds.setTargetingParams(
  age: '28',
  gender: 'male',
  keywords: 'sports,games,tech',
);
```

### Manage Consent (GDPR)

```dart
// Check current consent
bool hasConsent = await verveAds.getUserConsentStatus();

// Set consent
await verveAds.setUserConsentStatus(true);
```

### Enable Test Mode

```dart
// Enable for development
await verveAds.setTestMode(true);

// Disable for production
await verveAds.setTestMode(false);
```

### Get SDK Information

```dart
// SDK version
String? version = await verveAds.getSdkVersion();

// Device ID
String? deviceId = await verveAds.getDeviceId();

// Full diagnostics
Map diagnostics = await verveAds.getDiagnostics();
print(diagnostics);
```

---

## Supported Ad Formats

- `AdFormat.banner` - Standard banner
- `AdFormat.mediumRectangle` - 300x250 rectangle
- `AdFormat.leaderboard` - 728x90 leaderboard
- `AdFormat.interstitial` - Full-screen ad
- `AdFormat.rewarded` - Rewarded video
- `AdFormat.native` - Native format

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request |
| 401 | Unauthorized/Invalid Token |
| 429 | Rate Limited |
| 500 | Server Error |

---

## Platform Setup

### Android
1. App token added to VerveConfig ✅
2. Permissions handled automatically ✅
3. ProGuard configuration included ✅

### iOS
1. App token added to VerveConfig ✅
2. CocoaPods setup automatic ✅
3. Minimum iOS 12.0 required ✅

---

## Example App

Full working example available in `example/lib/main.dart` with:
- Ad requests
- Ad display
- User targeting
- Privacy controls
- Error handling
- Diagnostics

Run:
```bash
cd example
flutter run
```

---

## Troubleshooting

### "Invalid app token" (401)
- Verify token from Verve Dashboard
- Check token is set correctly in VerveConfig

### "No fill" error
- Verify test mode is enabled in development
- Check placement ID is correct
- App may not be in approved geography

### "Rate limited" (429)
- Implement retry logic with backoff
- Reduce request frequency

---

## Documentation

- **Full README**: See README.md
- **Integration Guide**: See INTEGRATION_GUIDE.md
- **Project Summary**: See PROJECT_SUMMARY.md
- **Changelog**: See CHANGELOG.md
- **Example App**: See example/lib/main.dart

---

## Next Steps

1. ✅ Add plugin to pubspec.yaml
2. ✅ Initialize SDK in main.dart
3. ✅ Request your first ad
4. ✅ Display the ad in your UI
5. ✅ Test on real devices
6. ✅ Set production token
7. ✅ Disable test mode
8. ✅ Launch to production

---

## Support

- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check README.md and INTEGRATION_GUIDE.md
- **Example App**: Study example/lib/main.dart
- **Verve Docs**: https://developers.verve.com

---

**Ready to monetize? Let's go! 🚀**
