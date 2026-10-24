# 任务总表

**当前任务：M0 和 M1（两个互不依赖，可以两个 agent 同时做，也可以一个 agent 先 M1 后 M0）**

| 编号 | 文件 | 分支 | 内容 | 状态 |
|---|---|---|---|---|
| M0 | `M0-visual.md` | `feat/m0-visual` | 液态玻璃复习页静态样稿，出 4 张截图 | 待开始 |
| M1 | `M1-scheduler.md` | `feat/m1-scheduler` | 纯 Dart 调度器 + 单元测试 | 待开始 |
| M2 | 待写 | | 数据库（drift）+ 笔记生成卡片 | 未开放 |
| M3 | 待写 | | 能用的 MVP：卡组列表、复习、添加 | 未开放 |
| M4 | 待写 | | CSV 导入导出、备份 | 未开放 |
| M5 | 待写 | | 浏览编辑、搜索、批量、Leech | 未开放 |
| M6 | 待写 | | 统计、TTS | 未开放 |

M2 及以后的任务文件，等 M0 的截图被开哥确认、M1 的 PR 被审核后再写。**不要提前做。**

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
      data/                   drift 数据库（M2）
```
