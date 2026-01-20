# Verve Ads Plugin - Integration Guide

## Platform-Specific Setup

### Android Setup

#### 1. Add Gradle Dependencies

The plugin automatically includes HyBid SDK dependencies. Ensure your project has the Verve Maven repository configured in `build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://verve.jfrog.io/artifactory/verve-gradle-release' }
    }
}
```

#### 2. Manifest Permissions

The plugin automatically declares required permissions. For optimal targeting, you may also need:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

#### 3. ProGuard/R8 Configuration

Add to `proguard-rules.pro`:

```proguard
-keepattributes Signature
-keep class net.pubnative.** { *; }
-keep class com.iab.omid.library.pubnativenet.** { *; }
```

#### 4. Android Manifest Configuration

Example AndroidManifest.xml addition:

```xml
<application>
    <!-- Your app activities here -->
</application>
```

### iOS Setup

#### 1. CocoaPods Configuration

The plugin uses CocoaPods for dependency management. Ensure Podfile includes:

```ruby
platform :ios, '12.0'

target 'Runner' do
  flutter_root = File.expand_path(File.join(packages_dir, 'flutter'))
  load File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper')

  flutter_ios_podfile_setup

  pod 'HyBid', '~> 3.7.1'
end
```

#### 2. iOS Permissions

Add to `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to deliver better-targeted ads</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to deliver better-targeted ads</string>
```

#### 3. Build Settings

Ensure deployment target is iOS 12.0 or higher in Xcode Build Settings.

## Dart Implementation

### Basic App Integration

```dart
import 'package:flutter/material.dart';
import 'package:verve_ads/verve_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize at app startup
  final verveAds = VerveAds();
  final config = VerveConfig(
    appToken: 'YOUR_APP_TOKEN',
    testMode: true,
    locationTrackingEnabled: true,
  );
  
  final response = await verveAds.initialize(config);
  if (!response.isSuccess) {
    print('Initialization failed: ${response.errorMessage}');
  }
  
  runApp(MyApp());
}
```

### Creating Custom Ad Widgets

```dart
class NativeAdWidget extends StatefulWidget {
  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  final verveAds = VerveAds();
  VerveAd? _ad;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    setState(() => _loading = true);

    final adRequest = AdRequest(
      placementId: 'native_placement_1',
      adFormat: AdFormat.native,
    );

    final response = await verveAds.requestAd(adRequest);

    setState(() {
      _loading = false;
      if (response.isSuccess) {
        _ad = response.data;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_ad == null) {
      return SizedBox.shrink();
    }

    return Card(
      child: Column(
        children: [
          if (_ad!.imageUrl != null)
            Image.network(_ad!.imageUrl!),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_ad!.title != null)
                  Text(_ad!.title!, style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
                if (_ad!.description != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(_ad!.description!),
                  ),
                if (_ad!.ctaText != null)
                  ElevatedButton(
                    onPressed: () => verveAds.showAd(_ad!.adId),
                    child: Text(_ad!.ctaText!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Advanced Configuration

### Custom User Targeting

```dart
final verveAds = VerveAds();

// Set basic targeting
await verveAds.setTargetingParams(
  age: '30',
  gender: 'male',
  keywords: 'sports,tech,finance',
);

// Set advanced user data
await verveAds.setCustomUserData({
  'user_type': 'premium',
  'subscription_level': 'gold',
  'lifetime_value': '500.00',
  'interests': ['tech', 'sports', 'finance'],
});
```

### Privacy & Compliance

```dart
// GDPR Consent Management
final hasConsent = await verveAds.getUserConsentStatus();

if (!hasConsent) {
  // Show consent dialog
  bool userConsent = await showConsentDialog();
  if (userConsent) {
    await verveAds.setUserConsentStatus(true);
  }
}

// COPPA Compliance (for children's apps)
await verveAds.setCoppaEnabled(true);

// Location Control
await verveAds.setLocationTrackingEnabled(false);
```

### Error Handling & Retry Logic

```dart
Future<VerveAd?> requestAdWithRetry({
  required String placementId,
  int maxRetries = 3,
  int delayMs = 1000,
}) async {
  final verveAds = VerveAds();
  
  for (int i = 0; i < maxRetries; i++) {
    final request = AdRequest(
      placementId: placementId,
      adFormat: AdFormat.native,
      timeoutMs: 10000,
    );

    final response = await verveAds.requestAd(request);

    if (response.isSuccess && response.data != null) {
      return response.data;
    }

    // Check status code to determine if retry is appropriate
    switch (response.statusCode) {
      case HttpStatusCode.tooManyRequests:
        // Rate limited - exponential backoff
        await Future.delayed(Duration(milliseconds: delayMs * (i + 1)));
        break;
      case HttpStatusCode.noFill:
        // No ads available - retry
        await Future.delayed(Duration(milliseconds: delayMs));
        break;
      case HttpStatusCode.badRequest:
      case HttpStatusCode.unauthorized:
        // Don't retry on client errors
        return null;
      default:
        // Other errors - retry with delay
        await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  return null;
}
```

## State Management Integration

### With Provider

```dart
import 'package:provider/provider.dart';

class VerveAdsProvider extends ChangeNotifier {
  final verveAds = VerveAds();
  VerveAd? _currentAd;
  bool _isLoading = false;

  VerveAd? get currentAd => _currentAd;
  bool get isLoading => _isLoading;

  Future<void> loadAd(String placementId) async {
    _isLoading = true;
    notifyListeners();

    final request = AdRequest(
      placementId: placementId,
      adFormat: AdFormat.native,
    );

    final response = await verveAds.requestAd(request);

    _currentAd = response.data;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> showAd() async {
    if (_currentAd != null) {
      await verveAds.showAd(_currentAd!.adId);
    }
  }
}

// Usage
class AdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerveAdsProvider(),
      child: Consumer<VerveAdsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return CircularProgressIndicator();
          }
          return provider.currentAd != null ? AdWidget(ad: provider.currentAd!) : SizedBox.shrink();
        },
      ),
    );
  }
}
```

### With Riverpod

```dart
import 'package:riverpod/riverpod.dart';

final verveAdsProvider = Provider((ref) => VerveAds());

final adProvider = FutureProvider.family<VerveAd?, String>((ref, placementId) async {
  final verveAds = ref.read(verveAdsProvider);
  final request = AdRequest(
    placementId: placementId,
    adFormat: AdFormat.native,
  );
  final response = await verveAds.requestAd(request);
  return response.data;
});
```

## Debugging & Diagnostics

### Enable Detailed Logging

```dart
void setupVerveAdsLogging() {
  final verveAds = VerveAds();
  
  // Get diagnostics
  verveAds.getDiagnostics().then((diag) {
    print('SDK Diagnostics:');
    diag.forEach((key, value) {
      print('  $key: $value');
    });
  });
}

// Call in development
void main() {
  if (kDebugMode) {
    setupVerveAdsLogging();
  }
  runApp(MyApp());
}
```

### Monitor Ad Performance

```dart
class AdMetrics {
  static final Map<String, int> requestCount = {};
  static final Map<String, int> successCount = {};
  static final Map<String, int> failureCount = {};

  static Future<VerveResponse<VerveAd>> trackAdRequest(
    VerveAds verveAds,
    AdRequest request,
  ) async {
    requestCount[request.placementId] =
        (requestCount[request.placementId] ?? 0) + 1;

    final response = await verveAds.requestAd(request);

    if (response.isSuccess) {
      successCount[request.placementId] =
          (successCount[request.placementId] ?? 0) + 1;
    } else {
      failureCount[request.placementId] =
          (failureCount[request.placementId] ?? 0) + 1;
    }

    return response;
  }

  static void printMetrics() {
    print('Ad Metrics:');
    requestCount.forEach((placement, count) {
      final success = successCount[placement] ?? 0;
      final failure = failureCount[placement] ?? 0;
      final fillRate = count > 0 ? (success / count * 100).toStringAsFixed(2) : '0';
      print('  $placement: $success/$count ($fillRate% fill rate)');
    });
  }
}
```

## Testing

### Unit Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:verve_ads/verve_ads.dart';

void main() {
  group('Verve Ads Plugin', () {
    test('Initialize with valid config', () async {
      final verveAds = VerveAds();
      final config = VerveConfig(appToken: 'test_token');
      final response = await verveAds.initialize(config);
      
      expect(response.isSuccess, isTrue);
    });

    test('Ad request returns valid response', () async {
      final verveAds = VerveAds();
      final request = AdRequest(
        placementId: 'test_placement',
        adFormat: AdFormat.native,
      );
      
      final response = await verveAds.requestAd(request);
      
      expect(response.statusCode != null, isTrue);
    });
  });
}
```

## Performance Optimization

### Ad Caching Strategy

```dart
class AdCacheManager {
  static const _cacheDuration = Duration(hours: 1);
  static Map<String, CachedAd> _cache = {};

  static Future<VerveAd?> getOrFetchAd(
    String placementId,
    VerveAds verveAds,
  ) async {
    final cached = _cache[placementId];
    
    if (cached != null && !cached.isExpired) {
      return cached.ad;
    }

    final request = AdRequest(placementId: placementId, adFormat: AdFormat.native);
    final response = await verveAds.requestAd(request);

    if (response.isSuccess && response.data != null) {
      _cache[placementId] = CachedAd(
        ad: response.data!,
        cachedAt: DateTime.now(),
      );
      return response.data;
    }

    return null;
  }
}

class CachedAd {
  final VerveAd ad;
  final DateTime cachedAt;

  CachedAd({required this.ad, required this.cachedAt});

  bool get isExpired =>
      DateTime.now().difference(cachedAt) > Duration(hours: 1);
}
```

## Production Checklist

- [ ] Replace test app token with production token
- [ ] Disable test mode: `testMode: false`
- [ ] Implement proper error handling and user feedback
- [ ] Set up appropriate ad placement IDs
- [ ] Test on actual devices (Android & iOS)
- [ ] Implement GDPR consent management
- [ ] Set up proper user targeting parameters
- [ ] Monitor ad performance metrics
- [ ] Test with ProGuard/R8 on Android
- [ ] Verify all permissions are properly handled
- [ ] Test on various device sizes and orientations
- [ ] Implement proper logging for debugging

## Support & Resources

- **Verve Documentation**: https://developers.verve.com
- **HyBid Android SDK**: https://github.com/pubnative/pubnative-hybid-android-sdk
- **HyBid iOS SDK**: https://github.com/pubnative/pubnative-hybid-ios-sdk
- **Plugin Issues**: Submit on GitHub issues page
