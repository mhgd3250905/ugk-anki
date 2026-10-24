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
- [ ] 1.1 `git fetch && git checkout feat/m6-io && git pull`
- [ ] 1.2 `cd packages/data && dart pub get && dart test` → `+32: All tests passed!`
- [ ] 1.3 `cd ../../app && flutter pub get`
- [ ] 1.4 仓库根目录 `dart format app/lib app/test packages/data/lib packages/data/test`；有变化单独提交 `M6: dart format`
- [ ] 1.5 `cd app && flutter analyze` → `No issues found!`
- [ ] 1.6 `flutter test` → `+7: All tests passed!`
- [ ] 1.7 提交推送（`M6: 本机编译与测试通过`）

## 步骤 2：真机准备
- [ ] 2.1 **覆盖安装**（不要卸载，保留 M5 走查留下的数据）：`flutter run --release`。首页能看到 M5 的 `Default` 和 `Dance`。
- [ ] 2.2 `adb push docs/samples/m6-sample.csv /sdcard/Download/m6-sample.csv`

## 步骤 3：真机走查（结果逐条写进「走查记录」）
- [ ] 3.1 点首页「⋯」→ 底部升起玻璃面板，标题「数据」，4 项，最后一项「从备份恢复」是红色。**截图 `m6-menu.png`**。
- [ ] 3.2 **先备份**：点「备份整个库」→ 系统保存界面 → 存到 Download → 顶部绿色提示「备份已保存」。记下文件名（`ugk-anki-backup-日期-时间.json`）。
- [ ] 3.3 点「导入 CSV / TXT」→ 选 `m6-sample.csv` → 进入「导入」页：文件名、`5 行 · 3 列 · 分隔符 逗号`（含表头行）。「第一行」自动选中「是表头，跳过」（因为第一行是 front/back/tags）。类型默认 Basic；Front 映射「第 1 列 · Do you want to battle?」，Back「第 2 列 · 要不要 battle 一下？」，标签「第 3 列 · 街舞 battle」。**截图 `m6-import.png`**。
- [ ] 3.4 先点「标签」行 → 面板里能看到「不导入」和第 1～3 列，选回「第 3 列」。卡组选 `English::Dance`。内容格式保持「纯文本」，重复保持「跳过」。
- [ ] 3.5 点右上角「导入」→ 回到首页，顶部绿色提示「导入 4 条笔记（4 张卡片）」。`Dance` 蓝色新卡数 +4。
- [ ] 3.6 进 `Dance` 复习：能看到 `Do you want to battle?`，标签「街舞 · battle」；`Two lines in one cell` 那张正面分两行显示。
- [ ] 3.7 再导一次同一个文件（同样设置）→ 提示「导入 0 条笔记（0 张卡片），跳过重复 4」，橙色圆点。
- [ ] 3.8 「导出全部笔记为 TXT」→ 存到 Download → 提示「已导出 N 条笔记」（N = M5 的 3 条 + 本次 4 条 = 7；如果你看到别的数字，如实记录）。`adb pull` 下来，用文本编辑器打开：前 5 行是 `#separator:tab`、`#html:true`、`#notetype column:1`、`#deck column:2`、`#tags column:…`。把前 8 行贴进走查记录。
- [ ] 3.9 「从备份恢复」→ 选 3.2 的备份 → 玻璃确认弹窗「从备份恢复？」，按钮「取消 / 覆盖恢复（红）」。**截图 `m6-confirm.png`**。先点「取消」→ 什么都不变。
- [ ] 3.10 再来一次，点「覆盖恢复」→ 绿色提示「已从备份恢复」，`Dance` 回到导入前的数字（刚导入的 4 张不见了）。
- [ ] 3.11 「从备份恢复」→ 选 `m6-sample.csv`（不是备份）→ 点「覆盖恢复」→ 橙色提示「不是有效的备份文件」，数据不变。
- [ ] 3.12 杀进程重开，数据和 3.10 后一致。
- [ ] 3.13 深色模式下打开「⋯」面板和导入页各看一眼。**截图 `m6-dark-import.png`**。

## 步骤 4：入库
- [ ] 4.1 4 张截图放 `docs/screenshots/m6/`：`m6-menu.png`、`m6-import.png`、`m6-confirm.png`、`m6-dark-import.png`
- [ ] 4.2 走查记录逐条填写 3.1～3.13
- [ ] 4.3 提交推送（`M6: 真机走查与截图`），开 **Draft PR** `feat/m6-io` → `main`，标题 `M6 导入导出与备份`

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

## 问题记录
