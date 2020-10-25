import 'dart:collection';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/local.dart';
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

  /// Picture storage service
  final PictureStash _picStash;

  /// Views subscribe to the fields below
  Quiz _selectedQuiz;

  Quiz get selectedQuiz => _selectedQuiz;

  Map<int, Quiz> _availableQuizzes = {};
  Map<int, Quiz> _createdQuizzes = {};

  UnmodifiableListView<Quiz> get availableQuizzes =>
      UnmodifiableListView(_availableQuizzes.values);

  UnmodifiableListView<Quiz> get createdQuizzes =>
      UnmodifiableListView(_createdQuizzes.values);
  GameSession _currentSession;

  GameSession get currentSession => _currentSession;

  /// Constructor for external use
  QuizCollectionModel(this._authStateModel, this._picStash,
      {QuizApi quizApi, SessionApi sessionApi}) {
    _quizApi = quizApi ?? QuizApi();
    _sessionApi = sessionApi ?? SessionApi();
    refreshAvailableQuizzes();
    refreshCreatedQuizzes();
  }

  UnmodifiableListView<Quiz> getQuizzesWhere({int groupId, QuizType type}) =>
      UnmodifiableListView([
        ..._availableQuizzes.values,
        ..._createdQuizzes.values
      ].where((quiz) =>
          (groupId == null || quiz.groupId == groupId) &&
          (type == null || quiz.type == type)));

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

  /// Activate a self-paced quiz
  Future<void> setQuizActivation(Quiz quiz, bool active) async {
    if (quiz.type != QuizType.SELF_PACED)
      throw ArgumentError('Quiz must be self-paced to use this method');
    if (quiz.isActive == active) return;

    try {
      // Set quiz state, immediate UI feedback
      quiz.isActive = active;
      notifyListeners();
      // Perform operation
      var updated = await _quizApi.updateQuiz(_authStateModel.token, quiz);
      // If result is different
      if (quiz.isActive != updated.isActive) {
        quiz.isActive = updated.isActive;
        notifyListeners();
      }
    } catch (err) {
      await refreshQuiz(quiz.id);
      throw err;
    }
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

  /// Refreshes the specified quiz
  Future<void> refreshQuiz(int quizId) async {
    var quiz = await _quizApi.getQuiz(_authStateModel.token, quizId);
    if (quiz.role == GroupRole.OWNER) {
      _createdQuizzes[quiz.id] = quiz;
    } else {
      _availableQuizzes[quiz.id] = quiz;
    }
    notifyListeners();
  }

  Future<void> refreshAvailableQuizzes() async {
    _availableQuizzes = Map.fromIterable(
        (await _quizApi.getQuizzes(_authStateModel.token))
            .where((quiz) => quiz.role == GroupRole.MEMBER),
        key: (quiz) => quiz.id);
    await Future.wait(_availableQuizzes.values.map((Quiz quiz) async {
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
    _createdQuizzes = Map.fromIterable(
        (await _quizApi.getQuizzes(_authStateModel.token))
            .where((quiz) => quiz.role == GroupRole.OWNER),
        key: (quiz) => quiz.id);
    await Future.wait(_createdQuizzes.values.map((Quiz quiz) async {
      try {
        quiz.picture =
            await _quizApi.getQuizPicture(_authStateModel.token, quiz.id);
      } catch (_) {
        // cannot obtain picture; move on
      }
    }));
    notifyListeners();
  }

  /// Refreshes specific group's quizzes.
  Future<void> refreshGroupQuizzes(int groupId) async {
    List<Quiz> quizzes =
        await _quizApi.getGroupQuizzes(_authStateModel.token, groupId);
    await Future.wait(quizzes.map((quiz) async {
      if (quiz.role == GroupRole.OWNER)
        _createdQuizzes[quiz.id] = quiz;
      else
        _availableQuizzes[quiz.id] = quiz;
      await getQuizPicture(quiz);
    }));
  }

  /// Load the picture of a quiz into the `picture` field of a [quiz].
  Future<void> getQuizPicture(Quiz quiz) async {
    if (quiz.pictureId == null) return;
    // if stored locally, no need to use the API
    if ((quiz.picture = await _picStash.getPic(quiz.pictureId)) != null) return;
    // otherwise, fetch via the API
    quiz.picture =
        await _quizApi.getQuizPicture(_authStateModel.token, quiz.id);
    // save it for next time
    _picStash.storePic(quiz.pictureId, quiz.picture);
  }
}
