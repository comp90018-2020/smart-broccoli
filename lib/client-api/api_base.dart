import 'package:injectable/injectable.dart';

import './auth/auth.dart';
import 'package:http/http.dart' as http;

@singleton
class ApiBase {
  AuthService _authService;

  static const String BASE_URL = 'https://fuzzybroccoli.com';

  Map<String, String> get _headers {
    if (_authService.token == null) throw MissingTokenException();
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${_authService.token}'
    };
  }

  // Adapted from:
  // https://github.com/TechGeekD/flutter_todo_bloc/blob/master/lib/services/api.dart
  Future<http.Response> post(String url, {Map<String, String> body, encoding}) {
    return http.post('$BASE_URL/$url',
        headers: _headers, body: body, encoding: encoding);
  }

  Future<http.Response> get(String url, {Map<String, String> body}) {
    return http.get('$BASE_URL/$url', headers: _headers);
  }
}

class MissingTokenException implements Exception {}
