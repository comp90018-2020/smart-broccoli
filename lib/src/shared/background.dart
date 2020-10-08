import 'package:flutter/material.dart';

/// Super hacky (but official) way to have weird shapes in the background
/// For clarifications please talk to Harrison
class BackgroundClipperMain extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, size.height * 0.63);
    // path.moveTo(0, size.width*1.5);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - size.height * 0.66);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}