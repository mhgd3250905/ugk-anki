/// base91 字符表（91 个字符）
const String _base91 =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#\$%&()*+,-./:;<=>?@[]^_`{|}~';

/// 把整数编码成 Anki 的 base91 GUID
String guidFromInt(int value) {
  if (value < 0) throw ArgumentError('value 不能为负数: $value');
  if (value == 0) return 'a';
  final digits = <String>[];
  var remaining = value;
  while (remaining > 0) {
    digits.add(_base91[remaining % 91]);
    remaining ~/= 91;
  }
  return digits.reversed.join();
}
