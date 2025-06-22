import 'dart:math';

import 'package:flutter/material.dart';

class NavbarShape extends NotchedShape {
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);

    const double notchRadius = 38.0;
    final double s1 = 15.0;
    final double s2 = 1.0;

    final double r = notchRadius;
    final double a = -1.0 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = sqrt(b * b + a * a);
    final double p = r / n2;

    final double x1 = guest.center.dx + a * p;
    final double x2 = guest.center.dx - a * p;

    final Path path = Path()
      ..moveTo(host.left, host.top)
      ..lineTo(x1 - s1, host.top)
      ..quadraticBezierTo(guest.center.dx, guest.top - 20, x2 + s1, host.top)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();

    return path;
  }
}
