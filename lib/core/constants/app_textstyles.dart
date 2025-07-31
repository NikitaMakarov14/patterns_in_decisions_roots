import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle monospace(
      {double fontSize = 16, Color color = AppColors.white}) {
    return TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle italic(
      {double fontSize = 16, Color color = AppColors.white}) {
    return TextStyle(
      fontStyle: FontStyle.italic,
      fontSize: fontSize,
      color: color,
    );
  }
}
