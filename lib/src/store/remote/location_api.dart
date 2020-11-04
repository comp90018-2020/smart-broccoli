import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:smart_broccoli/src/remote.dart';

class LocationAPI {
  Future<List<String>> queryString(String input) async {
    List<String> output;
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

        List<dynamic> lst = jsonDecode(httpResult);

        log("lst: " + httpResult, name: "Foreground Location");

        for (var i = 0; i < lst.length; i++) {
          output[i] = lst[i]["display_name"];
        }
        log("Query: " + uri + "Output: " + output.toString(),
            name: "Foreground Location");

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
