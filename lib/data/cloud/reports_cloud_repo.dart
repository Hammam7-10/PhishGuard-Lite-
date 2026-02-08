import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/report.dart';

class ReportsCloudRepo {
  ReportsCloudRepo(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> uploadReport({
    required String uid,
    required Report report,
  }) async {
    final doc = _firestore.collection('users').doc(uid).collection('reports').doc();
    await doc.set({
      'title': report.title,
      'messageText': report.messageText,
      'url': report.url,
      // imagePath is local-only. In real apps, upload image to Storage and store URL.
      'imagePath': report.imagePath,
      'riskScore': report.riskScore,
      'riskLabel': report.riskLabel,
      'createdAt': report.createdAt.toIso8601String(),
    });
  }

  Future<List<Report>> fetchReports(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((d) {
      final m = d.data();
      return Report(
        id: null,
        title: (m['title'] as String?) ?? '',
        messageText: (m['messageText'] as String?) ?? '',
        url: m['url'] as String?,
        imagePath: m['imagePath'] as String?,
        riskScore: (m['riskScore'] as int?) ?? 0,
        riskLabel: (m['riskLabel'] as String?) ?? 'Safe',
        createdAt: DateTime.tryParse((m['createdAt'] as String?) ?? '') ?? DateTime.now(),
        syncedToCloud: true,
      );
    }).toList();
  }
}
