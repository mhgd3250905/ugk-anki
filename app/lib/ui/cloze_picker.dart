import 'package:flutter/material.dart';

import 'theme/tokens.dart';

/// 把句子拆成一个个可点的字块：中文一字一块，英文/数字一词一块，标点不可点。
class ClozeToken {
  const ClozeToken(this.start, this.end, this.text, {required this.pickable});

  final int start;
  final int end;
  final String text;
  final bool pickable;
}

final _word = RegExp(r"[A-Za-z0-9'’\-]+");
final _space = RegExp(r'\s');
final _punct = RegExp(r'[\p{P}\p{S}]', unicode: true);

List<ClozeToken> clozeTokens(String text) {
  final out = <ClozeToken>[];
  var i = 0;
  while (i < text.length) {
    final ch = text[i];
    if (_space.hasMatch(ch)) {
      i++;
      continue;
    }
    final m = _word.matchAsPrefix(text, i);
    if (m != null) {
      out.add(ClozeToken(i, m.end, m[0]!, pickable: true));
      i = m.end;
      continue;
    }
    out.add(ClozeToken(i, i + 1, ch, pickable: !_punct.hasMatch(ch)));
    i++;
  }
  return out;
}

/// 句子 + 选中的字（下标集合）→ Anki 填空格式。
/// 连在一起的选中字合成一处挖空（中间只隔空格也算连着），每处挖空生成一张卡片。
String buildClozeText(String text, Set<int> picked) {
  final b = StringBuffer();
  var n = 0;
  var i = 0;
  while (i < text.length) {
    if (!picked.contains(i)) {
      b.write(text[i]);
      i++;
      continue;
    }
    var end = i;
    var j = i;
    while (j < text.length) {
      if (picked.contains(j)) {
        end = j + 1;
        j++;
      } else if (_space.hasMatch(text[j])) {
        j++;
      } else {
        break;
      }
    }
    n++;
    b.write('{{c$n::${text.substring(i, end)}}}');
    i = end;
  }
  return b.toString();
}

/// 正文改动后，尽量保留原来选中的字：前后没变的部分照旧，改动的地方取消选中。
Set<int> shiftPicked(String old, String next, Set<int> picked) {
  var head = 0;
  final minLen = old.length < next.length ? old.length : next.length;
  while (head < minLen && old[head] == next[head]) {
    head++;
  }
  var tail = 0;
  while (tail < minLen - head &&
      old[old.length - 1 - tail] == next[next.length - 1 - tail]) {
    tail++;
  }
  final delta = next.length - old.length;
  return {
    for (final p in picked)
      if (p < head) p else if (p >= old.length - tail) p + delta,
  };
}

/// 挖了几处
int blankCount(String text, Set<int> picked) =>
    RegExp(r'\{\{c\d+::').allMatches(buildClozeText(text, picked)).length;

/// 点字挖空：句子拆成字块，点一下变蓝 = 要考这个字，再点取消。
class ClozePicker extends StatelessWidget {
  const ClozePicker({
    required this.text,
    required this.picked,
    required this.onChanged,
    super.key,
  });

  final String text;
  final Set<int> picked;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tokens = clozeTokens(text);
    if (tokens.isEmpty) {
      return Text(
        '在上面输入一句话后，这里会出现可以点的字',
        style: TextStyle(
          color: onSurface.withValues(alpha: 0.45),
          fontSize: UgkText.hint,
        ),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final t in tokens)
          _TokenChip(
            key: ValueKey('tok-${t.start}'),
            token: t,
            selected:
                t.pickable &&
                [
                  for (var i = t.start; i < t.end; i++) i,
                ].every(picked.contains),
            onTap: () {
              final next = {...picked};
              final range = [for (var i = t.start; i < t.end; i++) i];
              if (range.every(next.contains)) {
                next.removeAll(range);
              } else {
                next.addAll(range);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({
    required this.token,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final ClozeToken token;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    if (!token.pickable) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          token.text,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.4),
            fontSize: UgkText.field,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? UgkColors.newBlue
              : onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? UgkColors.newBlue
                : onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          token.text,
          style: TextStyle(
            color: selected ? Colors.white : onSurface,
            fontSize: UgkText.field,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 复习时的样子：选中的部分变成横线空格
class ClozePreview extends StatelessWidget {
  const ClozePreview({required this.text, required this.picked, super.key});

  final String text;
  final Set<int> picked;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cloze = buildClozeText(text, picked);
    final shown = cloze.replaceAll(RegExp(r'\{\{c\d+::.*?\}\}'), '＿＿＿');
    final n = blankCount(text, picked);
    return Text(
      n == 0
          ? '还没有选要考的字'
          : '复习时会这样考：$shown${n > 1 ? '（挖了 $n 处，会生成 $n 张卡片）' : ''}',
      style: TextStyle(
        color: onSurface.withValues(alpha: 0.6),
        fontSize: UgkText.hint,
      ),
    );
  }
}
