import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ugk_data/ugk_data.dart';

import 'data/repo_scope.dart';
import 'ui/screens/deck_list_screen.dart';
import 'ui/theme/tokens.dart';

/// ugk-anki 应用
class UgkAnkiApp extends StatelessWidget {
  const UgkAnkiApp({required this.repo, super.key});

  final UgkRepository repo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ugk-anki',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const DeckListScreen(),
      builder: (context, child) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        final iconBrightness = brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: UgkColors.transparent,
            statusBarIconBrightness: iconBrightness,
            statusBarBrightness: brightness,
            systemNavigationBarColor: UgkColors.transparent,
            systemNavigationBarIconBrightness: iconBrightness,
          ),
          child: RepoScope(repo: repo, child: child!),
        );
      },
    );
  }
}

/// 统一主题：主色用我们的蓝，去掉 Material 水波纹，光标和选区也用蓝色
ThemeData _theme(Brightness brightness) => ThemeData(
  useMaterial3: true,
  brightness: brightness,
  colorScheme: ColorScheme.fromSeed(
    seedColor: UgkColors.newBlue,
    brightness: brightness,
  ),
  splashFactory: NoSplash.splashFactory,
  highlightColor: UgkColors.transparent,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: UgkColors.newBlue,
    selectionColor: UgkColors.newBlue.withValues(alpha: 0.25),
    selectionHandleColor: UgkColors.newBlue,
  ),
);
