import 'package:flutter/material.dart';

class CircleTransition extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleTransition({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
