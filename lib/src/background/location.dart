import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';

class WifiGeoFence {
  String pth;
  Database db;

  Future<bool> onTrain(Position userLocation) async {
    double lon1 = userLocation.longitude + 0.001;
    double lon2 = userLocation.longitude - 0.001;
    double lat1 = userLocation.latitude + 0.001;
    double lat2 = userLocation.latitude - 0.001;
    return await _onTrain(
        lat2.toString(), lon2.toString(), lat1.toString(), lon1.toString());
  }

  // get GPS lon lat reading
  Future<Position> getPosition() async {
    Position userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return userLocation;
  }

  // Placemark info
  Future<Placemark> getPlacemark(Position userLocation) async {
    List<Placemark> placemark = await placemarkFromCoordinates(
        userLocation.latitude, userLocation.longitude);

    // Just return the nearest place mark
    return placemark.first;
  }

  Future<bool> inGeoFence(Position userLocation) async {
    List<GeoFence> gf = await getGeoFence();
    double distance;
    // TODO define a geofence radius for now assume 1 km
    for (var i = 0; i < gf.length; i++) {
      distance = Geolocator.distanceBetween(
          gf[i].lat, gf[i].lon, userLocation.latitude, userLocation.latitude);

      if (distance < 1000) {
        return true;
      }
    }
    return false;
  }

  /// XML http request stuff

  http.Client _http;

  Future<bool> _onTrain(
      String lon, String lat, String lon1, String lat1) async {
    final data = '''<?xml version="1.0" encoding="UTF-8"?>
<osm-script>
  <union into="_">
    <query into="_" type="way">
      <has-kv k="railway" modv="" regv="^(rail|subway)"/>
      <bbox-query s="$lon" w="$lat" n="$lon1" e="$lat1"/>
    </query>
    <recurse from="_" into="_" type="down"/>
  </union>
  <print e="" from="_" geometry="skeleton" ids="yes" limit="" mode="body" n="" order="id" s="" w=""/>
</osm-script>''';

    final document = XmlDocument.parse(data);
    String _uriMsj = document.toString();
    print("uri msj =" + _uriMsj);

    String _uri = 'http://overpass-api.de/api/interpreter';

    http.Response response = await http.post(_uri, body: _uriMsj, headers: {
      'Content-type': 'text/xml',
    });

    print("Response code " + response.statusCode.toString());
    print("Response body " + response.body.toString());

    final result = XmlDocument.parse(response.body);

    // The user is very likely on a train
    if (result.findAllElements('tag').length != 0) {
      return true;
    }
    return false;
  }

  /// SQL database stuff

  WifiGeoFence() {
    init();
  }

  void closeDB() {
    db.close();
  }

  init() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'backend_database.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE last(id INTEGER PRIMARY KEY, lon DOUBLE, lat DOUBLE)",
        );
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE geo(id INTEGER PRIMARY KEY, lon DOUBLE, lat DOUBLE)",
        );
      },
    );
  }

// Define a function that inserts dogs into the database
  Future<void> insertFence(GeoFence fence) async {
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
  Future<void> insertLast(LastLocation lastLocation) async {
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
  Future<List<GeoFence>> getGeoFence() async {
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
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<LastLocation>> getLast() async {
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

  Future<void> updateLast(LastLocation last) async {
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

  Future<void> deleteGeoFence(int id) async {
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

/// Data structures

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
