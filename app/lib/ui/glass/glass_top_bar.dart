import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/tokens.dart';
import 'glass_icon_button.dart';

/// 顶部栏：返回 | 卡组名 + 三个计数 | 更多。三块独立玻璃，不融合。
class GlassTopBar extends StatelessWidget {
  const GlassTopBar({
    required this.title,
    required this.newCount,
    required this.learnCount,
    required this.reviewCount,
    required this.onBack,
    super.key,
  });

  final String title;
  final int newCount;
  final int learnCount;
  final int reviewCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final deckName = title.split('::').last;
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        GlassIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
        const SizedBox(width: UgkSpace.s),
        Expanded(
          child: LiquidGlass(
            shape: const LiquidRoundedSuperellipse(borderRadius: UgkRadius.bar),
            child: SizedBox(
              height: UgkSize.barHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: UgkSpace.m),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        deckName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: UgkText.barTitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _Count(value: newCount, color: UgkColors.newBlue),
                    const SizedBox(width: UgkSpace.s + 2),
                    _Count(value: learnCount, color: UgkColors.learnRed),
                    const SizedBox(width: UgkSpace.s + 2),
                    _Count(value: reviewCount, color: UgkColors.reviewGreen),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: UgkSpace.s),
        GlassIconButton(icon: Icons.more_horiz, onTap: () {}),
      ],
    );
  }
}

/// 计数：小圆点 + 数字
class _Count extends StatelessWidget {
  const _Count({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: UgkSpace.xs + 1),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: UgkText.count,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
