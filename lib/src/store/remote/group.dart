import 'api_base.dart';
import 'auth.dart';

/// Class for making group management requests
class GroupModel {
  static const GROUP_URL = ApiBase.BASE_URL + '/group';

  /// AuthModel object used to obtain token for requests
  AuthModel _authModel;

  /// Constructor for external use
  GroupModel(this._authModel);
}
