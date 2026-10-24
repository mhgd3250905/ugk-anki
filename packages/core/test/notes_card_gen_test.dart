// packages/core/test/notes_card_gen_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  final basic = basicNoteType(1);
  final reversed = basicReversedNoteType(2);
  final cloze = clozeNoteType(3);

  group('内置笔记类型', () {
    test('Basic', () {
      expect(basic.name, 'Basic');
      expect(basic.kind, NoteKind.standard);
      expect(basic.fieldNames, ['Front', 'Back']);
      expect(basic.templates.length, 1);
      expect(basic.templates[0].qfmt, '{{Front}}');
      expect(basic.templates[0].afmt, '{{FrontSide}}<hr id=answer>{{Back}}');
    });
    test('Basic (and reversed card)', () {
      expect(reversed.name, 'Basic (and reversed card)');
      expect(reversed.templates.map((t) => t.name), ['Card 1', 'Card 2']);
      expect(reversed.templates[1].qfmt, '{{Back}}');
      expect(
          reversed.templates[1].afmt, '{{FrontSide}}<hr id=answer>{{Front}}');
    });
    test('Cloze', () {
      expect(cloze.kind, NoteKind.cloze);
      expect(cloze.fieldNames, ['Text', 'Back Extra']);
      expect(cloze.templates.single.qfmt, '{{cloze:Text}}');
      expect(cloze.templates.single.afmt, '{{cloze:Text}}<br>{{Back Extra}}');
    });
  });

  group('generateCardOrds', () {
    test('Basic', () {
      expect(generateCardOrds(basic, ['apple', '苹果']), [0]);
      expect(generateCardOrds(basic, ['', '苹果']), <int>[]);
      expect(generateCardOrds(basic, ['<br>', '苹果']), <int>[]);
    });
    test('Basic reversed', () {
      expect(generateCardOrds(reversed, ['apple', '苹果']), [0, 1]);
      expect(generateCardOrds(reversed, ['apple', '']), [0]);
      expect(generateCardOrds(reversed, ['', '苹果']), [1]);
      expect(generateCardOrds(reversed, ['', '']), <int>[]);
    });
    test('Cloze', () {
      expect(generateCardOrds(cloze, ['{{c1::a}} {{c3::b}}', '']), [0, 2]);
      expect(generateCardOrds(cloze, ['{{c2::a}}', '{{c1::extra}}']), [0, 1]);
      expect(generateCardOrds(cloze, ['no cloze', '']), <int>[]);
    });
    test('字段数量不对', () {
      expect(() => generateCardOrds(basic, ['only one']), throwsArgumentError);
    });
    test('条件模板', () {
      const t = NoteType(
        id: 9,
        name: 'Optional reverse',
        kind: NoteKind.standard,
        fields: [
          NoteField('Front', 0),
          NoteField('Back', 1),
          NoteField('Add Reverse', 2)
        ],
        templates: [
          CardTemplate(
              name: 'Card 1', ord: 0, qfmt: '{{Front}}', afmt: '{{Back}}'),
          CardTemplate(
              name: 'Card 2',
              ord: 1,
              qfmt: '{{#Add Reverse}}{{Back}}{{/Add Reverse}}',
              afmt: '{{Front}}'),
        ],
        css: '',
      );
      expect(generateCardOrds(t, ['a', 'b', '']), [0]);
      expect(generateCardOrds(t, ['a', 'b', 'y']), [0, 1]);
    });
  });

  group('renderCard', () {
    test('Basic 正反面', () {
      final c = renderCard(basic, ['apple', '苹果'], 0);
      expect(c.question, 'apple');
      expect(c.answer, 'apple<hr id=answer>苹果');
    });
    test('Basic reversed 第二张', () {
      final c = renderCard(reversed, ['apple', '苹果'], 1);
      expect(c.question, '苹果');
      expect(c.answer, '苹果<hr id=answer>apple');
    });
    test('Cloze', () {
      final c = renderCard(
          cloze, ['The {{c1::cat}} sat {{c2::here::where}}', 'extra'], 1);
      expect(c.question, 'The cat sat <span class="cloze">[where]</span>');
      expect(c.answer, 'The cat sat <span class="cloze">here</span><br>extra');
    });
    test('不存在的 ord', () {
      expect(() => renderCard(basic, ['a', 'b'], 5), throwsArgumentError);
    });
  });

  group('sortFieldValue', () {
    test('取 sortFieldIdx 字段去 HTML 并 trim', () {
      expect(sortFieldValue(basic, [' <b>Apple</b> ', 'x']), 'Apple');
    });
  });
}
