class Announcement {
  final String id;
  final Map<String, String> content; // {"tr": "...", "en": "...", "de": "..."}
  final bool isActive;
  final bool isPremiumPromotion;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.content,
    required this.isActive,
    required this.isPremiumPromotion,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    // Parse content JSON map
    final contentMap = json['content'] as Map<String, dynamic>? ?? {};
    final Map<String, String> parsedContent = {};
    contentMap.forEach((key, value) {
      parsedContent[key] = value.toString();
    });

    return Announcement(
      id: json['id'] as String,
      content: parsedContent,
      isActive: json['is_active'] as bool? ?? true,
      isPremiumPromotion: json['is_premium_promotion'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Gets localized text for the current language code.
  /// Falls back to English ('en'), then Turkish ('tr'), then the first available text.
  String getLocalizedContent(String langCode) {
    if (content.containsKey(langCode)) {
      return content[langCode]!;
    }
    // Fallbacks
    if (content.containsKey('en')) {
      return content['en']!;
    }
    if (content.containsKey('tr')) {
      return content['tr']!;
    }
    return content.values.isNotEmpty ? content.values.first : '';
  }
}
