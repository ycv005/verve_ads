/// Configuration model for Verve SDK initialization and setup
class VerveConfig {
  /// Application token from Verve Publisher Dashboard (required)
  final String appToken;

  /// Enable test mode (default: false)
  /// When enabled, impressions and clicks won't count towards your account
  final bool testMode;

  /// Enable location tracking (default: false)
  /// Improves ad targeting with user location
  final bool locationTrackingEnabled;

  /// Enable location updates (default: false)
  /// Keeps location accuracy by refreshing after each ad request
  final bool locationUpdatesEnabled;

  /// Enable COPPA compliance (default: false)
  /// Enable if your app targets children (under 13)
  final bool coppaEnabled;

  /// User's age for better targeting
  final String? age;

  /// User's gender for better targeting ('male', 'female')
  final String? gender;

  /// Comma-separated keywords for targeting
  final String? keywords;

  /// Additional custom parameters for server requests
  final Map<String, dynamic>? customParameters;

  const VerveConfig({ 
    required this.appToken,
    this.testMode = false,
    this.locationTrackingEnabled = false,
    this.locationUpdatesEnabled = false,
    this.coppaEnabled = false,
    this.age,
    this.gender,
    this.keywords,
    this.customParameters,
  });

  /// Convert config to Map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'appToken': appToken,
      'testMode': testMode,
      'locationTrackingEnabled': locationTrackingEnabled,
      'locationUpdatesEnabled': locationUpdatesEnabled,
      'coppaEnabled': coppaEnabled,
      'age': age,
      'gender': gender,
      'keywords': keywords,
      'customParameters': customParameters ?? {},
    };
  }

  @override
  String toString() =>
      'VerveConfig('
      'appToken: $appToken, '
      'testMode: $testMode, '
      'locationTracking: $locationTrackingEnabled, '
      'coppaEnabled: $coppaEnabled'
      ')';
}
