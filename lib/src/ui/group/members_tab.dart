import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';

class MembersTab extends StatelessWidget {
  final int groupId;

  MembersTab(this.groupId);

  @override
  Widget build(BuildContext context) => Container(
        color: SmartBroccoliColourScheme.membersTabBackground,
        child: Consumer<GroupRegistryModel>(
          builder: (context, registry, child) {
            Group group = registry.getGroup(groupId);
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
                          if (await _confirmKickMember(
                              context, group.members[index].name))
                            try {
                              await registry.kickMemberFromGroup(
                                  group, group.members[index].id);
                            } catch (_) {
                              _showKickFailedDialogue(context);
                            }
                        },
                      )
                    : null,
              ),
            );
          },
        ),
      );

  Future<bool> _confirmKickMember(BuildContext context, String name) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm kick member"),
        content: Text(
            "${name == null ? 'The member' : name} will no longer be a " +
                "member of the group"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showKickFailedDialogue(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text("Cannot kick member"),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }
}
