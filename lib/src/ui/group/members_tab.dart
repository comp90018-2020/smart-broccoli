import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/dialog.dart';
import 'package:smart_broccoli/theme.dart';

class MembersTab extends StatelessWidget {
  final int groupId;

  MembersTab(this.groupId);

  @override
  Widget build(BuildContext context) => Container(
        color: SmartBroccoliColourScheme.membersTabBackground,
        child: Consumer<GroupRegistryModel>(
          builder: (context, registry, child) {
            Group group = registry.getGroupFromCache(groupId);
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: group.members.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                // Avatar
                leading: FutureBuilder(
                    future:
                        registry.getGroupMemberPicture(group.members[index].id),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return UserAvatar.placeholder();
                      }
                      return UserAvatar(snapshot.data);
                    }),
                // Name
                title: Text(group.members[index].name),
                // Remove
                trailing: group.role == GroupRole.OWNER
                    ? IconButton(
                        icon: Icon(Icons.person_remove),
                        splashRadius: 20,
                        onPressed: () async {
                          if (await showConfirmDialog(
                              context,
                              "${group.members[index].name ?? 'The member'}" +
                                  "will no longer be a member of the group",
                              title: "Confirm kick member"))
                            try {
                              await registry.kickMemberFromGroup(
                                  group, group.members[index].id);
                            } catch (_) {
                              showBasicDialog(context, "Cannot kick member");
                            }
                        },
                      )
                    : null,
              ),
            );
          },
        ),
      );
}
