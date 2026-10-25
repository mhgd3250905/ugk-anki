import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../theme/tokens.dart';
import 'glass_page.dart';

/// 统一参数的玻璃层。页面、弹窗、提示条各自有一层。
class GlassLayer extends StatelessWidget {
  const GlassLayer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return LiquidGlassLayer(
      fake: UgkGlass.useFake,
      settings: LiquidGlassSettings.ios27Regular(brightness: brightness),
      defaultAppearance: LiquidGlassAppearance.ios27Regular(
        brightness: brightness,
      ),
      child: child,
    );
  }
}

/// 胶囊玻璃按钮。primary = 蓝色粗字，否则是灰色字。
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.danger = false,
    this.height = UgkSize.barHeight,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  /// 危险操作：红色粗字
  final bool danger;
  final double height;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final enabled = onTap != null;
    final color = danger
        ? UgkColors.again
        : primary
        ? UgkColors.newBlue
        : onSurface.withValues(alpha: 0.7);
    return GestureDetector(
      onTap: onTap,
      child: LiquidStretch(
        interactionScale: 0.96,
        child: LiquidGlass(
          shape: const LiquidRoundedSuperellipse(
            borderRadius: UgkRadius.button,
          ),
          child: SizedBox(
            height: height,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: enabled ? color : color.withValues(alpha: 0.35),
                  fontSize: UgkText.button,
                  fontWeight: primary || danger
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 我们自己的输入框：淡色圆角底，没有下划线
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    required this.controller,
    this.hint,
    this.autofocus = false,
    this.maxLines = 1,
    this.onSubmitted,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String? hint;
  final bool autofocus;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(UgkRadius.field),
        border: Border.all(color: onSurface.withValues(alpha: 0.06)),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        minLines: 1,
        maxLines: maxLines,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        cursorColor: UgkColors.newBlue,
        style: TextStyle(color: onSurface, fontSize: UgkText.field),
        decoration: InputDecoration.collapsed(
          hintText: hint,
          hintStyle: TextStyle(
            color: onSurface.withValues(alpha: 0.3),
            fontSize: UgkText.field,
          ),
        ),
      ),
    );
  }
}

/// 一组可选的胶囊（替代 ChoiceChip）
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
    super.key,
  });

  final List<T> items;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Wrap(
      spacing: UgkSpace.s,
      runSpacing: UgkSpace.s,
      children: [
        for (final item in items)
          GestureDetector(
            onTap: () => onSelect(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: item == selected
                    ? UgkColors.newBlue.withValues(alpha: 0.14)
                    : onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(UgkRadius.pill),
                border: Border.all(
                  color: item == selected
                      ? UgkColors.newBlue.withValues(alpha: 0.45)
                      : onSurface.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                labelOf(item),
                style: TextStyle(
                  color: item == selected
                      ? UgkColors.newBlue
                      : onSurface.withValues(alpha: 0.7),
                  fontSize: UgkText.hint + 1,
                  fontWeight: item == selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 可点的一行：左标签、右当前值 + 箭头（替代 DropdownButton，点了弹出选择面板）
class GlassSelectRow extends StatelessWidget {
  const GlassSelectRow({required this.value, required this.onTap, super.key});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(UgkRadius.field),
          border: Border.all(color: onSurface.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: onSurface, fontSize: UgkText.field),
              ),
            ),
            Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// 加载中：本地数据库通常几毫秒就好，所以什么都不画，避免闪一下转圈
class GlassLoading extends StatelessWidget {
  const GlassLoading({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 弹窗标题
class _DialogTitle extends StatelessWidget {
  const _DialogTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: UgkText.dialogTitle,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  );
}

/// 弹窗外壳：暗一点的遮罩 + 缩放淡入
Future<T?> _showGlassRoute<T>(
  BuildContext context, {
  required Widget Function(BuildContext) builder,
  Alignment alignment = Alignment.center,
}) {
  final fromBottom = alignment == Alignment.bottomCenter;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭',
    barrierColor: const Color(0x33000000),
    transitionDuration: const Duration(milliseconds: 260),
    // 软键盘弹出时整体上移到键盘上方，空间不够就滚动
    pageBuilder: (ctx, _, _) => GlassLayer(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SafeArea(
          child: Align(
            alignment: alignment,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(UgkSpace.m),
              child: Material(
                type: MaterialType.transparency,
                child: builder(ctx),
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: fromBottom
            ? SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              )
            : ScaleTransition(
                scale: Tween(begin: 0.94, end: 1.0).animate(curved),
                child: child,
              ),
      );
    },
  );
}

/// 输入弹窗（替代 AlertDialog + TextField）。返回输入内容，取消返回 null。
Future<String?> showGlassPrompt(
  BuildContext context, {
  required String title,
  String? hint,
  String confirmLabel = '确定',
}) async {
  final controller = TextEditingController();
  final result = await _showGlassRoute<String>(
    context,
    builder: (ctx) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: GlassPanel(
        radius: UgkRadius.card,
        padding: const EdgeInsets.all(UgkSpace.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogTitle(title),
            const SizedBox(height: UgkSpace.m),
            GlassTextField(
              key: const ValueKey('prompt-field'),
              controller: controller,
              hint: hint,
              autofocus: true,
              onSubmitted: (v) => Navigator.of(ctx).pop(v),
            ),
            const SizedBox(height: UgkSpace.l),
            Row(
              children: [
                Expanded(
                  child: GlassPillButton(
                    label: '取消',
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ),
                const SizedBox(width: UgkSpace.ratingGap),
                Expanded(
                  child: GlassPillButton(
                    label: confirmLabel,
                    primary: true,
                    onTap: () => Navigator.of(ctx).pop(controller.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  // 等退场动画结束再释放
  Future<void>.delayed(const Duration(milliseconds: 400), controller.dispose);
  return result;
}

/// 新建一项并选择放在哪里（例如新建卡组）。不用记任何特殊写法：
/// 名字照常输入，上级从列表里点选。返回 (名字, 上级下标)，上级为 null 表示放在最外层。
Future<(String, int?)?> showGlassNameAndPlace(
  BuildContext context, {
  required String title,
  required String nameHint,
  required String placeTitle,
  required String noneLabel,
  required List<String> places,
  String confirmLabel = '确定',
}) async {
  final controller = TextEditingController();
  int? place;
  final result = await _showGlassRoute<(String, int?)>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final onSurface = Theme.of(ctx).colorScheme.onSurface;
        Widget label(String t) => Padding(
          padding: const EdgeInsets.only(bottom: UgkSpace.s, left: 2),
          child: Text(
            t,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.55),
              fontSize: UgkText.tag,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: GlassPanel(
            radius: UgkRadius.card,
            padding: const EdgeInsets.all(UgkSpace.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DialogTitle(title),
                const SizedBox(height: UgkSpace.m),
                label('名称'),
                GlassTextField(
                  key: const ValueKey('prompt-field'),
                  controller: controller,
                  hint: nameHint,
                  autofocus: true,
                ),
                if (places.isNotEmpty) ...[
                  const SizedBox(height: UgkSpace.m),
                  label(placeTitle),
                  GlassSelectRow(
                    key: const ValueKey('place-select'),
                    value: place == null ? noneLabel : places[place!],
                    onTap: () async {
                      // -1 表示「最外层」，取消返回 null
                      final picked = await showGlassPicker<int>(
                        ctx,
                        title: placeTitle,
                        items: [-1, for (var i = 0; i < places.length; i++) i],
                        selected: place ?? -1,
                        labelOf: (i) => i < 0 ? noneLabel : places[i],
                      );
                      if (picked != null) {
                        setState(() => place = picked < 0 ? null : picked);
                      }
                    },
                  ),
                ],
                const SizedBox(height: UgkSpace.l),
                Row(
                  children: [
                    Expanded(
                      child: GlassPillButton(
                        label: '取消',
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    const SizedBox(width: UgkSpace.ratingGap),
                    Expanded(
                      child: GlassPillButton(
                        label: confirmLabel,
                        primary: true,
                        onTap: () =>
                            Navigator.of(ctx).pop((controller.text, place)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  Future<void>.delayed(const Duration(milliseconds: 400), controller.dispose);
  return result;
}

/// 底部选择面板（替代 DropdownButton 的菜单）
Future<T?> showGlassPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required T selected,
  required String Function(T) labelOf,
}) {
  return _showGlassRoute<T>(
    context,
    alignment: Alignment.bottomCenter,
    builder: (ctx) {
      final onSurface = Theme.of(ctx).colorScheme.onSurface;
      final maxH = MediaQuery.sizeOf(ctx).height * 0.6;
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxH),
        child: GlassPanel(
          radius: UgkRadius.card,
          padding: const EdgeInsets.fromLTRB(
            UgkSpace.l,
            UgkSpace.l,
            UgkSpace.l,
            UgkSpace.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DialogTitle(title),
              const SizedBox(height: UgkSpace.s),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in items)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(ctx).pop(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  labelOf(item),
                                  style: TextStyle(
                                    color: item == selected
                                        ? UgkColors.newBlue
                                        : onSurface,
                                    fontSize: UgkText.field,
                                    fontWeight: item == selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (item == selected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: UgkColors.newBlue,
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 顶部浮出的玻璃提示条（替代 SnackBar），2.2 秒后自动消失
void showGlassToast(BuildContext context, String message, {bool warn = false}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _GlassToastHost.current?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _GlassToastHost(
      message: message,
      warn: warn,
      onDone: () {
        if (_GlassToastHost.current == entry) _GlassToastHost.current = null;
        if (entry.mounted) entry.remove();
      },
    ),
  );
  _GlassToastHost.current = entry;
  overlay.insert(entry);
}

class _GlassToastHost extends StatefulWidget {
  const _GlassToastHost({
    required this.message,
    required this.warn,
    required this.onDone,
  });

  static OverlayEntry? current;

  final String message;
  final bool warn;
  final VoidCallback onDone;

  @override
  State<_GlassToastHost> createState() => _GlassToastHostState();
}

class _GlassToastHostState extends State<_GlassToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            UgkSpace.l,
            UgkSpace.s + UgkSize.barHeight + UgkSpace.s,
            UgkSpace.l,
            0,
          ),
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(curved),
              child: Center(
                child: GlassLayer(
                  child: Material(
                    type: MaterialType.transparency,
                    child: GlassPanel(
                      radius: UgkRadius.pill,
                      padding: const EdgeInsets.symmetric(
                        horizontal: UgkSpace.m + 2,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: widget.warn
                                  ? UgkColors.hard
                                  : UgkColors.good,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: UgkSpace.s + 2),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: onSurface,
                                fontSize: UgkText.hint + 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 操作面板里的一项
class GlassAction {
  const GlassAction(this.icon, this.label, {this.danger = false});

  final IconData icon;
  final String label;

  /// 危险操作用红色
  final bool danger;
}

/// 底部操作面板（替代 showModalBottomSheet / PopupMenu）。返回选中的序号，取消返回 null。
Future<int?> showGlassActions(
  BuildContext context, {
  required String title,
  required List<GlassAction> actions,
}) {
  return _showGlassRoute<int>(
    context,
    alignment: Alignment.bottomCenter,
    builder: (ctx) {
      final onSurface = Theme.of(ctx).colorScheme.onSurface;
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GlassPanel(
          radius: UgkRadius.card,
          padding: const EdgeInsets.fromLTRB(
            UgkSpace.l,
            UgkSpace.l,
            UgkSpace.l,
            UgkSpace.s,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DialogTitle(title),
              const SizedBox(height: UgkSpace.s),
              for (var i = 0; i < actions.length; i++)
                GestureDetector(
                  key: ValueKey('action-$i'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(ctx).pop(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          actions[i].icon,
                          size: 20,
                          color: actions[i].danger
                              ? UgkColors.again
                              : onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: UgkSpace.m),
                        Expanded(
                          child: Text(
                            actions[i].label,
                            style: TextStyle(
                              color: actions[i].danger
                                  ? UgkColors.again
                                  : onSurface,
                              fontSize: UgkText.field,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// 确认弹窗（替代 AlertDialog）。确认返回 true。
Future<bool> showGlassConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '确定',
  bool danger = false,
}) async {
  final ok = await _showGlassRoute<bool>(
    context,
    builder: (ctx) {
      final onSurface = Theme.of(ctx).colorScheme.onSurface;
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassPanel(
          radius: UgkRadius.card,
          padding: const EdgeInsets.all(UgkSpace.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DialogTitle(title),
              const SizedBox(height: UgkSpace.s),
              Text(
                message,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.7),
                  fontSize: UgkText.button - 1,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: UgkSpace.l),
              Row(
                children: [
                  Expanded(
                    child: GlassPillButton(
                      label: '取消',
                      onTap: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: UgkSpace.ratingGap),
                  Expanded(
                    child: GlassPillButton(
                      key: const ValueKey('confirm'),
                      label: confirmLabel,
                      primary: !danger,
                      danger: danger,
                      onTap: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return ok ?? false;
}
