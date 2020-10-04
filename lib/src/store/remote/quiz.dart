import 'dart:convert';
import 'dart:typed_data';

import 'package:smart_broccoli/models.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'api_base.dart';
import 'auth.dart';

/// Class for making quiz management requests
class QuizModel {
  static const QUIZ_URL = ApiBase.BASE_URL + '/quiz';
  static const SESSION_URL = ApiBase.BASE_URL + '/session';

  /// AuthModel object used to obtain token for requests
  AuthModel _authModel;

  /// HTTP client (mock client can be specified for testing)
  http.Client _http;

  /// Constructor for external use
  QuizModel(this._authModel, {http.Client mocker}) {
    _http = mocker != null ? mocker : IOClient();
  }

  /// Return a list of all quizzes created by the authenticated user.
  /// Caveat: The `questions` field of each quiz is NOT set (i.e. is `null`).
  /// `getQuiz` must be invoked to retrieve the list of questions associated
  /// with a quiz.
  Future<List<Quiz>> getQuizzes() async {
    http.Response response = await _http.get(QUIZ_URL,
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200)
      return (json.decode(response.body) as List)
          .map((repr) => Quiz.fromJson(repr))
          .toList();

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get quizzes: unknown error occurred');
  }

  /// Return the quiz with specified [id].
  Future<Quiz> getQuiz(int id) async {
    http.Response response = await _http.get('$QUIZ_URL/$id',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200)
      return Quiz.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to get specified quiz: unknown error occurred');
  }

  /// Synchronise an updated [quiz] with the server.
  /// Return a `Quiz` object constructed from the server's response (all fields
  /// should be equal in content).
  ///
  /// Usage:
  /// [quiz] should be a `Quiz` object obtained by `getQuiz` or `getQuizzes`.
  /// Mutate the fields to be updated (e.g. `title`, `questions`) then invoke
  /// this method.
  Future<Quiz> updateQuiz(Quiz quiz) async {
    // serialise quiz and remove null values
    Map<String, dynamic> quizJson = quiz.toJson();
    quizJson.removeWhere((key, value) => value == null);

    http.Response response = await _http.patch('$QUIZ_URL/${quiz.id}',
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(quizJson));

    if (response.statusCode == 200)
      return Quiz.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to update quiz: unknown error occurred');
  }

  /// Upload a new [quiz] to the server.
  /// Return a `Quiz` object constructed from the server's response.
  ///
  /// Usage:
  /// [quiz] should be a newly constructed `Quiz` object, not one obtained by
  /// `getQuiz` or `getQuizzes`.  The returned object will have a non-null `id`.
  Future<Quiz> createQuiz(Quiz quiz) async {
    // serialise quiz and remove null values
    Map<String, dynamic> quizJson = quiz.toJson();
    quizJson.removeWhere((key, value) => value == null);

    http.Response response = await _http.post(QUIZ_URL,
        headers: ApiBase.headers(authToken: _authModel.token),
        body: jsonEncode(quizJson));

    if (response.statusCode == 201)
      return Quiz.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to create quiz: unknown error occurred');
  }

  /// Delete a [quiz].
  ///
  /// Usage:
  /// [quiz] should be a `Quiz` object obtained by `getQuiz` or `getQuizzes`.
  Future<void> deleteQuiz(Quiz quiz) async {
    http.Response response = await _http.delete('$QUIZ_URL/${quiz.id}',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to delete quiz: unknown error occurred');
  }

  /// Get the picture of a [quiz] as a list of bytes.
  /// Return `null` if there is no picture.
  ///
  /// Usage:
  /// [quiz] should be a `Quiz` object obtained by `getQuiz` or `getQuizzes`.
  Future<Uint8List> getQuizPicture(Quiz quiz) async {
    final http.Response response = await _http.get(
        '$QUIZ_URL/${quiz.id}/picture',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) return null;
    throw Exception('Unable to get quiz picture: unknown error occurred');
  }

  /// Set the picture of a [quiz].
  /// This method takes the image as a list of bytes.
  ///
  /// Usage:
  /// [quiz] should be a `Quiz` object obtained by `getQuiz` or `getQuizzes`.
  Future<void> setQuizPicture(Quiz quiz, Uint8List bytes) async {
    final http.MultipartRequest request =
        http.MultipartRequest('PUT', Uri.parse('$QUIZ_URL/${quiz.id}/picture'))
          ..files.add(http.MultipartFile.fromBytes('picture', bytes));

    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to set quiz picture: unknown error occurred');
  }

  /// Delete the picture of a [quiz].
  ///
  /// Usage:
  /// [quiz] should be a `Quiz` object obtained by `getQuiz` or `getQuizzes`.
  Future<void> deleteQuizPicture(Quiz quiz) async {
    final http.Response response = await _http.delete(
        '$QUIZ_URL/${quiz.id}/picture',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to delete quiz picture: unknown error occurred');
  }

  /// Get the picture of a [question] as a list of bytes.
  /// Return `null` if there is no picture.
  ///
  /// Usage:
  /// [question] should be in the list `quiz.questions` where `quiz` is a `Quiz`
  /// object obtained by `getQuiz` or `getQuizzes`.
  Future<Uint8List> getQuestionPicture(Question question) async {
    final http.Response response = await _http.get(
        '$QUIZ_URL/${question.quiz.id}/question/${question.id}/picture',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) return null;
    throw Exception('Unable to get question picture: unknown error occurred');
  }

  /// Set the picture of a [question].
  ///
  /// Usage:
  /// [question] should be in the list `quiz.questions` where `quiz` is a `Quiz`
  /// object obtained by `getQuiz` or `getQuizzes`.
  Future<void> setQuestionPicture(Question question, Uint8List bytes) async {
    final http.MultipartRequest request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            '$QUIZ_URL/${question.quiz.id}/question/${question.id}/picture'))
      ..files.add(http.MultipartFile.fromBytes('picture', bytes));

    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuestionNotFoundException();
    throw Exception('Unable to set question picture: unknown error occurred');
  }

  /// Delete the picture of a [question].
  ///
  /// Usage:
  /// [question] should be in the list `quiz.questions` where `quiz` is a `Quiz`
  /// object obtained by `getQuiz` or `getQuizzes`.
  Future<void> deleteQuestionPicture(Question question) async {
    final http.Response response = await _http.delete(
        '$QUIZ_URL/${question.quiz.id}/question/${question.id}/picture',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get question picture: unknown error occurred');
  }

  /// Start a new game [session].
  /// Return a `GameSession` object constructed from the server's response.
  ///
  /// Usage:
  /// [session] should be a newly constructed `Session` object. Only `quizId`,
  /// `sessionType` and `groupAutoJoin` will be non-`null` in the object.
  /// However, the returned object will not have `null` fields.
  Future<GameSession> createSession(GameSession session) async {
    // serialise session object and remove null values
    Map<String, dynamic> sessionJson = session.toJson();
    sessionJson.removeWhere((key, value) => value == null);

    final http.Response response = await _http.post(SESSION_URL,
        headers: ApiBase.headers(authToken: _authModel.token),
        body: json.encode(sessionJson));

    if (response.statusCode == 200)
      return GameSession.fromJson(json.decode(response.body));

    if (response.statusCode == 400 &&
        json.decode(response.body)["message"] ==
            "User is already participant of ongoing quiz session")
      throw InSessionException();
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to create session: unknown error occurred');
  }

  /// Get the user's current session.
  /// Return `null` if the user has no session.
  Future<GameSession> getSession() async {
    final http.Response response = await _http.get(SESSION_URL,
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200)
      return GameSession.fromJson(json.decode(response.body));

    if (response.statusCode == 204) return null;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get session: unknown error occurred');
  }

  /// Join an extsing game session.
  Future<GameSession> joinSession(String joinCode) async {
    final http.Response response = await _http.post('$SESSION_URL/join',
        headers: ApiBase.headers(authToken: _authModel.token),
        body: json.encode(<String, dynamic>{"code": joinCode}));

    if (response.statusCode == 200)
      return GameSession.fromJson(json.decode(response.body));

    if (response.statusCode == 400 &&
        json.decode(response.body)["message"] ==
            "User is already participant of ongoing quiz session")
      throw InSessionException();
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw SessionNotFoundException();
    throw Exception('Unable to join session: unknown error occurred');
  }
}
