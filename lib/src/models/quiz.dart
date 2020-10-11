import 'package:smart_broccoli/cache.dart';

import '../store/remote/quiz_api.dart';
import 'auth.dart';

/// View model for quiz management
class QuizCollectionModel {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the user profile service
  QuizApi _quizApi;

  /// Local storage service
  final KeyValueStore _keyValueStore;

  // TODO
  // List of quiz
  // Current quiz

  /// Constructor for external use
  QuizCollectionModel(this._keyValueStore, this._authStateModel, {QuizApi quizApi}) {
    _quizApi = quizApi ?? QuizApi();
  }
}
