import 'package:feledhaza/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class Friend {
  String id;
  String name;
  String phone;
  String email;

  Friend({this.id, this.name, this.phone, this.email});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email};
  }
}

class FriendRepository {
  final Sql sql;

  FriendRepository({this.sql});

  Future<List<Friend>> load() async {
    final Database database = await sql.database;

    final List<Map<String, dynamic>> result = await database.query(
      'friends',
    );

    return List.generate(result.length, (i) {
      return Friend(
          id: result[i]['id'],
          email: result[i]['email'],
          name: result[i]['name'],
          phone: result[i]['phone']);
    });
  }

  Future<void> addFriend(Friend friend) async {
    final Database database = await sql.database;
    await database.insert(
      'friends',
      friend.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFriend(Friend friend) async {
    final Database database = await sql.database;
    database.delete(
      'friends',
      where: 'id = ?',
      whereArgs: [friend.id],
    );
  }
}
