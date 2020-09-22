class ApiBase {
  static const String BASE_URL = 'https://fuzzybroccoli.com';

  static Map<String, String> headers({String authToken = ''}) {
    if (authToken == null) {
      throw MissingTokenException();
    }

    if (authToken != '') {
      return <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $authToken'
      };
    }
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }
}

class MissingTokenException implements Exception {}
