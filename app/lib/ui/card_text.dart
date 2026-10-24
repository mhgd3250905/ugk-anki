import 'package:ugk_core/ugk_core.dart';

/// 卡片 HTML 转成可显示的纯文本（MVP 先不渲染 HTML）
String cardPlainText(String html) {
  final withBreaks = html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(div|p)>', caseSensitive: false), '\n');
  return stripHtml(withBreaks)
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .join('\n');
}

/// 背面只取 `<hr id=answer>` 之后的部分；没有分隔线时整段显示
String answerPlainText(String answerHtml) {
  final m = RegExp(
    r'<hr id=.?answer.?>',
    caseSensitive: false,
  ).firstMatch(answerHtml);
  final part = m == null ? answerHtml : answerHtml.substring(m.end);
  return cardPlainText(part);
}

/// 标签字符串转成卡片右上角的短文字：「街舞 · 邀约」
String tagLine(String tags) => parseTags(tags).join(' · ');
