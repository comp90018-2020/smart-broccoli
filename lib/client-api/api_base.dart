class ApiBase {
  static const String BASE_URL = 'https://fuzzybroccoli.com';

  static Map<String, String> headers(
      {String contentType = 'application/json; charset=UTF-8',
      String authToken}) {
    if (authToken == null)
      return <String, String>{
        'Content-Type': contentType,
      };

    return <String, String>{
      'Content-Type': contentType,
      'Authorization': 'Bearer $authToken'
    };
  }
}
