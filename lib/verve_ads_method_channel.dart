import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'verve_ads_platform_interface.dart';
import 'models/verve_config.dart';
import 'models/verve_response.dart';
import 'models/ad_request.dart';
import 'models/ad_model.dart';
import 'models/ad_event.dart';

/// An implementation of [VerveAdsPlatform] that uses method channels.
class MethodChannelVerveAds extends VerveAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.verveads/verve_ads');

  /// The event channel for receiving ad events from native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('com.verveads/verve_ads_events');

  /// Cached stream of ad events from the native platform
  Stream<AdEvent>? _adEventStream;

  /// Stream of ad events from the native platform.
  /// Use this to listen for ad lifecycle events like impressions, clicks, rewards.
  @override
  Stream<AdEvent> get adEvents {
    _adEventStream ??= eventChannel.receiveBroadcastStream().map((event) {
      return AdEvent.fromMap(Map<dynamic, dynamic>.from(event as Map));
    }).handleError((error) {
      debugPrint('Error receiving ad event: $error');
    });
    return _adEventStream!;
  }

  /// Private helper to handle platform exceptions and convert to VerveResponse
  Future<VerveResponse<T>> _handleMethodCall<T>(
    Future<dynamic> Function() call,
    T Function(dynamic)? dataConverter,
  ) async {
    try {
      final result = await call();

      if (result is Map) {
        final statusCode = HttpStatusCode.fromCode(result['statusCode'] ?? 200);
        final isSuccess = result['isSuccess'] ?? true;
        final errorMessage = result['errorMessage'] as String?;
        final metadata = Map<String, dynamic>.from(result['metadata'] ?? {});

        if (isSuccess) {
          final data = dataConverter != null && result.containsKey('data')
              ? dataConverter(result['data'])
              : null;
          return VerveResponse.success(
            data: data,
            statusCode: statusCode,
            metadata: metadata,
            rawResponse: result,
          );
        } else {
          return VerveResponse.error(
            errorMessage: errorMessage ?? 'Unknown error',
            statusCode: statusCode,
            metadata: metadata,
            rawResponse: result,
          );
        }
      } else {
        return VerveResponse.success(data: result as T?);
      }
    } on PlatformException catch (e) {
      return VerveResponse.error(
        errorMessage: e.message ?? e.code,
        statusCode: HttpStatusCode.internalServerError,
        rawResponse: e,
      );
    } catch (e) {
      return VerveResponse.error(
        errorMessage: e.toString(),
        statusCode: HttpStatusCode.internalServerError,
      );
    }
  }

  @override
  Future<VerveResponse<void>> initialize(VerveConfig config) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('initialize', config.toMap()),
      null,
    );
  }

  @override
  Future<bool> isInitialized() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isInitialized');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking initialization: $e');
      return false;
    }
  }

  @override
  Future<String?> getSdkVersion() async {
    try {
      return await methodChannel.invokeMethod<String>('getSdkVersion');
    } catch (e) {
      debugPrint('Error getting SDK version: $e');
      return null;
    }
  }

  @override
  Future<VerveResponse<VerveAd>> requestAd(AdRequest adRequest) async {
    return _handleMethodCall<VerveAd>(
      () => methodChannel.invokeMethod('requestAd', adRequest.toMap()),
      (data) => VerveAd.fromMap(Map<dynamic, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<bool> isAdReady(String zoneId) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isAdReady', {
        'zoneId': zoneId,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking ad ready: $e');
      return false;
    }
  }

  @override
  Future<VerveResponse<void>> showAd(String zoneId) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('showAd', {'zoneId': zoneId}),
      null,
    );
  }

  @override
  Future<VerveResponse<void>> destroyAd(String zoneId) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('destroyAd', {'zoneId': zoneId}),
      null,
    );
  }

  @override
  Future<VerveResponse<void>> setTargetingParams({
    String? age,
    String? gender,
    String? keywords,
  }) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('setTargetingParams', {
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (keywords != null) 'keywords': keywords,
      }),
      null,
    );
  }

  @override
  Future<VerveResponse<void>> setCustomUserData(
    Map<String, dynamic> userData,
  ) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('setCustomUserData', userData),
      null,
    );
  }

  @override
  Future<VerveResponse<void>> setTestMode(bool enabled) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('setTestMode', {'enabled': enabled}),
      null,
    );
  }

  @override
  Future<VerveResponse<void>> setLocationTrackingEnabled(bool enabled) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('setLocationTrackingEnabled', {
        'enabled': enabled,
      }),
      null,
    );
  }

  @override
  Future<VerveResponse<void>> setCoppaEnabled(bool enabled) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('setCoppaEnabled', {'enabled': enabled}),
      null,
    );
  }

  @override
  Future<VerveResponse<void>> clearAdCache() async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('clearAdCache'),
      null,
    );
  }

  @override
  Future<String?> getDeviceId() async {
    try {
      return await methodChannel.invokeMethod<String>('getDeviceId');
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return null;
    }
  }

  @override
  Future<bool> getUserConsentStatus() async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'getUserConsentStatus',
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error getting consent status: $e');
      return false;
    }
  }

  @override
  Future<VerveResponse<void>> setUserConsentStatus(bool consent) async {
    return _handleMethodCall<void>(
      () => methodChannel.invokeMethod('setUserConsentStatus', {
        'consent': consent,
      }),
      null,
    );
  }

  @override
  Future<String?> getPlatformVersion() async {
    try {
      return await methodChannel.invokeMethod<String>('getPlatformVersion');
    } catch (e) {
      debugPrint('Error getting platform version: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getDiagnostics() async {
    try {
      final result = await methodChannel.invokeMethod<Map>('getDiagnostics');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      debugPrint('Error getting diagnostics: $e');
      return {};
    }
  }
}
