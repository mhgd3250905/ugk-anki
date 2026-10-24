import 'package:flutter/material.dart';

/// 颜色令牌
class UgkColors {
  static const newBlue = Color(0xFF0A84FF);
  static const learnRed = Color(0xFFFF453A);
  static const reviewGreen = Color(0xFF30D158);

  static const again = Color(0xFFFF453A);
  static const hard = Color(0xFFFF9F0A);
  static const good = Color(0xFF30D158);
  static const easy = Color(0xFF0A84FF);

  static const lightBackdrop = [
    Color(0xFFFFD6E8),
    Color(0xFFC9E4FF),
    Color(0xFFD9FFE9),
  ];
  static const darkBackdrop = [
    Color(0xFF1B1035),
    Color(0xFF0B2A4A),
    Color(0xFF07332A),
  ];
}

/// 圆角令牌
class UgkRadius {
  static const card = 32.0;
  static const button = 28.0;
  static const bar = 26.0;
}

/// 间距令牌
class UgkSpace {
  static const xs = 4.0, s = 8.0, m = 16.0, l = 24.0, xl = 32.0;
}

/// 字号令牌
class UgkText {
  static const cardFront = 30.0,
      cardBack = 20.0,
      button = 15.0,
      buttonHint = 12.0,
      barTitle = 17.0;
}
