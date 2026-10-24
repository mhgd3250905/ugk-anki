import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// 圆形玻璃图标按钮
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        shape: const LiquidOval(),
        child: SizedBox.square(
          dimension: 44,
          child: GlassGlowLayer(child: GlassGlow(child: Icon(icon, size: 20))),
        ),
      ),
    );
  }
}
