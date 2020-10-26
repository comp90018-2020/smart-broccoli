import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'package:smart_broccoli/src/data/user.dart';

import 'api_base.dart';

class UserApi {
  static const USER_URL = ApiBase.BASE_URL + '/user';

  /// HTTP client (mock client can be specified for testing)
  http.Client _http;

  UserApi({http.Client mocker}) {
    _http = mocker ?? IOClient();
  }

  /// Get the profile of a user.
  ///
  /// Return a `User` object corresponding to the user to whom an auth [token]
  /// was issued.
  Future<User> getUser(String token) async {
    http.Response response = await _http.get('$USER_URL/profile',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return User.fromJson(json.decode(response.body));
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get user: unknown error occurred');
  }

  /// Get the profile of a different user.
  ///
  /// Return a `User` object corresponding to the user with specified [id].
  Future<User> getUserBy(String token, int id) async {
    http.Response response = await _http.get('$USER_URL/$id/profile',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return User.fromJson(json.decode(response.body));
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get user: unknown error occurred');
  }

  /// Update the profile of the logged-in/joined user.
  /// This method is to be invoked with only the parameters to be updated.
  /// For example, if only the email and name are to be updated:
  /// ```
  /// updateUser(email: 'new@email.com', name: 'New Name');
  /// ```
  Future<User> updateUser(String token,
      {String email, String password, String name}) async {
    Map<String, String> body = {};
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    if (name != null) body['name'] = name;

    final http.Response response = await _http.patch('$USER_URL/profile',
        headers: ApiBase.headers(authToken: token), body: jsonEncode(body));

    if (response.statusCode == 200)
      return User.fromJson(json.decode(response.body));
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 409) throw RegistrationConflictException();
    throw Exception('Unable to update user: unknown error occurred');
  }

  /// Get the profile picture of a user.
  ///
  /// Return the picture as a list of bytes or `null` if it doesn't exist.
  Future<Uint8List> getProfilePic(String token) async {
    final http.Response response = await _http.get('$USER_URL/profile/picture',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) return null; // user has no profile pic
    throw Exception('Unable to get user profile pic: unknown error occurred');
  }

  /// Get the profile picture of a different user.
  ///
  /// Return the picture as a list of bytes or `null` if it doesn't exist.
  Future<Uint8List> getProfilePicOf(String token, int id) async {
    final http.Response response = await _http.get(
        '$USER_URL/$id/profile/picture',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) return null; // user has no profile pic
    throw Exception('Unable to get user profile pic: unknown error occurred');
  }

  /// Set the profile pic of a user.
  ///
  /// This method takes the image as a list of bytes.
  Future<void> setProfilePic(String token, Uint8List bytes) async {
    final http.MultipartRequest request = http.MultipartRequest(
        'PUT', Uri.parse('$USER_URL/profile/picture'))
      ..headers.addAll(
          ApiBase.headers(contentType: 'multipart/form-data', authToken: token))
      ..files.add(
          http.MultipartFile.fromBytes('avatar', bytes, filename: 'avatar'));

    final http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to set user profile pic: unknown error occurred');
  }

  /// Delete the profile pic of a user.
  Future<void> deleteProfilePic(String token) async {
    final http.Response response = await _http.delete(
        '$USER_URL/profile/picture',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception(
        'Unable to delete user profile pic: unknown error occurred');
  }
}
