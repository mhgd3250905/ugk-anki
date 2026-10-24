import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/tokens.dart';

/// 评分条：四个评分按钮与「显示答案」之间的淡入淡出
class GlassRatingBar extends StatelessWidget {
  const GlassRatingBar({
    required this.labels,
    required this.onRate,
    required this.visible,
    required this.onShowAnswer,
    super.key,
  });

  final List<String> labels;
  final ValueChanged<int> onRate;
  final bool visible;
  final VoidCallback onShowAnswer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: !visible,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: visible ? 1 : 0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) =>
                  LiquidGlassVisibility(visibility: value, child: child!),
              child: _RatingButtons(labels: labels, onRate: onRate),
            ),
          ),
          IgnorePointer(
            ignoring: visible,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1, end: visible ? 0 : 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) =>
                  LiquidGlassVisibility(visibility: value, child: child!),
              child: GestureDetector(
                onTap: onShowAnswer,
                child: LiquidGlass(
                  shape: const LiquidRoundedSuperellipse(
                    borderRadius: UgkRadius.button,
                  ),
                  child: SizedBox(
                    height: 64,
                    child: Center(
                      child: Text(
                        '显示答案',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: UgkText.button,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({required this.labels, required this.onRate});

  final List<String> labels;
  final ValueChanged<int> onRate;

  static const _names = ['Again', 'Hard', 'Good', 'Easy'];
  static const _colors = [
    UgkColors.again,
    UgkColors.hard,
    UgkColors.good,
    UgkColors.easy,
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return LiquidGlassBlendGroup(
      blend: 24,
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: UgkSpace.s),
            Expanded(
              child: _RatingButton(
                name: _names[i],
                label: labels[i],
                color: _colors[i],
                brightness: brightness,
                onTap: () => onRate(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.name,
    required this.label,
    required this.color,
    required this.brightness,
    required this.onTap,
  });

  final String name;
  final String label;
  final Color color;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = color.withValues(alpha: 0.35);
    final appearance = brightness == Brightness.dark
        ? LiquidGlassAppearance.ios27RegularDark(tint: tint)
        : LiquidGlassAppearance.ios27RegularLight(tint: tint);
    final textColor = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: LiquidStretch(
        interactionScale: 0.97,
        child: LiquidGlass.grouped(
          shape: const LiquidRoundedSuperellipse(
            borderRadius: UgkRadius.button,
          ),
          appearance: appearance,
          child: SizedBox(
            height: 64,
            child: GlassGlowLayer(
              child: GlassGlow(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: UgkText.button,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: UgkText.buttonHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
