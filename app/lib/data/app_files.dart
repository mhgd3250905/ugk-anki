import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// 选中的文件
class PickedFile {
  const PickedFile(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}

/// 文件读写入口。测试里换成假的。
abstract class AppFiles {
  /// 当前实现
  static AppFiles instance = const _PickerFiles();

  /// 让用户选一个文件；取消返回 null
  Future<PickedFile?> pick();

  /// 让用户选位置保存；取消返回 false
  Future<bool> save(String fileName, Uint8List bytes, String mimeType);
}

class _PickerFiles implements AppFiles {
  const _PickerFiles();

  @override
  Future<PickedFile?> pick() async {
    final f = await FilePicker.pickFile();
    if (f == null) return null;
    return PickedFile(f.name, await f.readAsBytes());
  }

  @override
  Future<bool> save(String fileName, Uint8List bytes, String mimeType) async {
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
    );
    return uri != null;
  }
}
