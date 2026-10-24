import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugk_anki/app.dart';
import 'package:ugk_anki/data/app_files.dart';
import 'package:ugk_anki/data/clock.dart';
import 'package:ugk_data/ugk_data.dart';

class FakeFiles implements AppFiles {
  PickedFile? next;
  final saved = <String, Uint8List>{};

  @override
  Future<PickedFile?> pick() async => next;

  @override
  Future<bool> save(String fileName, Uint8List bytes, String mimeType) async {
    saved[fileName] = bytes;
    return true;
  }
}

void main() {
  late UgkDatabase db;
  late UgkRepository repo;
  late FakeFiles files;

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> finishToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  Future<void> menu(WidgetTester tester, int i) async {
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    expect(find.text('数据'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('action-$i')));
    await settle(tester);
  }

  setUp(() {
    files = FakeFiles();
    AppFiles.instance = files;
  });

  testWidgets('导入 CSV：选文件 → 设置页 → 导入 → 提示条 → 计数', (tester) async {
    await tester.runAsync(() async {
      db = UgkDatabase(NativeDatabase.memory());
      repo = UgkRepository(db);
      await repo.initIfEmpty(nowMs: nowMs());
    });
    files.next = PickedFile(
      'words.csv',
      Uint8List.fromList(utf8.encode('hello,你好,街舞\nbye,再见,\n')),
    );
    await tester.pumpWidget(UgkAnkiApp(repo: repo));
    await settle(tester);

    await menu(tester, 0);
    expect(find.text('words.csv'), findsOneWidget);
    expect(find.text('2 行 · 3 列 · 分隔符 逗号'), findsOneWidget);
    expect(find.text('第 1 列 · hello'), findsOneWidget);
    expect(find.text('第 2 列 · 你好'), findsOneWidget);

    // 标签列手动选第 3 列
    await tester.ensureVisible(find.byKey(const ValueKey('map-tags')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('map-tags')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('第 3 列 · 街舞').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('do-import')));
    await settle(tester);
    expect(find.text('导入 2 条笔记（2 张卡片）'), findsOneWidget);
    await finishToast(tester);
    expect(find.text('2'), findsOneWidget); // Default 新卡数

    await tester.runAsync(() async {
      final cards = await repo.cardsOfDeck(kDefaultDeckId);
      expect(await repo.noteTags(cards.first.noteId), ' 街舞 ');
    });

    // 再导一次全部重复
    await menu(tester, 0);
    await tester.tap(find.byKey(const ValueKey('do-import')));
    await settle(tester);
    expect(find.text('导入 0 条笔记（0 张卡片），跳过重复 2'), findsOneWidget);
    await finishToast(tester);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => db.close());
  });

  testWidgets('导出、备份、确认弹窗后恢复', (tester) async {
    await tester.runAsync(() async {
      db = UgkDatabase(NativeDatabase.memory());
      repo = UgkRepository(db);
      await repo.initIfEmpty(nowMs: nowMs());
      await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['a', 'b'],
        nowMs: nowMs(),
      );
    });
    await tester.pumpWidget(UgkAnkiApp(repo: repo));
    await settle(tester);

    await menu(tester, 1);
    expect(find.text('已导出 1 条笔记'), findsOneWidget);
    await finishToast(tester);
    expect(files.saved.keys.single, endsWith('.txt'));

    await menu(tester, 2);
    expect(find.text('备份已保存'), findsOneWidget);
    await finishToast(tester);
    final backupName = files.saved.keys.firstWhere((k) => k.endsWith('.json'));

    await tester.runAsync(() => repo.createDeck('Later', nowMs: nowMs()));
    files.next = PickedFile(backupName, files.saved[backupName]!);

    // 取消不恢复
    await menu(tester, 3);
    expect(find.text('从备份恢复？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await settle(tester);
    expect(find.text('Later'), findsOneWidget);

    // 确认后恢复
    await menu(tester, 3);
    await tester.tap(find.byKey(const ValueKey('confirm')));
    await settle(tester);
    expect(find.text('已从备份恢复'), findsOneWidget);
    await finishToast(tester);
    expect(find.text('Later'), findsNothing);

    // 坏文件：提示，不动库
    files.next = PickedFile('bad.json', Uint8List.fromList(utf8.encode('{}')));
    await menu(tester, 3);
    await tester.tap(find.byKey(const ValueKey('confirm')));
    await settle(tester);
    expect(find.text('不是 ugk-anki 备份文件'), findsOneWidget);
    await finishToast(tester);
    expect(find.text('Default'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => db.close());
  });
}
