import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/remote.dart';

import 'auth_state.dart';

/// View model for quiz management
class QuizCollectionModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the user profile service
  QuizApi _quizApi;

  /// Local storage service
  final KeyValueStore _keyValueStore;

  /// Views subscribe to the fields below
  Quiz _selectedQuiz;
  Quiz get selectedQuiz => _selectedQuiz;
  Iterable<Quiz> _availableQuizzes;
  UnmodifiableListView<Quiz> get availableQuizzes =>
      UnmodifiableListView(_availableQuizzes);
  Iterable<Quiz> _createdQuizzes;
  UnmodifiableListView<Quiz> get createdQuizzes =>
      UnmodifiableListView(_createdQuizzes);

  /// Constructor for external use
  QuizCollectionModel(this._keyValueStore, this._authStateModel,
      {QuizApi quizApi}) {
    _quizApi = quizApi ?? QuizApi();
    // load last record of available and created quizzes from local storage
    try {
      _availableQuizzes =
          (json.decode(_keyValueStore.getString('availableQuizzes')) as List)
              .map((repr) => Quiz.fromJson(repr));
    } catch (_) {}
    try {
      _createdQuizzes =
          (json.decode(_keyValueStore.getString('createdQuizzes')) as List)
              .map((repr) => Quiz.fromJson(repr));
    } catch (_) {}
  }

  Future<void> selectQuiz(int id) async {
    _selectedQuiz = await _quizApi.getQuiz(_authStateModel.token, id);
    notifyListeners();
  }

  Future<void> refreshAvailableQuizzes() async {
    _availableQuizzes = (await _quizApi.getQuizzes(_authStateModel.token))
        .where((quiz) => quiz.role == GroupRole.MEMBER);
    _keyValueStore.setString('availableQuizzes',
        json.encode(_availableQuizzes.map((quiz) => quiz.toJson())));
    notifyListeners();
  }

  Future<void> refreshCreatedQuizzes() async {
    _createdQuizzes = (await _quizApi.getQuizzes(_authStateModel.token))
        .where((quiz) => quiz.role == GroupRole.OWNER);
    _keyValueStore.setString('createdQuizzes',
        json.encode(_createdQuizzes.map((quiz) => quiz.toJson())));
    notifyListeners();
  }
}
