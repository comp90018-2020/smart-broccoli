import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// Bottom Left coroner
class TiltFalse extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double shapeSize;

    if (size.width > size.height) {
      shapeSize = size.height;
    } else {
      shapeSize = size.width;
    }

    shapeSize = shapeSize / 4;

    var path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width - size.width / 4, 0);
    path.lineTo(size.width - size.width / 4, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

/// Bottom Left coroner
class TiltTrue extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double shapeSize;

    if (size.width > size.height) {
      shapeSize = size.height;
    } else {
      shapeSize = size.width;
    }

    shapeSize = shapeSize / 4;

    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width / 4, size.height);
    path.lineTo(size.width / 4, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

// Top right coroner
class CustomClipperCorner2 extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double shapeSize;

    if (size.width > size.height) {
      shapeSize = size.height;
    } else {
      shapeSize = size.width;
    }

    shapeSize = shapeSize/4;

    var path = Path();
    path.moveTo(size.width - shapeSize, 0);
    path.lineTo(size.width, shapeSize);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - shapeSize, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

/// Bottom Right coroner
class CustomClipperCorner4 extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double shapeSize;

    if (size.width > size.height) {
      shapeSize = size.height;
    } else {
      shapeSize = size.width;
    }
    shapeSize = shapeSize / 4;

    var path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width - shapeSize, size.height);
    path.lineTo(size.width, size.height - shapeSize);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

/// Bottom Left coroner
class CustomClipperCorner3 extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double shapeSize;

    if (size.width > size.height) {
      shapeSize = size.height;
    } else {
      shapeSize = size.width;
    }

    shapeSize = shapeSize / 4;

    var path = Path();
    path.moveTo(0, size.height - shapeSize);
    path.lineTo(0, size.height);
    path.lineTo(shapeSize, size.height);
    path.lineTo(0, size.height - shapeSize);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

// Top left coroner
class CustomClipperCorner1 extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double shapeSize;

    if (size.width > size.height) {
      shapeSize = size.height;
    } else {
      shapeSize = size.width;
    }

    shapeSize = shapeSize/4;

    var path = Path();
    path.lineTo(shapeSize, 0);
    path.lineTo(0, shapeSize);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
