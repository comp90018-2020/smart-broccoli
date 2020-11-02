import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackgroundDatabase {
  static String pth;
  static Database db;

  static void closeDB() {
    db.close();
  }

  static init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'backend_database.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE events(id INTEGER PRIMARY KEY, time INTEGER)",
        );

        db.execute(
          "CREATE TABLE last(id INTEGER PRIMARY KEY, lon DOUBLE, lat DOUBLE)",
        );
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE geo(id INTEGER PRIMARY KEY, lon DOUBLE, lat DOUBLE)",
        );
      },
      version: 1,
    );
  }

  static Future<void> cleanEvent() async {
    //here we execute a query to drop the table if exists which is called "tableName"
    //and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS events");

    //and finally here we recreate our beloved "tableName" again which needs
    //some columns initialization
    await db.execute("CREATE TABLE events (id INTEGER, time INTEGER)");
  }

  // Define a function that inserts dogs into the database
  static Future<void> insertEvent(CalEvent calEvent) async {
    await db.insert(
      'events',
      calEvent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Define a function that inserts dogs into the database
  static Future<void> insertFence(GeoFence fence) async {
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'geo',
      fence.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Define a function that inserts dogs into the database
  static Future<void> insertLast(LastLocation lastLocation) async {
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'last',
      lastLocation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<CalEvent>> getEvents() async {
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('events');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
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
    } catch(e){
      print(e);
    }
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<LastLocation>> getLast() async {
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('last');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return LastLocation(
        id: maps[i]['id'],
        lon: maps[i]['lon'],
        lat: maps[i]['lat'],
      );
    });
  }

  static Future<void> updateLast(LastLocation last) async {
    // Update the given Dog.
    await db.update(
      'last',
      last.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [last.id],
    );
  }

  /*
  * e.g
  // Update Fido's age.
  await updateDog(Dog(
    id: 0,
    name: 'Fido',
    age: 42,
  ));

  * */

  static Future<void> deleteGeoFence(int id) async {
    // Remove the Dog from the Database.
    await db.delete(
      'geo',
      // Use a `where` clause to delete a specific dog.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}

/// Data structure

class LastLocation {
  final int id;
  final double lon;
  final double lat;

  LastLocation({this.id, this.lon, this.lat});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lon': lon,
      'lat': lat,
    };
  }
}

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
