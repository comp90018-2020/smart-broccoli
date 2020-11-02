import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart';

import '../background_database.dart';

// check when app is open

// Abstract database API
class BackgroundLocation {
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

  Future<String> placeMarkType(Placemark placeMark) async {
    String name = (placeMark.street +
            " " +
            placeMark.postalCode +
            " " +
            placeMark.country)
        .replaceAll(" ", "+");
    print("Name: " + name);

    String query =
        "https://nominatim.openstreetmap.org/search?q=$name&format=json&polygon_geojson=1&addressdetails=1";

    http.Response response = await http.post(query);

    print("Response code JSON" + response.statusCode.toString());
    print("Response body JSON" + response.body.toString());
    // We don't need to use Json stuff actually, we just need to identify keywords
    // Todo parse JSON in future iterations
    // json.decode(response.body);
    return response.body.toString();
  }

  Future<bool> inGeoFence(Position userLocation) async {
    List<GeoFence> gf = await BackgroundDatabase.getGeoFence();
    double distance;
    // TODO define a geofence radius for now assume 1 km
    for (var i = 0; i < gf.length; i++) {
      distance = Geolocator.distanceBetween(
          gf[i].lat, gf[i].lon, userLocation.latitude, userLocation.longitude);

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

  BackgroundLocation() {}
}
