import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_broccoli/cache.dart';

import '../../models.dart';
import '../store/remote/group_api.dart';
import 'auth_state.dart';
import 'user_repository.dart';

/// View model for group management
class GroupRegistryModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the user profile service
  GroupApi _groupApi;

  /// Cached provider for user profile service
  UserRepository _userRepo;

  /// Local storage service
  KeyValueStore _keyValueStore;

  /// Views subscribe to the fields below
  ///
  /// [selectedGroup] will have a populated `members` field
  /// [joinedGroups] and [createdGroups] do not
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

  /// Select a group.
  ///
  /// Make [selectedGroup] point to the group with [id]. This callback also
  /// populates the `members` field the group.
  Future<void> selectGroup(int id) async {
    _selectedGroup = await _groupApi.getGroup(_authStateModel.token, id);
    // profile pics are fetched transparently by `UserRepository.getMembersOf`
    _selectedGroup.members =
        await _userRepo.getMembersOf(_authStateModel.token, id);
    notifyListeners();
  }

  /// Refresh the group currently selected ([selectedGroup] points to this).
  ///
  /// This callback also refreshes the `members` field the group. If no group
  /// is currently selected, this callback has no effect.
  Future<void> refreshSelectedGroup() async {
    if (_selectedGroup == null) return;
    selectGroup(_selectedGroup.id);
    notifyListeners();
  }

  /// Refresh the ListView of groups the user has joined.
  ///
  /// This callback does not populate the `members` field of each group. The
  /// `members` field of a group is populated when the `selectGroup` callback
  /// is invoked for a particular group.
  Future<void> refreshJoinedGroups() async {
    _joinedGroups = (await _groupApi.getGroups(_authStateModel.token))
        .where((group) => group.role == GroupRole.MEMBER);
    _keyValueStore.setString('joinedGroups',
        json.encode(_joinedGroups.map((group) => group.toJson())));
    notifyListeners();
  }

  /// Refresh the ListView of groups the user has created.
  ///
  /// This callback does not populate the `members` field of each group. The
  /// `members` field of a group is populated when the `selectGroup` callback
  /// is invoked for a particular group.
  Future<void> refreshCreatedGroups() async {
    _createdGroups = (await _groupApi.getGroups(_authStateModel.token))
        .where((group) => group.role == GroupRole.OWNER);
    _keyValueStore.setString('createdGroups',
        json.encode(_createdGroups.map((group) => group.toJson())));
    notifyListeners();
  }

  /// Create a new group.
  ///
  /// This callback refreshes [createdGroups].
  Future<void> createGroup(String name) async {
    await _groupApi.createGroup(_authStateModel.token, name);
    refreshCreatedGroups();
  }
}
