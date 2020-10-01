import 'dart:convert';
import 'dart:typed_data';

import 'package:fuzzy_broccoli/models.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'api_base.dart';
import 'auth.dart';
import 'generic_request_exceptions.dart';

/// Class for making user profile requests
/// For all methods in this class:
/// `UnauthorisedRequestException` is thrown if the user is not logged in.
/// `ForbiddenRequestException` is thrown if the user is logged in but not
/// authorised to make the request.
class UserModel {
  static const USER_URL = ApiBase.BASE_URL + '/user';

  /// AuthModel object used to obtain token for requests
  final AuthModel _authModel;

  /// HTTP client (mock client can be specified for testing)
  http.Client _http;

  /// Constructor for external use
  UserModel(this._authModel, {http.Client mocker}) {
    _http = mocker != null ? mocker : IOClient();
  }

  /// Return a `RegisteredUser` or `ParticipantUser` object corresponding to
  /// the logged-in or joined user.
  Future<User> getUser() async {
    http.Response response = await _http.get('$USER_URL/profile',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) return _userFromJson(response.body);
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get user: unknown error occurred');
  }

  /// Synchronise changes to profile of the logged-in/joined user with server.
  /// Return a `Quiz` object constructed from the server's response. All fields
  /// should be equal in content except `password` (`null` in returned object).
  ///
  /// Usage:
  /// [user] should be a `User` object obtained by `getUser`. Mutate the fields
  /// to be updated (e.g. `email`, `name`, `password`) then invoke this method.
  Future<User> updateUser(User user) async {
    final http.Response response = await _http.patch('$USER_URL/profile',
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(user.toJson()));

    if (response.statusCode == 200) return _userFromJson(response.body);
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 409) throw RegistrationConflictException();
    throw Exception('Unable to update user: unknown error occurred');
  }

  /// Get the profile picture of the logged-in user as a list of bytes.
  Future<Uint8List> getProfilePic() async {
    final http.Response response = await _http.get('$USER_URL/profile/picture',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) return null; // user has no profile pic
    throw Exception('Unable to get user profile pic: unknown error occurred');
  }

  /// Set the profile pic of the logged-in user.
  /// This method takes the image as a list of bytes.
  Future<void> setProfilePic(Uint8List bytes) async {
    final http.MultipartRequest request =
        http.MultipartRequest('PUT', Uri.parse('$USER_URL/profile/picture'))
          ..files.add(http.MultipartFile.fromBytes('avatar', bytes));

    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to set user profile pic: unknown error occurred');
  }

  /// Delete the profile pic of the logged-in user.
  Future<void> deleteProfilePic() async {
    final http.Response response = await _http.delete(
        '$USER_URL/profile/picture',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception(
        'Unable to delete user profile pic: unknown error occurred');
  }

  User _userFromJson(String json) {
    Map<String, dynamic> jsonMap = jsonDecode(json);
    return jsonMap['role'] == 'participant'
        ? ParticipantUser.fromJson(jsonMap)
        : RegisteredUser.fromJson(jsonMap);
  }
}
