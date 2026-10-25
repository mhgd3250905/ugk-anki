import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugk_anki/app.dart';
import 'package:ugk_anki/data/clock.dart';
import 'package:ugk_anki/ui/labels.dart';
import 'package:ugk_core/ugk_core.dart' hide Card;
import 'package:ugk_data/ugk_data.dart';

void main() {
  group('挖空按钮', () {
    test('选中文字 → {{c1::…}}，光标到后面', () {
      final v = applyCloze(
        const TextEditingValue(
          text: '巴黎是法国的首都',
          selection: TextSelection(baseOffset: 3, extentOffset: 5),
        ),
      );
      expect(v.text, '巴黎是{{c1::法国}}的首都');
      expect(v.selection.baseOffset, '巴黎是{{c1::法国}}'.length);
    });

    test('已有 c1、c3 时用 c4；没选中时插入空挖空，光标在里面', () {
      final v = applyCloze(
        const TextEditingValue(
          text: '{{c1::a}} {{c3::b}} ',
          selection: TextSelection.collapsed(offset: 20),
        ),
      );
      expect(v.text, '{{c1::a}} {{c3::b}} {{c4::}}');
      expect(v.selection.baseOffset, '{{c1::a}} {{c3::b}} {{c4::'.length);
    });
  });

  group('添加前检查', () {
    final basic = basicNoteType(1);
    final cloze = clozeNoteType(3);

    test('问答：正面空', () {
      expect(addNoteProblem(basic, ['  ', 'x']), '正面还没填');
      expect(addNoteProblem(basic, ['q', '']), isNull);
    });

    test('填空：正文空 / 没挖空 / 正常', () {
      expect(addNoteProblem(cloze, ['', '']), '正文还没填');
      expect(addNoteProblem(cloze, ['巴黎', '']), contains('挖空'));
      expect(addNoteProblem(cloze, ['{{c1::巴黎}}', '']), isNull);
    });

    test('中文名', () {
      expect(typeLabel(basic), '问答');
      expect(typeLabel(cloze), '填空');
      expect(fieldLabel('Back Extra'), '补充说明');
      expect(fieldLabel('自定义'), '自定义');
    });
  });

  testWidgets('软键盘弹出时，弹窗按钮在键盘上方', (tester) async {
    late UgkDatabase db;
    await tester.runAsync(() async {
      db = UgkDatabase(NativeDatabase.memory());
      await UgkRepository(db).initIfEmpty(nowMs: nowMs());
    });
    // 普通手机尺寸（390×844，3 倍屏），键盘约 320
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(UgkAnkiApp(repo: UgkRepository(db)));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
    await tester.pumpAndSettle();
    final dpr = tester.view.devicePixelRatio;
    final screenH = tester.view.physicalSize.height / dpr;
    const keyboard = 320.0;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard * dpr);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    final create = tester.getRect(find.text('创建'));
    expect(create.bottom, lessThanOrEqualTo(screenH - keyboard));

    tester.view.resetViewInsets();
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => db.close());
  });
}
