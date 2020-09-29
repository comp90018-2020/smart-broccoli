import 'dart:convert';
import 'dart:typed_data';

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
  /// Caveat: The `questions` field of each quiz is NOT set (i.e. is `null`).
  /// `getQuiz` must be invoked to retrieve the list of questions associated
  /// with a quiz.
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

  /// Return the quiz with specified [id].
  Future<Quiz> getQuiz(int id) async {
    http.Response response = await http.get('$QUIZ_URL/$id',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200)
      return Quiz.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to get specified quiz: unknown error occurred');
  }

  /// Synchronise an updated [quiz] with the server.
  /// Return a `Quiz` object constructed from the server's response. All fields
  /// should be equal in content.
  ///
  /// Usage:
  /// [quiz] should be a `Quiz` object obtained by `getQuiz` or `getQuizzes`.
  /// Mutate the fields to be updated (e.g. `title`, `questions`) then invoke
  /// this method.
  Future<Quiz> updateQuiz(Quiz quiz) async {
    // serialise quiz and remove null values
    Map<String, dynamic> quizJson = quiz.toJson();
    quizJson.removeWhere((key, value) => value == null);

    http.Response response = await http.patch('$QUIZ_URL/${quiz.id}',
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

    http.Response response = await http.post(QUIZ_URL,
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
  /// Mutate the fields to be updated (e.g. `title`, `questions`) then invoke
  /// this method.
  Future<void> deleteQuiz(Quiz quiz) async {
    http.Response response = await http.delete('$QUIZ_URL/${quiz.id}',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to delete quiz: unknown error occurred');
  }

  /// Get the picture of the quiz with specified [id] as a list of bytes.
  /// Return `null` if there is no picture.
  Future<Uint8List> getQuizPicture(int id) async {
    final http.Response response = await http.get('$QUIZ_URL/$id/picture',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) return null;
    throw Exception('Unable to get user profile pic: unknown error occurred');
  }

  /// Set the picture of the quiz with specified [id].
  /// This method takes the image as a list of bytes.
  Future<void> setQuizPicture(int id, Uint8List bytes) async {
    final http.MultipartRequest request =
        http.MultipartRequest('PUT', Uri.parse('$QUIZ_URL/$id/picture'))
          ..files.add(http.MultipartFile.fromBytes('picture', bytes));

    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to set user profile pic: unknown error occurred');
  }

  /// Get the picture of the quiz with specified [id] as a list of bytes.
  /// Return `null` if there is no picture.
  Future<Uint8List> getQuestionPicture(int quizId, int questionId) async {
    final http.Response response = await http.get(
        '$QUIZ_URL/$quizId/question/$questionId/picture',
        headers: ApiBase.headers(authToken: _authModel.token));

    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) return null;
    throw Exception('Unable to get user profile pic: unknown error occurred');
  }

  /// Set the picture of the specified [questionId] in the quiz with specified
  /// [quizId]. This method takes the image as a list of bytes.
  Future<void> setQuestionPicture(
      int quizId, int questionId, Uint8List bytes) async {
    final http.MultipartRequest request = http.MultipartRequest(
        'PUT', Uri.parse('$QUIZ_URL/$quizId/question/$questionId/picture'))
      ..files.add(http.MultipartFile.fromBytes('picture', bytes));

    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuestionNotFoundException();
    throw Exception('Unable to set user profile pic: unknown error occurred');
  }
}
