import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/tokens.dart';

/// 圆形玻璃图标按钮
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: LiquidStretch(
        interactionScale: 0.94,
        child: LiquidGlass(
          shape: const LiquidOval(),
          child: SizedBox.square(
            dimension: UgkSize.barHeight,
            child: GlassGlowLayer(
              child: GlassGlow(
                child: Icon(icon, size: 18, color: color.withValues(alpha: 0.85)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
