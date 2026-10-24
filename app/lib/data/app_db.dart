import 'package:drift_flutter/drift_flutter.dart';
import 'package:ugk_data/ugk_data.dart';

import 'clock.dart';

/// 打开手机上的数据库并完成首次初始化
Future<UgkRepository> openRepository() async {
  final db = UgkDatabase(driftDatabase(name: 'ugk_anki'));
  final repo = UgkRepository(db);
  await repo.initIfEmpty(nowMs: nowMs());
  return repo;
}
