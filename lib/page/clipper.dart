// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// A round clipper for the homepage.

import 'package:flutter/material.dart';

class RoundClipper extends CustomClipper<Path> {
  final double height;

  RoundClipper({
    required this.height,
  });

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, height / 2);

    var firstStart = Offset(size.width / 2, height);
    //fist point of quadratic bezier curve
    var firstEnd = Offset(size.width, height / 2);
    //second point of quadratic bezier curve
    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);
    //end with this path if you are making wave at bottom

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; //if new instance have different instance than old instance
    //then you must return true;
  }
}

class FillLineClipper extends CustomClipper<Path> {
  final double imgHeight;

  FillLineClipper(this.imgHeight);

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant FillLineClipper oldClipper) {
    return oldClipper.imgHeight != imgHeight;
  }
}
