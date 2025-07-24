import 'package:flutter/material.dart';
import 'package:inlek/constants/extensions.dart';

EdgeInsets getMarginOrPadding({
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  if (all != null) {
    left = all.dp;
    top = all.dp;
    right = all.dp;
    bottom = all.dp;
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
  return EdgeInsets.only(
    left: left?.dp ?? 0,
    top: top?.dp ?? 0,
    right: right?.dp ?? 0,
    bottom: bottom?.dp ?? 0,
  );
}
