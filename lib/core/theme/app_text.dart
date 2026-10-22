import 'package:flutter/painting.dart';

import 'app_colors.dart';

const String appFontFamily = 'Manrope';

/// Manrope ships as a variable font, so the weight is also set on the `wght`
/// axis; [FontWeight] alone would not pick the right instance everywhere.
TextStyle appText({
  required double size,
  int weight = 400,
  Color color = AppColors.ink,
  double? height,
}) {
  return TextStyle(
    fontFamily: appFontFamily,
    fontSize: size,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation('wght', weight.toDouble())],
    color: color,
    height: height,
  );
}
