import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/backdrop.dart';
import '../theme/tokens.dart';

/// 所有页面共用的底：背景 + 铺满整屏的玻璃层 + SafeArea
class GlassPage extends StatelessWidget {
  const GlassPage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return Scaffold(
      backgroundColor: UgkColors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: UgkBackdrop()),
          Positioned.fill(
            child: LiquidGlassLayer(
              fake: UgkGlass.useFake,
              settings: LiquidGlassSettings.ios27Regular(
                brightness: brightness,
              ),
              defaultAppearance: LiquidGlassAppearance.ios27Regular(
                brightness: brightness,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UgkSpace.m,
                    UgkSpace.s,
                    UgkSpace.m,
                    UgkSpace.m,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 一块圆角玻璃面板
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(UgkSpace.m),
    this.radius = UgkRadius.bar,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      shape: LiquidRoundedSuperellipse(borderRadius: radius),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// 简单的页面标题栏：返回按钮 + 标题 + 右侧可选按钮
class GlassTitleRow extends StatelessWidget {
  const GlassTitleRow({
    required this.title,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      height: UgkSize.barHeight,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: UgkSpace.s)],
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
