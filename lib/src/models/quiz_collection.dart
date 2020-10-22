import 'dart:collection';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/remote.dart';

import 'auth_state.dart';

/// View model for quiz management
class QuizCollectionModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the user profile service
  QuizApi _quizApi;

  /// Views subscribe to the fields below
  Quiz _selectedQuiz;
  Quiz get selectedQuiz => _selectedQuiz;
  Iterable<Quiz> _availableQuizzes = Iterable.empty();
  UnmodifiableListView<Quiz> get availableQuizzes =>
      UnmodifiableListView(_availableQuizzes);
  Iterable<Quiz> _createdQuizzes = Iterable.empty();
  UnmodifiableListView<Quiz> get createdQuizzes =>
      UnmodifiableListView(_createdQuizzes);

  /// Constructor for external use
  QuizCollectionModel(this._authStateModel, {QuizApi quizApi}) {
    _quizApi = quizApi ?? QuizApi();
    refreshAvailableQuizzes();
    refreshCreatedQuizzes();
  }

  Future<void> selectQuiz(int id) async {
    _selectedQuiz = await _quizApi.getQuiz(_authStateModel.token, id);
    notifyListeners();
  }

  Future<void> refreshAvailableQuizzes() async {
    _availableQuizzes = (await _quizApi.getQuizzes(_authStateModel.token))
        .where((quiz) => quiz.role == GroupRole.MEMBER);
    notifyListeners();
  }

  Future<void> refreshCreatedQuizzes() async {
    _createdQuizzes = (await _quizApi.getQuizzes(_authStateModel.token))
        .where((quiz) => quiz.role == GroupRole.OWNER);
    notifyListeners();
  }
}
