/// 一天的毫秒数
const int _dayMs = 86400000;

int _shiftFor(int utcOffsetMinutes, int rolloverHour) =>
    utcOffsetMinutes * 60000 - rolloverHour * 3600000;

int _absDay(int ms, int shift) => ((ms + shift) / _dayMs).floor();

/// 计算当前是创建以来的第几天（按 rolloverHour 分界）
int dayNumber({
  required int nowMs,
  required int collectionCreatedMs,
  required int utcOffsetMinutes,
  int rolloverHour = 4,
}) {
  final shift = _shiftFor(utcOffsetMinutes, rolloverHour);
  return _absDay(nowMs, shift) - _absDay(collectionCreatedMs, shift);
}

/// 第 today 天结束、下一天开始的毫秒时刻
int dayCutoffMs({
  required int today,
  required int collectionCreatedMs,
  required int utcOffsetMinutes,
  int rolloverHour = 4,
}) {
  final shift = _shiftFor(utcOffsetMinutes, rolloverHour);
  return (_absDay(collectionCreatedMs, shift) + today + 1) * _dayMs - shift;
}
