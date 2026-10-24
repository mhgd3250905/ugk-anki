import 'package:flutter/widgets.dart';
import 'package:ugk_data/ugk_data.dart';

/// 把仓库往下传给所有页面
class RepoScope extends InheritedWidget {
  const RepoScope({required this.repo, required super.child, super.key});

  final UgkRepository repo;

  /// 取仓库
  static UgkRepository of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RepoScope>()!.repo;

  @override
  bool updateShouldNotify(RepoScope oldWidget) => oldWidget.repo != repo;
}
