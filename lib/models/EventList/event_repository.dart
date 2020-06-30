import 'package:feledhaza/models/FriendList/friend_repository.dart';
import 'package:feledhaza/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class Event {
  String id;
  String title;
  String description;
  String attractionId;
  DateTime time;
  List<Friend> invitedFriends;

  Event(
      {this.id,
      this.title,
      this.description,
      this.attractionId,
      this.time,
      this.invitedFriends});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'attraction_id': attractionId,
      'time': time.toIso8601String()
    };
  }
}

class EventRepository {
  Sql sql;
  EventRepository({this.sql});

  Future<List<Event>> loadEventList() async {
    final Database database = await sql.database;

    final List<Map<String, dynamic>> result = await database.query(
      'events',
    );

    List<Event> eventList = List.generate(result.length, (i) {
      return Event(
          id: result[i]['id'],
          title: result[i]['title'],
          description: result[i]['description'],
          attractionId: result[i]['attraction_id'],
          time: DateTime.tryParse(result[i]['time']));
    });

    for (int i = 0; i < eventList.length; i++) {
      final List<Map<String, dynamic>> friendListResult =
          await database.rawQuery('''
        SELECT f.id, f.name, f.phone, f.email
        FROM event_friend AS ef
        JOIN friends AS f ON f.id = ef.friend_id
        AND ef.event_id = ?
      ''', [eventList[i].id]);

      eventList[i].invitedFriends = List.generate(friendListResult.length, (j) {
        return Friend(
          id: friendListResult[j]['id'],
          email: friendListResult[j]['email'],
          name: friendListResult[j]['name'],
          phone: friendListResult[j]['phone'],
        );
      });
    }

    return eventList;
  }

  Future<void> addEvent(Event event, List<String> listOfFriendIds) async {
    final Database database = await sql.database;

    await database.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    listOfFriendIds.forEach((friendId) async {
      await database.rawInsert('''
        INSERT INTO event_friend(event_id, friend_id) VALUES(?,?)
      ''', [event.id, friendId]);
    });
  }

  Future<void> removeEvent(String id) async {
    final Database database = await sql.database;

    await database.delete('events', where: 'id = ?', whereArgs: [id]);
    await database
        .delete('event_friend', where: 'event_id = ?', whereArgs: [id]);
  }
}
