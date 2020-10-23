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
  Group _selectedGroup;

  Group get selectedGroup => _selectedGroup;

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
  ///
  /// First, look in `_joinedGroups` and `_createdGroups`. If not found, fall
  /// back to the API.
  Future<Group> getGroup(int id) async {
    if (_joinedGroups.containsKey(id)) return _joinedGroups[id];
    if (_createdGroups.containsKey(id)) return _createdGroups[id];
    return await _groupApi.getGroup(_authStateModel.token, id);
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
    if (_selectedGroup != null) selectGroup(_selectedGroup.id);
  }

  /// Refresh the code to join the selected group (ask server for new one).
  Future<void> refreshSelectedGroupCode() async {
    await _groupApi.refreshCode(_authStateModel.token, _selectedGroup.id);
    refreshSelectedGroup();
  }

  /// Update the name of the group currently selected.
  Future<void> updateSelectedGroup(String name) async {
    await _groupApi.updateGroup(_authStateModel.token, _selectedGroup.id, name);
    refreshSelectedGroup();
    refreshCreatedGroups();
  }

  /// Leave the selected group.
  ///
  /// No group will subsequently be selected (i.e. [selectedGroup] is `null`).
  Future<void> leaveSelectedGroup() async {
    await _groupApi.leaveGroup(_authStateModel.token, _selectedGroup.id);
    _selectedGroup = null;
    refreshJoinedGroups(withMembers: true);
  }

  Future<void> kickMemberFromSelectedGroup(int memberId) async {
    await _groupApi.kickMember(
        _authStateModel.token, _selectedGroup.id, memberId);
    refreshSelectedGroup();
    refreshCreatedGroups(withMembers: true);
  }

  /// Delete the selected group.
  ///
  /// No group will subsequently be selected (i.e. [selectedGroup] is `null`).
  Future<void> deleteSelectedGroup() async {
    if (_selectedGroup == null) return;
    await _groupApi.deleteGroup(_authStateModel.token, _selectedGroup.id);
    _selectedGroup = null;
    refreshCreatedGroups(withMembers: true);
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
    refreshCreatedGroups(withMembers: true);
  }

  /// Join a group.
  ///
  /// The group will subsequently be selected (i.e. is [selectedGroup]).
  Future<void> joinGroup({String name, String code}) async {
    Group group = await _groupApi.joinGroup(_authStateModel.token,
        name: name, code: code);
    selectGroup(group.id);
    refreshJoinedGroups(withMembers: true);
  }
}
