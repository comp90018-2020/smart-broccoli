import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../background_database.dart';

class BackgroundLocation {
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

  /// The API to get details of a specific placemark
  /// i.e 601 Little Lonsdale Street
  /// Nominatim also returns the type of building, where it be residential or
  /// Commercial
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

    try {
      if (response.statusCode == 200) {
        print("Response code JSON" + response.statusCode.toString());
        print("Response body JSON" + response.body.toString());
        String httpResult = response.body.toString();
        // We don't need to use Json stuff actually, we just need to check
        // if certain keywords is within the JSON file
        return httpResult;
      }

      if (response.statusCode == 401) {
        print("Overpass Turbo API Unauthorised");
      }
      if (response.statusCode == 403) {
        print("Overpass Turbo API Forbidden Request");
      } else {
        throw Exception('Unable to get groups: unknown error occurred');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// Check if a long lat is within 1km of a Geofence point
  /// 1 Km as that assumes for GPS errors and other inaccuracies
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

  /// Intermediate function to control the area which we scan for trains.
  Future<bool> onTrain(Position userLocation) async {
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

    if (response.statusCode == 200) {
      try {
        final result = XmlDocument.parse(response.body);
        // The user is very likely on a train
        if (result.findAllElements('tag').length != 0) {
          return true;
        }
      } catch (e) {
        print(e);
      }
      return false;
    }

    if (response.statusCode == 401) {
      print("Overpass Turbo API Unauthorised");
    }
    if (response.statusCode == 403) {
      print("Overpass Turbo API Forbidden Request");
    } else {
      throw Exception('Unable to get groups: unknown error occurred');
    }
  }
}
