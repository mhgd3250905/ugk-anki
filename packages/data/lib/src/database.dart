import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

/// ugk-anki 数据库
@DriftDatabase(
  tables: [
    CollectionMeta,
    DeckConfigs,
    Decks,
    NoteTypes,
    Notes,
    Cards,
    Revlog,
    DeckDayCounts,
  ],
)
class UgkDatabase extends _$UgkDatabase {
  /// 用给定的执行器打开（App 里用 drift_flutter，测试里用 NativeDatabase.memory()）
  UgkDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
