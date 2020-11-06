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

  /// Picture storage service
  final PictureStash _picStash;

  Map<int, Quiz> _availableQuizzes = {};
  Map<int, Quiz> _createdQuizzes = {};

  GameSession _currentSession;
  GameSession get currentSession => _currentSession;

  /// Quiz that is selected in quiz page
  Quiz _selectedQuiz;
  Quiz get selectedQuiz => _selectedQuiz;

  /// Constructor for external use
  QuizCollectionModel(this._authStateModel, this._picStash, {QuizApi quizApi}) {
    _quizApi = quizApi ?? QuizApi();
  }

  /// get quizzes by rules
  UnmodifiableListView<Quiz> filterQuizzesWhere(Iterable<Quiz> quizzes,
          {int groupId, QuizType type}) =>
      UnmodifiableListView(quizzes
          .where((quiz) =>
              (groupId == null || quiz.groupId == groupId) &&
              (type == null || quiz.type == type))
          .toList()
            ..sort());

  /// Gets all quizzes
  UnmodifiableListView<Quiz> getQuizzesWhere({int groupId, QuizType type}) =>
      filterQuizzesWhere(
          [..._availableQuizzes.values, ..._createdQuizzes.values],
          groupId: groupId, type: type);

  /// Gets available (user accessible) quizzes
  UnmodifiableListView<Quiz> getAvailableQuizzesWhere(
          {int groupId, QuizType type}) =>
      filterQuizzesWhere(_availableQuizzes.values,
          groupId: groupId, type: type);

  /// Gets created (user managed) quizzes
  UnmodifiableListView<Quiz> getCreatedQuizzesWhere(
          {int groupId, QuizType type}) =>
      filterQuizzesWhere(_createdQuizzes.values, groupId: groupId, type: type);

  Future<Quiz> getQuiz(int id) async {
    return _createdQuizzes[id] ?? _availableQuizzes[id];
  }

  Future<void> selectQuiz(int id) async {
    _selectedQuiz = await _refreshQuiz(id, withQuestionPictures: true);
    notifyListeners();
  }

  void clearSelectedQuiz() {
    _selectedQuiz = null;
  }

  /// Gets the specified quiz's picture.
  Future<String> getQuizPicturePath(Quiz quiz) {
    if (quiz == null || !quiz.hasPicture) return null;
    if (quiz.pendingPicturePath != null)
      return Future.value(quiz.pendingPicturePath);
    return _picStash.getPic(quiz.pictureId);
  }

  /// Get question picture
  Future<String> getQuestionPicturePath(Question question) {
    if (question == null || !question.hasPicture) return null;
    if (question.pendingPicturePath != null)
      return Future.value(question.pendingPicturePath);
    return _picStash.getPic(question.pictureId);
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
      await _refreshQuiz(quiz.id);
      throw err;
    }
  }

  /// Deletes a quiz
  Future<void> deleteQuiz(Quiz quiz) async {
    if (quiz == null || quiz.id == null) return;
    await _quizApi.deleteQuiz(_authStateModel.token, quiz.id);
    if (quiz.role == GroupRole.MEMBER)
      _availableQuizzes.remove(quiz.id);
    else
      _createdQuizzes.remove(quiz.id);
    notifyListeners();
  }

  /// Save selected quiz
  Future<void> saveQuiz(Quiz quiz) async {
    if (quiz == null) return;
    // First save the quiz
    Quiz updated = quiz.id == null
        ? await _quizApi.createQuiz(_authStateModel.token, quiz)
        : await _quizApi.updateQuiz(_authStateModel.token, quiz);

    // Exit if unexpected happens
    if (updated.questions.length != quiz.questions.length) return;

    // Futures
    var futures = <Future>[];

    // Has quiz picture to save
    if (quiz.pendingPicturePath != null)
      futures.add(_quizApi.setQuizPicture(_authStateModel.token, updated.id,
          await File(quiz.pendingPicturePath).readAsBytes()));

    // Has quiz question pictures to save
    for (var i = 0; i < quiz.questions.length; i++) {
      var question = quiz.questions[i];
      var questionUpdated = updated.questions[i];

      // Has question picture
      if (question.pendingPicturePath != null) {
        futures.add(_quizApi.setQuestionPicture(
            _authStateModel.token,
            updated.id, // Updated quiz id
            questionUpdated.id, // Updated question id
            await File(question.pendingPicturePath).readAsBytes()));
      }
    }
    if (futures.length > 0) {
      await Future.wait(futures);
    }

    // Refresh quiz (since picture IDs may have changed by this point)
    _refreshQuiz(updated.id, withQuestionPictures: true);
  }

  /// Refreshes the specified quiz
  Future<Quiz> _refreshQuiz(int quizId,
      {bool withQuestionPictures = false}) async {
    // Refreshes the specified quiz
    var quiz = await _quizApi.getQuiz(_authStateModel.token, quizId);
    await _refreshQuizPicture(quiz);
    // Refresh pictures if necessary
    if (withQuestionPictures)
      await Future.wait(quiz.questions.map((Question question) async {
        await refreshQuestionPicture(quiz.id, question);
      }));
    // Set
    if (quiz.role == GroupRole.OWNER) {
      _createdQuizzes[quiz.id] = quiz;
    } else {
      _availableQuizzes[quiz.id] = quiz;
    }
    notifyListeners();
    return quiz;
  }

  /// Refreshes list of available quizzes
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

  /// Refreshes list of created quizzes
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

  /// Loads the picture of a quiz into cache
  Future<void> _refreshQuizPicture(Quiz quiz) async {
    // No picture
    if (quiz.pictureId == null) return;
    // Picture cached
    if (await _picStash.getPic(quiz.pictureId) != null) return;
    // Get picture and cache
    var picture = await _quizApi.getQuizPicture(_authStateModel.token, quiz.id);
    _picStash.storePic(quiz.pictureId, picture);
  }

  // Loads the picture of a question into cache
  Future<void> refreshQuestionPicture(int quizId, Question question,
      {String token}) async {
    // No picture
    if (question.pictureId == null) return;
    // Picture cached
    if (await _picStash.getPic(question.pictureId) != null) return;
    // Get picture and cache
    var picture = await _quizApi.getQuestionPicture(
        token ?? _authStateModel.token, quizId, question.id);
    _picStash.storePic(question.pictureId, picture);
  }

  /// When the auth state is updated
  void authUpdated() {
    if (!_authStateModel.inSession) {
      _availableQuizzes = {};
      _createdQuizzes = {};
      _selectedQuiz = null;
    }
  }
}
