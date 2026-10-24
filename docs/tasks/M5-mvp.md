# M5：能用的 MVP（卡组列表 / 复习 / 添加）——本机验证 + 真机走查

- 分支：`feat/m5-mvp`（**开哥已经把全部代码推到这个分支**，你不要新建分支）
- 预计：一个 agent 一次完成，约 1 小时（大部分是真机操作和截图）
- 依赖：M0～M4 已合并 main。
- 完成后打 tag：`m5-done`（开哥审核通过后才打，你不要打）

## 0. 背景（只读）
App 第一次接上真数据库：首页是卡组列表，点卡组进复习页（M0 的玻璃样式 + 真实队列 + 真实评分），右上角 + 进添加页。
主控在 Linux 上用 Flutter 3.44 + 玻璃库桩跑过 `flutter analyze`（0 问题）和 `flutter test`（4 个全绿），**但没有真机和真玻璃库**，所以本任务重点是你那边的真机验证。

本分支新增 / 修改的文件：
```
app/pubspec.yaml                         新增 drift 2.35.3、drift_flutter 0.3.1、ugk_core、ugk_data（path）
app/lib/main.dart                        启动时打开数据库
app/lib/app.dart                         首页改成卡组列表；RepoScope 包住所有页面
app/lib/data/clock.dart                  唯一读系统时间的地方
app/lib/data/app_db.dart                 openRepository()
app/lib/data/repo_scope.dart             InheritedWidget 传仓库
app/lib/ui/card_text.dart                卡片 HTML → 纯文本（MVP 先不渲染 HTML）
app/lib/ui/glass/glass_page.dart         公共页面底座 GlassPage / GlassPanel / GlassTitleRow
app/lib/ui/screens/deck_list_screen.dart 首页
app/lib/ui/screens/study_screen.dart     复习页
app/lib/ui/screens/add_note_screen.dart  添加页
app/test/widget_test.dart                4 个测试
```
M0 的玻璃组件（`lib/ui/glass/glass_card.dart` 等）和 `review_preview_screen.dart` 没有改。

## 1. 硬性规则
- **不要改 `lib/` 和 `test/` 的逻辑和测试期望。** 跑不通就停下写「问题记录」（贴报错原文）。
- 允许的改动只有：`pubspec.lock`、`dart format` 造成的纯格式变化、任务文件勾选、截图、问题记录。
- 不要加依赖、不要改版本号。如果 `flutter pub get` 版本冲突，原文写进问题记录，停下。
- 不要动 `packages/`。

---

## 步骤 1：拉代码、编译检查
- [x] 1.1 `git fetch && git checkout feat/m5-mvp && git pull`
- [x] 1.2 `cd app && flutter pub get` 成功。
- [x] 1.3 `dart format lib test`；如有变化，单独提交 `M5: dart format`。
- [x] 1.4 `flutter analyze` → `No issues found!`
- [x] 1.5 `flutter test` → `+4: All tests passed!`
- [x] 1.6 提交推送（`M5: 本机编译与测试通过`）。

## 步骤 1B：拉取「自有设计组件」更新（开哥要求：不要系统简陋弹窗）
主控新增 `app/lib/ui/glass/glass_kit.dart`，把所有系统控件换成我们自己的玻璃组件：
新建卡组弹窗 → `showGlassPrompt`（玻璃卡片 + 圆角输入框 + 两个胶囊按钮）；SnackBar → 顶部玻璃提示条 `showGlassToast`；
类型 ChoiceChip → `GlassSegmented`；卡组 DropdownButton → `GlassSelectRow` + 底部玻璃选择面板 `showGlassPicker`；
下划线输入框 → `GlassTextField`；转圈 → 不显示；「刷新」→ 玻璃胶囊按钮；主题主色改成我们的蓝、去掉水波纹。
- [x] 1B.1 `git pull`（如果你本地有未推送的走查记录，先提交再 pull）
- [x] 1B.2 `flutter pub get`、`dart format lib test`（有变化单独提交 `M5: dart format 2`）
- [x] 1B.3 `flutter analyze` → `No issues found!`
- [x] 1B.4 `flutter test` → `+5: All tests passed!`（新增 1 个：弹窗 + 选择面板 + 提示条）
- [x] 1B.5 提交推送（`M5: 设计组件更新后编译与测试通过`）。**之前已经做过的真机走查作废，从步骤 2 重新开始。**

## 步骤 2：真机安装
- [ ] 2.1 **先在手机上卸载旧的 ugk-anki**（M0 版本没有数据库，避免残留）。
- [ ] 2.2 `flutter run --release` 装到真机（浅色模式）。首次启动不能崩溃，首页显示标题「卡组」和一行「Default」，三个数字都是灰色 0。

## 步骤 3：真机走查（每一项照做，结果写在后面）
- [ ] 3.1 首页右上角「文件夹+」→ 屏幕变暗，中间浮出**玻璃卡片**弹窗（标题「新建卡组」、圆角浅色输入框、底部两个胶囊按钮「取消 / 创建」，创建是蓝色），**不能是系统白色弹窗、不能有下划线**。输入前**截图 `m5-dialog.png`**（键盘可以开着）。输入 `English::Dance` → 创建。列表出现 `Default` 和缩进的 `Dance`。再建一次同名 → 顶部浮出玻璃提示条（橙色小圆点）「卡组「English::Dance」已存在」，约 2 秒后自己消失，**不能是底部黑色 SnackBar**。
- [ ] 3.2 右上角「+」进添加页。类型是一排胶囊，选 **Basic (and reversed card)**（选中变蓝）；点「卡组」那一行 → 底部升起**玻璃选择面板**，**截图 `m5-picker.png`**，选 `English::Dance`。正面 `Do you want to join our cypher tonight?`，背面 `今晚要不要来我们的 cypher 一起跳？`，标签 `街舞 邀约`，点右上角蓝色「添加」→ 顶部提示条（绿色小圆点）「已添加 2 张卡片」，两个输入框清空，标签保留。
- [ ] 3.3 继续添加：类型 **Basic**，正面 `I'm down`，背面 `我可以 / 算我一个` → 「已添加 1 张卡片」。
- [ ] 3.4 类型 **Cloze**，Text 填 `Let's {{c1::battle}} after the {{c2::cypher}}` → 「已添加 2 张卡片」。
- [ ] 3.5 类型 Basic，正面留空，背面随便写 → 顶部橙色提示条「不会生成卡片：正面为空，或填空没写 {{c1::…}}」，不添加。
- [ ] 3.6 返回首页：`Dance` 一行三个数字应为 **蓝 5、红 0、绿 0**（3 条笔记共 5 张新卡，还没开始学）。`Default` 仍是 0 0 0。
- [ ] 3.7 点 `Dance` 进复习页：顶栏显示 `Dance` 和计数 5 / 0 / 0；第一张是 `Do you want to join our cypher tonight?`，右上角标签「街舞 · 邀约」。**截图 `m5-study-front.png`**。
- [ ] 3.8 点卡片 → 显示背面，下面出现 4 个按钮，文字应为 `<1m 重来`、`<6m 困难`、`<10m 良好`、`4d 简单`。**截图 `m5-study-back.png`**。
- [ ] 3.9 点「良好」→ 下一张是 `I'm down`，计数变成 **3 / 1 / 0**（这张进学习中 +1 红；同笔记的反向卡今天被 bury，所以蓝色一下少 2）。
- [ ] 3.10 之后每张都按「简单」：依次是 `I'm down`、填空 `Let's [...] after the cypher`、然后第一张英文句子会**再出现一次**（它 10 分钟后到期，在 20 分钟提前量内，属于正常），再按「简单」→ 出现「完成 🎉 / 今天这个卡组没有要学的了」。第二张填空今天被 bury，不会出现。**截图 `m5-done.png`**。
- [ ] 3.11 返回首页，**截图 `m5-decks.png`**。
- [ ] 3.12 进添加页填一半内容，**截图 `m5-add.png`**（键盘收起状态）。
- [ ] 3.13 **杀掉 App 后重新打开**：首页数据还在（卡组、计数没有清零），说明数据库落盘了。
- [ ] 3.14 切到深色模式，首页和复习页各看一眼，文字清楚、没有崩溃。**截图 `m5-dark-study.png`**。

## 步骤 4：截图入库
- [ ] 4.1 8 张截图放到 `docs/screenshots/m5/`：`m5-dialog.png`、`m5-picker.png`、`m5-decks.png`、`m5-add.png`、`m5-study-front.png`、`m5-study-back.png`、`m5-done.png`、`m5-dark-study.png`。
- [ ] 4.2 在本文件「走查记录」里逐条写 3.1～3.14 的实际结果（一行一条，正常就写「正常」，不正常写看到了什么）。
- [ ] 4.3 提交推送（`M5: 真机走查与截图`），开 **Draft PR** `feat/m5-mvp` → `main`，标题 `M5 MVP`。

## 验收清单（汇报时原样贴）
- [ ] `flutter analyze` 无问题
- [ ] `flutter test` 5 个全绿
- [ ] 真机首次启动不崩溃
- [ ] 建卡组、加 Basic / 反向 / Cloze 笔记都正常
- [ ] 复习页能显示正面 / 背面 / 4 个间隔，评分后进入下一张
- [ ] 能复习到「完成」
- [ ] 杀进程重开数据还在
- [ ] 深色模式正常
- [ ] 整个 App 看不到系统白色弹窗、底部黑色提示条、下拉菜单、紫色控件、转圈
- [ ] 8 张截图已入库，走查记录已填
- [ ] 没有改 lib/ test/ 逻辑、没有改依赖
- [ ] Draft PR 已开，未合并

## 走查记录
（3.1～3.14 每条一行）

## 问题记录
（没有就留空）
