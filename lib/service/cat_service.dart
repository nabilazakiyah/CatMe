import 'package:flutter_application_1/model/cat_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class CatService {
  static Database? _db;
  Future<Database> get db async {
  
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'catme.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cats(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            breed TEXT,
            origin TEXT,
            country TEXT,
            coat TEXT,
            pattern TEXT,
            adoptionFeeIDR REAL
          )
        ''');
        await _insertDummyCats(db);
      },
    );  
  }

  Future<void> _insertDummyCats(Database db) async {
    final cats = [
      CatModel(breed: "Abyssinian", origin: "Natural/Standard", country: "Ethiopia", coat: "Short", pattern: "Ticked", adoptionFeeIDR: 450000, description: ''),
      CatModel(breed: "Aegean", origin: "Natural/Standard", country: "Greece", coat: "Semi-long", pattern: "Bicolor", adoptionFeeIDR: 450000, description: ''),
      CatModel(breed: "American Curl", origin: "Mutation", country: "USA", coat: "Short/Long", pattern: "All", adoptionFeeIDR: 400000, description: ''),
      CatModel(breed: "American Bobtail", origin: "Mutation", country: "USA", coat: "Short/Long", pattern: "All", adoptionFeeIDR: 250000, description: ''),
    ];
    for (var cat in cats) {
      await db.insert('cats', cat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List> getCats() async {
    final dbClient = await db;
    final maps = await dbClient.query('cats');
    return maps.map((m) => CatModel.fromMap(m)).toList();
  }

  Future<bool> login(String username, String hash) async {
    final dbClient = await db;
    final res = await dbClient.query('users', where: 'username = ? AND password = ?', whereArgs: [username, hash]);
    return res.isNotEmpty;
  }

  Future<bool> register(String username, String hash) async {
    final dbClient = await db;
    try {
      await dbClient.insert('users', {'username': username, 'password': hash});
      return true;
    } catch (e) {
      return false;
    }
  }
}