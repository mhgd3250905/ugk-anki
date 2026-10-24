import 'cloze.dart';
import 'fields.dart';

/// 模板渲染结果
class RenderResult {
  final String text;
  final bool usedNonEmptyField;
  const RenderResult(this.text, this.usedNonEmptyField);
}

final RegExp _tagPattern = RegExp(r'\{\{(.*?)\}\}', dotAll: true);

/// 渲染 Anki 模板
RenderResult renderTemplate(
  String template,
  Map<String, String> fields, {
  String? frontSide,
  int? clozeOrd,
  bool answer = false,
}) {
  final tokens = <_Token>[];
  var last = 0;
  for (final match in _tagPattern.allMatches(template)) {
    if (match.start > last) {
      tokens.add(_Token.text(template.substring(last, match.start)));
    }
    tokens.add(_Token.tag(match[1]!.trim()));
    last = match.end;
  }
  if (last < template.length) {
    tokens.add(_Token.text(template.substring(last)));
  }

  var i = 0;
  var used = false;

  String walk(String? closing) {
    final out = StringBuffer();
    while (i < tokens.length) {
      final token = tokens[i++];
      if (token.text != null) {
        out.write(token.text);
        continue;
      }
      final tag = token.tag!;
      if (tag.startsWith('/')) {
        final name = tag.substring(1).trim();
        if (closing == null || name != closing) {
          throw const FormatException('模板格式错误');
        }
        return out.toString();
      }
      if (tag.startsWith('#') || tag.startsWith('^')) {
        final isNegated = tag.startsWith('^');
        final name = tag.substring(1).trim();
        final nonEmpty = fieldIsNonEmpty(fields[name] ?? '');
        final show = isNegated ? !nonEmpty : nonEmpty;
        final saved = used;
        final inner = walk(name);
        if (show) {
          out.write(inner);
        } else {
          used = saved;
        }
        continue;
      }
      if (tag == 'FrontSide') {
        out.write(frontSide ?? '');
        continue;
      }
      if (tag.startsWith('cloze:')) {
        final name = tag.substring(6).trim();
        final value = fields[name] ?? '';
        if (clozeOrd == null) {
          out.write(value);
          if (fieldIsNonEmpty(value)) used = true;
        } else {
          out.write(renderCloze(value, clozeOrd, answer: answer));
          if (clozeNumbers(value).contains(clozeOrd)) used = true;
        }
        continue;
      }
      if (tag.startsWith('text:')) {
        final name = tag.substring(5).trim();
        final value = fields[name] ?? '';
        out.write(stripHtml(value));
        if (fieldIsNonEmpty(value)) used = true;
        continue;
      }
      final value = fields[tag] ?? '';
      out.write(value);
      if (fieldIsNonEmpty(value)) used = true;
    }
    if (closing != null) throw const FormatException('模板格式错误');
    return out.toString();
  }

  final text = walk(null);
  return RenderResult(text, used);
}

class _Token {
  final String? tag;
  final String? text;
  const _Token.tag(this.tag) : text = null;
  const _Token.text(this.text) : tag = null;
}
