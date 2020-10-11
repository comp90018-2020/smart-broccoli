import 'package:smart_broccoli/cache.dart';

import '../../models.dart';
import '../store/remote/group_api.dart';
import 'auth_state.dart';

/// Class for making group management requests
class GroupRegistryModel {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the user profile service
  GroupApi _groupApi;

  /// Local storage service
  KeyValueStore _keyValueStore;

  /// Constructor for external use
  GroupRegistryModel(this._keyValueStore, this._authStateModel,
      {GroupApi groupApi}) {
    _groupApi = groupApi ?? GroupApi();
  }
}
