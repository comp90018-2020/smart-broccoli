import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_broccoli/src/profile/joined_profile.dart';
import 'package:smart_broccoli/src/profile/profile.dart';
import 'package:smart_broccoli/src/profile/registered_profile.dart';

class ProfileMain extends StatelessWidget {
  bool isRegistered;

  ProfileMain() {
    /// Provider Code here
    /// Defaults to true
    isRegistered = true;
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RegisteredProfile(true)),
        );
      });
    } else {
      // Wait for rendering to complete
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => JoinedProfile(false)),
        );
      });
    }
    return new Scaffold();
  }
}
