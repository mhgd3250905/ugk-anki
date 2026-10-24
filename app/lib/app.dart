import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/screens/review_preview_screen.dart';
import 'ui/theme/tokens.dart';

/// ugk-anki 应用
class UgkAnkiApp extends StatelessWidget {
  const UgkAnkiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ugk-anki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const ReviewPreviewScreen(),
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
          child: child!,
        );
      },
    );
  }
}
