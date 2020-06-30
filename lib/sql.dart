import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class Sql {
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await openDatabase(
      join(
        await getDatabasesPath(),
        'organiser.db',
      ),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE friends(
          id TEXT PRIMARY KEY,
          name TEXT,
          phone TEXT,
          email TEXT
        );
        ''');
        await db.execute('''
        CREATE TABLE attractions(
          id TEXT PRIMARY KEY,
          lat REAL,
          lon  REAL,
          name TEXT,
          image_url TEXT,
          address TEXT
        );
        ''');
        await db.execute('''
        CREATE TABLE events(
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          attraction_id TEXT,
          time TEXT
        );
        ''');
        await db.execute('''
        CREATE TABLE event_friend(
          event_id TEXT,
          friend_id TEXT
        );
        ''');
      },
    );
    return _database;
  }
}
