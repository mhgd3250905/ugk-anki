import 'dart:convert';

/// 字段分隔符（Anki 的 \x1f）
const String kFieldSep = '\x1f';

/// 把字段列表拼成 Anki 的单个字符串
String joinFields(List<String> fields) => fields.join(kFieldSep);

/// 把 Anki 的字段字符串拆成列表
List<String> splitFields(String joined) => joined.split(kFieldSep);

/// 去掉 HTML 注释、标签并还原实体，不 trim
String stripHtml(String html) {
  var s = html.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
  s = s.replaceAll(RegExp(r'<[^>]*>'), '');
  return s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&');
}

/// 字段去掉 HTML 并 trim 后是否非空
bool fieldIsNonEmpty(String value) => stripHtml(value).trim().isNotEmpty;

/// 字段内容的 FNV-1a 32 位校验和
int fieldChecksum(String field) {
  var hash = 0x811c9dc5;
  for (final b in utf8.encode(stripHtml(field).trim())) {
    hash ^= b;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}
