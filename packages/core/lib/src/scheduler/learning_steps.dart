const int kDaySecs = 86400;

/// 学习/重学步骤计算
class LearningSteps {
  final List<double> steps; // 分钟
  const LearningSteps(this.steps);

  static int _toSecs(double minutes) => (minutes * 60).truncate();

  /// remaining 是“剩余步数”，可能带千位（Anki 旧格式），只取 % 1000
  int _index(int remaining) {
    final total = steps.length;
    final i = total - (remaining % 1000);
    final clamped = i < 0 ? 0 : i;
    final maxIdx = total - 1 < 0 ? 0 : total - 1;
    return clamped > maxIdx ? maxIdx : clamped;
  }

  int? _secsAt(int index) =>
      (index >= 0 && index < steps.length) ? _toSecs(steps[index]) : null;

  /// Again：回到第 1 步。没有步骤时返回 null
  int? againDelaySecs() => _secsAt(0);

  /// Hard：第 1 步特殊处理，其他步重复当前步
  int? hardDelaySecs(int remaining) {
    final idx = _index(remaining);
    final current = _secsAt(idx) ?? (steps.isEmpty ? null : _toSecs(steps.first));
    if (current == null) return null;
    if (idx != 0) return current;
    final next = _secsAt(1);
    if (next != null) return _maybeRoundInDays((current + next) ~/ 2);
    final a = current * 3 ~/ 2;
    final b = current + kDaySecs;
    return _maybeRoundInDays(a < b ? a : b);
  }

  /// Good：进入下一步；已经是最后一步返回 null（表示毕业）
  int? goodDelaySecs(int remaining) => _secsAt(_index(remaining) + 1);

  /// 当前步的延迟（写 revlog 的 last_ivl 用）
  int currentDelaySecs(int remaining) => _secsAt(_index(remaining)) ?? 0;

  /// 按 Good 后的剩余步数
  int remainingForGood(int remaining) {
    final r = steps.length - (_index(remaining) + 1);
    return r < 0 ? 0 : r;
  }

  /// 按 Again 后的剩余步数
  int remainingForFailed() => steps.length;

  bool get isEmpty => steps.isEmpty;
}

int _maybeRoundInDays(int secs) =>
    secs > kDaySecs ? (secs / kDaySecs).round() * kDaySecs : secs;
