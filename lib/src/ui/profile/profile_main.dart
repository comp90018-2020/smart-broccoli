import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/ui/profile/promoted_profile.dart';
import 'package:smart_broccoli/src/ui/profile/registered_profile.dart';


class ProfileMain extends StatelessWidget {
  // Debug value
  final bool isRegistered = true;

  ProfileMain() {
    /// Provider Code here
    /// Defaults to true
  }

  /// The job of this class is to be a tmp widget to determine which Profile
  /// Widget to display The classes are layed out this way to allow for
  /// Future expansion on different profile types alongside their common
  /// Widgets in Profile.dart
  @override
  Widget build(BuildContext context) {
    if (isRegistered) {
      // Wait for rendering to complete
      Future.delayed(Duration.zero, () {
        // A user which has joined but not promoted
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RegisteredProfile(),
          ),
        );
      });
    } else {
      // Wait for rendering to complete
      Future.delayed(Duration.zero, () {
        // A promoted user
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => PromotedProfile()),
        );
      });
    }
    return new Scaffold();
  }
}
