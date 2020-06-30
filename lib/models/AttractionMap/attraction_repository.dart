import 'package:feledhaza/models/AttractionMap/attraction.dart';
import 'package:feledhaza/sql.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqlite_api.dart';

class AttractionRepository {
  final Sql sql;

  AttractionRepository({this.sql});

  Future<List<Attraction>> loadAttractions() async {
    final Database database = await sql.database;

    final List<Map<String, dynamic>> result = await database.query(
      'attractions',
      orderBy: 'id DESC',
    );

    return List.generate(result.length, (i) {
      return Attraction(
          id: result[i]['id'],
          cameraPosition: CameraPosition(
              target: LatLng(result[i]['lat'], result[i]['lon']), zoom: 19),
          address: result[i]['address'],
          imageUrl: result[i]['image_url'],
          name: result[i]['name']);
    });
  }

  Future<void> addAttraction(Attraction attraction) async {
    final Database database = await sql.database;
    await database.insert(
      'attractions',
      attraction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeAttraction(String id) async {
    final Database database = await sql.database;
    database.delete(
      'attractions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
