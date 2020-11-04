import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationData {
  final String name;
  final double lon;
  final double lat;

  LocationData({this.name, this.lon, this.lat});
}

class LocationAPI {
  // Query by name string
  Future<List<LocationData>> queryByName(String input) async {
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
        List<LocationData> output = jsonObject.map((obj) => LocationData(
              name: obj["display_name"].toString(),
              lon: double.tryParse(obj["lon"]),
              lat: double.tryParse(obj["lat"]),
            ));

        return output;
      }
      return Future.error(response);
    } catch (e) {
      return Future.error(e);
    }
  }

  // Query by latitude and longitude
  Future<String> queryLonLat(double long, double lat) async {
    Placemark placemark = (await placemarkFromCoordinates(lat, long)).first;
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
  }
}
