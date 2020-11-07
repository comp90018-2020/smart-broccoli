import 'dart:async';
import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'background_database.dart';

class BackgroundLocation {
  // get GPS lon lat reading
  static Future<Position> getPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (err) {
      return Future.error(err.toString());
    }
  }

  // Placemark info
  static Future<Placemark> getPlacemark(Position userLocation) async {
    try {
      List<Placemark> placemark = await placemarkFromCoordinates(
          userLocation.latitude, userLocation.longitude);
      // Just return the nearest place mark
      return placemark.isNotEmpty
          ? placemark.first
          : Future.error("No placemarks");
    } catch (err) {
      return Future.error(err.toString());
    }
  }

  /// The API to get details of a specific placemark
  /// i.e 601 Little Lonsdale Street
  /// Nominatim also returns the type of building, where it be residential or
  /// commercial
  static Future<String> placeMarkType(Position position) async {
    double lat = position.latitude;
    double lon = position.longitude;
    log(
        "Place mark: " +
            (await getPlacemark(position).catchError((_) => null))?.street,
        name: "Location");

    String query =
        "https://nominatim.openstreetmap.org/reverse?format=geocodejson&lat=$lat&lon=$lon";
    log("Query: $query", name: "Location");

    try {
      http.Response response = await http.post(query);
      if (response.statusCode == 200) {
        String httpResult = response.body.toString();
        log(
            "Response Status " +
                response.statusCode.toString() +
                " Response " +
                httpResult,
            name: "Backend-Location");
        // We don't need to use Json stuff actually, we just need to check
        // if certain keywords is within the JSON file
        return httpResult;
      }
      return Future.error(response.body);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  /// Check if a long lat is within 1km of a Geofence point
  /// 1 Km as that assumes for GPS errors and other inaccuracies
  static Future<bool> inGeoFence(List<GeoFence> geofenceList,
      Position userLocation, int distanceKM) async {
    if (geofenceList == null) {
      return false;
    }
    for (var i = 0; i < geofenceList.length; i++) {
      var distance = Geolocator.distanceBetween(geofenceList[i].lat,
          geofenceList[i].lon, userLocation.latitude, userLocation.longitude);
      if (distance < distanceKM * 1000) {
        return true;
      }
    }
    return false;
  }

  /// Intermediate function to control the area which we scan for trains.
  static Future<bool> onTrain(Position userLocation) async {
    double lon1 = userLocation.longitude + 0.001;
    double lon2 = userLocation.longitude - 0.001;
    double lat1 = userLocation.latitude + 0.001;
    double lat2 = userLocation.latitude - 0.001;
    return await _onTrain(
        lat2.toString(), lon2.toString(), lat1.toString(), lon1.toString());
  }

  /// Makes an HTTP request to the overpass API and checks if the user is on the
  /// I made the decision not to convert the XML and just check for specific
  /// Elements as ideally you want to reduce background processing
  static Future<bool> _onTrain(
      String lon1, String lat1, String lon2, String lat2) async {
    final data = '''<?xml version="1.0" encoding="UTF-8"?>
<osm-script>
  <union into="_">
    <query into="_" type="way">
      <has-kv k="railway" modv="" regv="^(rail|subway)"/>
      <bbox-query s="$lon1" w="$lat1" n="$lon2" e="$lat2"/>
    </query>
    <recurse from="_" into="_" type="down"/>
  </union>
  <print e="" from="_" geometry="skeleton" ids="yes" limit="" mode="body" n="" order="id" s="" w=""/>
</osm-script>''';

    // HTTP request
    String uri = 'http://overpass-api.de/api/interpreter';
    String body = XmlDocument.parse(data).toString();
    http.Response response = await http.post(uri, body: body, headers: {
      'Content-type': 'text/xml',
    });
    log("Input" + body, name: "Backend-Location");

    if (response.statusCode == 200) {
      log(
          "Response code " +
              response.statusCode.toString() +
              "Response body " +
              response.body.toString(),
          name: "Backend-Location");

      try {
        // Parse XML
        final result = XmlDocument.parse(response.body);
        // The user is very likely on a train
        if (result.findAllElements('tag').length != 0) {
          return true;
        }
      } catch (e) {
        print(e);
      }
    }
    return false;
  }
}
