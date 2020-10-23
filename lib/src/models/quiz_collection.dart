import 'dart:collection';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/remote.dart';

import 'auth_state.dart';

/// View model for quiz management
class QuizCollectionModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the quiz service
  QuizApi _quizApi;

  /// API provider for the session service
  SessionApi _sessionApi;

  /// Views subscribe to the fields below
  Quiz _selectedQuiz;
  Quiz get selectedQuiz => _selectedQuiz;
  Iterable<Quiz> _availableQuizzes = Iterable.empty();
  UnmodifiableListView<Quiz> get availableQuizzes =>
      UnmodifiableListView(_availableQuizzes);
  Iterable<Quiz> _createdQuizzes = Iterable.empty();
  UnmodifiableListView<Quiz> get createdQuizzes =>
      UnmodifiableListView(_createdQuizzes);
  GameSession _currentSession;
  GameSession get currentSession => _currentSession;

  /// Constructor for external use
  QuizCollectionModel(this._authStateModel,
      {QuizApi quizApi, SessionApi sessionApi}) {
    _quizApi = quizApi ?? QuizApi();
    _sessionApi = sessionApi ?? SessionApi();
    refreshAvailableQuizzes();
    refreshCreatedQuizzes();
  }

  Future<void> selectQuiz(int id) async {
    _selectedQuiz = await _quizApi.getQuiz(_authStateModel.token, id);
    try {
      _selectedQuiz.picture =
          await _quizApi.getQuizPicture(_authStateModel.token, id);
    } catch (_) {
      // cannot obtain picture; move on
    }
    notifyListeners();
  }

  Future<void> updateQuiz(Quiz quiz) async {
    await _quizApi.updateQuiz(_authStateModel.token, quiz);
    notifyListeners();
  }

  Future<void> refreshCurrentSession() async {
    _currentSession = await _sessionApi.getSession(_authStateModel.token);
    notifyListeners();
  }

  Future<void> startQuizSession(Quiz quiz, GameSessionType type) async {
    await _sessionApi.joinSession(
        _authStateModel.token,
        (await _sessionApi.createSession(_authStateModel.token, quiz.id, type))
            .joinCode);
    refreshCurrentSession();
  }

  Future<void> refreshAvailableQuizzes() async {
    _availableQuizzes = (await _quizApi.getQuizzes(_authStateModel.token))
        .where((quiz) => quiz.role == GroupRole.MEMBER);
    await Future.wait(_availableQuizzes.map((Quiz quiz) async {
      try {
        quiz.picture =
            await _quizApi.getQuizPicture(_authStateModel.token, quiz.id);
      } catch (_) {
        // cannot obtain picture; move on
      }
    }));
    notifyListeners();
  }

  Future<void> refreshCreatedQuizzes() async {
    _createdQuizzes = (await _quizApi.getQuizzes(_authStateModel.token))
        .where((quiz) => quiz.role == GroupRole.OWNER);
    await Future.wait(_createdQuizzes.map((Quiz quiz) async {
      try {
        quiz.picture =
            await _quizApi.getQuizPicture(_authStateModel.token, quiz.id);
      } catch (_) {
        // cannot obtain picture; move on
      }
    }));
    notifyListeners();
  }
}
