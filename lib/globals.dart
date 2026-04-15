import 'dart:math';

import 'helpers/devlog.dart';

double headingToRotation(double? headingInRadians) {
  if (headingInRadians == null) return 0.0;

  // Convert radians → degrees
  final degrees = headingInRadians * (180 / pi);

  // Normalize to 0–360
  final rotation = degrees % 360;

  final result = rotation < 0 ? rotation + 360 : rotation;

  devlog(
    "headingToRotation is : $result° for heading(rad): $headingInRadians",
  );

  return result;
}
