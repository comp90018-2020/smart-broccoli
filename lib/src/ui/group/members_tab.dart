import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';

class MembersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: SmartBroccoliColourScheme.membersTabBackground,
        child: Consumer<GroupRegistryModel>(
          builder: (context, registry, child) => ListView.builder(
            itemCount: registry.selectedGroup.members.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 8 : 0),
                child: ListTile(
                  // Avatar
                  leading: registry.selectedGroup.members[index].picture == null
                      ? UserAvatar.placeholder()
                      : UserAvatar(
                          registry.selectedGroup.members[index].picture),
                  // Name
                  title: registry.selectedGroup.members[index].name == null
                      ? Text("(anonymous member)")
                      : Text(registry.selectedGroup.members[index].name),
                  // Remove
                  trailing: registry.selectedGroup.role == GroupRole.OWNER
                      ? IconButton(
                          icon: Icon(Icons.person_remove),
                          splashRadius: 20,
                          onPressed: () async {
                            if (await _confirmKickMember(context,
                                registry.selectedGroup.members[index].name))
                              try {
                                await registry.kickMemberFromSelectedGroup(
                                    registry.selectedGroup.members[index].id);
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
