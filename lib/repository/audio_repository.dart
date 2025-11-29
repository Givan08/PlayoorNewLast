import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/audio_item.dart';

class AudioRepository {
  static final AudioRepository _instance = AudioRepository._internal();
  factory AudioRepository() => _instance;
  AudioRepository._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'playoor.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE audioitem (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            assetPath TEXT NOT NULL,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            imagePath TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertInitialSongs(List<AudioItem> songs) async {
    final db = await database;

    // Verificamos si la tabla tiene al menos un registro
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM audioitem'));

    if (count == 0) {
      Batch batch = db.batch();
      for (var song in songs) {
        batch.insert('audioitem', song.toMap());
      }
      await batch.commit();
    } else {
    }
  }

  Future<List<AudioItem>> getAllSongs() async {
    final db = await database;
    final result = await db.query('audioitem');

    return result.map((map) => AudioItem.fromMap(map)).toList();
  }
}