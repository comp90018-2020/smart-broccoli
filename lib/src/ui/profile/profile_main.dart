import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/profile/promoted_profile.dart';
import 'package:smart_broccoli/src/ui/profile/registered_profile.dart';

class ProfileMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ProfileMainState();
}

class _ProfileMainState extends State<ProfileMain> {
  bool isRegistered;

  @override
  void didChangeDependencies() {
    isRegistered = false;
    super.didChangeDependencies();
    QuizCollectionModel qcm =
        Provider.of<QuizCollectionModel>(context, listen: true);

  }

  /// The job of this class is to be a tmp widget to determine which Profile
  /// Widget to display The classes are layed out this way to allow for
  /// Future expansion on different profile types alongside their common
  /// Widgets in Profile.dart
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: isRegistered ? RegisteredProfile() : PromotedProfile()
    );
  }
}
