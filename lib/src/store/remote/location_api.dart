import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:smart_broccoli/src/remote.dart';

class LocationData {
  final String name;
  final double lon;
  final double lat;

  LocationData({this.name, this.lon, this.lat});
}

class LocationAPI {
  Future<List<LocationData>> queryString(String input) async {
    String uri =
        "https://nominatim.openstreetmap.org/?addressdetails=1&q=$input&format=json&limit=20";
    var encodedUri = Uri.encodeFull(uri);

    log("Query: " + uri, name: "Foreground Location");

    http.Response response = await http.post(encodedUri);

    try {
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
            lon: 0.0,
            lat: 0.0,
          );
          print(i);
          print(jsonObject.length);
          print(jsonObject[i]["display_name"]);
          output.add(loc);
        }

        return output;
      }

      if (response.statusCode == 401) throw UnauthorisedRequestException();
      if (response.statusCode == 403) throw ForbiddenRequestException();
      throw Exception('Unable to get groups: unknown error occurred');
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> queryLonLat(double long, double lati) async {
    Placemark placemark = (await placemarkFromCoordinates(lati, long)).first;
    log(
        " Lat " +
            lati.toString() +
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
