# M0：液态玻璃复习页样稿（只做一页，静态假数据）

- 分支：`feat/m0-visual`（从 `main` 拉）
- 目的：**先定视觉方向**。只做一个页面，出 4 张真机截图给开哥确认。确认前不要做任何其他页面。
- 完成后打 tag：`m0-approved`（开哥确认后才打，你不要打）

## 1. 硬性规则
- 只允许这两个依赖：`liquid_glass_renderer: ^1.0.0-dev.1`、`flutter_riverpod`（M0 其实用不到 riverpod，**先不要加**）。其他包一律不加。
- 所有颜色、圆角、间距写在 `app/lib/ui/theme/tokens.dart` 里，页面里不允许写死颜色数值。
- 所有玻璃控件写成 `app/lib/ui/glass/` 下的独立组件，页面只组合组件。
- 同一屏的玻璃尽量放在**同一个** `LiquidGlassLayer` 里（每多一个 layer 就多一次整屏拷贝，耗性能）。
- 不要用 `Opacity`/`FadeTransition` 包在 `LiquidGlassLayer` 和 `LiquidGlass` 中间。
- 不要接数据库、不要写调度逻辑，数字全部写死。

## 2. 液态玻璃库要点（来自 pub.dev 文档，照着用）
- 版本 `1.0.0-dev.x`，API 和 0.2.x 完全不同，**网上旧教程不要照抄**。
- 需要 Flutter 3.47+、Impeller、Flutter GPU。Android 开启方法：在 `AndroidManifest.xml` 的 `<application>` 里加
  ```xml
  <meta-data android:name="io.flutter.embedding.android.EnableFlutterGPU" android:value="true" />
  ```
  开发时也可以 `flutter run --enable-flutter-gpu`。
- 玻璃会采样它背后的像素，所以**内容和玻璃必须在同一个 `Stack` 里**，内容在下，玻璃在上。
- 关键组件：
  - `LiquidGlassLayer(settings: ..., child: ...)`：一层，下面所有 `LiquidGlass` 共用一次背景采样。
  - `LiquidGlass(shape: ..., child: ...)`：一个玻璃形状，child 画在玻璃上面。
  - `LiquidGlassBlendGroup(blend: 24, child: ...)` + `LiquidGlass.grouped(...)`：靠近的形状像水滴一样融在一起。
  - 形状：`LiquidRoundedSuperellipse(borderRadius: 28)`（圆角/胶囊）、`LiquidOval()`。
  - 预设：`LiquidGlassSettings.ios27Regular(brightness: b)`，`LiquidGlassAppearance.ios27Regular(brightness: b)`；`b = MediaQuery.platformBrightnessOf(context)`。
  - 单个按钮着色：`appearance: LiquidGlassAppearance.ios27RegularLight(tint: Color(...))`（深色用 `ios27RegularDark`）。
  - `GlassGlow`：按下时的内发光；`LiquidStretch`：拖动时的挤压拉伸。
  - 一个 layer 最多 16 个形状。
- `main()` 里先预热：
  ```dart
  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await LiquidGlass.precache();
    runApp(const UgkAnkiApp());
  }
  ```
- 如果 API 名字和上面对不上（库在快速迭代），以 `https://pub.dev/packages/liquid_glass_renderer` 当前文档和 `example/` 为准，并在「问题记录」写明差异。

---

## 步骤 1：建 Flutter 工程
- [x] 1.1 仓库根目录执行：`flutter create --org com.ugk --project-name ugk_anki --platforms android,ios app`
- [x] 1.2 `cd app && flutter pub add liquid_glass_renderer:^1.0.0-dev.1`（如果 pub 报找不到预发布版，写成 `liquid_glass_renderer: 1.0.0-dev.1` 手动加到 pubspec）。
- [x] 1.3 `app/android/app/src/main/AndroidManifest.xml` 加上面的 meta-data。
- [x] 1.4 `minSdkVersion` 保持 Flutter 默认，不要改。
- [x] 1.5 删除 `app/test/widget_test.dart` 里计数器的测试，改成只验证 App 能 build 的冒烟测试。
- [x] 1.6 `flutter analyze` 无报错。提交推送。

## 步骤 2：目录和设计令牌
- [x] 2.1 建文件：
```
app/lib/main.dart
app/lib/app.dart                         // MaterialApp，跟随系统深浅色
app/lib/ui/theme/tokens.dart             // 颜色、圆角、间距、字号
app/lib/ui/theme/backdrop.dart           // 彩色背景组件
app/lib/ui/glass/glass_top_bar.dart
app/lib/ui/glass/glass_rating_bar.dart
app/lib/ui/glass/glass_card.dart
app/lib/ui/glass/glass_icon_button.dart
app/lib/ui/screens/review_preview_screen.dart
app/lib/ui/screens/fake_data.dart
```
- [x] 2.2 `tokens.dart` 至少包含（数值照抄，之后开哥调）：
```dart
class UgkColors {
  static const newBlue = Color(0xFF0A84FF);
  static const learnRed = Color(0xFFFF453A);
  static const reviewGreen = Color(0xFF30D158);
  static const again = Color(0xFFFF453A);
  static const hard = Color(0xFFFF9F0A);
  static const good = Color(0xFF30D158);
  static const easy = Color(0xFF0A84FF);
  // 背景渐变：浅色 / 深色各三色
  static const lightBackdrop = [Color(0xFFFFD6E8), Color(0xFFC9E4FF), Color(0xFFD9FFE9)];
  static const darkBackdrop  = [Color(0xFF1B1035), Color(0xFF0B2A4A), Color(0xFF07332A)];
}
class UgkRadius { static const card = 32.0; static const button = 28.0; static const bar = 26.0; }
class UgkSpace  { static const xs = 4.0, s = 8.0, m = 16.0, l = 24.0, xl = 32.0; }
class UgkText   { static const cardFront = 30.0, cardBack = 20.0, button = 15.0, buttonHint = 12.0, barTitle = 17.0; }
```

## 步骤 3：背景（backdrop.dart）
玻璃没有彩色背景就看不出效果，必须先做。
- [x] 3.1 `UgkBackdrop` 组件：全屏 `LinearGradient`（从左上到右下，用 tokens 里对应深浅色的三色），上面再叠 3 个模糊的彩色圆（`ImageFiltered` + `ImageFilter.blur(sigmaX: 60, sigmaY: 60)`，颜色取 newBlue/learnRed/reviewGreen，透明度 0.35，直径 260，位置：左上、右中、左下）。
- [x] 3.2 不要动画。提交推送。

## 步骤 4：fake_data.dart
```dart
const fakeDeckName = 'English::Dance';
const fakeCounts = (newCount: 12, learnCount: 3, reviewCount: 41);
const fakeFront = 'Do you want to join our cypher tonight?';
const fakeBack = '今晚要不要来我们的 cypher 一起跳？';
const fakeTag = '街舞 · 邀约';
const fakeLabels = ['<1m', '<6m', '<10m', '4d'];   // Again / Hard / Good / Easy
```

## 步骤 5：玻璃组件
所有组件都**不自己建 LiquidGlassLayer**，而是用 `LiquidGlass(...)` / `LiquidGlass.grouped(...)`，由页面统一包一层 layer。

- [x] 5.1 `GlassIconButton`：参数 `IconData icon`、`VoidCallback onTap`。`LiquidGlass(shape: LiquidOval(), child: SizedBox.square(dimension: 44, child: Icon(...)))`，外面包 `GestureDetector`，按下用 `GlassGlow`。
- [x] 5.2 `GlassTopBar`：参数 `title`、`newCount`、`learnCount`、`reviewCount`、`onBack`。布局：左边 `GlassIconButton(Icons.arrow_back_ios_new)`；中间一个胶囊玻璃（`LiquidRoundedSuperellipse(borderRadius: UgkRadius.bar)`，高 44），里面一行：卡组名（取 `::` 后最后一段，即 `Dance`）+ 三个数字（颜色 newBlue / learnRed / reviewGreen，字重 600）；右边 `GlassIconButton(Icons.more_horiz)`。三个玻璃放进一个 `LiquidGlassBlendGroup(blend: 20)`，用 `LiquidGlass.grouped`。
- [x] 5.3 `GlassCard`：参数 `front`、`back`、`tag`、`bool showBack`、`VoidCallback onTap`。一个大玻璃 `LiquidRoundedSuperellipse(borderRadius: UgkRadius.card)`，宽 = 屏宽 − 2×UgkSpace.l，高 = 屏高 × 0.5。内容：
  - 正面：`front` 居中，字号 cardFront，字重 600。
  - 背面：上方 `front`（字号 22，透明度 0.6），中间一条 1px 分隔线（透明度 0.2），下方 `back`（字号 cardBack），最下方 `tag` 小胶囊（字号 12）。
  - 正反切换用 `AnimatedSwitcher`（250ms，淡入淡出 + 轻微缩放 0.98→1.0），**只切换 child 文字，不要给玻璃本身加 Opacity**。
- [x] 5.4 `GlassRatingBar`：参数 `List<String> labels`（4 个）、`ValueChanged<int> onRate`、`bool visible`。
  - 一行 4 个胶囊玻璃按钮（`LiquidRoundedSuperellipse(borderRadius: UgkRadius.button)`，高 64，等宽，间距 8），放进 `LiquidGlassBlendGroup(blend: 24)`，用 `LiquidGlass.grouped`。
  - 每个按钮用 `appearance` 着色：Again/Hard/Good/Easy 分别 tint `UgkColors.again/hard/good/easy`，tint 透明度 0.35（`color.withValues(alpha: 0.35)`）。深浅色分别用 `ios27RegularDark` / `ios27RegularLight`。
  - 按钮内两行字：上行按钮名（Again/Hard/Good/Easy，字号 button，字重 600），下行间隔 label（字号 buttonHint，透明度 0.7）。
  - `visible == false` 时：在同一位置显示一个整宽胶囊玻璃「显示答案」（高 64）。切换用 `LiquidGlassVisibility` 做淡入淡出（300ms），**不要用 Opacity**。
  - 按下时 `LiquidStretch` 轻微挤压 + `GlassGlow`。
- [x] 5.5 每个组件写完都 `flutter analyze` 一次。每完成两个组件提交推送一次。

## 步骤 6：页面（review_preview_screen.dart）
- [x] 6.1 `ReviewPreviewScreen` 是 StatefulWidget，状态只有 `bool showBack = false`。
- [x] 6.2 结构（照抄层级）：
```
Scaffold(backgroundColor: Colors.transparent, body:
  Stack(children: [
    Positioned.fill(child: UgkBackdrop()),
    SafeArea(child:
      LiquidGlassLayer(
        settings: LiquidGlassSettings.ios27Regular(brightness: b),
        defaultAppearance: LiquidGlassAppearance.ios27Regular(brightness: b),
        child: Column(children: [
          Padding(顶部 UgkSpace.s, 左右 UgkSpace.m) → GlassTopBar(...)
          Expanded → Center → GlassCard(showBack: showBack, onTap: 切换 showBack)
          Padding(左右 UgkSpace.m, 底部 UgkSpace.l) → GlassRatingBar(
              labels: fakeLabels, visible: showBack,
              onRate: (_) => setState(() => showBack = false))
        ]),
      ),
    ),
  ]),
)
```
- [x] 6.3 点「显示答案」或点卡片 → `showBack = true`；点任意评分按钮 → 回到正面。
- [x] 6.4 `app.dart` 的 `home` 直接是 `ReviewPreviewScreen`，`themeMode: ThemeMode.system`，Material 3。状态栏透明（`SystemUiOverlayStyle`，图标颜色跟随深浅色）。
- [x] 6.5 提交推送。

## 步骤 7：真机运行和截图
- [ ] 7.1 `cd app && flutter run --release --enable-flutter-gpu`（release 模式看真实性能）。
- [ ] 7.2 确认日志里**没有** liquid_glass 关于「多次 backdrop copy」的警告（debug 模式下会打印）。如果有，说明有组件自己建了 layer，按步骤 5 的规则改。
- [ ] 7.3 截 4 张图（手机系统设置切换深浅色）：
  1. 浅色 · 正面
  2. 浅色 · 背面（评分按钮出现）
  3. 深色 · 正面
  4. 深色 · 背面
- [ ] 7.4 截图放到 `docs/screenshots/m0/`，文件名 `light-front.png`、`light-back.png`、`dark-front.png`、`dark-back.png`，提交推送。
- [ ] 7.5 再录一段 10 秒以内的屏幕录像（翻面 → 点 Good → 回正面），放同目录 `flip.mp4`（超过 10MB 就不提交，直接发给开哥）。
- [ ] 7.6 开 Draft PR `M0 视觉样稿` 到 main，正文贴 4 张截图。

## 验收清单（汇报时原样贴，逐项勾选）
- [ ] 只加了 `liquid_glass_renderer` 一个依赖
- [ ] 页面和组件里没有写死的颜色数值（都来自 tokens.dart）
- [ ] 整页只有一个 `LiquidGlassLayer`，release 模式运行流畅、无 backdrop copy 警告
- [ ] 4 张截图 + 录像已提交（或已发送）
- [ ] 没做任何其他页面
- [ ] Draft PR 已开，未合并

## 问题记录
（照做跑不通时写在这里：哪一步、做了什么、报错原文）
