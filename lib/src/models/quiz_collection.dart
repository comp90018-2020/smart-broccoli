import 'dart:collection';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/local.dart';
import 'package:smart_broccoli/src/remote.dart';
import 'model_change.dart';
import 'auth_state.dart';

/// View model for quiz management
class QuizCollectionModel extends ChangeNotifier implements AuthChange {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the quiz service
  QuizApi _quizApi;

  /// API provider for the session service
  SessionApi _sessionApi;

  /// Picture storage service
  final PictureStash _picStash;

  Quiz _selectedQuiz;
  Quiz get selectedQuiz => _selectedQuiz;

  Map<int, Quiz> _availableQuizzes = {};
  Map<int, Quiz> _createdQuizzes = {};

  GameSession _currentSession;
  GameSession get currentSession => _currentSession;

  /// Constructor for external use
  QuizCollectionModel(this._authStateModel, this._picStash,
      {QuizApi quizApi, SessionApi sessionApi}) {
    _quizApi = quizApi ?? QuizApi();
    _sessionApi = sessionApi ?? SessionApi();
  }

  /// Gets all quizzes
  UnmodifiableListView<Quiz> getQuizzesWhere({int groupId, QuizType type}) =>
      UnmodifiableListView([
        ..._availableQuizzes.values,
        ..._createdQuizzes.values
      ].where((quiz) =>
          (groupId == null || quiz.groupId == groupId) &&
          (type == null || quiz.type == type)));

  /// Gets available (user accessible) quizzes
  UnmodifiableListView<Quiz> getAvailableQuizzesWhere(
          {int groupId, QuizType type}) =>
      UnmodifiableListView(_availableQuizzes.values.where((quiz) =>
          (groupId == null || quiz.groupId == groupId) &&
          (type == null || quiz.type == type)));

  /// Gets created (user managed) quizzes
  UnmodifiableListView<Quiz> getCreatedQuizzesWhere(
          {int groupId, QuizType type}) =>
      UnmodifiableListView(_createdQuizzes.values.where((quiz) =>
          (groupId == null || quiz.groupId == groupId) &&
          (type == null || quiz.type == type)));

  Future<void> selectQuiz(int id) async {
    _selectedQuiz = await _quizApi.getQuiz(_authStateModel.token, id);
    _refreshQuizPicture(_selectedQuiz);
    notifyListeners();
  }

  Quiz getQuiz(int id) {
    return _createdQuizzes[id] ?? _availableQuizzes[id];
  }

  /// Gets the specified quiz's picture.
  Future<String> getQuizPicture(int id) {
    Quiz quiz = getQuiz(id);
    if (quiz == null || quiz.pictureId == null) return null;
    return _picStash.getPic(quiz.pictureId);
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

  Future<void> deleteQuiz(Quiz quiz) async {
    await _quizApi.deleteQuiz(_authStateModel.token, quiz.id);
    _createdQuizzes.remove(quiz.id);
    notifyListeners();
  }

  /// Save selected quiz
  Future<void> saveQuiz() async {
    if (_selectedQuiz == null) return;

    // First save the quiz
    Quiz updated;
    if (_selectedQuiz.id == null) {
      updated = await _quizApi.createQuiz(_authStateModel.token, _selectedQuiz);
    } else {
      updated = await _quizApi.updateQuiz(_authStateModel.token, _selectedQuiz);
    }

    // Has quiz picture to save
    if (_selectedQuiz.pendingPicturePath != null) {
      await _quizApi.setQuizPicture(_authStateModel.token, updated.id,
          await File(_selectedQuiz.pendingPicturePath).readAsBytes());
    }

    // Has quiz question pictures to save
    for (var question in _selectedQuiz.questions) {
      // Has question picture
      if (_selectedQuiz.pendingPicturePath != null) {
        if (question.id != null) {
          // Has ID
          await _quizApi.setQuestionPicture(
              _authStateModel.token,
              updated.id,
              question.id,
              await File(question.pendingPicturePath).readAsBytes());
        } else {
          /// TODO: weird things can happen here
        }
      }
    }

    // Refresh quiz (since picture IDs may have changed by this point)
    refreshQuiz(updated.id);
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
    if (!_authStateModel.inSession) return;
    _availableQuizzes = Map.fromIterable(
        (await _quizApi.getQuizzes(_authStateModel.token))
            .where((quiz) => quiz.role == GroupRole.MEMBER),
        key: (quiz) => quiz.id);
    await Future.wait(_availableQuizzes.values.map((Quiz quiz) async {
      await _refreshQuizPicture(quiz);
    }));
    notifyListeners();
  }

  Future<void> refreshCreatedQuizzes() async {
    if (!_authStateModel.inSession) return;
    _createdQuizzes = Map.fromIterable(
        (await _quizApi.getQuizzes(_authStateModel.token))
            .where((quiz) => quiz.role == GroupRole.OWNER),
        key: (quiz) => quiz.id);
    await Future.wait(_createdQuizzes.values.map((Quiz quiz) async {
      await _refreshQuizPicture(quiz);
    }));
    notifyListeners();
  }

  /// Refreshes specific group's quizzes.
  Future<void> refreshGroupQuizzes(int groupId) async {
    if (!_authStateModel.inSession) return;
    List<Quiz> quizzes =
        await _quizApi.getGroupQuizzes(_authStateModel.token, groupId);
    await Future.wait(quizzes.map((quiz) async {
      if (quiz.role == GroupRole.OWNER)
        _createdQuizzes[quiz.id] = quiz;
      else
        _availableQuizzes[quiz.id] = quiz;
      await _refreshQuizPicture(quiz);
    }));
  }

  /// Load the picture of a quiz into the `picture` field of a [quiz].
  Future<void> _refreshQuizPicture(Quiz quiz) async {
    // No picture
    if (quiz.pictureId == null) return;
    // Picture cached
    if (await _picStash.getPic(quiz.pictureId) != null) return;
    // Get picture and cache
    var picture = await _quizApi.getQuizPicture(_authStateModel.token, quiz.id);
    _picStash.storePic(quiz.pictureId, picture);
  }

  /// When the auth state is updated
  void authUpdated() {
    if (!_authStateModel.inSession) {
      _selectedQuiz = null;
      _availableQuizzes = {};
      _createdQuizzes = {};
    }
  }
}
