import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/tokens.dart';
import 'glass_icon_button.dart';

/// 顶部玻璃栏：返回、卡组名和计数、更多
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
    return LiquidGlassBlendGroup(
      blend: 20,
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
          const SizedBox(width: UgkSpace.s),
          Expanded(
            child: LiquidGlass.grouped(
              shape: const LiquidRoundedSuperellipse(
                borderRadius: UgkRadius.bar,
              ),
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
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
                    const SizedBox(width: UgkSpace.s),
                    _CountText(value: newCount, color: UgkColors.newBlue),
                    const SizedBox(width: UgkSpace.xs),
                    _CountText(value: learnCount, color: UgkColors.learnRed),
                    const SizedBox(width: UgkSpace.xs),
                    _CountText(
                      value: reviewCount,
                      color: UgkColors.reviewGreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: UgkSpace.s),
          GlassIconButton(icon: Icons.more_horiz, onTap: () {}),
        ],
      ),
    );
  }
}

class _CountText extends StatelessWidget {
  const _CountText({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: TextStyle(
        color: color,
        fontSize: UgkText.button,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
