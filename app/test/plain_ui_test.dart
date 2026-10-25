import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugk_anki/app.dart';
import 'package:ugk_anki/data/clock.dart';
import 'package:ugk_anki/ui/card_text.dart';
import 'package:ugk_anki/ui/cloze_picker.dart';
import 'package:ugk_anki/ui/labels.dart';
import 'package:ugk_data/ugk_data.dart';

void main() {
  test('复习间隔显示中文', () {
    expect(zhInterval('<1m'), '1分钟后');
    expect(zhInterval('<10m'), '10分钟后');
    expect(zhInterval('<2h'), '2小时后');
    expect(zhInterval('4d'), '4天后');
    expect(zhInterval('1.5mo'), '1.5个月后');
    expect(zhInterval('2y'), '2年后');
  });

  test('标签按空格、逗号、顿号拆分', () {
    expect(splitTags('街舞, 邀约，口语、 英语'), ['街舞', '邀约', '口语', '英语']);
  });

  group('点字挖空', () {
    test('中文一字一块，英文一词一块，标点不可点', () {
      final t = clozeTokens('Paris 是法国，的');
      expect([for (final x in t) x.text], ['Paris', '是', '法', '国', '，', '的']);
      expect(t[4].pickable, isFalse);
    });

    test('连着的字合成一处挖空，分开的各算一处', () {
      expect(buildClozeText('巴黎是法国的首都', {3, 4}), '巴黎是{{c1::法国}}的首都');
      expect(
        buildClozeText('巴黎是法国的首都', {0, 1, 6, 7}),
        '{{c1::巴黎}}是法国的{{c2::首都}}',
      );
      // 英文词之间隔空格也算连着
      final t = 'I love New York';
      final picked = {for (var i = 7; i < 15; i++) i}..remove(10);
      expect(buildClozeText(t, picked), 'I love {{c1::New York}}');
    });

    test('改正文时尽量保留选中', () {
      // 在前面加字，选中跟着往后挪
      expect(shiftPicked('法国的首都', '巴黎是法国的首都', {0, 1}), {3, 4});
      // 改掉被选的字，选中取消
      expect(shiftPicked('巴黎是法国', '巴黎是德国', {3, 4}), {4});
    });

    test('复习时 [...] 显示成横线', () {
      expect(
        cardPlainText('巴黎是<span class=cloze>[...]</span>的首都'),
        '巴黎是＿＿＿的首都',
      );
    });
  });

  testWidgets('添加页：点字挖空，标签变成小标签，菜单是中文', (tester) async {
    late UgkDatabase db;
    await tester.runAsync(() async {
      db = UgkDatabase(NativeDatabase.memory());
      await UgkRepository(db).initIfEmpty(nowMs: nowMs());
    });
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Future<void> settle() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(UgkAnkiApp(repo: UgkRepository(db)));
    await settle();
    expect(
      Localizations.localeOf(tester.element(find.byType(Scaffold).first)),
      const Locale('zh', 'CN'),
    );

    await tester.tap(find.byIcon(Icons.add));
    await settle();
    await tester.tap(find.text('填空'));
    await tester.pumpAndSettle();

    final field = find.descendant(
      of: find.byKey(ValueKey('field-$kClozeTypeId-0')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, '巴黎是法国的首都');
    await tester.pump();
    // 正文下面出现一个个字块，点「法」「国」
    await tester.tap(find.byKey(const ValueKey('tok-3')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tok-4')));
    await tester.pump();
    expect(find.text('复习时会这样考：巴黎是＿＿＿的首都'), findsOneWidget);
    // 正文本身不变，界面上没有任何记号
    expect(tester.widget<EditableText>(field).controller.text, '巴黎是法国的首都');
    expect(find.textContaining('{{'), findsNothing);
    // 再点一下取消
    await tester.tap(find.byKey(const ValueKey('tok-4')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tok-4')));
    await tester.pump();

    final tags = find.descendant(
      of: find.byKey(const ValueKey('tags')),
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(tags);
    await tester.enterText(tags, '地理 ');
    await tester.pump();
    expect(find.text('地理'), findsOneWidget); // 变成小标签
    expect(tester.widget<EditableText>(tags).controller.text, '');

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => db.close());
    await tester.pump(const Duration(seconds: 3));
  });
}
