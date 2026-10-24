// packages/core/test/notes_template_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  const f = {'Front': 'apple', 'Back': '苹果', 'Empty': '', 'Html': '<b>hi</b>'};

  group('renderTemplate 基本替换', () {
    test('字段替换', () {
      final r = renderTemplate('Q: {{Front}}', f);
      expect(r.text, 'Q: apple');
      expect(r.usedNonEmptyField, true);
    });
    test('标签内空格会 trim', () {
      expect(renderTemplate('{{ Front }}', f).text, 'apple');
    });
    test('不存在的字段输出空', () {
      final r = renderTemplate('[{{Nope}}]', f);
      expect(r.text, '[]');
      expect(r.usedNonEmptyField, false);
    });
    test('空字段不算 used', () {
      final r = renderTemplate('Q: {{Empty}}', f);
      expect(r.text, 'Q: ');
      expect(r.usedNonEmptyField, false);
    });
    test('没有任何标签', () {
      final r = renderTemplate('static text', f);
      expect(r.text, 'static text');
      expect(r.usedNonEmptyField, false);
    });
    test('text: 过滤器', () {
      expect(renderTemplate('{{text:Html}}', f).text, 'hi');
      expect(renderTemplate('{{Html}}', f).text, '<b>hi</b>');
    });
    test('FrontSide', () {
      final r = renderTemplate('{{FrontSide}}<hr id=answer>{{Back}}', f,
          frontSide: 'apple');
      expect(r.text, 'apple<hr id=answer>苹果');
      expect(renderTemplate('{{FrontSide}}', f).text, '');
      expect(
          renderTemplate('{{FrontSide}}', f, frontSide: 'x').usedNonEmptyField,
          false);
    });
  });

  group('区段', () {
    test('#字段非空才显示', () {
      expect(renderTemplate('{{#Back}}B={{Back}}{{/Back}}', f).text, 'B=苹果');
      expect(renderTemplate('{{#Empty}}E={{Empty}}{{/Empty}}', f).text, '');
    });
    test('^字段为空才显示', () {
      expect(renderTemplate('{{^Empty}}none{{/Empty}}', f).text, 'none');
      expect(renderTemplate('{{^Back}}none{{/Back}}', f).text, '');
    });
    test('嵌套', () {
      const t = '{{#Front}}F{{#Back}}B{{/Back}}{{^Empty}}e{{/Empty}}{{/Front}}';
      expect(renderTemplate(t, f).text, 'FBe');
    });
    test('隐藏区段里的字段不算 used', () {
      final r = renderTemplate('{{#Empty}}{{Front}}{{/Empty}}', f);
      expect(r.text, '');
      expect(r.usedNonEmptyField, false);
    });
    test('不存在的字段当空字段', () {
      expect(renderTemplate('{{#Nope}}x{{/Nope}}{{^Nope}}y{{/Nope}}', f).text,
          'y');
    });
    test('格式错误', () {
      expect(() => renderTemplate('{{#Front}}x', f), throwsFormatException);
      expect(() => renderTemplate('x{{/Front}}', f), throwsFormatException);
      expect(() => renderTemplate('{{#Front}}x{{/Back}}', f),
          throwsFormatException);
    });
  });

  group('cloze', () {
    test('clozeNumbers', () {
      expect(clozeNumbers('no cloze'), <int>{});
      expect(clozeNumbers('{{c1::a}} {{c2::b}} {{c1::c}}'), {1, 2});
      expect(clozeNumbers('{{c3::x::hint}}'), {3});
      expect(clozeNumbers('{{c0::x}}'), <int>{});
      expect(clozeNumbers('{{c12::x}}'), {12});
    });
    test('renderCloze 正面', () {
      const t = 'The {{c1::cat}} sat on the {{c2::mat::thing}}.';
      expect(renderCloze(t, 1, answer: false),
          'The <span class="cloze">[...]</span> sat on the mat.');
      expect(renderCloze(t, 2, answer: false),
          'The cat sat on the <span class="cloze">[thing]</span>.');
    });
    test('renderCloze 背面', () {
      const t = 'The {{c1::cat}} sat on the {{c2::mat::thing}}.';
      expect(renderCloze(t, 1, answer: true),
          'The <span class="cloze">cat</span> sat on the mat.');
      expect(renderCloze(t, 2, answer: true),
          'The cat sat on the <span class="cloze">mat</span>.');
    });
    test('同编号出现两次都挖空', () {
      expect(renderCloze('{{c1::a}}-{{c1::b}}', 1, answer: false),
          '<span class="cloze">[...]</span>-<span class="cloze">[...]</span>');
    });
    test('cloze: 过滤器', () {
      const m = {'Text': 'x {{c1::y}} {{c2::z}}'};
      final q = renderTemplate('{{cloze:Text}}', m, clozeOrd: 2);
      expect(q.text, 'x y <span class="cloze">[...]</span>');
      expect(q.usedNonEmptyField, true);
      final missing = renderTemplate('{{cloze:Text}}', m, clozeOrd: 3);
      expect(missing.text, 'x y z');
      expect(missing.usedNonEmptyField, false);
      expect(renderTemplate('{{cloze:Text}}', m).text, 'x {{c1::y}} {{c2::z}}');
    });
  });
}
