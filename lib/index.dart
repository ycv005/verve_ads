/// Main entry point for the Verve Ads Flutter Plugin
///
/// This file exports all public APIs for the plugin.
library;

export 'verve_ads.dart';
export 'verve_ads_platform_interface.dart';
export 'models/verve_config.dart';
export 'models/verve_response.dart';
export 'models/ad_request.dart';
export 'models/ad_model.dart';
export 'models/ad_event.dart';

// Main Classes
// - VerveAds: Main plugin API with all methods

// Models
// - VerveConfig: Configuration for SDK initialization
// - VerveResponse<T>: Generic response wrapper
// - AdRequest: Parameters for ad requests
// - VerveAd: Received ad data
// - NativeAdAsset: Native ad asset data

// Enums
// - HttpStatusCode: HTTP status codes with values
// - AdFormat: Supported ad format types
// - AdRequestStatus: Ad request status codes

// Platform Interface
// - VerveAdsPlatform: Abstract platform interface

// Example Usage:
//
// import 'package:verve_ads/verve_ads.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   final verveAds = VerveAds();
//   final response = await verveAds.initialize(
//     VerveConfig(appToken: 'YOUR_TOKEN', testMode: true),
//   );
//
//   if (response.isSuccess) {
//     print('✓ SDK Initialized');
//   } else {
//     print('✗ Error: ${response.errorMessage}');
//   }
//
//   runApp(const MyApp());
// }
