import 'package:flutter/material.dart';

/// Widget to hold the app logo on auth screen
class LogoContainer extends Container {
  LogoContainer({@required Widget child})
      : super(
          height: 200,
          color: Colors.white,
          child: child,
        );
}
