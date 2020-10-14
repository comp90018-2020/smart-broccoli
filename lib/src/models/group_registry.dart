import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_broccoli/cache.dart';

import '../../models.dart';
import '../store/remote/group_api.dart';
import 'auth_state.dart';

/// View model for group management
class GroupRegistryModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the user profile service
  GroupApi _groupApi;

  /// Local storage service
  KeyValueStore _keyValueStore;

  /// Views subscribe to the fields below
  Group _selectedGroup;
  Group get selectedGroup => _selectedGroup;
  Iterable<Group> _joinedGroups;
  UnmodifiableListView<Group> get joinedGroups =>
      UnmodifiableListView(_joinedGroups);
  Iterable<Group> _createdGroups;
  UnmodifiableListView<Group> get createdGroups =>
      UnmodifiableListView(_createdGroups);

  /// Constructor for external use
  GroupRegistryModel(this._keyValueStore, this._authStateModel,
      {GroupApi groupApi}) {
    _groupApi = groupApi ?? GroupApi();
    // load last record of joined and created quizzes from local storage
    try {
      _joinedGroups =
          (json.decode(_keyValueStore.getString('joinedGroups')) as List)
              .map((repr) => Group.fromJson(repr));
    } catch (_) {}
    try {
      _createdGroups =
          (json.decode(_keyValueStore.getString('createdGroups')) as List)
              .map((repr) => Group.fromJson(repr));
    } catch (_) {}
  }

  Future<void> selectGroup(int id) async {
    _selectedGroup = await _groupApi.getGroup(_authStateModel.token, id);
    _selectedGroup.members =
        await _groupApi.getMembers(_authStateModel.token, id);
    notifyListeners();
  }

  Future<void> refreshSelectedGroup() async {
    if (_selectedGroup == null) return;
    _selectedGroup =
        await _groupApi.getGroup(_authStateModel.token, _selectedGroup.id);
    _selectedGroup.members =
        await _groupApi.getMembers(_authStateModel.token, _selectedGroup.id);
    notifyListeners();
  }

  Future<void> refreshAvailableQuizzes() async {
    _joinedGroups = (await _groupApi.getGroups(_authStateModel.token))
        .where((group) => group.role == GroupRole.MEMBER);
    _keyValueStore.setString('availableQuizzes',
        json.encode(_joinedGroups.map((group) => group.toJson())));
    notifyListeners();
  }

  Future<void> refreshCreatedQuizzes() async {
    _createdGroups = (await _groupApi.getGroups(_authStateModel.token))
        .where((group) => group.role == GroupRole.OWNER);
    _keyValueStore.setString('createdQuizzes',
        json.encode(_createdGroups.map((group) => group.toJson())));
    notifyListeners();
  }
}
