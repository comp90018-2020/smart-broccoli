import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/src/ui/shared/indicators.dart';
import 'package:smart_broccoli/theme.dart';

class MembersTab extends StatelessWidget {
  final int groupId;
  MembersTab(this.groupId);

  @override
  Widget build(BuildContext context) => Container(
        color: SmartBroccoliColourScheme.membersTabBackground,
        child: FutureBuilder(
            future: Provider.of<GroupRegistryModel>(context)
                .getGroupMembers(groupId),
            builder: (context, snapshot) {
              return Consumer<GroupRegistryModel>(
                builder: (context, registry, child) {
                  log("Members tab future ${snapshot.toString()}");
                  if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("An error has occurred, cannot load"),
                    );

                  // To get into the members tab, the group must be loaded
                  var group = registry.getGroupFromCache(groupId);
                  // Members from future
                  var members = registry.getGroupMembersCached(groupId);

                  if (snapshot.hasData && group != null && members != null) {
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: members.length,
                      itemBuilder: (BuildContext context, int index) =>
                          ListTile(
                        // Avatar
                        leading: FutureBuilder(
                            future: registry
                                .getGroupMemberPicture(members[index].id),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              return UserAvatar(snapshot.data);
                            }),
                        // Name
                        title: Text(members[index].name),
                        // Remove
                        trailing: group.role == GroupRole.OWNER
                            ? IconButton(
                                icon: Icon(Icons.person_remove),
                                splashRadius: 20,
                                onPressed: () async {
                                  if (await showConfirmDialog(
                                      context,
                                      "${members[index].name ?? 'The member'}" +
                                          "will no longer be a member of the group",
                                      title: "Confirm kick member"))
                                    await registry
                                        .kickMemberFromGroup(
                                            group, members[index].id)
                                        .catchError((err) => showBasicDialog(
                                            context, err.toString()));
                                },
                              )
                            : null,
                      ),
                    );
                  }
                  return LoadingIndicator(EdgeInsets.symmetric(vertical: 32));
                },
              );
            }),
      );
}
