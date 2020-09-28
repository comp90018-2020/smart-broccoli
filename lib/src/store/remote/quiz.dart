import 'dart:convert';

import 'package:fuzzy_broccoli/models.dart';
import 'package:http/http.dart' as http;

import 'api_base.dart';
import 'auth.dart';

/// Class for making quiz management requests
class QuizModel {
  static const QUIZ_URL = ApiBase.BASE_URL + '/quiz';

  /// AuthModel object used to obtain token for requests
  AuthModel _authModel;

  /// Constructor for external use
  QuizModel(this._authModel);

  /// Return a list of all quizzes created by the authenticated user.
  Future<List<Quiz>> getQuizzes() async {
    http.Response response = await http.get(QUIZ_URL,
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200)
      return (json.decode(response.body) as List)
          .map((repr) => Quiz.fromJson(repr))
          .toList();

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get quizzes: unknown error occurred');
  }
}
