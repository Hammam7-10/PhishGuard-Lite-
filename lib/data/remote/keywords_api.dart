import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Fetch phishing keywords from a public endpoint.
/// If the endpoint fails, fallback to local asset.
class KeywordsApi {
  // You can change this link to any endpoint you want.
  // We keep it simple (student-friendly).
  static const String endpoint =
      'https://raw.githubusercontent.com/zeropingheroes/keywords/main/phishing_keywords.txt';

  Future<List<String>> loadKeywords() async {
    try {
      final res = await http.get(Uri.parse(endpoint)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final lines = res.body
            .split(RegExp(r'[\r\n]+'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (lines.length >= 5) return lines.take(200).toList();
      }
    } catch (_) {
      // ignore and fallback
    }
    return loadFallbackKeywords();
  }

  Future<List<String>> loadFallbackKeywords() async {
    final raw = await rootBundle.loadString('assets/keywords_fallback.json');
    final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
    final list = (jsonMap['keywords'] as List).cast<String>();
    return list;
  }
}
