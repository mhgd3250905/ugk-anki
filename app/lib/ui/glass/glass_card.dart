import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/tokens.dart';

/// 可翻面的玻璃卡片：撑满父级给的空间（由页面决定尺寸和留白）
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.front,
    required this.back,
    required this.tag,
    required this.showBack,
    required this.onTap,
    super.key,
  });

  final String front;
  final String back;
  final String tag;
  final bool showBack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: LiquidGlass(
        shape: const LiquidRoundedSuperellipse(borderRadius: UgkRadius.card),
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              UgkSpace.l,
              UgkSpace.l - 4,
              UgkSpace.l,
              UgkSpace.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerLeft, child: _Tag(tag)),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (current, previous) => Stack(
                      fit: StackFit.expand,
                      children: [...previous, ?current],
                    ),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.98, end: 1)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: showBack
                        ? _BackFace(
                            front: front,
                            back: back,
                            key: const ValueKey('back'),
                          )
                        : _FrontFace(front: front, key: const ValueKey('front')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(UgkRadius.pill),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withValues(alpha: 0.6),
          fontSize: UgkText.tag,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.front, super.key});

  final String front;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              front,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: UgkText.cardFront,
                fontWeight: FontWeight.w600,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
        Text(
          '轻点卡片显示答案',
          style: TextStyle(
            color: color.withValues(alpha: 0.35),
            fontSize: UgkText.hint,
          ),
        ),
      ],
    );
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace({required this.front, required this.back, super.key});

  final String front;
  final String back;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: UgkSpace.m),
        Text(
          front,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color.withValues(alpha: 0.5),
            fontSize: UgkText.cardBackQuestion,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: UgkSpace.m),
        Center(
          child: Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              back,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: UgkText.cardBack,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
