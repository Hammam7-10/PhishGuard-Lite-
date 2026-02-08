import 'dart:math';

class RiskResult {
  final int score;
  final String label;
  final List<String> matchedKeywords;

  RiskResult(
      {required this.score,
      required this.label,
      required this.matchedKeywords});
}

class RiskEngine {
  /// Simple student-friendly phishing risk scoring.
  /// - We check message text + url for suspicious keywords
  /// - We add points if url looks strange (ip, many dots, too long)
  static RiskResult analyze({
    required String messageText,
    required String? url,
    required List<String> keywords,
  }) {
    final text = ('$messageText ${url ?? ''}').toLowerCase();

    final matched = <String>[];
    int score = 0;

    for (final k in keywords) {
      final kk = k.toLowerCase().trim();
      if (kk.isEmpty) continue;
      if (text.contains(kk)) {
        matched.add(k);
        score += 13;
      }
    }

    // URL heuristics
    if (url != null && url.trim().isNotEmpty) {
      final u = url.trim().toLowerCase();

      // very long url
      if (u.length > 60) score += 10;

      // IP-like url
      final ipLike = RegExp(r'\b(\d{1,3}\.){3}\d{1,3}\b');
      if (ipLike.hasMatch(u)) score += 20;

      // many dots/subdomains
      final dots = '.'.allMatches(u).length;
      if (dots >= 4) score += 10;

      // suspicious tld patterns
      if (u.contains('@') || u.contains('bit.ly') || u.contains('tinyurl'))
        score += 15;
    }

    score = min(100, max(0, score));

    final label = score >= 50
        ? 'Dangerous'
        : score >= 20
            ? 'Suspicious'
            : 'Safe';

    return RiskResult(score: score, label: label, matchedKeywords: matched);
  }
}
