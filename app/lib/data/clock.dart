/// App 层的时钟：只有这里允许读系统时间，core / data 一律从参数接收
int nowMs() => DateTime.now().millisecondsSinceEpoch;

/// 当前时区偏移（分钟），上海 = 480
int utcOffsetMinutes() => DateTime.now().timeZoneOffset.inMinutes;

/// 文件名用的时间戳：20261024-2315
String fileStamp() {
  final d = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}${two(d.month)}${two(d.day)}-${two(d.hour)}${two(d.minute)}';
}
