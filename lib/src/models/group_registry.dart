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

  // Groups stored in memory
  Map<int, Group> _joinedGroups = {};
  Map<int, Group> _createdGroups = {};
  // Whether group are loaded
  bool _joinedGroupsLoaded = false;
  bool _createdGroupsLoaded = false;
  // Stores group members
  Map<int, List<User>> _groupMembers = {};
  // Stores whether quizzes are loaded
  Map<int, bool> _groupQuizLoaded = {};

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

  Group getGroupFromCache(int id) {
    return _joinedGroups[id] ?? _createdGroups[id];
  }

  /// Function to get group
  Future<Group> getGroup(int id, {bool refresh = false}) {
    // If in cache and we don't force refresh
    if (!refresh && (_joinedGroups[id] != null || _createdGroups[id] != null)) {
      return Future.value(getGroupFromCache(id));
    }
    // If not, retrieve group
    return refreshGroup(id);
  }

  /// Gets a group member's picture.
  Future<String> getGroupMemberPicture(int id) {
    return _userRepo.getUserPicture(id);
  }

  /// Get a group's members
  Future<List<User>> getGroupMembers(int groupId,
      {bool refresh = false}) async {
    // Already exists and no refresh, get from cache
    if (_groupMembers.containsKey(groupId) && !refresh)
      return _groupMembers[groupId];
    // Return the future
    return _refreshGroupMembers(groupId);
  }

  /// Get a group's quizzes
  Future<List<Quiz>> getGroupQuizzes(int groupId,
      {bool refresh = false}) async {
    // Already exists and no refresh, get from cache
    if (_groupQuizLoaded.containsKey(groupId) && !refresh)
      return _quizCollectionModel.getQuizzesWhere(groupId: groupId);

    try {
      // Refresh quizzes
      await _quizCollectionModel.refreshGroupQuizzes(groupId);
      _groupQuizLoaded[groupId] = true;
    } catch (e) {
      return Future.error(e);
    }

    // Return retrieved quizzes
    return _quizCollectionModel.getQuizzesWhere(groupId: groupId);
  }

  /// Rename a group.
  Future<void> renameGroup(Group group, String newName) async {
    try {
      await _groupApi.updateGroup(_authStateModel.token, group.id, newName);
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
      _joinedGroups.remove(group.id);
      _createdGroups.remove(group.id);
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

  /// Kick a member from a group.
  Future<void> kickMemberFromGroup(Group group, int memberId) async {
    try {
      await _groupApi.kickMember(_authStateModel.token, group.id, memberId);
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }

    try {
      // fetch the members list
      _groupMembers[group.id] = await _refreshGroupMembers(group.id);
    } catch (err) {
      return Future.error(err);
    }

    notifyListeners();
  }

  /// Delete a group.
  Future<void> deleteGroup(Group group) async {
    try {
      await _groupApi.deleteGroup(_authStateModel.token, group.id);
      _createdGroups.remove(group.id);
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

  /// Refresh the ListView of groups the user has joined.
  Future<List<Group>> getJoinedGroups(
      {bool refreshIfLoaded = false, bool withMembers = false}) async {
    // If not loaded and we want to refresh
    if (refreshIfLoaded && !_joinedGroupsLoaded) return null;

    // fetch from API and save into map
    if (refreshIfLoaded || !_joinedGroupsLoaded) {
      try {
        _joinedGroups = Map.fromIterable(
            (await _groupApi.getGroups(_authStateModel.token))
                .where((group) => group.role == GroupRole.MEMBER),
            key: (group) => group.id);

        if (withMembers)
          await Future.wait(_joinedGroups.values.map((group) async {
            _groupMembers[group.id] =
                await _userRepo.getMembersOf(_authStateModel.token, group.id);
          }));
        _joinedGroupsLoaded = true;
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
    return _joinedGroups.values.toList();
  }

  /// Refresh the ListView of groups the user has created.
  Future<List<Group>> getCreatedGroups(
      {bool refreshIfLoaded = false, bool withMembers = false}) async {
    // If not loaded and we want to refresh
    if (refreshIfLoaded && !_createdGroupsLoaded) return null;

    // fetch from API and save into map
    if (refreshIfLoaded || !_createdGroupsLoaded) {
      try {
        _createdGroups = Map.fromIterable(
            (await _groupApi.getGroups(_authStateModel.token))
                .where((group) => group.role == GroupRole.OWNER),
            key: (group) => group.id);

        if (withMembers)
          await Future.wait(_createdGroups.values.map((group) async {
            _groupMembers[group.id] =
                await _userRepo.getMembersOf(_authStateModel.token, group.id);
          }));
        _createdGroupsLoaded = true;
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
    return _createdGroups.values.toList();
  }

  /// Refreshes the specified group.
  Future<Group> refreshGroup(int id,
      {bool withMembers = true, bool withQuizzes = true}) async {
    var group;
    try {
      // fetch group
      group = await _groupApi.getGroup(_authStateModel.token, id);
      if (group.role == GroupRole.OWNER) {
        _createdGroups[group.id] = group;
      } else {
        _joinedGroups[group.id] = group;
      }
    } on ApiAuthException {
      _authStateModel.checkSession();
      return Future.error("Authentication failure");
    } on ApiException catch (e) {
      return Future.error(e.toString());
    } on Exception {
      return Future.error("Something went wrong");
    }

    try {
      // fetch quizzes
      if (withQuizzes) await _quizCollectionModel.refreshGroupQuizzes(id);
      // fetch members
      if (withMembers)
        _groupMembers[group.id] = await _refreshGroupMembers(group.id);
      notifyListeners();
      return group;
    } catch (err) {
      return Future.error(err);
    }
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
    // Refresh created groups
    try {
      await getCreatedGroups(refreshIfLoaded: true);
    } catch (e) {
      return Future.error(e);
    }
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
    // Refresh joined groups
    try {
      await getJoinedGroups(refreshIfLoaded: true);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// Refreshes group members
  Future<List<User>> _refreshGroupMembers(int groupId) async {
    try {
      _groupMembers[groupId] =
          await _userRepo.getMembersOf(_authStateModel.token, groupId);
      return _groupMembers[groupId];
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
