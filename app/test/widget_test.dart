import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugk_anki/app.dart';
import 'package:ugk_anki/data/clock.dart';
import 'package:ugk_anki/ui/card_text.dart';
import 'package:ugk_data/ugk_data.dart';

void main() {
  group('card_text', () {
    test('正面去掉 HTML', () {
      expect(cardPlainText('<b>hello</b><br>world'), 'hello\nworld');
    });
    test('背面只取分隔线之后', () {
      expect(answerPlainText('hello<hr id=answer>你好'), '你好');
      expect(
        answerPlainText('<span class="cloze">Paris</span> is<br>'),
        'Paris is',
      );
    });
    test('标签行', () {
      expect(tagLine(' 街舞 邀约 '), '街舞 · 邀约');
      expect(tagLine(''), '');
    });
  });

  testWidgets('首页 → 复习 → 评分', (tester) async {
    late UgkDatabase db;
    late UgkRepository repo;
    await tester.runAsync(() async {
      db = UgkDatabase(NativeDatabase.memory());
      repo = UgkRepository(db);
      await repo.initIfEmpty(nowMs: nowMs());
      await repo.addNote(
        noteTypeId: kBasicTypeId,
        deckId: kDefaultDeckId,
        fields: ['hello', '你好'],
        tags: ['街舞'],
        nowMs: nowMs(),
      );
    });

    await tester.pumpWidget(UgkAnkiApp(repo: repo));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    expect(find.text('卡组'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('街舞'), findsOneWidget);

    await tester.tap(find.text('hello'));
    await tester.pumpAndSettle();
    expect(find.text('你好'), findsOneWidget);
    expect(find.text('<10m'), findsOneWidget);

    expect(find.text('4d'), findsOneWidget);
    await tester.tap(find.text('简单'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(find.text('完成 🎉'), findsOneWidget);

    await tester.runAsync(() async {
      final card = (await repo.cardsOfDeck(kDefaultDeckId)).single;
      expect(card.reps, 1);
      expect((await repo.revlogOf(card.id)).length, 1);
    });

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => db.close());
  });

  testWidgets('新建卡组弹窗 + 添加页选卡组 + 提示条', (tester) async {
    late UgkDatabase db;
    late UgkRepository repo;
    await tester.runAsync(() async {
      db = UgkDatabase(NativeDatabase.memory());
      repo = UgkRepository(db);
      await repo.initIfEmpty(nowMs: nowMs());
    });
    Future<void> settle() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
    }

    Finder editable(Key key) => find.descendant(
      of: find.byKey(key),
      matching: find.byType(EditableText),
    );

    await tester.pumpWidget(UgkAnkiApp(repo: repo));
    await settle();

    await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
    await tester.pumpAndSettle();
    expect(find.text('新建卡组'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.enterText(editable(const ValueKey('prompt-field')), 'English::Dance');
    await tester.tap(find.text('创建'));
    await settle();
    expect(find.text('Dance'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await settle();
    await tester.tap(find.byKey(const ValueKey('deck-select')));
    await tester.pumpAndSettle();
    expect(find.text('选择卡组'), findsOneWidget);
    await tester.tap(find.text('English::Dance').last);
    await tester.pumpAndSettle();
    expect(find.text('选择卡组'), findsNothing);
    expect(find.text('English::Dance'), findsOneWidget);

    await tester.enterText(editable(const ValueKey('field-$kBasicTypeId-0')), 'hi');
    await tester.enterText(editable(const ValueKey('field-$kBasicTypeId-1')), '嗨');
    await tester.tap(find.byKey(const ValueKey('save')));
    await settle();
    expect(find.text('已添加 1 张卡片'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('已添加 1 张卡片'), findsNothing);

    await tester.runAsync(() async {
      final dance = (await repo.decks()).firstWhere(
        (d) => d.name == 'English::Dance',
      );
      expect((await repo.cardsOfDeck(dance.id)).length, 1);
    });

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => db.close());
  });
}
