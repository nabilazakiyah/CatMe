import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_application_1/model/cat_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;
  static const int _version = 3;

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
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS wishlist (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              breed TEXT NOT NULL,
              origin TEXT,
              country TEXT,
              coat TEXT,
              pattern TEXT,
              adoptionFeeIDR REAL,
              description TEXT,
              date TEXT NOT NULL
            )
          ''');
        }
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
    
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        breed TEXT NOT NULL,
        origin TEXT,
        country TEXT,
        coat TEXT,
        pattern TEXT,
        adoptionFeeIDR REAL,
        description TEXT,
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

  Future<void> addToWishlist(CatModel cat) async {
    try {
      final dbClient = await db;
      await dbClient.insert(
        'wishlist',
        {
          'breed': cat.breed,
          'origin': cat.origin,
          'country': cat.country,
          'coat': cat.coat,
          'pattern': cat.pattern,
          'adoptionFeeIDR': cat.adoptionFeeIDR,
          'description': cat.description,
          'date': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error addToWishlist: $e');
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String breed) async {
    try {
      final dbClient = await db;
      await dbClient.delete(
        'wishlist',
        where: 'breed = ?',
        whereArgs: [breed],
      );
    } catch (e) {
      debugPrint('Error removeFromWishlist: $e');
      rethrow;
    }
  }

  Future<List<CatModel>> getWishlist() async {
    try {
      final dbClient = await db;
      final maps = await dbClient.query('wishlist', orderBy: 'date DESC');
      return maps.map((m) => CatModel.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error getWishlist: $e');
      return [];
    }
  }

  Future<bool> isInWishlist(String breed) async {
    try {
      final dbClient = await db;
      final result = await dbClient.query(
        'wishlist',
        where: 'breed = ?',
        whereArgs: [breed],
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error isInWishlist: $e');
      return false;
    }
  }

  Future<void> clearWishlist() async {
    try {
      final dbClient = await db;
      await dbClient.delete('wishlist');
    } catch (e) {
      debugPrint('Error clearWishlist: $e');
    }
  }

  Future<void> close() async {
    final dbClient = await db;
    await dbClient.close();
    _db = null;
  }
  void debugPrint(String s) {}
}