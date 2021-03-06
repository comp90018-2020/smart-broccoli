/// Class providing the base URL and headers for requests to the backend server
/// This class is not for direct use by the UI.
class ApiBase {
  static const String BASE_URL = 'https://fuzzybroccoli.com';

  /// Return headers used for HTTP requests to the backend server.
  /// Calling `headers()` returns the default headers:
  ///   ```
  ///   {
  ///     'Content-Type': 'application/json; charset=UTF-8'
  ///   }
  ///   ```
  /// Content-Type and Authorization (none by default) can be specified.
  /// For example, calling `headers(authToken: '123456')` returns:
  ///   ```
  ///   {
  ///     'Content-Type': 'application/json; charset=UTF-8',
  ///     'Authorization': 'Bearer 123456'
  ///   }
  ///   ```
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

// General API exception
class ApiException implements Exception {
  final String msg;

  ApiException(this.msg);

  @override
  String toString() => msg;
}

// Auth exception
class ApiAuthException extends ApiException {
  ApiAuthException(String msg) : super(msg);
}

class UnauthorisedRequestException extends ApiAuthException {
  UnauthorisedRequestException() : super("Unauthorized");
}

class ForbiddenRequestException extends ApiAuthException {
  ForbiddenRequestException() : super("Forbidden");
}
