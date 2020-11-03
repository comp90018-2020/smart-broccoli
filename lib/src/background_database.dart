import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A Sql lite database which holds all the calendar events within 7 days
/// And all Geo Fences

class BackgroundDatabase {
  static String pth;
  static Database db;

  static void closeDB() {
    db.close();
  }

  // Initialise the database
  static init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'backend_database.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE events(id INTEGER PRIMARY KEY,start INTEGER, end INTEGER)",
        );

        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE geo(id INTEGER PRIMARY KEY, lon DOUBLE, lat DOUBLE)",
        );
      },
      version: 1,
    );
  }

  /// Clears out the GeoFence Database for later use
  static Future<void> cleanGeo() async {
    //here we execute a query to drop the table if exists which is called "tableName"
    //and could be given as method's input parameter too
    await db.execute("DROP TABLE IF geo events");

    //and finally here we recreate our beloved "tableName" again which needs
    //some columns initialization
    await db.execute(
        "CREATE TABLE geo (id INTEGER PRIMARY KEY, lon DOUBLE, lat DOUBLE)");
  }

  static Future<void> cleanEvent() async {
    await db.execute("DROP TABLE IF EXISTS events");
    await db.execute(
      "CREATE TABLE events(id INTEGER PRIMARY KEY,start INTEGER, end INTEGER)",
    );
  }

  // Define a function that inserts dogs into the database
  static Future<void> insertEvent(CalEvent calEvent) async {
    await db.insert(
      'events',
      calEvent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Define a function that inserts fence into the database
  static Future<void> insertFence(GeoFence fence) async {
    // Insert the Fence into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same fence is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'geo',
      fence.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the  Calendar events from the events table.
  static Future<List<CalEvent>> getEvents() async {
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('events');

    // Convert the List<Map<String, dynamic> into a List<CalEvents>.
    return List.generate(maps.length, (i) {
      return CalEvent(
        id: maps[i]['id'],
        start: maps[i]['start'],
        end: maps[i]['end'],
      );
    });
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<GeoFence>> getGeoFence() async {
    try {
      // Query the table for all The Dogs.
      final List<Map<String, dynamic>> maps = await db.query('geo');

      // Convert the List<Map<String, dynamic> into a List<Dog>.
      return List.generate(maps.length, (i) {
        return GeoFence(
          id: maps[i]['id'],
          lon: maps[i]['lon'],
          lat: maps[i]['lat'],
        );
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<void> deleteGeoFence(int id) async {
    // Remove the Geofence from the Database.
    await db.delete(
      'geo',
      // Use a `where` clause to delete a specific Fence
      where: "id = ?",
      // Pass the Fence's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}

/// Data structure

/// These two are seperate since we may need to add additional data to either of
/// these in the future
class GeoFence {
  final int id;
  final double lon;
  final double lat;

  GeoFence({this.id, this.lon, this.lat});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lon': lon,
      'lat': lat,
    };
  }
}

class CalEvent {
  final int id;
  final int start;
  final int end;

  CalEvent({this.id, this.start, this.end});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': start,
      'end': end,
    };
  }
}
