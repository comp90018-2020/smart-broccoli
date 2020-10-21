import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/local.dart';
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

  /// Local storage service
  final KeyValueStore _keyValueStore;

  /// Views subscribe to the fields below
  ///
  /// [selectedGroup] will have a populated `members` field
  /// [joinedGroups] and [createdGroups] do not
  Group _selectedGroup;
  Group get selectedGroup => _selectedGroup;
  Iterable<Group> _joinedGroups = Iterable.empty();
  UnmodifiableListView<Group> get joinedGroups =>
      UnmodifiableListView(_joinedGroups);
  Iterable<Group> _createdGroups = Iterable.empty();
  UnmodifiableListView<Group> get createdGroups =>
      UnmodifiableListView(_createdGroups);

  /// Constructor for external use
  GroupRegistryModel(this._keyValueStore, this._authStateModel, this._userRepo,
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
    refreshJoinedGroups();
  }

  Future<void> kickMemberFromSelectedGroup(int memberId) async {
    await _groupApi.kickMember(
        _authStateModel.token, _selectedGroup.id, memberId);
    refreshSelectedGroup();
  }

  /// Delete the selected group.
  ///
  /// No group will subsequently be selected (i.e. [selectedGroup] is `null`).
  Future<void> deleteSelectedGroup() async {
    if (_selectedGroup == null) return;
    await _groupApi.deleteGroup(_authStateModel.token, _selectedGroup.id);
    _selectedGroup = null;
    refreshCreatedGroups();
  }

  /// Refresh the ListView of groups the user has joined.
  ///
  /// This callback only populates the `members` field of each group if the
  /// optional [withMembers] parameter is `true`.
  Future<void> refreshJoinedGroups({bool withMembers = false}) async {
    _joinedGroups = (await _groupApi.getGroups(_authStateModel.token))
        .where((group) => group.role == GroupRole.MEMBER);
    if (withMembers)
      await Future.forEach(_joinedGroups, (group) async {
        group.members =
            await _userRepo.getMembersOf(_authStateModel.token, group.id);
      });
    // _keyValueStore.setString('joinedGroups',
    //     json.encode(_joinedGroups.map((group) => group.toJson())));
    notifyListeners();
  }

  /// Refresh the ListView of groups the user has created.
  ///
  /// This callback only populates the `members` field of each group if the
  /// optional [withMembers] parameter is `true`.
  Future<void> refreshCreatedGroups({bool withMembers = false}) async {
    _createdGroups = (await _groupApi.getGroups(_authStateModel.token))
        .where((group) => group.role == GroupRole.OWNER);
    if (withMembers)
      await Future.forEach(_createdGroups, (group) async {
        group.members =
            await _userRepo.getMembersOf(_authStateModel.token, group.id);
      });
    // _keyValueStore.setString('createdGroups',
    //     json.encode(_createdGroups.map((group) => group.toJson())));
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
