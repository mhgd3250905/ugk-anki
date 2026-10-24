/// 按空白拆分标签并忽略大小写去重（保留首次出现的写法）
List<String> parseTags(String tags) {
  final result = <String>[];
  final seen = <String>{};
  for (final tag in tags.split(RegExp(r'\s+'))) {
    if (tag.isEmpty) continue;
    if (seen.add(tag.toLowerCase())) result.add(tag);
  }
  return result;
}

/// 把标签列表拼成 Anki 格式（前后各一个空格）
String joinTags(List<String> tags) => tags.isEmpty ? '' : ' ${tags.join(' ')} ';

/// 是否包含指定标签（忽略大小写）
bool hasTag(String tags, String tag) =>
    parseTags(tags).any((t) => t.toLowerCase() == tag.toLowerCase());

/// 添加标签（忽略大小写去重）后返回 Anki 格式字符串
String addTag(String tags, String tag) {
  final parsed = parseTags(tags);
  if (!hasTag(tags, tag)) parsed.add(tag);
  return joinTags(parsed);
}
