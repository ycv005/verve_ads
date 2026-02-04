/// Enum for different ad formats supported by Verve
enum AdFormat {
  /// Banner ad format (320x50, 300x50, etc.)
  banner('banner'),

  /// Medium Rectangle (300x250)
  mediumRectangle('medium_rectangle'),

  /// Leaderboard (728x90)
  leaderboard('leaderboard'),

  /// Interstitial full-screen ad
  interstitial('interstitial'),

  /// Rewarded video ad
  rewarded('rewarded'),

  /// Native ad format
  native('native');

  final String value;

  const AdFormat(this.value);

  static AdFormat? fromString(String? value) {
    return AdFormat.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AdFormat.banner,
    );
  }
}

/// Enum for ad request status codes
enum AdRequestStatus {
  /// Request successfully completed
  success(0),

  /// No fill - ads not available
  noFill(1),

  /// Invalid parameters provided
  invalidParameters(2),

  /// Network error during request
  networkError(3),

  /// Request timeout
  timeout(4),

  /// Server error
  serverError(5),

  /// Ad format not supported
  unsupportedAdFormat(6),

  /// App token invalid or expired
  invalidAppToken(7),

  /// Rate limited - too many requests
  rateLimited(8),

  /// Internal SDK error
  internalError(99);

  final int code;

  const AdRequestStatus(this.code);

  static AdRequestStatus fromCode(int code) {
    try {
      return AdRequestStatus.values.firstWhere((e) => e.code == code);
    } catch (e) {
      return AdRequestStatus.internalError;
    }
  }
}

/// Model for ad request parameters
class AdRequest {
  /// Zone ID from PubNative/HyBid Publisher Dashboard (required)
  /// This is the primary identifier used by HyBid SDK to load ads
  final String zoneId;

  /// Unique identifier for this ad placement (optional, for app-side tracking)
  final String? placementId;

  /// Ad format to request
  final AdFormat adFormat;

  /// Timeout for ad request in milliseconds
  final int timeoutMs;

  /// Custom parameters for server
  final Map<String, dynamic>? customParameters;

  /// Whether to retry failed requests
  final bool retryEnabled;

  /// Maximum retry attempts
  final int maxRetries;

  AdRequest({
    required this.zoneId,
    this.placementId,
    required this.adFormat,
    this.timeoutMs = 10000,
    this.customParameters,
    this.retryEnabled = true,
    this.maxRetries = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      'zoneId': zoneId,
      'placementId': placementId ?? zoneId,
      'adFormat': adFormat.value,
      'timeoutMs': timeoutMs,
      'customParameters': customParameters ?? {},
      'retryEnabled': retryEnabled,
      'maxRetries': maxRetries,
    };
  }

  @override
  String toString() =>
      'AdRequest('
      'zoneId: $zoneId, '
      'format: ${adFormat.value}, '
      'timeout: ${timeoutMs}ms'
      ')';
}
