import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

const AUTH_URL = 'https://fuzzybroccoli.com/auth';

Future<RegisteredUser> register(
    String email, String password, String name, String username) async {
  // construct request body based on whether a username is supplied
  String body;
  if (username == null) {
    body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
      'name': name,
    });
  } else {
    body = jsonEncode(<String, String>{
      'username': username,
      'email': email,
      'password': password,
      'name': name,
    });
  }

  // send request
  final http.Response res = await http.post(AUTH_URL + "/register",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body);

  // inspect response and return RegisteredUser
  if (res.statusCode == 201) {
    return RegisteredUser.fromJson(json.decode(res.body));
  } else if (res.statusCode == 409) {
    // todo: specify which registration params are causing conflict
    throw RegistrationConflictException(List());
  } else {
    throw RegistrationException();
  }
}
