import 'api_base.dart';
import 'auth.dart';

/// Class for making quiz management requests
class QuizModel {
  static const QUIZ_URL = ApiBase.BASE_URL + '/quiz';

  /// AuthModel object used to obtain token for requests
  AuthModel _authModel;

  /// Constructor for external use
  QuizModel(this._authModel);
}
