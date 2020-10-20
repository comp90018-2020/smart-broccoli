import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/theme.dart';

class MembersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<GroupRegistryModel>(
        builder: (context, registry, child) => Container(
          color: SmartBroccoliColourScheme.membersTabBackground,
          child: ListView.builder(
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
                  title: Text(registry.selectedGroup.members[index].name),
                  // Remove
                  trailing: IconButton(
                    icon: Icon(Icons.person_remove),
                    splashRadius: 20,
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
        ),
      );
}
