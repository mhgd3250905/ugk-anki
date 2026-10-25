import 'package:flutter/material.dart';

import 'theme/tokens.dart';

/// 填空正文的输入控制器。
///
/// 存储仍是 Anki 的 `{{c1::词}}` 格式，但界面上只显示「词」本身（蓝底高亮），
/// `{{c1::` 和 `}}` 这些内部记号被隐藏，用户不用认识它们：
/// - 光标不会停在隐藏记号中间；
/// - 在挖空边上删字，会整个取消这处挖空（保留词本身）。
class ClozeEditingController extends TextEditingController {
  ClozeEditingController({super.text});

  static final _cloze = RegExp(r'\{\{c(\d+)::(.*?)(::.*?)?\}\}', dotAll: true);

  /// 每处挖空：开头记号 [openStart, openEnd)、词 [openEnd, closeStart)、结尾记号 [closeStart, closeEnd)
  static List<_Blank> _blanks(String text) => [
    for (final m in _cloze.allMatches(text))
      _Blank(
        m.start,
        m.start + 5 + m.group(1)!.length,
        m.start + 5 + m.group(1)!.length + m.group(2)!.length,
        m.end,
      ),
  ];

  @override
  set value(TextEditingValue next) {
    final old = super.value;
    super.value = _fix(old, next);
  }

  TextEditingValue _fix(TextEditingValue old, TextEditingValue next) {
    // 1. 删掉了某处挖空的隐藏记号 → 改成取消这处挖空
    if (next.text.length < old.text.length) {
      final cut = _deletedRange(old.text, next.text);
      if (cut != null) {
        for (final b in _blanks(old.text)) {
          final hitsOpen = cut.$1 < b.openEnd && cut.$2 > b.openStart;
          final hitsClose = cut.$1 < b.closeEnd && cut.$2 > b.closeStart;
          if (hitsOpen || hitsClose) {
            final word = old.text.substring(b.openEnd, b.closeStart);
            final text =
                old.text.substring(0, b.openStart) +
                word +
                old.text.substring(b.closeEnd);
            return TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(
                offset: b.openStart + word.length,
              ),
            );
          }
        }
      }
    }
    // 2. 光标落在隐藏记号中间 → 挪到记号外面
    final sel = next.selection;
    if (sel.isValid && sel.isCollapsed) {
      for (final b in _blanks(next.text)) {
        final o = sel.baseOffset;
        int? snap;
        if (o > b.openStart && o < b.openEnd) snap = b.openEnd;
        if (o > b.closeStart && o < b.closeEnd) snap = b.closeEnd;
        if (snap != null) {
          return next.copyWith(
            selection: TextSelection.collapsed(offset: snap),
          );
        }
      }
    }
    return next;
  }

  /// 单段连续删除时返回被删的区间（在 old 里的下标）
  static (int, int)? _deletedRange(String old, String next) {
    var head = 0;
    while (head < next.length && old[head] == next[head]) {
      head++;
    }
    var tail = 0;
    while (tail < next.length - head &&
        old[old.length - 1 - tail] == next[next.length - 1 - tail]) {
      tail++;
    }
    if (head + tail != next.length) return null;
    return (head, old.length - tail);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final blanks = _blanks(text);
    if (blanks.isEmpty || (withComposing && !value.isComposingRangeValid)) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    const hidden = TextStyle(
      fontSize: 0.01,
      color: Color(0x00000000),
      letterSpacing: 0,
    );
    final word = TextStyle(
      color: UgkColors.newBlue,
      fontWeight: FontWeight.w600,
      backgroundColor: UgkColors.newBlue.withValues(alpha: 0.14),
    );
    final spans = <TextSpan>[];
    var at = 0;
    for (final b in blanks) {
      if (b.openStart > at) {
        spans.add(TextSpan(text: text.substring(at, b.openStart)));
      }
      spans.add(
        TextSpan(text: text.substring(b.openStart, b.openEnd), style: hidden),
      );
      spans.add(
        TextSpan(text: text.substring(b.openEnd, b.closeStart), style: word),
      );
      spans.add(
        TextSpan(text: text.substring(b.closeStart, b.closeEnd), style: hidden),
      );
      at = b.closeEnd;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return TextSpan(style: style, children: spans);
  }
}

class _Blank {
  const _Blank(this.openStart, this.openEnd, this.closeStart, this.closeEnd);

  final int openStart;
  final int openEnd;
  final int closeStart;
  final int closeEnd;
}
