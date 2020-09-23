class ApiBase {
  static const String BASE_URL = 'https://fuzzybroccoli.com';

  static Map<String, String> headers({String authToken}) {
    if (authToken == null)
      return <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };

    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $authToken'
    };
  }
}
