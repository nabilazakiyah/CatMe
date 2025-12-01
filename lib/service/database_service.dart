import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/cat_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;
  static const int _version = 2; 

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'catme.db');

    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS adopsi');
        await _createTables(db);
      },
      onOpen: (db) async {
        final tables = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='adopsi'");
        if (tables.isEmpty) {
          await _createTables(db);
        }
      },
    );
  }


  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE adopsi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        breed TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveAdopsi(CatModel cat) async {
    try {
      final dbClient = await db;
      await dbClient.insert(
        'adopsi',
        {
          'breed': cat.breed,
          'date': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saveAdopsi: $e');
      rethrow;
    }
  }

 Future<List<CatModel>> getRiwayat() async {
  try {
    final dbClient = await db;
    final maps = await dbClient.query('adopsi', orderBy: 'date DESC');
    return maps.map((m) => CatModel.fromMap(m)).toList();
  } catch (e) {
    debugPrint('Error getRiwayat: $e');
    return [];
  }
}


  Future<void> clearRiwayat() async {
    try {
      final dbClient = await db;
      await dbClient.delete('adopsi');
    } catch (e) {
      debugPrint('Error clearRiwayat: $e');
    }
  }

  Future<void> close() async {
    final dbClient = await db;
    await dbClient.close();
    _db = null;
  }
  
  void debugPrint(String s) {}
}