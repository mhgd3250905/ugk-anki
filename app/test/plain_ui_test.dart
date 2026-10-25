import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugk_anki/app.dart';
import 'package:ugk_anki/data/clock.dart';
import 'package:ugk_anki/ui/cloze_controller.dart';
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

  group('填空输入框', () {
    test('光标不会停在隐藏记号里', () {
      final c = ClozeEditingController(text: '巴黎是{{c1::法国}}的首都');
      c.selection = const TextSelection.collapsed(offset: 5); // 在 {{c1:: 中间
      expect(c.selection.baseOffset, '巴黎是{{c1::'.length);
      c.selection = TextSelection.collapsed(
        offset: '巴黎是{{c1::法国}'.length,
      ); // 在 }} 中间
      expect(c.selection.baseOffset, '巴黎是{{c1::法国}}'.length);
    });

    test('在挖空边上删字 = 取消挖空，词保留', () {
      final c = ClozeEditingController(text: '巴黎是{{c1::法国}}的首都');
      const after = '巴黎是{{c1::法国}}';
      // 光标在挖空后面按退格，删掉的是隐藏的 }
      c.value = TextEditingValue(
        text: '巴黎是{{c1::法国}的首都',
        selection: TextSelection.collapsed(offset: after.length - 1),
      );
      expect(c.text, '巴黎是法国的首都');
      expect(c.selection.baseOffset, '巴黎是法国'.length);
    });

    test('普通输入不受影响', () {
      final c = ClozeEditingController(text: '{{c1::a}}');
      c.value = const TextEditingValue(
        text: '{{c1::a}}b',
        selection: TextSelection.collapsed(offset: 10),
      );
      expect(c.text, '{{c1::a}}b');
    });
  });

  testWidgets('添加页：填空不露记号，标签变成小标签，菜单是中文', (tester) async {
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
    // 没选中就点挖空：提示，不插入看不见的东西
    await tester.tap(find.byKey(const ValueKey('cloze')));
    await tester.pump();
    expect(find.textContaining('先在正文里选中'), findsOneWidget);
    final ctrl = tester.widget<EditableText>(field).controller;
    expect(ctrl.text, '巴黎是法国的首都');
    ctrl.selection = const TextSelection(baseOffset: 3, extentOffset: 5);
    await tester.tap(find.byKey(const ValueKey('cloze')));
    await tester.pump();
    expect(ctrl.text, '巴黎是{{c1::法国}}的首都');
    // 屏幕上画出来的只有「法国」（记号字号接近 0、透明）
    final span = ctrl.buildTextSpan(
      context: tester.element(field),
      withComposing: false,
    );
    final hidden = <String>[];
    span.visitChildren((s) {
      if (s is TextSpan && (s.style?.fontSize ?? 14) < 1) hidden.add(s.text!);
      return true;
    });
    expect(hidden, ['{{c1::', '}}']);

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
