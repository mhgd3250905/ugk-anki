# M6：CSV 导入导出 + 整库备份恢复——本机验证 + 真机走查

- 分支：`feat/m6-io`（**开哥已经把全部代码推到这个分支**，你不要新建分支）
- 预计：约 1 小时
- 依赖：M0～M5 已合并 main。
- tag `m6-done` 由开哥审核后打，你不要打。

## 0. 背景（只读）
首页右上角新增「⋯」按钮 → 底部玻璃面板「数据」：导入 CSV / TXT、导出全部笔记为 TXT、备份整个库、从备份恢复。
文件选择和保存用 `file_picker 13.1.0`（系统文件选择器 / 保存位置，属于系统界面，不算我们的弹窗）。
主控已在 Linux 上跑过：`packages/data` 32 个测试全绿（新增 13 个），`app` `flutter analyze` 0 问题、`flutter test` 7 个全绿（新增 2 个）。

新增 / 修改：
```
packages/data/lib/src/csv_codec.dart      parseCsv / writeCsv（引号、引号内换行、BOM、Anki #文件头、自动识别分隔符）
packages/data/lib/src/import_export.dart  importCsv / exportCsv / backupJson / restoreJson
packages/data/test/import_export_test.dart
app/pubspec.yaml                          新增 file_picker: 13.1.0
app/lib/data/app_files.dart               选文件 / 存文件（测试可替换）
app/lib/data/clock.dart                   新增 fileStamp()
app/lib/ui/glass/glass_kit.dart           新增 showGlassActions、showGlassConfirm、GlassPillButton.danger
app/lib/ui/screens/import_screen.dart     导入设置页
app/lib/ui/screens/deck_list_screen.dart  「⋯」菜单和四个操作
app/test/io_test.dart
docs/samples/m6-sample.csv                走查用样例（4 行，含引号、逗号、格内换行）
```

## 1. 硬性规则
- 不要改 `lib/`、`test/` 的逻辑和测试期望；跑不通就停下写问题记录（贴原文）。
- 允许的改动：`pubspec.lock`、`dart format` 纯格式、任务文件勾选、截图、问题记录。
- 不要改依赖版本。`flutter pub get` 冲突就原文记录并停下。
- Gradle 内存不够时可以临时改 `gradle.properties`，但**不要提交**。

## 步骤 1：编译检查
- [x] 1.1 `git fetch && git checkout feat/m6-io && git pull`
- [x] 1.2 `cd packages/data && dart pub get && dart test` → `+32: All tests passed!`
- [x] 1.3 `cd ../../app && flutter pub get`
- [x] 1.4 仓库根目录 `dart format app/lib app/test packages/data/lib packages/data/test`；有变化单独提交 `M6: dart format`
- [x] 1.5 `cd app && flutter analyze` → `No issues found!`
- [x] 1.6 `flutter test` → `+7: All tests passed!`
- [x] 1.7 提交推送（`M6: 本机编译与测试通过`）

## 步骤 2：真机准备
- [x] 2.1 **覆盖安装**（不要卸载，保留 M5 走查留下的数据）：`flutter run --release`。首页能看到 M5 的 `Default` 和 `Dance`。
- [x] 2.2 `adb push docs/samples/m6-sample.csv /sdcard/Download/m6-sample.csv`

## 步骤 3：真机走查（结果逐条写进「走查记录」）
- [x] 3.1 点首页「⋯」→ 底部升起玻璃面板，标题「数据」，4 项，最后一项「从备份恢复」是红色。**截图 `m6-menu.png`**。
- [x] 3.2 **先备份**：点「备份整个库」→ 系统保存界面 → 存到 Download → 顶部绿色提示「备份已保存」。记下文件名（`ugk-anki-backup-日期-时间.json`）。
- [x] 3.3 点「导入 CSV / TXT」→ 选 `m6-sample.csv` → 进入「导入」页：文件名、`5 行 · 3 列 · 分隔符 逗号`（含表头行）。「第一行」自动选中「是表头，跳过」（因为第一行是 front/back/tags）。类型默认 Basic；Front 映射「第 1 列 · Do you want to battle?」，Back「第 2 列 · 要不要 battle 一下？」，标签「第 3 列 · 街舞 battle」。**截图 `m6-import.png`**。
- [x] 3.4 先点「标签」行 → 面板里能看到「不导入」和第 1～3 列，选回「第 3 列」。卡组选 `English::Dance`。内容格式保持「纯文本」，重复保持「跳过」。
- [x] 3.5 点右上角「导入」→ 回到首页，顶部绿色提示「导入 4 条笔记（4 张卡片）」。`Dance` 蓝色新卡数 +4。
- [x] 3.6 进 `Dance` 复习：能看到 `Do you want to battle?`，标签「街舞 · battle」；`Two lines in one cell` 那张正面分两行显示。
- [x] 3.7 再导一次同一个文件（同样设置）→ 提示「导入 0 条笔记（0 张卡片），跳过重复 4」，橙色圆点。
- [x] 3.8 「导出全部笔记为 TXT」→ 存到 Download → 提示「已导出 N 条笔记」（N = M5 的 3 条 + 本次 4 条 = 7；如果你看到别的数字，如实记录）。`adb pull` 下来，用文本编辑器打开：前 5 行是 `#separator:tab`、`#html:true`、`#notetype column:1`、`#deck column:2`、`#tags column:…`。把前 8 行贴进走查记录。
- [x] 3.9 「从备份恢复」→ 选 3.2 的备份 → 玻璃确认弹窗「从备份恢复？」，按钮「取消 / 覆盖恢复（红）」。**截图 `m6-confirm.png`**。先点「取消」→ 什么都不变。
- [x] 3.10 再来一次，点「覆盖恢复」→ 绿色提示「已从备份恢复」，`Dance` 回到导入前的数字（刚导入的 4 张不见了）。
- [x] 3.11 「从备份恢复」→ 选 `m6-sample.csv`（不是备份）→ 点「覆盖恢复」→ 橙色提示「不是有效的备份文件」，数据不变。
- [x] 3.12 杀进程重开，数据和 3.10 后一致。
- [x] 3.13 深色模式下打开「⋯」面板和导入页各看一眼。**截图 `m6-dark-import.png`**。

## 步骤 4：入库
- [x] 4.1 4 张截图放 `docs/screenshots/m6/`：`m6-menu.png`、`m6-import.png`、`m6-confirm.png`、`m6-dark-import.png`
- [x] 4.2 走查记录逐条填写 3.1～3.13
- [x] 4.3 提交推送（`M6: 真机走查与截图`），开 **Draft PR** `feat/m6-io` → `main`，标题 `M6 导入导出与备份`

## 验收清单（汇报时原样贴）
- [ ] data 32 个测试全绿
- [ ] app analyze 无问题、7 个测试全绿
- [ ] 菜单、导入页、确认弹窗都是玻璃样式，没有系统弹窗
- [ ] CSV 导入（含引号、逗号、格内换行、标签列）正常
- [ ] 表头行自动识别并跳过；重复导入被跳过
- [ ] 导出文件头正确
- [ ] 备份 → 恢复正常；取消不动数据；错误文件有提示且不动数据
- [ ] 杀进程重开数据正确
- [ ] 4 张截图已入库，走查记录已填
- [ ] 没有改 lib/ test/ 逻辑、没有改依赖
- [ ] Draft PR 已开，未合并

## 走查记录
- 2.1 正常：`flutter build apk --release` 后用 `adb install -r` 覆盖安装（未卸载），首页保留 M5 的 `Default` 与 `Dance`。
- 2.2 正常：`m6-sample.csv` 已推送到 `/sdcard/Download/`（246 B）。
- 3.1 正常：「⋯」→ 底部升起玻璃面板「数据」，4 项，最后一项「从备份恢复」为红色；无系统弹窗。截图 `m6-menu.png`。
- 3.2 正常：系统保存界面默认 Download；保存后顶部绿色提示「备份已保存」；文件 `ugk-anki-backup-20261025-0051.json`（4.46 KB）。
- 3.3 正常（标签默认值除外）：导入页显示 `m6-sample.csv`、`5 行 · 3 列 · 分隔符 逗号`（含表头行）；「第一行」自动选中「是表头，跳过」；类型默认 `Basic`；Front「第 1 列 · Do you want to battle?」、Back「第 2 列 · 要不要 battle 一下？」。**标签实际默认「不导入」**，与任务预期「第 3 列 · 街舞 battle」不一致，见问题记录 1。截图 `m6-import.png`。
- 3.4 正常：标签面板含「不导入」和第 1～3 列，改选「第 3 列」；卡组改选 `English::Dance`；内容格式「纯文本」、重复「跳过」保持默认。
- 3.5 异常（与任务预期数字不符）：首次导入后 `Dance` 蓝色新卡为 3；因提示条未及时截到，恢复 3.2 的备份后按相同设置重导，绿色提示原文为「导入 3 条笔记（3 张卡片），跳过重复 1」，`Dance` 仍为 3。任务预期 4 条 / 4 张，原因见问题记录 2。
- 3.6 正常：进入 `Dance` 复习，首张 `Do you want to battle?` 标签显示「街舞 · battle」；第二张 `Let's cypher, then eat`，标签「街舞 · 日常」；第三张 `Two lines in one cell` 正面分两行显示，标签「测试」。两张按「简单」评完，剩 1 张新卡未评。
- 3.7 正常：同一文件、相同设置再导一次，橙色提示「导入 0 条笔记（0 张卡片），跳过重复 4」；`Dance` 计数不变（1 / 0 / 0）。
- 3.8 异常（与任务预期数字不符）：绿色提示「已导出 6 条笔记」（任务预期 7，原因同问题记录 2）；文件 `ugk-anki-20261025-0101.txt`（611 B）。前 8 行：
  ```text
  #separator:tab
  #html:true
  #notetype column:1
  #deck column:2
  #tags column:5
  Basic (and reversed card)	English::Dance	Do you want to join our cypher tonight?	今晚要不要来我们的 cypher 一起跳？	街舞 邀约
  Basic	English::Dance	I'm down	我可以 / 算我一个	街舞 邀约
  Cloze	English::Dance	Let's {{c1::battle}} after the {{c2::cypher}}		街舞 邀约
  ```
- 3.9 正常：选 3.2 的备份 → 玻璃确认弹窗「从备份恢复？」，含备份文件名与覆盖警告，按钮「取消 / 覆盖恢复（红）」；截图 `m6-confirm.png`。点「取消」→ 数据不变（当时 `Dance` 1 / 0 / 0；结束前在 0 / 0 / 0 状态复测，取消后仍为 0 / 0 / 0）。
- 3.10 正常：再次选择备份并点「覆盖恢复」→ 绿色提示「已从备份恢复」，`Dance` 回到 0 / 0 / 0；本次导入的 3 条笔记消失（任务原文为 4 条，实际导入 3 条）。
- 3.11 正常：选 `m6-sample.csv` → 点「覆盖恢复」→ 橙红色提示「不是有效的备份文件」，数据保持 0 / 0 / 0。
- 3.12 正常：`adb shell am force-stop com.ugk.ugk_anki` 后 monkey 重开，应用正常启动，`Default` / `Dance` 均为 0 / 0 / 0，与 3.10 后一致。为确认 M5 卡片仍在，重开后再导出，提示「已导出 3 条笔记」（`ugk-anki-20261025-0107.txt`），内容为 M5 的 3 条笔记，导入的 3 条不在。
- 3.13 正常：`adb shell cmd uimode night yes` 后首页、「⋯」面板、导入页均为深色玻璃，文字清晰；截图 `m6-dark-import.png`。随后 `cmd uimode night no` 切回浅色，首页恢复浅色。
- 全局：菜单、导入页、确认弹窗、提示条均为玻璃样式，未出现系统白色弹窗、底部黑色 SnackBar 或下拉菜单。

## 问题记录
- 3.3 标签默认值：导入页「标签」默认「不导入」，任务文件预期「第 3 列 · 街舞 battle」。`parseCsv` 只从 `#tags column:` 文件头取标签列，普通 `tags` 表头不参与映射；`ImportScreen` 用 `table.tagsColumn` 初始化，因此默认不导入。按 3.4 手动选「第 3 列」后功能正常（导入与导出的标签均正确）。未改 `lib/`；建议后续更新任务文案或评估普通 `tags` 表头的自动映射。
- 3.5 / 3.8 数量：实际导入 3 条笔记 / 3 张卡片、跳过重复 1，导出 6 条；任务预期 4 / 4 与 7。`m6-sample.csv` 的 `I'm down` 与 M5 已有 `Basic` 笔记「I'm down」同类型且首字段相同，设置「跳过」时按类型范围判重（`packages/data/lib/src/import_export.dart`），该行被跳过。导入、去重、导出行为符合实现；差异来自任务预期未计入这条重复。未改代码与测试。
- 走查过程：系统文件选择器滑动未停稳时曾误触打开一个 MP4 的导入页（6388 行 / 9 列）及 SmartFit 应用；两次都没有执行导入，数据未变。之后改用 `uiautomator dump` 精确坐标并等待列表停稳。为截到首次导入提示原文，曾用 3.2 的备份恢复后按相同设置重导，再继续 3.6～3.13；最终数据已回到 M5 状态（重启后再导出验证为 3 条）。
- 构建：本机 Gradle 默认 8G 堆在先前构建中触发 native OOM；M6 release 构建临时把 `app/android/gradle.properties` 改为 3G，构建与覆盖安装成功后已恢复原值，不提交。

---

# M6.1 补充：体验修复（主控已推到同一分支，走查后一起合并）

开哥真机反馈三个问题，主控已修：
1. **卡组缩进看着像挂在 Default 下面**：`English::Dance` 缩进了但上级 `English` 没建。现在新建 / 导入子卡组会自动补上级卡组，首页打开时也会给旧数据补齐。
2. **软键盘挡住弹窗按钮**：所有玻璃弹窗（新建卡组、确认、选择面板）在键盘弹出时整体抬到键盘上方，放不下就可滚动。添加页本来就会随键盘收缩并滚动。
3. **面向中国用户**：内置卡组 Default 显示为「默认」；首页三列数字上方加说明「新卡 / 在学 / 待复习」；新建卡组提示改成「例如 英语::口语（:: 表示下一级）」。
4. **提示语看不懂**：类型改成中文（问答 / 问答 · 正反都考 / 填空），字段改成中文（正面 / 背面 / 正文 / 补充说明）。添加前先检查并给人话提示；填空类型新增「挖空」按钮（选中文字一点就变成挖空）。去掉了 `{{c1::…}}`、`leech`、原始异常文本这类提示。

主控本地：data `+33` 全绿，app analyze 0 问题、`+14` 全绿。

## 步骤 5：编译检查
- [ ] 5.1 `git pull`，`cd packages/data && dart test` → `+33: All tests passed!`
- [ ] 5.2 仓库根 `dart format app/lib app/test packages/data/lib packages/data/test`，有变化单独提交 `M6.1: dart format`
- [ ] 5.3 `cd app && flutter analyze` → 无问题；`flutter test` → `+14: All tests passed!`

## 步骤 6：真机走查（覆盖安装，不卸载）
- [ ] 6.1 首页：`Default` 显示为「默认」；出现 `English` 卡组，`Dance` 缩进在它下面，「默认」与 `English` 左边对齐；数字上方有「新卡 / 在学 / 待复习」，和下面的数字右对齐。**截图 `m61-decks.png`**
- [ ] 6.2 点「新建卡组」，键盘弹出后弹窗整体在键盘上方，「取消 / 创建」两个按钮完整可见可点。**截图 `m61-keyboard.png`**。输入 `Test::A::B` 创建 → 首页出现 `Test`、`A`、`B` 三层。
- [ ] 6.3 「⋯ → 从备份恢复」的确认弹窗、卡组选择面板在键盘收起状态下显示正常（回归）。
- [ ] 6.4 添加页：类型显示「问答 / 问答 · 正反都考 / 填空」，字段显示「正面 / 背面」。什么都不填点「添加」→ 橙色提示「正面还没填」。
- [ ] 6.5 切到「填空」：字段「正文 / 补充说明」，正文下面有「挖空」按钮。输入 `巴黎是法国的首都` 直接点「添加」→ 提示「还没有要挖空的词：选中正文里的一段文字，再点「挖空」」。选中「法国」点「挖空」→ 正文变成 `巴黎是{{c1::法国}}的首都` → 点「添加」→「已添加 1 张卡片」。**截图 `m61-cloze.png`**（挖空后、添加前）
- [ ] 6.6 添加页最下面「标签」输入框获得焦点时，键盘不遮挡输入框（页面自动滚上去）。
- [ ] 6.7 导入页类型 / 字段也是中文。
- [ ] 6.8 3 张截图放 `docs/screenshots/m6/`，走查记录写在下面，提交推送 `M6.1: 真机走查`，PR 保持 Draft。

## M6.1 走查记录

## M6.1 问题记录
