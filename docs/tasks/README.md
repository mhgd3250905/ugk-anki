# 任务总表

**当前任务：M0、M2、M3（三个互不依赖，可以三个 agent 同时做）**

| 编号 | 文件 | 分支 | 内容 | 状态 |
|---|---|---|---|---|
| M0 | `M0-visual.md` | `feat/m0-visual` | 液态玻璃复习页静态样稿，出 4 张截图 | 待开始 |
| M1 | `M1-scheduler.md` | `feat/m1-scheduler` | 纯 Dart 调度器 + 单元测试 | 已完成（tag `m1-done`） |
| M2 | `M2-notes.md` | `feat/m2-notes` | 纯 Dart：笔记类型、模板渲染、生成卡片 | 待开始 |
| M3 | `M3-queue.md` | `feat/m3-queue` | 纯 Dart：每日分界、今日队列、每日上限 | 待开始 |
| M4 | 待写 | | 数据库（drift）+ 仓库层 | 未开放 |
| M5 | 待写 | | 能用的 MVP：卡组列表、复习、添加 | 未开放 |
| M6 | 待写 | | CSV 导入导出、备份 | 未开放 |
| M7 | 待写 | | 浏览编辑、搜索、批量、Leech | 未开放 |
| M8 | 待写 | | 统计、TTS | 未开放 |

M4 及以后的任务文件，等 M2、M3 审核通过后再写；M5 的界面还要等 M0 截图被开哥确认。**不要提前做。**

注意：M2 和 M3 都会在 `packages/core/lib/ugk_core.dart` 末尾加 export，合并时的冲突由开哥那边处理，你不用管。

## 仓库最终目录结构（供参考，每个任务只建自己负责的部分）
```
ugk-anki/
  AGENTS.md
  docs/
    anki-clone-spec.md        规格书（只读）
    tasks/                    任务文件
  packages/
    core/                     纯 Dart：调度器、队列、模板、CSV（M1 开始）
  app/                        Flutter App（M0 开始）
    lib/
      ui/glass/               液态玻璃组件库
      ui/screens/             页面
      data/                   drift 数据库（M4）
```
