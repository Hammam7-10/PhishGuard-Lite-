class Report {
  final int? id;
  final String title;
  final String messageText;
  final String? url;
  final String? imagePath;
  final int riskScore; // 0 - 100
  final String riskLabel; // Safe / Suspicious / Dangerous
  final DateTime createdAt;
  final bool syncedToCloud;

  Report({
    this.id,
    required this.title,
    required this.messageText,
    this.url,
    this.imagePath,
    required this.riskScore,
    required this.riskLabel,
    required this.createdAt,
    required this.syncedToCloud,
  });

  Report copyWith({
    int? id,
    String? title,
    String? messageText,
    String? url,
    String? imagePath,
    int? riskScore,
    String? riskLabel,
    DateTime? createdAt,
    bool? syncedToCloud,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      messageText: messageText ?? this.messageText,
      url: url ?? this.url,
      imagePath: imagePath ?? this.imagePath,
      riskScore: riskScore ?? this.riskScore,
      riskLabel: riskLabel ?? this.riskLabel,
      createdAt: createdAt ?? this.createdAt,
      syncedToCloud: syncedToCloud ?? this.syncedToCloud,
    );
  }
}
