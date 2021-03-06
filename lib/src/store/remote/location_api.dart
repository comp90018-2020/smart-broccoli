import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:quiver/core.dart';

class LocationData {
  final String name;
  final double lon;
  final double lat;

  LocationData({this.name, this.lon, this.lat});

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      LocationData(name: json['name'], lat: json['lat'], lon: json['lon']);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'lat': lat, 'lon': lon};

  operator ==(Object other) {
    return other is LocationData &&
        name == other.name &&
        lat == other.lat &&
        lon == other.lon;
  }

  int get hashCode => hash3(name.hashCode, lat.hashCode, lon.hashCode);
}

class LocationAPI {
  // Query by name string
  static Future<List<LocationData>> queryByName(String input) async {
    String uri =
        "https://nominatim.openstreetmap.org/?addressdetails=1&q=$input&format=json&limit=20";
    var encodedUri = Uri.encodeFull(uri);
    log("Query: " + uri, name: "Foreground Location");

    try {
      http.Response response = await http.post(encodedUri);
      if (response.statusCode == 200) {
        String httpResult = response.body.toString();
        log(
            "Response Status " +
                response.statusCode.toString() +
                " Response " +
                httpResult,
            name: "Foreground Location");

        List<dynamic> jsonObject = json.decode(httpResult);
        List<LocationData> output = [];

        for (var i = 0; i < jsonObject.length; i++) {
          LocationData loc = new LocationData(
            name: jsonObject[i]["display_name"].toString(),
            lon: double.tryParse(jsonObject[i]["lon"]),
            lat: double.tryParse(jsonObject[i]["lat"]),
          );
          output.add(loc);
        }
        return output;
      }
      return Future.error(response.body);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Query by latitude and longitude
  static Future<String> queryAddressByLatLon(double lat, double long) async {
    // Get placemarks
    try {
      // Get placemarks
      var placemarks = await placemarkFromCoordinates(lat, long);
      // No placemarks
      if (placemarks.isEmpty) return Future.error("No placemarks");

      // Get street
      Placemark placemark = placemarks.first;
      log(
          " Lat " +
              lat.toString() +
              " Lon " +
              long.toString() +
              " Name: " +
              placemark.name +
              " Address: " +
              placemark.street,
          name: "Foreground Location");
      return placemark.street.toString();
    } catch (err) {
      return Future.error(err.toString());
    }
  }
}
