import 'package:http/http.dart' as http;

class ApiBase {
  static const String BASE_URL = 'https://fuzzybroccoli.com';

  static Map<String, String> _headers(String authToken) {
    if (authToken == null) throw MissingTokenException();
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $authToken'
    };
  }

  static Future<http.Response> post(String url,
      {Map<String, String> body, encoding, headers, String authToken = ''}) {
    return http.post('$BASE_URL/$url',
        headers: authToken != '' ? _headers(authToken) : headers,
        body: body,
        encoding: encoding);
  }

  static Future<http.Response> get(String url,
      {Map<String, String> body,
      Map<String, String> headers,
      String authToken = ''}) {
    return http.get('$BASE_URL/$url',
        headers: authToken != '' ? _headers(authToken) : headers);
  }
}

class MissingTokenException implements Exception {}
