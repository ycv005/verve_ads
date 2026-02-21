/// Ad event types that can be received from the native platform
enum AdEventType {
  /// Ad has been loaded and is ready to show
  loaded,

  /// Ad failed to load
  loadFailed,

  /// Ad has been displayed and an impression has been recorded
  impression,

  /// User clicked on the ad
  click,

  /// Full-screen ad has been opened
  opened,

  /// Full-screen ad has been closed
  closed,

  /// Interstitial ad has been dismissed
  dismissed,

  /// Rewarded ad completed and reward should be granted
  reward,
}

/// Extension to parse event type from string
extension AdEventTypeExtension on AdEventType {
  String get value {
    switch (this) {
      case AdEventType.loaded:
        return 'loaded';
      case AdEventType.loadFailed:
        return 'loadFailed';
      case AdEventType.impression:
        return 'impression';
      case AdEventType.click:
        return 'click';
      case AdEventType.opened:
        return 'opened';
      case AdEventType.closed:
        return 'closed';
      case AdEventType.dismissed:
        return 'dismissed';
      case AdEventType.reward:
        return 'reward';
    }
  }

  static AdEventType fromString(String value) {
    switch (value) {
      case 'loaded':
        return AdEventType.loaded;
      case 'loadFailed':
        return AdEventType.loadFailed;
      case 'impression':
        return AdEventType.impression;
      case 'click':
        return AdEventType.click;
      case 'opened':
        return AdEventType.opened;
      case 'closed':
        return AdEventType.closed;
      case 'dismissed':
        return AdEventType.dismissed;
      case 'reward':
        return AdEventType.reward;
      default:
        throw ArgumentError('Unknown AdEventType: $value');
    }
  }
}

/// Represents an ad event received from the native platform
class AdEvent {
  /// The type of ad event
  final AdEventType type;

  /// The zone ID associated with this event
  final String zoneId;

  /// Timestamp when the event occurred (milliseconds since epoch)
  final int timestamp;

  /// Additional data associated with the event
  final Map<String, dynamic>? data;

  const AdEvent({
    required this.type,
    required this.zoneId,
    required this.timestamp,
    this.data,
  });

  /// Creates an AdEvent from a map (from native platform)
  factory AdEvent.fromMap(Map<dynamic, dynamic> map) {
    return AdEvent(
      type: AdEventTypeExtension.fromString(map['type'] as String),
      zoneId: map['zoneId'] as String,
      timestamp: map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      data: map['data'] != null
          ? Map<String, dynamic>.from(map['data'] as Map)
          : null,
    );
  }

  /// Verve numeric error code from load-failed events.
  /// See [VerveErrorCode] for the full list of codes.
  int? get errorCode {
    if (type == AdEventType.loadFailed) {
      return data?['errorCode'] as int?;
    }
    return null;
  }

  /// Get error message from load failed event
  String? get errorMessage {
    if (type == AdEventType.loadFailed) {
      return data?['error'] as String?;
    }
    return null;
  }

  /// Get reward type from reward event
  String? get rewardType {
    if (type == AdEventType.reward) {
      return data?['rewardType'] as String?;
    }
    return null;
  }

  /// Get reward amount from reward event
  int? get rewardAmount {
    if (type == AdEventType.reward) {
      return data?['rewardAmount'] as int?;
    }
    return null;
  }

  @override
  String toString() {
    return 'AdEvent(type: $type, zoneId: $zoneId, timestamp: $timestamp, data: $data)';
  }
}
