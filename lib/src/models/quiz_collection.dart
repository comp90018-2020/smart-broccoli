import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/src/base/firebase_messages.dart';
import 'package:smart_broccoli/src/base/helper.dart';
import 'package:smart_broccoli/src/base/pubsub.dart';
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

  bool _isAvailableQuizzesLoaded = false;
  bool _isCreatedQuizzesLoaded = false;
  Map<int, Quiz> _availableQuizzes = {};
  Map<int, Quiz> _createdQuizzes = {};

  GameSession _currentSession;
  GameSession get currentSession => _currentSession;

  /// Constructor for external use
  QuizCollectionModel(this._authStateModel, this._picStash, {QuizApi quizApi}) {
    _quizApi = quizApi ?? QuizApi();
    // Firebase message handling
    PubSub().subscribe(PubSubTopic.QUIZ_CREATE, _handleQuizCreate);
    PubSub().subscribe(PubSubTopic.QUIZ_UPDATE, _handleQuizUpdate);
    PubSub().subscribe(PubSubTopic.QUIZ_DELETE, _handleQuizDelete);
    PubSub().subscribe(PubSubTopic.SESSION_START, _handleSessionStart);
    PubSub().subscribe(PubSubTopic.SESSION_ACTIVATED, _handleSessionActivate);
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

  Quiz getQuizFromCache(int id) {
    return _createdQuizzes[id] ?? _availableQuizzes[id];
  }

  Future<Quiz> getQuiz(int id,
      {bool refresh = false, bool withQuestionPictures = false}) async {
    // If can get from cache, get from cache
    if (!refresh &&
        (_createdQuizzes.containsKey(id) || _availableQuizzes.containsKey(id)))
      return _createdQuizzes[id] ?? _availableQuizzes[id];
    return _refreshQuiz(id, withQuestionPictures: withQuestionPictures);
  }

  /// Gets the specified quiz's picture from cache
  /// note: _refresh functions will retrieve pictures
  Future<String> getQuizPicturePath(Quiz quiz) async {
    if (quiz == null || !quiz.hasPicture) return null;
    if (quiz.pendingPicturePath != null) return quiz.pendingPicturePath;
    return _picStash.getPic(quiz.pictureId);
  }

  /// Get question picture
  /// note: _refresh functions will retrieve pictures
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
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on QuizNotFoundException {
      _createdQuizzes.remove(quiz.id);
      _availableQuizzes.remove(quiz.id);
      notifyListeners();
      return Future.error("Quiz not found");
    } on ApiException catch (e) {
      try {
        await _refreshQuiz(quiz.id);
      } catch (err) {
        return Future.error(e.toString());
      }
      return Future.error(e.toString());
    } catch (err) {
      return Future.error("Something went wrong");
    }
  }

  /// Deletes a quiz
  Future<void> deleteQuiz(Quiz quiz) async {
    if (quiz == null || quiz.id == null) return;
    try {
      await _quizApi.deleteQuiz(_authStateModel.token, quiz.id);
      _availableQuizzes.remove(quiz.id);
      _createdQuizzes.remove(quiz.id);
      notifyListeners();
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on QuizNotFoundException catch (e) {
      _createdQuizzes.remove(quiz.id);
      _availableQuizzes.remove(quiz.id);
      notifyListeners();
      throw e;
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something unexpected has happened");
    }
  }

  /// Save selected quiz
  Future<void> saveQuiz(Quiz quiz) async {
    if (quiz == null) return;
    // First save the quiz
    Quiz updated;

    try {
      updated = quiz.id == null
          ? await _quizApi.createQuiz(_authStateModel.token, quiz)
          : await _quizApi.updateQuiz(_authStateModel.token, quiz);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failed");
    } on QuizNotFoundException catch (e) {
      _createdQuizzes.remove(quiz.id);
      _availableQuizzes.remove(quiz.id);
      notifyListeners();
      throw e;
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }

    // Exit if unexpected happens
    if (updated.questions.length != quiz.questions.length)
      return Future.error("Question length mismatch");

    // Futures
    var futures = <Future>[];
    // Has quiz picture to save
    if (quiz.pendingPicturePath != null)
      futures.add(_quizApi.setQuizPicture(_authStateModel.token, updated.id,
          await loadFileAndBakeOrientation(quiz.pendingPicturePath)));
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
            await loadFileAndBakeOrientation(question.pendingPicturePath)));
      }
    }

    // Wait for futures
    try {
      if (futures.length > 0) await Future.wait(futures);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on QuizNotFoundException catch (e) {
      _createdQuizzes.remove(quiz.id);
      _availableQuizzes.remove(quiz.id);
      throw e;
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }

    // Refresh quiz (since picture IDs may have changed by this point)
    _refreshQuiz(updated.id, withQuestionPictures: true)
        .catchError((_) => null);
  }

  /// Refreshes the specified quiz
  Future<Quiz> _refreshQuiz(int quizId,
      {bool withQuestionPictures = false}) async {
    // Refreshes the specified quiz
    try {
      // Get quiz and quiz picture
      var quiz = await _quizApi.getQuiz(_authStateModel.token, quizId);
      await _refreshQuizPicture(quiz);

      // Refresh pictures if necessary
      if (withQuestionPictures)
        await Future.wait(quiz.questions.map(
            (Question question) => refreshQuestionPicture(quiz.id, question)));
      // Set
      if (quiz.role == GroupRole.OWNER)
        _createdQuizzes[quiz.id] = quiz;
      else
        _availableQuizzes[quiz.id] = quiz;
      notifyListeners();
      return quiz;
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failed");
    } on QuizNotFoundException {
      _createdQuizzes.remove(quizId);
      _availableQuizzes.remove(quizId);
      notifyListeners();
      return Future.error("Quiz not found");
    } on QuizDeactivatedException {
      _createdQuizzes.remove(quizId);
      _availableQuizzes.remove(quizId);
      notifyListeners();
      return Future.error("Quiz deactivated");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  /// Refreshes list of available quizzes
  Future<bool> refreshAvailableQuizzes({bool refreshIfLoaded = false}) async {
    // Do not force refresh on start
    if (!_isAvailableQuizzesLoaded && refreshIfLoaded) return true;
    // Get from cache
    if (!refreshIfLoaded && _isAvailableQuizzesLoaded) return true;

    try {
      _availableQuizzes = Map.fromIterable(
          (await _quizApi.getQuizzes(_authStateModel.token))
              .where((quiz) => quiz.role == GroupRole.MEMBER),
          key: (quiz) => quiz.id);
      await Future.wait(_availableQuizzes.values
          .map((Quiz quiz) => _refreshQuizPicture(quiz)));
      _isAvailableQuizzesLoaded = true;
      notifyListeners();
      return true;
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("API exception has occurred");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  /// Refreshes list of created quizzes
  Future<bool> refreshCreatedQuizzes({bool refreshIfLoaded = false}) async {
    // Do not force refresh on start
    if (!_isCreatedQuizzesLoaded && refreshIfLoaded) return true;
    // Get from cache
    if (!refreshIfLoaded && _isCreatedQuizzesLoaded) return true;

    try {
      _createdQuizzes = Map.fromIterable(
          (await _quizApi.getQuizzes(_authStateModel.token))
              .where((quiz) => quiz.role == GroupRole.OWNER),
          key: (quiz) => quiz.id);
      await Future.wait(
          _createdQuizzes.values.map((Quiz quiz) => _refreshQuizPicture(quiz)));
      _isCreatedQuizzesLoaded = true;
      notifyListeners();
      return true;
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("API exception has occurred");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  /// Refreshes specific group's quizzes.
  Future<List<Quiz>> refreshGroupQuizzes(int groupId) async {
    try {
      // Get quizzes
      List<Quiz> quizzes =
          await _quizApi.getGroupQuizzes(_authStateModel.token, groupId);
      // Add to maps and refresh
      await Future.wait(quizzes.map((quiz) async {
        if (quiz.role == GroupRole.OWNER)
          _createdQuizzes[quiz.id] = quiz;
        else
          _availableQuizzes[quiz.id] = quiz;
        await _refreshQuizPicture(quiz);
      }));
      notifyListeners();
      return quizzes;
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  /// Loads the picture of a quiz into cache
  /// Caller is responsible for catching exceptions
  Future<void> _refreshQuizPicture(Quiz quiz) async {
    // No picture
    if (quiz.pictureId == null) return;
    // Picture cached
    if (await _picStash.getPic(quiz.pictureId) != null) return;
    // Get picture and cache
    var picture = await _quizApi.getQuizPicture(_authStateModel.token, quiz.id);
    _picStash.storePic(quiz.pictureId, picture);
  }

  /// Loads the picture of a question into cache
  /// Caller is responsible for catching exceptions
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

  // Deletes quizzes of a group (after a group is deleted)
  void deleteQuizzesOfGroup(int groupId) {
    _createdQuizzes.removeWhere((key, quiz) => quiz.groupId == groupId);
    _availableQuizzes.removeWhere((key, quiz) => quiz.groupId == groupId);
    notifyListeners();
  }

  // Firebase function to handle QUIZ_DELETE
  void _handleQuizDelete(dynamic content) {
    QuizUpdatePayload payload = QuizUpdatePayload.fromJson(jsonDecode(content));
    _createdQuizzes.remove(payload.quizId);
    _availableQuizzes.remove(payload.quizId);
    notifyListeners();
  }

  // Firebase function to handle QUIZ_UPDATE
  void _handleQuizUpdate(dynamic content) {
    QuizUpdatePayload payload = QuizUpdatePayload.fromJson(jsonDecode(content));
    int quizId = payload.quizId;
    // _refreshQuiz calls notify
    _refreshQuiz(quizId).catchError((_) => null);
  }

  // Firebase function to handle QUIZ_CREATE
  void _handleQuizCreate(dynamic content) {
    QuizUpdatePayload payload = QuizUpdatePayload.fromJson(jsonDecode(content));
    int quizId = payload.quizId;
    // Quiz collection currently has no way to tell if quizzes for a group
    // are loaded, so just refresh it
    _refreshQuiz(quizId).catchError((_) => null);
  }

  // Firebase function to handle SESSION_ACTIVATED
  void _handleSessionActivate(dynamic content) {
    SessionActivatePayload payload =
        SessionActivatePayload.fromJson(jsonDecode(content));
    int quizId = payload.quizId;
    // Quiz not loaded
    if (!_availableQuizzes.containsKey(quizId) &&
        !_createdQuizzes.containsKey(quizId)) return;
    // Refresh quiz (and therefore sessions)
    _refreshQuiz(quizId).catchError((_) => null);
  }

  // Firebase function to handle SESSION_ACTIVATED
  void _handleSessionStart(dynamic content) {
    int quizId = content;
    // Quiz not loaded
    if (!_availableQuizzes.containsKey(quizId) &&
        !_createdQuizzes.containsKey(quizId)) return;
    // Refresh quiz (and therefore sessions)
    _refreshQuiz(quizId).catchError((_) => null);
  }

  /// When the auth state is updated
  void authUpdated() {
    if (!_authStateModel.inSession) {
      _availableQuizzes = {};
      _createdQuizzes = {};
      _isAvailableQuizzesLoaded = false;
      _isCreatedQuizzesLoaded = false;
    }
  }
}
