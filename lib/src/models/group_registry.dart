import 'dart:collection';
import 'package:flutter/widgets.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/remote.dart';
import 'model_change.dart';

import 'auth_state.dart';
import 'user_repository.dart';

/// View model for group management
class GroupRegistryModel extends ChangeNotifier implements AuthChange {
  /// AuthStateModel object used to obtain token for requests
  final AuthStateModel _authStateModel;

  /// QuizCollectionModel to obtain quizzes for group
  final QuizCollectionModel _quizCollectionModel;

  /// API provider for the user profile service
  GroupApi _groupApi;

  /// Cached provider for user profile service
  final UserRepository _userRepo;

  // Internal storage
  bool _joinedGroupsLoaded = false;
  bool _createdGroupsLoaded = false;
  Map<int, Group> _joinedGroups = {};
  Map<int, Group> _createdGroups = {};
  Map<int, bool> _groupQuizLoaded = {};
  Map<int, List<User>> _groupMembers = {};

  /// List of groups which the user has joined
  UnmodifiableListView<Group> get joinedGroups =>
      UnmodifiableListView(_joinedGroups.values);

  /// List of groups which the user has created
  UnmodifiableListView<Group> get createdGroups =>
      UnmodifiableListView(_createdGroups.values);

  /// Constructor for external use
  GroupRegistryModel(
      this._authStateModel, this._userRepo, this._quizCollectionModel,
      {GroupApi groupApi}) {
    _groupApi = groupApi ?? GroupApi();
  }

  // Get a group.
  Group getGroupFromCache(int id) {
    return _joinedGroups[id] ?? _createdGroups[id];
  }

  /// Function to get group
  Future<Group> getGroup(int id, {bool refresh = false}) async {
    // If in cache and we don't force refresh
    if (!refresh && (_joinedGroups[id] != null || _createdGroups[id] != null)) {
      return _joinedGroups[id] ?? _createdGroups[id];
    }
    // If not, retrieve group
    await refreshGroup(id);
    return _joinedGroups[id] ?? _createdGroups[id];
  }

  /// Gets a group member's picture.
  Future<String> getGroupMemberPicture(int id) {
    return _userRepo.getUserPicture(id);
  }

  /// Get a group's members
  Future<List<User>> getGroupMembers(int groupId,
      {bool refresh = false}) async {
    if (_groupMembers.containsKey(groupId) && !refresh)
      return Future.value(_groupMembers[groupId]);
    return _refreshGroupMembers(groupId);
  }

  /// Rename a group.
  Future<void> renameGroup(Group group, String newName) async {
    try {
      // rename the group
      await _groupApi.updateGroup(_authStateModel.token, group.id, newName);
      // fetch the updated group and save it to the map
      _createdGroups[group.id] =
          await _groupApi.getGroup(_authStateModel.token, group.id);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
    notifyListeners();
  }

  /// Leave a group.
  Future<void> leaveGroup(Group group) async {
    try {
      await _groupApi.leaveGroup(_authStateModel.token, group.id);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
    getJoinedGroups(refresh: true).catchError((_) => null);
  }

  /// Kick a member from a group.
  Future<void> kickMemberFromGroup(Group group, int memberId) async {
    // kick the member
    await _groupApi.kickMember(_authStateModel.token, group.id, memberId);
    // fetch the members list
    await getGroupMembers(group.id);
    notifyListeners();
  }

  /// Delete a group.
  Future<void> deleteGroup(Group group) async {
    try {
      await _groupApi.deleteGroup(_authStateModel.token, group.id);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
    getCreatedGroups(refresh: true).catchError((_) => null);
  }

  /// Refresh the ListView of groups the user has joined.
  Future<List<Group>> getJoinedGroups(
      {bool refresh = false, bool withMembers = false}) async {
    if (!_authStateModel.inSession) return null;

    // fetch from API and save into map
    if (refresh || !_joinedGroupsLoaded) {
      try {
        _joinedGroups = Map.fromIterable(
            (await _groupApi.getGroups(_authStateModel.token))
                .where((group) => group.role == GroupRole.MEMBER),
            key: (group) => group.id);

        if (withMembers)
          await Future.wait(_joinedGroups.values.map((group) =>
              _userRepo.getMembersOf(_authStateModel.token, group.id)));
      } on ApiAuthException {
        _authStateModel.checkSession();
        return Future.error("Authentication failure");
      } on ApiException catch (e) {
        return Future.error(e.toString());
      } on Exception {
        return Future.error("Something went wrong");
      }
      notifyListeners();
    }

    return _joinedGroups.values;
  }

  /// Refresh the ListView of groups the user has created.
  Future<void> getCreatedGroups(
      {bool refresh = false, bool withMembers = false}) async {
    if (!_authStateModel.inSession) return;

    // fetch from API and save into map
    if (refresh || !_createdGroupsLoaded) {
      try {
        _createdGroups = Map.fromIterable(
            (await _groupApi.getGroups(_authStateModel.token))
                .where((group) => group.role == GroupRole.OWNER),
            key: (group) => group.id);

        if (withMembers)
          await Future.wait(_createdGroups.values.map((group) =>
              _userRepo.getMembersOf(_authStateModel.token, group.id)));
      } on ApiAuthException {
        _authStateModel.checkSession();
        return Future.error("Authentication failure");
      } on ApiException catch (e) {
        return Future.error(e.toString());
      } on Exception {
        return Future.error("Something went wrong");
      }
      notifyListeners();
    }
  }

  /// Refreshes the specified group.
  Future<void> refreshGroup(int id,
      {bool withMembers = true, bool withQuizzes = true}) async {
    if (!_authStateModel.inSession) return;
    // fetch group
    var group = await _groupApi.getGroup(_authStateModel.token, id);
    if (group.role == GroupRole.OWNER) {
      _createdGroups[group.id] = group;
    } else {
      _joinedGroups[group.id] = group;
    }
    // fetch quizzes
    if (withQuizzes) await _quizCollectionModel.refreshGroupQuizzes(id);
    // fetch members
    if (withMembers) await getGroupMembers(group.id);
    notifyListeners();
  }

  /// Create a new group.
  ///
  /// This callback refreshes [createdGroups].
  Future<void> createGroup(String name) async {
    try {
      await _groupApi.createGroup(_authStateModel.token, name);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on GroupCreateException catch (e) {
      throw e;
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
    getCreatedGroups(refresh: true).catchError((_) => null);
  }

  /// Join a group.
  Future<void> joinGroup({String name, String code}) async {
    try {
      await _groupApi.joinGroup(_authStateModel.token, name: name, code: code);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on GroupNotFoundException {
      return Future.error("Group does not exist: $name");
    } on AlreadyInGroupException {
      return Future.error("Already member of group: $name");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
    getJoinedGroups(refresh: true).catchError((_) => null);
  }

  /// Refreshes group members
  Future<List<User>> _refreshGroupMembers(int groupId) async {
    try {
      _groupMembers[groupId] =
          await _userRepo.getMembersOf(_authStateModel.token, groupId);
      return Future.value(_groupMembers[groupId]);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }
  }

  void authUpdated() {
    if (!_authStateModel.inSession) {
      _joinedGroupsLoaded = false;
      _createdGroupsLoaded = false;
      _joinedGroups = {};
      _createdGroups = {};
      _groupQuizLoaded = {};
      _groupMembers = {};
    }
  }
}
