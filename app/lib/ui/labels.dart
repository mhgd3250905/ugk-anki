import 'package:flutter/services.dart';
import 'package:ugk_core/ugk_core.dart' hide Card;

/// 内置笔记类型的中文名（自建类型原样显示）
String typeLabel(NoteType t) => switch (t.name) {
  'Basic' => '问答',
  'Basic (and reversed card)' => '问答 · 正反都考',
  'Cloze' => '填空',
  _ => t.name,
};

/// 内置字段的中文名（自建字段原样显示）
String fieldLabel(String name) => switch (name) {
  'Front' => '正面',
  'Back' => '背面',
  'Text' => '正文',
  'Back Extra' => '补充说明',
  _ => name,
};

final _clozeNum = RegExp(r'\{\{c(\d+)::');

/// 把选中的文字变成下一个挖空 {{cN::…}}；没选中时插入空挖空，光标放在里面
TextEditingValue applyCloze(TextEditingValue v) {
  var n = 1;
  for (final m in _clozeNum.allMatches(v.text)) {
    final k = int.parse(m.group(1)!);
    if (k >= n) n = k + 1;
  }
  final sel = v.selection.isValid
      ? v.selection
      : TextSelection.collapsed(offset: v.text.length);
  final picked = sel.textInside(v.text);
  final open = '{{c$n::';
  final text = '${sel.textBefore(v.text)}$open$picked}}${sel.textAfter(v.text)}';
  final cursor = sel.start + open.length + picked.length;
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(
      offset: picked.isEmpty ? cursor : cursor + 2,
    ),
  );
}

/// 添加前检查，返回给用户看的提示；没问题返回 null
String? addNoteProblem(NoteType type, List<String> fields) {
  final first = stripHtml(fields.first).trim();
  if (type.kind == NoteKind.cloze) {
    if (first.isEmpty) return '正文还没填';
    if (!_clozeNum.hasMatch(fields.first)) {
      return '还没有要挖空的词：选中正文里的一段文字，再点「挖空」';
    }
    return null;
  }
  if (first.isEmpty) return '${fieldLabel(type.fields.first.name)}还没填';
  return null;
}

/// 卡组显示名：内置的 Default 显示成「默认」
String deckLabel(String name) =>
    name.split('::').map((p) => p == 'Default' ? '默认' : p).join('::');
