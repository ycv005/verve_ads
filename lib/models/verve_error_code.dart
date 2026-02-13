/// Standardized error codes for the Verve Ads (HyBid SDK) plugin.
///
/// These codes directly mirror the **real** `HyBidErrorCode` enum from the
/// native HyBid Android SDK source:
/// https://github.com/pubnative/pubnative-hybid-android-sdk/blob/main/hybid.sdk/src/main/java/net/pubnative/lite/sdk/HyBidErrorCode.java
///
/// HyBid SDK error codes (1–25) are passed through as-is.
/// Plugin-level error codes (100+) are added for errors that originate
/// in our Flutter plugin layer rather than the HyBid SDK itself.
class VerveErrorCode {
  VerveErrorCode._(); // prevent instantiation

  // ══════════════════════════════════════════════════════════════════
  //  HyBid SDK error codes  (from HyBidErrorCode.java)
  // ══════════════════════════════════════════════════════════════════

  /// No ad fill — the server had no ads to serve for this request.
  static const int noFill = 1;

  /// Response could not be parsed.
  static const int parserError = 2;

  /// Server returned an error.
  static const int serverError = 3;

  /// The server returned an invalid ad asset.
  static const int invalidAsset = 4;

  /// The server returned an unsupported ad asset.
  static const int unsupportedAsset = 5;

  /// Server returned a null ad object.
  static const int nullAd = 6;

  /// The provided ad is invalid.
  static const int invalidAd = 7;

  /// Invalid zone ID was provided.
  static const int invalidZoneId = 8;

  /// Invalid signal data / Out of memory / Invalid view binder.
  /// (HyBid uses code 9 for multiple error types.)
  static const int invalidSignalData = 9;

  /// The HyBid SDK has not been initialised.
  static const int notInitialised = 10;

  /// The auction returned no ad.
  static const int auctionNoAd = 11;

  /// Error rendering banner ad.
  static const int errorRenderingBanner = 12;

  /// Error rendering interstitial ad.
  static const int errorRenderingInterstitial = 13;

  /// Error rendering rewarded ad.
  static const int errorRenderingRewarded = 14;

  /// Error rendering HTML/MRAID ad.
  static const int mraidPlayerError = 15;

  /// Error rendering VAST video ad.
  static const int vastPlayerError = 16;

  /// Error reporting a URL tracker.
  static const int errorTrackingUrl = 17;

  /// Error reporting a JS tracker.
  static const int errorTrackingJs = 18;

  /// Invalid request URL.
  static const int invalidUrl = 19;

  /// An internal error in the HyBid SDK.
  static const int internalError = 20;

  /// An unknown error in the HyBid SDK.
  static const int unknownError = 21;

  /// The requested ad format has been disabled.
  static const int disabledFormat = 22;

  /// The requested rendering engine has been disabled.
  static const int disabledRenderingEngine = 23;

  /// The ad has expired.
  static const int expiredAd = 24;

  /// Error loading the feedback form.
  static const int errorLoadingFeedback = 25;

  // ══════════════════════════════════════════════════════════════════
  //  Plugin-level error codes  (100+)
  //  These are NOT from HyBid — they originate in our plugin layer.
  // ══════════════════════════════════════════════════════════════════

  /// A required parameter (e.g. zoneId, appToken) was missing.
  static const int missingRequiredParameter = 100;

  /// An unsupported ad format string was requested.
  static const int unsupportedAdFormat = 101;

  /// Android Activity is not available (e.g. app backgrounded).
  static const int activityNotAvailable = 102;

  /// The ad is not ready/loaded when show was called.
  static const int adNotReady = 103;

  /// Could not obtain the Android Application context.
  static const int applicationContextUnavailable = 104;

  /// A plugin-level exception was thrown.
  static const int pluginException = 105;

  /// Catch-all for completely unrecognised errors.
  static const int unknown = 999;

  /// Returns a human-readable label for the given error [code].
  static String nameOf(int code) {
    switch (code) {
      // HyBid SDK codes
      case noFill:
        return 'NO_FILL';
      case parserError:
        return 'PARSER_ERROR';
      case serverError:
        return 'SERVER_ERROR';
      case invalidAsset:
        return 'INVALID_ASSET';
      case unsupportedAsset:
        return 'UNSUPPORTED_ASSET';
      case nullAd:
        return 'NULL_AD';
      case invalidAd:
        return 'INVALID_AD';
      case invalidZoneId:
        return 'INVALID_ZONE_ID';
      case invalidSignalData:
        return 'INVALID_SIGNAL_DATA';
      case notInitialised:
        return 'NOT_INITIALISED';
      case auctionNoAd:
        return 'AUCTION_NO_AD';
      case errorRenderingBanner:
        return 'ERROR_RENDERING_BANNER';
      case errorRenderingInterstitial:
        return 'ERROR_RENDERING_INTERSTITIAL';
      case errorRenderingRewarded:
        return 'ERROR_RENDERING_REWARDED';
      case mraidPlayerError:
        return 'MRAID_PLAYER_ERROR';
      case vastPlayerError:
        return 'VAST_PLAYER_ERROR';
      case errorTrackingUrl:
        return 'ERROR_TRACKING_URL';
      case errorTrackingJs:
        return 'ERROR_TRACKING_JS';
      case invalidUrl:
        return 'INVALID_URL';
      case internalError:
        return 'INTERNAL_ERROR';
      case unknownError:
        return 'UNKNOWN_ERROR';
      case disabledFormat:
        return 'DISABLED_FORMAT';
      case disabledRenderingEngine:
        return 'DISABLED_RENDERING_ENGINE';
      case expiredAd:
        return 'EXPIRED_AD';
      case errorLoadingFeedback:
        return 'ERROR_LOADING_FEEDBACK';

      // Plugin-level codes
      case missingRequiredParameter:
        return 'MISSING_REQUIRED_PARAMETER';
      case unsupportedAdFormat:
        return 'UNSUPPORTED_AD_FORMAT';
      case activityNotAvailable:
        return 'ACTIVITY_NOT_AVAILABLE';
      case adNotReady:
        return 'AD_NOT_READY';
      case applicationContextUnavailable:
        return 'APPLICATION_CONTEXT_UNAVAILABLE';
      case pluginException:
        return 'PLUGIN_EXCEPTION';
      case unknown:
        return 'UNKNOWN';
      default:
        return 'UNMAPPED_ERROR_$code';
    }
  }

  /// Returns `true` if retrying the ad request is likely to succeed
  /// (e.g., no fill, server error, auction miss).
  static bool isRetryable(int code) {
    return const {
      noFill,
      serverError,
      nullAd,
      auctionNoAd,
      unknownError,
    }.contains(code);
  }

  /// Returns `true` if the error is permanent / configuration-level
  /// and retrying will not fix it.
  static bool isPermanent(int code) {
    return const {
      invalidZoneId,
      notInitialised,
      disabledFormat,
      disabledRenderingEngine,
      missingRequiredParameter,
      unsupportedAdFormat,
      applicationContextUnavailable,
    }.contains(code);
  }
}
