import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'phishguard.db';
  static const _dbVersion = 1;

  static const reportsTable = 'reports';

  Database? _db;

  Future<Database> get db async {
    final existing = _db;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $reportsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            messageText TEXT NOT NULL,
            url TEXT,
            imagePath TEXT,
            riskScore INTEGER NOT NULL,
            riskLabel TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            syncedToCloud INTEGER NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
