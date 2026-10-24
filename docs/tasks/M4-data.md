# M4：数据库（drift）+ 仓库层（packages/data）——本机验证

- 分支：`feat/m4-data`（**开哥已经把全部代码推到这个分支**，你不要新建分支）
- 预计：一个 agent 一次完成，30 分钟内
- 依赖：M1、M2、M3 已合并 main。
- 完成后打 tag：`m4-done`（开哥审核通过后才打，你不要打）

## 0. 背景（只读）
新包 `packages/data`：drift 表结构 + `UgkRepository`（App 以后只通过它读写）。代码和测试主控已写好、在 Linux 上全绿。你的任务是**在你的机器上验证**它能编译、生成代码一致、测试通过，并修好环境差异导致的问题（只限环境问题）。

文件清单（都已在分支上）：
```
packages/data/pubspec.yaml            drift 2.35.3 / drift_dev 2.35.2 / build_runner 2.17.1 / sqlite3 3.8.0（版本锁死）
packages/data/lib/ugk_data.dart       导出
packages/data/lib/src/tables.dart     8 张表
packages/data/lib/src/database.dart   UgkDatabase（schemaVersion 1）
packages/data/lib/src/database.g.dart drift 生成的代码（已提交）
packages/data/lib/src/codecs.dart     preset / 字段 / 模板 的 JSON 编解码
packages/data/lib/src/repository.dart UgkRepository
packages/data/test/repository_test.dart  19 个测试
```

## 1. 硬性规则
- **不要改 `lib/` 和 `test/` 下的任何代码、任何期望值。** 跑不通就停下写「问题记录」。
- 不要加依赖、不要改版本号。
- `packages/core` 一个字都不要动。
- 唯一允许提交的改动：任务文件的勾选、`database.g.dart`（仅当 8.3 重新生成后有差异时）、问题记录。

---

## 步骤 1：拉代码
- [ ] 1.1 `git fetch && git checkout feat/m4-data && git pull`
- [ ] 1.2 `cd packages/data && dart pub get`，成功。

## 步骤 2：生成代码一致性
- [ ] 2.1 `dart run build_runner build --delete-conflicting-outputs`
- [ ] 2.2 `git status`：`lib/src/database.g.dart` **应当没有变化**。如果有变化，提交它（`M4: 重新生成 database.g.dart`），并在问题记录里写一句「g.dart 有差异，已提交」，继续往下。

## 步骤 3：静态检查和格式
- [ ] 3.1 `dart analyze` → `No issues found!`
- [ ] 3.2 `dart format --set-exit-if-changed lib test` → 退出码 0

## 步骤 4：测试
- [ ] 4.1 `dart test` → `+19: All tests passed!`
  - sqlite3 3.x 首次运行会执行 build hook 准备 sqlite 动态库，需要联网，等它跑完。
  - 如果报找不到 sqlite3 库：把报错原文写进问题记录，**不要**自己换包或改代码，停下汇报。
- [ ] 4.2 回到仓库根目录，`cd packages/core && dart test`，仍然全绿（确认没被影响）。

## 步骤 5：收尾
- [ ] 5.1 勾选本文件，提交推送：`M4: 本机验证通过`。
- [ ] 5.2 开 **Draft PR**：`feat/m4-data` → `main`，标题 `M4 数据库与仓库层`，正文贴验收清单。

## 验收清单（汇报时原样贴）
- [ ] build_runner 重新生成后 `database.g.dart` 无差异（或已提交差异并注明）
- [ ] `dart analyze` 无问题
- [ ] `dart format --set-exit-if-changed` 通过
- [ ] `packages/data`：`+19: All tests passed!`
- [ ] `packages/core`：全部通过
- [ ] 没有改 lib/ test/ 代码、没有改依赖
- [ ] Draft PR 已开，未合并

## 问题记录
（没有就留空）
