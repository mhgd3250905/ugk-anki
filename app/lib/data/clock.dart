/// App 层的时钟：只有这里允许读系统时间，core / data 一律从参数接收
int nowMs() => DateTime.now().millisecondsSinceEpoch;

/// 当前时区偏移（分钟），上海 = 480
int utcOffsetMinutes() => DateTime.now().timeZoneOffset.inMinutes;
