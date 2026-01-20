import 'package:flutter_test/flutter_test.dart';
import 'package:verve_ads/verve_ads.dart';
import 'package:verve_ads/verve_ads_platform_interface.dart';
import 'package:verve_ads/verve_ads_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVerveAdsPlatform
    with MockPlatformInterfaceMixin
    implements VerveAdsPlatform {
  @override
  Future<VerveResponse<void>> initialize(VerveConfig config) =>
      Future.value(VerveResponse.success());

  @override
  Future<bool> isInitialized() => Future.value(false);

  @override
  Future<String?> getSdkVersion() => Future.value('3.7.1');

  @override
  Future<VerveResponse<VerveAd>> requestAd(AdRequest adRequest) => Future.value(
    VerveResponse.error(
      errorMessage: 'Test error',
      statusCode: HttpStatusCode.badRequest,
    ),
  );

  @override
  Future<bool> isAdReady(String placementId) => Future.value(false);

  @override
  Future<VerveResponse<void>> showAd(String placementId) =>
      Future.value(VerveResponse.success());

  @override
  Future<VerveResponse<void>> setTargetingParams({
    String? age,
    String? gender,
    String? keywords,
  }) => Future.value(VerveResponse.success());

  @override
  Future<VerveResponse<void>> setCustomUserData(
    Map<String, dynamic> userData,
  ) => Future.value(VerveResponse.success());

  @override
  Future<VerveResponse<void>> setTestMode(bool enabled) =>
      Future.value(VerveResponse.success());

  @override
  Future<VerveResponse<void>> setLocationTrackingEnabled(bool enabled) =>
      Future.value(VerveResponse.success());

  @override
  Future<VerveResponse<void>> setCoppaEnabled(bool enabled) =>
      Future.value(VerveResponse.success());

  @override
  Future<VerveResponse<void>> clearAdCache() =>
      Future.value(VerveResponse.success());

  @override
  Future<String?> getDeviceId() => Future.value('test-device-id');

  @override
  Future<bool> getUserConsentStatus() => Future.value(true);

  @override
  Future<VerveResponse<void>> setUserConsentStatus(bool consent) =>
      Future.value(VerveResponse.success());

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>> getDiagnostics() =>
      Future.value({'status': 'ok'});
}

void main() {
  final VerveAdsPlatform initialPlatform = VerveAdsPlatform.instance;

  test('$MethodChannelVerveAds is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVerveAds>());
  });

  test('getPlatformVersion', () async {
    VerveAds verveAdsPlugin = VerveAds();
    MockVerveAdsPlatform fakePlatform = MockVerveAdsPlatform();
    VerveAdsPlatform.instance = fakePlatform;

    expect(await verveAdsPlugin.getPlatformVersion(), '42');
  });
}
