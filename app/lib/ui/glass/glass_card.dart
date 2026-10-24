import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/tokens.dart';

/// 可翻面的玻璃卡片
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
    final screen = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: screen.width - UgkSpace.l * 2,
        height: screen.height * 0.5,
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(borderRadius: UgkRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(UgkSpace.l),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              layoutBuilder: (currentChild, previousChildren) => Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [...previousChildren, ?currentChild],
              ),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: showBack
                  ? _BackFace(
                      front: front,
                      back: back,
                      tag: tag,
                      key: const ValueKey('back'),
                    )
                  : _FrontFace(front: front, key: const ValueKey('front')),
            ),
          ),
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
    return Center(
      child: Text(
        front,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: UgkText.cardFront,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace({
    required this.front,
    required this.back,
    required this.tag,
    super.key,
  });

  final String front;
  final String back;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          front,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: UgkSpace.m),
        Container(height: 1, color: color.withValues(alpha: 0.2)),
        const SizedBox(height: UgkSpace.m),
        Expanded(
          child: Center(
            child: Text(
              back,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: UgkText.cardBack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UgkSpace.m,
              vertical: UgkSpace.xs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(UgkRadius.button),
            ),
            child: Text(tag, style: TextStyle(color: color, fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
