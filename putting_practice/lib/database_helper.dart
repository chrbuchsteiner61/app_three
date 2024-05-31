import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PuttingResult {
  final int? id;
  final int distance;
  final double successRate;
  final String dateOfPractice;

  PuttingResult({
    this.id,
    required this.distance,
    required this.successRate,
    required this.dateOfPractice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'distance': distance,
      'successRate': successRate,
      'dateOfPractice': dateOfPractice,
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'putting_results.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE results(id INTEGER PRIMARY KEY AUTOINCREMENT, distance INTEGER, successRate REAL, dateOfPractice TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertResult(PuttingResult result) async {
    final db = await database;
    await db.insert('results', result.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PuttingResult>> getResults() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('results');
    return List.generate(maps.length, (i) {
      return PuttingResult(
        id: maps[i]['id'],
        distance: maps[i]['distance'],
        successRate: maps[i]['successRate'],
        dateOfPractice: maps[i]['dateOfPractice'],
      );
    });
  }
}
