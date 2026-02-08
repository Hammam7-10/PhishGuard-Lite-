import '../../domain/report.dart';
import 'app_database.dart';

class ReportsLocalRepo {
  ReportsLocalRepo(this._database);

  final AppDatabase _database;

  Future<List<Report>> getAll() async {
    final db = await _database.db;
    final rows =
        await db.query(AppDatabase.reportsTable, orderBy: 'createdAt DESC');
    return rows.map(_fromMap).toList();
  }

  Future<int> insert(Report report) async {
    final db = await _database.db;
    return db.insert(AppDatabase.reportsTable, _toMap(report));
  }

  Future<void> update(Report report) async {
    if (report.id == null) return;
    final db = await _database.db;
    await db.update(
      AppDatabase.reportsTable,
      _toMap(report),
      where: 'id=?',
      whereArgs: [report.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database.db;
    await db.delete(AppDatabase.reportsTable, where: 'id=?', whereArgs: [id]);
  }

  Map<String, Object?> _toMap(Report r) => {
        'id': r.id,
        'title': r.title,
        'messageText': r.messageText,
        'url': r.url,
        'imagePath': r.imagePath,
        'riskScore': r.riskScore,
        'riskLabel': r.riskLabel,
        'createdAt': r.createdAt.toIso8601String(),
        'syncedToCloud': r.syncedToCloud ? 1 : 0,
      };

  Report _fromMap(Map<String, Object?> m) => Report(
        id: m['id'] as int?,
        title: (m['title'] as String?) ?? '',
        messageText: (m['messageText'] as String?) ?? '',
        url: m['url'] as String?,
        imagePath: m['imagePath'] as String?,
        riskScore: (m['riskScore'] as int?) ?? 0,
        riskLabel: (m['riskLabel'] as String?) ?? 'Safe',
        createdAt: DateTime.tryParse((m['createdAt'] as String?) ?? '') ??
            DateTime.now(),
        syncedToCloud: ((m['syncedToCloud'] as int?) ?? 0) == 1,
      );
}
