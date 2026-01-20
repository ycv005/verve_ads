/// Represents a native ad asset
class NativeAdAsset {
  /// Asset ID
  final String id;

  /// Asset text content (title, description, etc.)
  final String? text;

  /// Asset image URL
  final String? imageUrl;

  /// Asset click URL
  final String? clickUrl;

  /// Additional data
  final Map<String, dynamic>? data;

  NativeAdAsset({
    required this.id,
    this.text,
    this.imageUrl,
    this.clickUrl,
    this.data,
  });

  factory NativeAdAsset.fromMap(Map<dynamic, dynamic> map) {
    return NativeAdAsset(
      id: map['id'] ?? '',
      text: map['text'],
      imageUrl: map['imageUrl'],
      clickUrl: map['clickUrl'],
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'clickUrl': clickUrl,
      'data': data ?? {},
    };
  }
}

/// Represents a received ad with all associated data
class VerveAd {
  /// Unique ad identifier
  final String adId;

  /// Ad format
  final String format;

  /// Ad title
  final String? title;

  /// Ad description/body text
  final String? description;

  /// Ad click URL
  final String? clickUrl;

  /// Ad image URL
  final String? imageUrl;

  /// Ad icon URL
  final String? iconUrl;

  /// Campaign ID
  final String? campaignId;

  /// Creative ID
  final String? creativeId;

  /// Advertiser ID
  final String? advertiserId;

  /// Ad rating
  final double? rating;

  /// Call-to-action text (e.g., "Download", "Learn More")
  final String? ctaText;

  /// Native ad assets
  final List<NativeAdAsset>? assets;

  /// Additional tracking data
  final Map<String, dynamic>? metadata;

  VerveAd({
    required this.adId,
    required this.format,
    this.title,
    this.description,
    this.clickUrl,
    this.imageUrl,
    this.iconUrl,
    this.campaignId,
    this.creativeId,
    this.advertiserId,
    this.rating,
    this.ctaText,
    this.assets,
    this.metadata,
  });

  factory VerveAd.fromMap(Map<dynamic, dynamic> map) {
    return VerveAd(
      adId: map['adId'] ?? '',
      format: map['format'] ?? 'unknown',
      title: map['title'],
      description: map['description'],
      clickUrl: map['clickUrl'],
      imageUrl: map['imageUrl'],
      iconUrl: map['iconUrl'],
      campaignId: map['campaignId'],
      creativeId: map['creativeId'],
      advertiserId: map['advertiserId'],
      rating: (map['rating'] as num?)?.toDouble(),
      ctaText: map['ctaText'],
      assets: (map['assets'] as List?)
          ?.map(
            (asset) =>
                NativeAdAsset.fromMap(Map<dynamic, dynamic>.from(asset as Map)),
          )
          .toList(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adId': adId,
      'format': format,
      'title': title,
      'description': description,
      'clickUrl': clickUrl,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'campaignId': campaignId,
      'creativeId': creativeId,
      'advertiserId': advertiserId,
      'rating': rating,
      'ctaText': ctaText,
      'assets': assets?.map((a) => a.toMap()).toList() ?? [],
      'metadata': metadata ?? {},
    };
  }

  @override
  String toString() =>
      'VerveAd('
      'id: $adId, '
      'format: $format, '
      'title: $title, '
      'campaign: $campaignId'
      ')';
}
