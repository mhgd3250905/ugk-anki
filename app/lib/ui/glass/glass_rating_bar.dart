import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/tokens.dart';

/// 底部操作区：「显示答案」与四个评分按钮之间淡入淡出。
/// 按钮是各自独立的中性玻璃（不融合、不染色），颜色只放在间隔文字上。
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
      height: UgkSize.actionHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Fade(
            visible: visible,
            child: _RatingButtons(labels: labels, onRate: onRate),
          ),
          _Fade(
            visible: !visible,
            child: _ShowAnswerButton(onTap: onShowAnswer),
          ),
        ],
      ),
    );
  }
}

class _Fade extends StatelessWidget {
  const _Fade({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: visible ? 1 : 0),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        builder: (context, value, child) =>
            LiquidGlassVisibility(visibility: value, child: child!),
        child: child,
      ),
    );
  }
}

class _ShowAnswerButton extends StatelessWidget {
  const _ShowAnswerButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: LiquidStretch(
        interactionScale: 0.98,
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(borderRadius: UgkRadius.button),
          child: GlassGlowLayer(
            child: GlassGlow(
              child: Center(
                child: Text(
                  '显示答案',
                  style: TextStyle(
                    color: color,
                    fontSize: UgkText.button,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({required this.labels, required this.onRate});

  final List<String> labels;
  final ValueChanged<int> onRate;

  static const _names = ['重来', '困难', '良好', '简单'];
  static const _colors = [
    UgkColors.again,
    UgkColors.hard,
    UgkColors.good,
    UgkColors.easy,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: UgkSpace.ratingGap),
          Expanded(
            child: _RatingButton(
              name: _names[i],
              interval: labels[i],
              color: _colors[i],
              onTap: () => onRate(i),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.name,
    required this.interval,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String interval;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: LiquidStretch(
        interactionScale: 0.96,
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(borderRadius: UgkRadius.button),
          child: GlassGlowLayer(
            child: GlassGlow(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    interval,
                    style: TextStyle(
                      color: color,
                      fontSize: UgkText.ratingInterval,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: UgkText.ratingName,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
