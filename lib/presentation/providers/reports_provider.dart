import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../data/cloud/reports_cloud_repo.dart';
import '../../data/local/app_database.dart';
import '../../data/local/reports_local_repo.dart';
import '../../data/remote/keywords_api.dart';
import '../../domain/report.dart';
import '../../domain/risk_engine.dart';
import 'auth_provider.dart';

class ReportsProvider extends ChangeNotifier {
  ReportsProvider({required this.authProvider});

  final AuthProvider authProvider;

  final _db = AppDatabase();
  late final ReportsLocalRepo _local = ReportsLocalRepo(_db);
  final _keywordsApi = KeywordsApi();

  ReportsCloudRepo? _cloud;
  List<String> _keywords = [];
  List<Report> _reports = [];

  bool isBusy = false;
  String? error;

  List<String> get keywords => _keywords;
  List<Report> get reports => _reports;

  Future<void> bootstrap() async {
    try {
      _reports = await _local.getAll();
    } catch (e) {
      error = 'DB: $e';
    }

    // Load keywords with fallback
    _keywords = await _keywordsApi.loadKeywords();

    if (authProvider.firebaseReady) {
      _cloud = ReportsCloudRepo(FirebaseFirestore.instance);
    }

    notifyListeners();
  }

  Future<void> reloadLocal() async {
    _reports = await _local.getAll();
    notifyListeners();
  }

  Future<Report> addReport({
    required String title,
    required String messageText,
    required String? url,
    required String? imagePath,
    required bool syncToCloud,
  }) async {
    isBusy = true;
    error = null;
    notifyListeners();

    try {
      final result = RiskEngine.analyze(
          messageText: messageText, url: url, keywords: _keywords);
      final report = Report(
        id: null,
        title: title.trim(),
        messageText: messageText.trim(),
        url: url?.trim().isEmpty == true ? null : url?.trim(),
        imagePath: imagePath,
        riskScore: result.score,
        riskLabel: result.label,
        createdAt: DateTime.now(),
        syncedToCloud: false,
      );

      final id = await _local.insert(report);
      var saved = report.copyWith(id: id);

      if (syncToCloud && _cloud != null && authProvider.user != null) {
        await _cloud!.uploadReport(uid: authProvider.user!.uid, report: saved);
        saved = saved.copyWith(syncedToCloud: true);
        await _local.update(saved);
      }

      await reloadLocal();
      return saved;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> deleteReport(int id) async {
    await _local.delete(id);
    await reloadLocal();
  }

  /// Optional: import from cloud (does not overwrite local; just adds a copy)
  Future<void> importFromCloud() async {
    if (_cloud == null || authProvider.user == null) return;
    isBusy = true;
    error = null;
    notifyListeners();

    try {
      final cloudReports = await _cloud!.fetchReports(authProvider.user!.uid);
      for (final r in cloudReports) {
        await _local.insert(r.copyWith(syncedToCloud: true));
      }
      await reloadLocal();
    } catch (e) {
      error = 'Cloud: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> refreshKeywords() async {
    isBusy = true;
    error = null;
    notifyListeners();

    try {
      _keywords = await _keywordsApi.loadKeywords();
    } catch (e) {
      error = 'API: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
