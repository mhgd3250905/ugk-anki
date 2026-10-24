import 'package:flutter/material.dart';

/// 颜色令牌（M0.1 重做：降低饱和度，背景只用两种冷暖光斑）
class UgkColors {
  static const transparent = Color(0x00000000);

  // 计数（新 / 学习 / 复习）
  static const newBlue = Color(0xFF3B82F6);
  static const learnRed = Color(0xFFEF4444);
  static const reviewGreen = Color(0xFF10B981);

  // 评分（只用于文字和小圆点，不再给整个按钮染色）
  static const again = Color(0xFFEF4444);
  static const hard = Color(0xFFF59E0B);
  static const good = Color(0xFF10B981);
  static const easy = Color(0xFF3B82F6);

  // 背景：浅色是暖白到淡蓝紫，深色是墨蓝
  static const lightBackdrop = [
    Color(0xFFF7F4EF),
    Color(0xFFEDEBFA),
    Color(0xFFE4EEF9),
  ];
  static const darkBackdrop = [
    Color(0xFF0B0E1A),
    Color(0xFF111833),
    Color(0xFF0A1424),
  ];

  // 背景光斑
  static const lightGlowA = Color(0xFF8B9CFF); // 靛蓝
  static const lightGlowB = Color(0xFFFFB38A); // 杏色
  static const darkGlowA = Color(0xFF4F46E5); // 靛紫
  static const darkGlowB = Color(0xFF0EA5A4); // 青
}

/// 圆角令牌
class UgkRadius {
  static const card = 36.0;
  static const button = 22.0;
  static const bar = 22.0;
  static const pill = 999.0;
  static const field = 14.0;
}

/// 间距令牌
class UgkSpace {
  static const xs = 4.0, s = 8.0, m = 16.0, l = 24.0, xl = 32.0;
  static const ratingGap = 10.0;
}

/// 尺寸令牌
class UgkSize {
  static const barHeight = 44.0;
  static const actionHeight = 60.0;
}

/// 字号令牌
class UgkText {
  static const cardFront = 28.0,
      cardBackQuestion = 16.0,
      cardBack = 24.0,
      hint = 13.0,
      tag = 12.0,
      button = 16.0,
      ratingInterval = 15.0,
      ratingName = 12.0,
      barTitle = 16.0,
      count = 14.0,
      field = 16.0,
      dialogTitle = 20.0;
}

/// 玻璃渲染开关
class UgkGlass {
  /// true = FakeGlass（稳定，无伪影）；false = Flutter GPU 全玻璃。
  /// liquid_glass_renderer 1.0.0-dev.1 在部分 Android 真机上有矩形色带，
  /// 先默认 FakeGlass，等库稳定再切回。
  static const useFake = true;
}
