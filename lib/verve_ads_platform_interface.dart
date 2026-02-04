import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/verve_config.dart';
import 'models/verve_response.dart';
import 'models/ad_request.dart';
import 'models/ad_model.dart';
import 'models/ad_event.dart';
import 'verve_ads_method_channel.dart';

abstract class VerveAdsPlatform extends PlatformInterface {
  /// Constructs a VerveAdsPlatform.
  VerveAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  static VerveAdsPlatform _instance = MethodChannelVerveAds();

  /// The default instance of [VerveAdsPlatform] to use.
  ///
  /// Defaults to [MethodChannelVerveAds].
  static VerveAdsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VerveAdsPlatform] when
  /// they register themselves.
  static set instance(VerveAdsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the Verve SDK with provided configuration
  Future<VerveResponse<void>> initialize(VerveConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Check if SDK is initialized
  Future<bool> isInitialized() {
    throw UnimplementedError('isInitialized() has not been implemented.');
  }

  /// Get current SDK version
  Future<String?> getSdkVersion() {
    throw UnimplementedError('getSdkVersion() has not been implemented.');
  }

  /// Request an ad with given parameters
  Future<VerveResponse<VerveAd>> requestAd(AdRequest adRequest) {
    throw UnimplementedError('requestAd() has not been implemented.');
  }

  /// Check if ad is ready for given zone ID
  Future<bool> isAdReady(String zoneId) {
    throw UnimplementedError('isAdReady() has not been implemented.');
  }

  /// Show ad for given zone ID
  Future<VerveResponse<void>> showAd(String zoneId) {
    throw UnimplementedError('showAd() has not been implemented.');
  }

  /// Destroy ad for given zone ID (cleanup resources)
  Future<VerveResponse<void>> destroyAd(String zoneId) {
    throw UnimplementedError('destroyAd() has not been implemented.');
  }

  /// Stream of ad events (impressions, clicks, rewards, etc.)
  /// Listen to this stream to receive ad lifecycle events
  Stream<AdEvent> get adEvents {
    throw UnimplementedError('adEvents has not been implemented.');
  }

  /// Set user targeting parameters
  Future<VerveResponse<void>> setTargetingParams({
    String? age,
    String? gender,
    String? keywords,
  }) {
    throw UnimplementedError('setTargetingParams() has not been implemented.');
  }

  /// Set custom user data for targeting
  Future<VerveResponse<void>> setCustomUserData(Map<String, dynamic> userData) {
    throw UnimplementedError('setCustomUserData() has not been implemented.');
  }

  /// Enable or disable test mode
  Future<VerveResponse<void>> setTestMode(bool enabled) {
    throw UnimplementedError('setTestMode() has not been implemented.');
  }

  /// Enable or disable location tracking
  Future<VerveResponse<void>> setLocationTrackingEnabled(bool enabled) {
    throw UnimplementedError(
      'setLocationTrackingEnabled() has not been implemented.',
    );
  }

  /// Enable or disable COPPA compliance
  Future<VerveResponse<void>> setCoppaEnabled(bool enabled) {
    throw UnimplementedError('setCoppaEnabled() has not been implemented.');
  }

  /// Clear all ads from cache
  Future<VerveResponse<void>> clearAdCache() {
    throw UnimplementedError('clearAdCache() has not been implemented.');
  }

  /// Get device identifier
  Future<String?> getDeviceId() {
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }

  /// Get user consent status
  Future<bool> getUserConsentStatus() {
    throw UnimplementedError(
      'getUserConsentStatus() has not been implemented.',
    );
  }

  /// Set user consent status
  Future<VerveResponse<void>> setUserConsentStatus(bool consent) {
    throw UnimplementedError(
      'setUserConsentStatus() has not been implemented.',
    );
  }

  /// Get platform version
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Get SDK diagnostics info
  Future<Map<String, dynamic>> getDiagnostics() {
    throw UnimplementedError('getDiagnostics() has not been implemented.');
  }
}
