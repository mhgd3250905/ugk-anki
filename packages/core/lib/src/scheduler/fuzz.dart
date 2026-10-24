import 'dart:math';

/// fuzzFactor 为 null 表示不抖动；否则是 [0,1) 之间的数
int withReviewFuzz(double? fuzzFactor, double interval, int minimum, int maximum) {
  if (fuzzFactor == null) {
    return interval.round().clamp(minimum, maximum);
  }
  final (lower, upper) = constrainedFuzzBounds(interval, minimum, maximum);
  return (lower + fuzzFactor * (1 + upper - lower)).floor();
}

/// 按最小/最大间隔限制后的抖动上下界
(int, int) constrainedFuzzBounds(double interval, int minimum, int maximum) {
  final mn = minimum < maximum ? minimum : maximum;
  final iv = interval.clamp(mn.toDouble(), maximum.toDouble());
  var (lower, upper) = fuzzBounds(iv);
  lower = lower.clamp(mn, maximum);
  upper = upper.clamp(mn, maximum);
  if (upper == lower && upper > 2 && upper < maximum) upper = lower + 1;
  return (lower, upper);
}

/// 由浮动间隔计算四舍五入后的抖动上下界
(int, int) fuzzBounds(double interval) {
  final d = fuzzDelta(interval);
  return ((interval - d).round(), (interval + d).round());
}

/// 区间：<2.5 天不抖；2.5–7 天每天 +0.15；7–20 天每天 +0.1；20 天以上每天 +0.05；起步 1.0
double fuzzDelta(double interval) {
  if (interval < 2.5) return 0;
  const ranges = [(2.5, 7.0, 0.15), (7.0, 20.0, 0.10), (20.0, double.infinity, 0.05)];
  var delta = 1.0;
  for (final (start, end, factor) in ranges) {
    final span = (interval < end ? interval : end) - start;
    if (span > 0) delta += factor * span;
  }
  return delta;
}

/// 由卡片 id 和复习次数得到确定的抖动因子（同一张卡同一次复习结果固定）
double fuzzFactorFor(int cardId, int reps) => Random(cardId + reps).nextDouble();
