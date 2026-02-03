// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'verve_ads_platform_interface.dart';
import 'models/verve_config.dart';
import 'models/verve_response.dart';
import 'models/ad_request.dart';
import 'models/ad_model.dart';
import 'models/ad_event.dart';

// Export all public classes and enums
export 'models/verve_config.dart';
export 'models/verve_response.dart';
export 'models/ad_request.dart';
export 'models/ad_model.dart';
export 'models/ad_event.dart';

/// Main Verve Ads plugin class - provides API for ad integration
class VerveAds {
  /// Private constructor
  VerveAds._();

  /// Singleton instance
  static final VerveAds _instance = VerveAds._();

  /// Get singleton instance
  factory VerveAds() {
    return _instance;
  }

  /// Initialize Verve SDK with configuration
  /// This must be called before using any other SDK methods
  Future<VerveResponse<void>> initialize(VerveConfig config) {
    return VerveAdsPlatform.instance.initialize(config);
  }

  /// Check if Verve SDK has been initialized
  Future<bool> isInitialized() {
    return VerveAdsPlatform.instance.isInitialized();
  }

  /// Get Verve SDK version
  Future<String?> getSdkVersion() {
    return VerveAdsPlatform.instance.getSdkVersion();
  }

  /// Request an ad with specific parameters
  /// Returns VerveResponse containing the ad or error details
  Future<VerveResponse<VerveAd>> requestAd(AdRequest adRequest) {
    return VerveAdsPlatform.instance.requestAd(adRequest);
  }

  /// Check if an ad is ready to be shown for the given zone ID
  Future<bool> isAdReady(String zoneId) {
    return VerveAdsPlatform.instance.isAdReady(zoneId);
  }

  /// Show ad for the given zone ID
  Future<VerveResponse<void>> showAd(String zoneId) {
    return VerveAdsPlatform.instance.showAd(zoneId);
  }

  /// Destroy ad for the given zone ID (cleanup resources)
  /// Call this when you no longer need the ad
  Future<VerveResponse<void>> destroyAd(String zoneId) {
    return VerveAdsPlatform.instance.destroyAd(zoneId);
  }

  /// Stream of ad events from the native platform
  /// Use this to listen for ad lifecycle events like:
  /// - loaded: Ad finished loading
  /// - loadFailed: Ad failed to load
  /// - impression: Ad was displayed
  /// - click: User clicked the ad
  /// - reward: User earned a reward (rewarded ads)
  /// - dismissed/closed: Ad was closed
  ///
  /// Example:
  /// ```dart
  /// verveAds.adEvents.listen((event) {
  ///   if (event.type == AdEventType.reward) {
  ///     grantUserReward(event.rewardAmount);
  ///   }
  /// });
  /// ```
  Stream<AdEvent> get adEvents {
    return VerveAdsPlatform.instance.adEvents;
  }

  /// Set user targeting parameters (age, gender, keywords)
  /// This helps improve ad relevance
  Future<VerveResponse<void>> setTargetingParams({
    String? age,
    String? gender,
    String? keywords,
  }) {
    return VerveAdsPlatform.instance.setTargetingParams(
      age: age,
      gender: gender,
      keywords: keywords,
    );
  }

  /// Set custom user data for advanced targeting
  Future<VerveResponse<void>> setCustomUserData(Map<String, dynamic> userData) {
    return VerveAdsPlatform.instance.setCustomUserData(userData);
  }

  /// Enable or disable test mode
  /// When enabled, ads don't count towards revenue
  Future<VerveResponse<void>> setTestMode(bool enabled) {
    return VerveAdsPlatform.instance.setTestMode(enabled);
  }

  /// Enable or disable location tracking for better ad targeting
  Future<VerveResponse<void>> setLocationTrackingEnabled(bool enabled) {
    return VerveAdsPlatform.instance.setLocationTrackingEnabled(enabled);
  }

  /// Enable COPPA compliance (for apps targeting children)
  Future<VerveResponse<void>> setCoppaEnabled(bool enabled) {
    return VerveAdsPlatform.instance.setCoppaEnabled(enabled);
  }

  /// Clear all cached ads
  Future<VerveResponse<void>> clearAdCache() {
    return VerveAdsPlatform.instance.clearAdCache();
  }

  /// Get device identifier
  Future<String?> getDeviceId() {
    return VerveAdsPlatform.instance.getDeviceId();
  }

  /// Get current user consent status
  Future<bool> getUserConsentStatus() {
    return VerveAdsPlatform.instance.getUserConsentStatus();
  }

  /// Set user consent status (for GDPR/privacy compliance)
  Future<VerveResponse<void>> setUserConsentStatus(bool consent) {
    return VerveAdsPlatform.instance.setUserConsentStatus(consent);
  }

  /// Get platform version information
  Future<String?> getPlatformVersion() {
    return VerveAdsPlatform.instance.getPlatformVersion();
  }

  /// Get SDK diagnostics for debugging
  Future<Map<String, dynamic>> getDiagnostics() {
    return VerveAdsPlatform.instance.getDiagnostics();
  }
}
