import 'dart:collection';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/remote.dart';
import 'package:smart_broccoli/src/data.dart';

import 'auth_state.dart';
import 'user_repository.dart';

/// View model for group management
class GroupRegistryModel extends ChangeNotifier {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// API provider for the user profile service
  GroupApi _groupApi;

  /// Cached provider for user profile service
  final UserRepository _userRepo;

  // Internal storage
  Map<int, Group> _joinedGroups = {};
  Map<int, Group> _createdGroups = {};

  /// List of groups which the user has joined
  UnmodifiableListView<Group> get joinedGroups =>
      UnmodifiableListView(_joinedGroups.values);

  /// List of groups which the user has created
  UnmodifiableListView<Group> get createdGroups =>
      UnmodifiableListView(_createdGroups.values);

  /// Constructor for external use
  GroupRegistryModel(this._authStateModel, this._userRepo,
      {GroupApi groupApi}) {
    _groupApi = groupApi ?? GroupApi();
  }

  /// Get a group.
  Group getGroup(int id) {
    return _joinedGroups[id] ?? _createdGroups[id];
  }

  /// Refresh the code to join a group (ask server for new one).
  Future<void> refreshGroupCode(Group group) async {
    await _groupApi.refreshCode(_authStateModel.token, group.id);
    refreshCreatedGroups();
  }

  /// Update a group.
  Future<void> updateGroup(Group group) async {
    await _groupApi.updateGroup(_authStateModel.token, group.id, group.name);
    refreshCreatedGroups();
  }

  /// Leave a group.
  Future<void> leaveGroup(Group group) async {
    await _groupApi.leaveGroup(_authStateModel.token, group.id);
    refreshJoinedGroups();
  }

  /// Kick a member from a group.
  Future<void> kickMemberFromGroup(Group group, int memberId) async {
    await _groupApi.kickMember(_authStateModel.token, group.id, memberId);
    refreshCreatedGroups();
  }

  /// Delete a group.
  Future<void> deleteGroup(Group group) async {
    await _groupApi.deleteGroup(_authStateModel.token, group.id);
    refreshCreatedGroups();
  }

  /// Refresh the ListView of groups the user has joined.
  ///
  /// This callback does not populate the `members` field of each group if the
  /// optional [withMembers] parameter is `false`.
  Future<void> refreshJoinedGroups({bool withMembers = true}) async {
    // fetch from API and save into map
    _joinedGroups = Map.fromIterable(
        (await _groupApi.getGroups(_authStateModel.token))
            .where((group) => group.role == GroupRole.MEMBER),
        key: (group) => group.id);
    // fetch members of each group
    if (withMembers)
      await Future.forEach(_joinedGroups.values, (group) async {
        group.members =
            await _userRepo.getMembersOf(_authStateModel.token, group.id);
      });
    notifyListeners();
  }

  /// Refresh the ListView of groups the user has created.
  ///
  /// This callback does not populate the `members` field of each group if the
  /// optional [withMembers] parameter is `false`.
  Future<void> refreshCreatedGroups({bool withMembers = true}) async {
    // fetch from API and save into map
    _createdGroups = Map.fromIterable(
        (await _groupApi.getGroups(_authStateModel.token))
            .where((group) => group.role == GroupRole.OWNER),
        key: (group) => group.id);
    // fetch members of each group
    if (withMembers)
      await Future.forEach(_createdGroups.values, (group) async {
        group.members =
            await _userRepo.getMembersOf(_authStateModel.token, group.id);
      });
    notifyListeners();
  }

  /// Create a new group.
  ///
  /// This callback refreshes [createdGroups].
  Future<void> createGroup(String name) async {
    await _groupApi.createGroup(_authStateModel.token, name);
    refreshCreatedGroups();
  }

  /// Join a group.
  Future<void> joinGroup({String name, String code}) async {
    await _groupApi.joinGroup(_authStateModel.token, name: name, code: code);
    refreshJoinedGroups();
  }
}
