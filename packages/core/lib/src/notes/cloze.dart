/// cloze 语法正则
final RegExp _clozePattern = RegExp(
  r'\{\{c(\d+)::(.*?)(?:::(.*?))?\}\}',
  dotAll: true,
);

/// 提取文本里所有 cloze 编号（只保留 >= 1）
Set<int> clozeNumbers(String text) {
  final result = <int>{};
  for (final match in _clozePattern.allMatches(text)) {
    final n = int.parse(match[1]!);
    if (n >= 1) result.add(n);
  }
  return result;
}

/// 按指定序号渲染 cloze：正面挖空，背面显示原文
String renderCloze(String text, int ord, {required bool answer}) {
  return text.replaceAllMapped(_clozePattern, (match) {
    final n = int.parse(match[1]!);
    final content = match[2]!;
    if (n != ord) return content;
    if (answer) return '<span class="cloze">$content</span>';
    final hint = match[3];
    return '<span class="cloze">[${hint ?? '...'}]</span>';
  });
}
