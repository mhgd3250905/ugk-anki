import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../glass/glass_card.dart';
import '../glass/glass_rating_bar.dart';
import '../glass/glass_top_bar.dart';
import '../theme/backdrop.dart';
import '../theme/tokens.dart';
import 'fake_data.dart';

/// 复习页静态样稿
class ReviewPreviewScreen extends StatefulWidget {
  const ReviewPreviewScreen({super.key});

  @override
  State<ReviewPreviewScreen> createState() => _ReviewPreviewScreenState();
}

class _ReviewPreviewScreenState extends State<ReviewPreviewScreen> {
  bool showBack = false;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return Scaffold(
      backgroundColor: UgkColors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: UgkBackdrop()),
          // layer 铺满整屏，SafeArea 放在 layer 里面，避免采样区域出现矩形边界
          Positioned.fill(
            child: LiquidGlassLayer(
              fake: UgkGlass.useFake,
              settings: LiquidGlassSettings.ios27Regular(brightness: brightness),
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
                  child: Column(
                    children: [
                      GlassTopBar(
                        title: fakeDeckName,
                        newCount: fakeCounts.newCount,
                        learnCount: fakeCounts.learnCount,
                        reviewCount: fakeCounts.reviewCount,
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: UgkSpace.l),
                      Expanded(
                        child: GlassCard(
                          front: fakeFront,
                          back: fakeBack,
                          tag: fakeTag,
                          showBack: showBack,
                          onTap: () => setState(() => showBack = true),
                        ),
                      ),
                      const SizedBox(height: UgkSpace.l),
                      GlassRatingBar(
                        labels: fakeLabels,
                        visible: showBack,
                        onRate: (_) => setState(() => showBack = false),
                        onShowAnswer: () => setState(() => showBack = true),
                      ),
                    ],
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
