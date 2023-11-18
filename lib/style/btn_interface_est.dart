// button_styles.dart

import 'package:flutter/material.dart';

class ButtonStyles {
  static ButtonStyle elevatedButtonStyle({
    required Color backgroundColor,
    required double fontSize,
  }) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(8.0),
       backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  static ButtonStyle outlinedButtonStyle({
    required Color backgroundColor,
    required double fontSize,
  }) {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
