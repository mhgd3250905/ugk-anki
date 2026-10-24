import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'app.dart';
import 'data/app_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.precache();
  final repo = await openRepository();
  runApp(UgkAnkiApp(repo: repo));
}
