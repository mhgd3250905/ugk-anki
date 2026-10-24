import 'cloze.dart';
import 'fields.dart';
import 'note_type.dart';
import 'template.dart';

/// 由字段生成应存在的卡片序号（0 开始，升序）
List<int> generateCardOrds(NoteType type, List<String> fields) {
  final map = _fieldMap(type, fields);
  if (type.kind == NoteKind.cloze) {
    final numbers = <int>{};
    for (final field in fields) {
      numbers.addAll(clozeNumbers(field));
    }
    final ords = [for (final n in numbers) n - 1];
    ords.sort();
    return ords;
  }
  final ords = <int>[];
  for (final template in type.templates) {
    final result = renderTemplate(template.qfmt, map);
    if (result.usedNonEmptyField) ords.add(template.ord);
  }
  ords.sort();
  return ords;
}

/// 渲染出的卡片正反面
class RenderedCard {
  final String question;
  final String answer;
  const RenderedCard(this.question, this.answer);
}

/// 渲染指定序号的卡片正反面
RenderedCard renderCard(NoteType type, List<String> fields, int ord) {
  final map = _fieldMap(type, fields);
  if (type.kind == NoteKind.cloze) {
    final template = type.templates[0];
    final question = renderTemplate(
      template.qfmt,
      map,
      clozeOrd: ord + 1,
    );
    final answer = renderTemplate(
      template.afmt,
      map,
      clozeOrd: ord + 1,
      answer: true,
      frontSide: question.text,
    );
    return RenderedCard(question.text, answer.text);
  }
  CardTemplate? template;
  for (final candidate in type.templates) {
    if (candidate.ord == ord) {
      template = candidate;
      break;
    }
  }
  if (template == null) throw ArgumentError('找不到模板 ord: $ord');
  final question = renderTemplate(template.qfmt, map);
  final answer = renderTemplate(
    template.afmt,
    map,
    frontSide: question.text,
    answer: true,
  );
  return RenderedCard(question.text, answer.text);
}

/// 取 sortFieldIdx 字段，去 HTML 并 trim
String sortFieldValue(NoteType type, List<String> fields) {
  _fieldMap(type, fields);
  return stripHtml(fields[type.sortFieldIdx]).trim();
}

Map<String, String> _fieldMap(NoteType type, List<String> fields) {
  if (fields.length != type.fields.length) {
    throw ArgumentError(
      '字段数量不对: ${fields.length} != ${type.fields.length}',
    );
  }
  return {for (final field in type.fields) field.name: fields[field.ord]};
}
