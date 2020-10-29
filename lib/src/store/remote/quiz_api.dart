import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'package:smart_broccoli/src/data/quiz.dart';

import 'api_base.dart';

class QuizApi {
  static const QUIZ_URL = ApiBase.BASE_URL + '/quiz';

  /// HTTP client (mock client can be specified for testing)
  http.Client _http;

  QuizApi({http.Client mocker}) {
    _http = mocker ?? IOClient();
  }

  /// Return a list of all quizzes available to a user.
  ///
  /// Caveat: The `questions` field of each quiz is NOT set (i.e. is `null`).
  /// `getQuiz` must be invoked to retrieve the list of questions associated
  /// with a quiz.
  Future<List<Quiz>> getQuizzes(String token) async {
    http.Response response =
        await _http.get(QUIZ_URL, headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return (json.decode(response.body) as List)
          .map((repr) => Quiz.fromJson(repr))
          .toList();

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get quizzes: unknown error occurred');
  }

  /// Return a list of all quizzes of a group.
  Future<List<Quiz>> getGroupQuizzes(String token, int groupId) async {
    http.Response response = await _http.get(
        ApiBase.BASE_URL + "/group/$groupId/quiz",
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return (json.decode(response.body) as List)
          .map((repr) => Quiz.fromJson(repr))
          .toList();

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get quizzes: unknown error occurred');
  }

  /// Return the quiz with specified [id].
  Future<Quiz> getQuiz(String token, int id) async {
    http.Response response = await _http.get('$QUIZ_URL/$id',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200)
      return Quiz.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to get specified quiz: unknown error occurred');
  }

  /// Synchronise an updated [quiz] with the server.
  ///
  /// Return a `Quiz` object constructed from the server's response (all fields
  /// should be equal in content).
  ///
  /// Usage:
  /// [quiz] should be a `Quiz` object obtained by `getQuiz` or `getQuizzes`.
  /// Mutate the fields to be updated (e.g. `title`, `questions`) then invoke
  /// this method.
  Future<Quiz> updateQuiz(String token, Quiz quiz) async {
    // serialise quiz and remove null values
    Map<String, dynamic> quizJson = quiz.toJson();
    quizJson.removeWhere((key, value) => value == null);

    http.Response response = await _http.patch('$QUIZ_URL/${quiz.id}',
        headers: ApiBase.headers(authToken: token), body: jsonEncode(quizJson));

    if (response.statusCode == 200)
      return Quiz.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to update quiz: unknown error occurred');
  }

  /// Upload a new [quiz] to the server.
  ///
  /// Return a `Quiz` object constructed from the server's response.
  /// The returned object will have a non-null `id`.
  ///
  /// Usage:
  /// [quiz] should be a newly constructed `Quiz` object, not one obtained by
  /// `getQuiz` or `getQuizzes`.
  Future<Quiz> createQuiz(String token, Quiz quiz) async {
    // serialise quiz and remove null values
    Map<String, dynamic> quizJson = quiz.toJson();
    quizJson.removeWhere((key, value) => value == null);

    http.Response response = await _http.post(QUIZ_URL,
        headers: ApiBase.headers(authToken: token), body: jsonEncode(quizJson));

    if (response.statusCode == 201)
      return Quiz.fromJson(json.decode(response.body));

    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to create quiz: unknown error occurred');
  }

  /// Delete a quiz with specified [id].
  Future<void> deleteQuiz(String token, int id) async {
    http.Response response = await _http.delete('$QUIZ_URL/$id',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to delete quiz: unknown error occurred');
  }

  /// Get the picture of a quiz with specified [id] as a list of bytes.
  ///
  /// Return `null` if there is no picture.
  Future<Uint8List> getQuizPicture(String token, int id) async {
    final http.Response response = await _http.get('$QUIZ_URL/$id/picture',
        headers: ApiBase.headers(authToken: token));

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
  Future<void> setQuizPicture(String token, int quizId, Uint8List bytes) async {
    final http.MultipartRequest request = http.MultipartRequest(
        'PUT', Uri.parse('$QUIZ_URL/$quizId/picture'))
      ..headers.addAll(
          ApiBase.headers(contentType: 'multipart/form-data', authToken: token))
      ..files.add(
          http.MultipartFile.fromBytes('picture', bytes, filename: 'picture'));

    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuizNotFoundException();
    throw Exception('Unable to set quiz picture: unknown error occurred');
  }

  /// Delete the picture of a quiz with specified [id].
  ///
  /// Usage:
  /// [quiz] should be a `Quiz` object obtained by `getQuiz` or `getQuizzes`.
  Future<void> deleteQuizPicture(String token, int id) async {
    final http.Response response = await _http.delete('$QUIZ_URL/$id/picture',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to delete quiz picture: unknown error occurred');
  }

  /// Get the picture of a question as a list of bytes.
  ///
  /// Return `null` if there is no picture.
  Future<Uint8List> getQuestionPicture(
      String token, int quizId, int questionId) async {
    final http.Response response = await _http.get(
        '$QUIZ_URL/$quizId/question/$questionId/picture',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 200) return response.bodyBytes;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) return null;
    throw Exception('Unable to get question picture: unknown error occurred');
  }

  /// Set the picture of a question.
  Future<void> setQuestionPicture(
      String token, int quizId, int questionId, Uint8List bytes) async {
    final http.MultipartRequest request = http.MultipartRequest(
        'PUT', Uri.parse('$QUIZ_URL/$quizId/question/$questionId/picture'))
      ..headers.addAll(
          ApiBase.headers(contentType: 'multipart/form-data', authToken: token))
      ..files.add(
          http.MultipartFile.fromBytes('picture', bytes, filename: 'picture'));

    final http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    if (response.statusCode == 404) throw QuestionNotFoundException();
    throw Exception('Unable to set question picture: unknown error occurred');
  }

  /// Delete the picture of a question.
  Future<void> deleteQuestionPicture(
      String token, int quizId, int questionId) async {
    final http.Response response = await _http.delete(
        '$QUIZ_URL/$quizId/question/$questionId/picture',
        headers: ApiBase.headers(authToken: token));

    if (response.statusCode == 204) return;
    if (response.statusCode == 401) throw UnauthorisedRequestException();
    if (response.statusCode == 403) throw ForbiddenRequestException();
    throw Exception('Unable to get question picture: unknown error occurred');
  }
}
