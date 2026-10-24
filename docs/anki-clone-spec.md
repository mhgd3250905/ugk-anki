# Anki Clone 设计规格书（面向 Android 开发者 Kai）

> 版本 v1.0 · 2026-10-24 · 只有文档，不含代码
> 目标：实现一个兼容 Anki 核心体验的间隔重复（Spaced Repetition）背卡 App。第一阶段只做单机版，sync 放在第二阶段。

---

## 0. 术语表

| 术语 | 含义 |
|---|---|
| Note | 一条“知识”，由多个 field 组成（比如 Front、Back） |
| Note Type | note 的模板类型，定义有哪些 field，以及有哪些 card template |
| Card Template | 用 field 渲染出卡片正面和背面的模板，一个 template 生成一张 card |
| Card | 真正被复习的单位，自带调度状态 |
| Deck | 卡组，card 属于某个 deck |
| Ease Factor (EF) | 难度系数，Anki 用千分比存储，2500 表示 250% |
| Interval (IVL) | 距离下次复习的天数 |
| Lapse | 已经进入复习阶段的卡被按了 Again（遗忘） |
| Learning / Relearning | 新卡的学习阶段 / 遗忘后的重学阶段，按分钟级 steps 推进 |
| Leech | 反复遗忘的“难缠卡” |

---

## 1. 调度算法

### 1.1 原始 SM-2（SuperMemo，Wozniak 1987）

- 每次复习给一个 0 到 5 分的 quality 评分 q。
- 间隔计算：I(1) = 1 天，I(2) = 6 天，从第 3 次起 I(n) = I(n-1) × EF。
- EF 更新：`EF' = EF + (0.1 − (5 − q) × (0.08 + (5 − q) × 0.02))`
  - 初始 EF 为 2.5，最小值 1.3（低于 1.3 就按 1.3 算）。
  - q=5 时 +0.10；q=4 时 +0；q=3 时 −0.14；q=2 时 −0.32；q=1 时 −0.54；q=0 时 −0.80。
- 如果 q < 3，重复次数从头开始（重新走 I(1)、I(2)），但 EF 不变（原文是只在评分后更新 EF，不同实现的处理略有差异）。
- 当天复习结束后，所有 q < 4 的卡要再复习一遍，直到都拿到 ≥ 4 分。

**示例**：EF=2.5，三次都打 q=4，EF 保持 2.5，间隔依次为 1 天、6 天、15 天、37.5 天（约 38 天）。

### 1.2 Anki 的 SM-2 变体（推荐实现这个）

和原版相比，主要有这些不同：
1. 评分只有 4 个按钮：Again / Hard / Good / Easy，没有 0 到 5 分。
2. 新卡先走分钟级的 **learning steps**，毕业后才进入按天计算的复习。原版没有这一阶段。
3. 遗忘（Again）不会把间隔清零回 1、6，而是走 relearning steps，并按 `New interval` 比例保留部分间隔。
4. EF 只在复习阶段调整，规则是固定的加减值：Again −20%，Hard −15%，Good 不变，Easy +15%。
5. 会把迟复习的天数算进去（delay bonus），还有 Interval Modifier、Easy Bonus、Fuzz 和 Maximum Interval。

#### 1.2.1 默认参数（Deck Options Preset）

| 参数 | 默认值 |
|---|---|
| Learning steps | 1m 10m |
| Graduating interval | 1 天 |
| Easy interval | 4 天 |
| Relearning steps | 10m |
| Minimum interval（遗忘后） | 1 天 |
| New interval（遗忘后保留比例） | 0%（即重置为 minimum interval） |
| Starting ease | 250%（2.5） |
| Easy bonus | 130%（1.3） |
| Hard interval | 120%（1.2） |
| Interval modifier | 100%（1.0） |
| Maximum interval | 36500 天 |
| Minimum ease | 130%（硬编码） |
| New cards/day | 20 |
| Maximum reviews/day | 200 |
| Leech threshold | 8 次 lapse |
| Leech action | Tag Only（可选 Suspend Card） |

#### 1.2.2 Learning 阶段（新卡，card.type = learning）

设 steps = [s1, s2, …, sn]，当前在第 k 步：

| 按钮 | 结果 |
|---|---|
| Again | 回到第 1 步，s1 之后再出现 |
| Hard | 停在当前步。若在第 1 步且有 ≥2 个 step，延迟取 (s1 + s2) / 2；若只有 1 个 step，延迟取 s1 × 1.5（但最多比 s1 多 1 天）。其他步重复当前步的延迟 |
| Good | 进入下一步；如果已是最后一步，就**毕业**，interval = Graduating interval（1 天），EF = Starting ease |
| Easy | 立刻毕业，interval = Easy interval（4 天） |

**示例**：默认 steps 1m 10m。新卡按 Good，10 分钟后再出现；再按 Good 就毕业，明天复习，EF=2.5。如果第一次按 Hard，则 (1+10)/2 = 5.5 分钟后再出现。

#### 1.2.3 Review 阶段（card.type = review）

设当前间隔为 I，EF 为 E，实际过期天数为 d（d = 今天 − 到期日，≥0），Interval Modifier 为 M：

| 按钮 | 新间隔 | EF 变化 |
|---|---|---|
| Again | 进入 relearning；lapses+1；relearning 完成后的间隔 = max(Minimum interval, I × New interval) | E − 0.20 |
| Hard | `I × HardInterval(1.2) × M`，且至少是 I + 1 | E − 0.15 |
| Good | `(I + d/2) × E × M`，且至少是 Hard 结果 + 1 | 不变 |
| Easy | `(I + d) × E × EasyBonus(1.3) × M`，且至少是 Good 结果 + 1 | E + 0.15 |

所有结果都要：EF 不低于 1.3；间隔不超过 Maximum interval；间隔取整；最后加上 **Fuzz**（随机抖动，避免同一天加的卡永远挤在同一天复习）。Fuzz 大致是：间隔 < 2.5 天不加；2.5 到 7 天 ±15%；7 到 20 天 ±10%；20 天以上 ±5%，抖动幅度至少 1 天。

> 注：Hard 和 Again 不享受过期奖励；Hard 在 v3 scheduler 里用的是 d=0。

#### 1.2.4 Relearning 阶段（遗忘后）

- 卡片进入 relearning steps（默认 10m）。各按钮的规则和 1.2.2 一样，但毕业时间隔取上面算出的 lapse 后间隔（默认 1 天）。在 relearning 里按 Easy，间隔再 +1 天。
- relearning 期间 EF 不再变化。

#### 1.2.5 完整数值示例

起始：新卡，steps 1m 10m，EF 2.5，M=1.0，无 fuzz，每次都按时复习（d=0）。

1. Day 0：Good，10 分钟后再出现；再按 Good 毕业，I=1，E=2.5。
2. Day 1：Good，I = 1 × 2.5 = 2.5，取整为 3（Anki 四舍五入），E=2.5。
3. Day 4：Good，I = 3 × 2.5 = 7.5，取整为 8。
4. Day 12：Easy，I = 8 × 2.5 × 1.3 = 26，E = 2.65。
5. Day 38：Hard，I = 26 × 1.2 = 31.2，取整为 31，E = 2.50。
6. Day 69：Again，lapses=1，E = 2.30，进入 relearning；10 分钟后按 Good，I = max(1, 31×0) = 1。
7. Day 70：Good，I = 1 × 2.3 = 2.3，取整为 2，且必须 ≥ Hard 结果 + 1，这里 Hard 结果为 max(1.2, 1+1) = 2，所以 Good 至少是 3，最终 I=3。

**迟复习示例**：I=10，E=2.5，晚了 4 天才复习（d=4）。Good：(10 + 2) × 2.5 = 30 天；Easy：(10 + 4) × 2.5 × 1.3 = 45.5，约 46 天。

### 1.3 FSRS（可选，第二阶段）

Anki 23.10 起内置了 FSRS（Free Spaced Repetition Scheduler）。它用 Difficulty、Stability、Retrievability 三个变量建模记忆，用户可以设定目标记忆率（Desired retention，默认 0.9），参数可以从用户自己的 review log 训练出来。通常在复习量更少的情况下达到同样的记忆率。建议：第一版实现 SM-2，但 **review log 要完整保存**（见 2.6），这样以后可以无痛切换到 FSRS。开源实现可以参考 open-spaced-repetition 组织下的项目（有 Kotlin/Java 移植版）。

---

## 2. 数据模型

建议用 SQLite（Room）。下面用表格描述，不写代码。时间统一用毫秒时间戳；“天”用相对于 collection 创建日的天数（day number），每日边界默认凌晨 4 点（Next day starts at 4:00）。

### 2.1 note_type（笔记类型）

| 字段 | 类型 | 说明 |
|---|---|---|
| id | long | 主键 |
| name | text | 比如 Basic、Basic (and reversed card)、Cloze |
| kind | int | 0=standard，1=cloze |
| fields | json/子表 | 有序的 field 列表：name、ord、字体等 |
| templates | json/子表 | card template 列表：name、ord、qfmt（正面模板）、afmt（背面模板） |
| css | text | 共享样式 |
| sort_field_idx | int | 浏览器里排序用哪个 field |
| mtime / usn | long / int | 修改时间 / 同步序号（第二阶段用） |

模板语法：`{{Front}}` 插入字段，`{{FrontSide}}` 在背面插入正面内容，`{{#Field}}...{{/Field}}` 字段非空才显示，`{{c1::text}}` 用于 cloze。

### 2.2 note（笔记）

| 字段 | 说明 |
|---|---|
| id | 主键 |
| guid | 全局唯一 ID，导入和同步时去重 |
| note_type_id | 外键 |
| fields | 各字段值，按 ord 顺序用 0x1F 分隔，或者用子表 |
| sort_field | 排序和搜索用的冗余字段 |
| checksum | 第一个字段的哈希，用于检查重复 |
| tags | 用空格分隔的标签 |
| mtime / usn | |

### 2.3 card（卡片）

| 字段 | 说明 |
|---|---|
| id | 主键（可以用创建时间戳） |
| note_id | 外键 |
| deck_id | 外键 |
| ord | 由第几个 template（或第几个 cloze 编号）生成 |
| type | 0=new，1=learning，2=review，3=relearning |
| queue | -3/-2=buried，-1=suspended，0=new，1=learning（分钟级），2=review，3=跨天的 learning |
| due | new：排序位置；learning：到期时间戳；review：到期的 day number |
| ivl | 当前间隔（天） |
| ease | EF，千分比（2500） |
| reps | 总复习次数 |
| lapses | 遗忘次数 |
| left | 剩余 learning steps 数 |
| flags | 颜色旗标 |
| mtime / usn | |

### 2.4 由 note 生成 card 的规则

- **Standard 类型**：对每个 template 渲染正面（qfmt）。渲染结果不为空（至少引用了一个非空字段），就生成一张 card，ord = template 序号。比如 Basic (and reversed) 有 2 个 template，每条 note 生成 2 张卡。
- **Cloze 类型**：扫描所有字段里的 `{{cN::...}}`，每个不同的 N 生成一张卡，ord = N−1。
- 编辑 note 后要重新计算：新出现的 template 或 cloze 编号就补卡；已经变空的卡不自动删，交给“Empty Cards”工具让用户确认后删除。
- 同一条 note 的兄弟卡（sibling）：复习一张后，另一张当天默认 bury，避免互相提示。

### 2.5 deck 与 deck_config

| deck 字段 | 说明 |
|---|---|
| id、name | name 用 `::` 表示层级，比如 English::Dance |
| config_id | 指向 preset |
| 今日计数 | new_today、review_today，按 day number 每天重置 |

deck_config（preset）保存 1.2.1 里所有参数，多个 deck 可以共用一个 preset。

### 2.6 revlog（复习日志，必须保存）

| 字段 | 说明 |
|---|---|
| id | 复习时间戳（ms） |
| card_id | |
| ease_button | 1=Again，2=Hard，3=Good，4=Easy |
| ivl | 新间隔（正数表示天，负数表示秒，用于 learning） |
| last_ivl | 旧间隔 |
| factor | 复习后的 EF |
| time_taken | 作答用时（ms，上限 60 秒） |
| type | 0=learn，1=review，2=relearn，3=filtered/cram，4=manual |

统计页面和 FSRS 都依赖这张表。

---

## 3. 调度与队列

### 3.1 每日上限

- New cards/day（默认 20）：当天最多引入多少张新卡。
- Maximum reviews/day（默认 200）：当天最多复习多少张到期卡。v3 里新卡也计入复习上限：复习数量快到上限时，新卡会相应减少。
- 父 deck 的上限也会限制子 deck；learning 卡不受上限限制。
- 每日边界：Next day starts at（默认 04:00 本地时间）。

### 3.2 三个队列和取卡顺序

1. **Learning / Relearning 队列（分钟级）**：只要到期就最优先出。如果当前时间 + Learn ahead limit（默认 20 分钟）之内会到期，而其他队列已经空了，可以提前展示。
2. **Review 队列**：今天及以前到期的复习卡。默认按到期日排序，同一天内随机。也可以选按 deck、按 ease 或 random。
3. **New 队列**：按 due（加入顺序）取，可以选 random。

新卡和复习卡的混合方式（New/review order）可选：和复习卡混合（默认）、先复习后新卡、先新卡后复习。跨天的 learning 卡（queue=3）当作复习卡处理。

### 3.3 Bury 与 Suspend

- Bury：今天先不出，第二天自动恢复（queue 设为 -2 或 -3）。
- Suspend：一直不出，直到用户手动恢复（queue=-1，type 和 ivl 保持不变）。

### 3.4 Leech 检测

- 每次 lapse 后检查：如果 lapses ≥ Leech threshold（默认 8），就标记为 leech。之后每再多 threshold/2 次（默认每多 4 次，即第 12、16 次）再提醒一次。
- 处理方式：给 note 加上 `leech` 标签；如果 Leech action 设为 Suspend Card，还要暂停这张卡。弹提示建议用户改写卡片内容。

---

## 4. UI 流程

### 4.1 首页（Deck 列表）
- 树形展示所有 deck，每行显示三个数字：New（蓝）、Learning（红）、Review（绿）。
- 入口：添加、浏览、统计、同步（第二阶段）、设置。

### 4.2 学习会话（Study Session）
1. 点击 deck，进入概览页：显示今天的三个数字和“开始学习”按钮。
2. 展示正面（question），用户回忆，点击“显示答案”。
3. 展示背面（answer），底部 4 个按钮，**每个按钮上标出预计的下次间隔**（比如 <1m、<6m、<10m、4d）。需要提前对 4 个按钮各算一遍调度结果。
4. 点按钮后：更新 card，写 revlog，取下一张卡。
5. 辅助操作：Undo（撤销上一次评分，需要保存评分前的快照）、Edit、Bury、Suspend、Flag、播放音频（TTS）。
6. 全部完成后显示“恭喜完成”，并提示下一张 learning 卡什么时候到期。
- 建议支持手势和快捷键：1 到 4 对应四个按钮，空格表示显示答案或 Good。

### 4.3 添加卡片（Add）
- 选择 note type 和 deck，然后按 field 输入，可以加标签。
- 保存时检查第一个字段是否重复（checksum），重复的话给出提示，但允许继续保存。
- 保存后按 2.4 的规则生成卡片，清空输入框，保留 note type、deck 和标签，方便连续添加。

### 4.4 浏览和编辑（Browse）
- 搜索语法（最少实现这些）：关键词、`deck:名字`、`tag:名字`、`is:new`、`is:due`、`is:suspended`、`prop:ivl>10`、`rated:1`、`added:7`。
- 列表可以切换 card 模式或 note 模式，列包括排序字段、deck、到期日、间隔、ease、lapses。
- 批量操作：改 deck、加减标签、suspend、重置为新卡（Forget）、手动设置到期日（Set due date）、删除。
- 点一条打开编辑器，修改后重新生成卡片（见 2.4）。

### 4.5 统计（Statistics）
数据全部来自 revlog 和 card 表：
- 今天：复习数量、用时、各按钮的比例、正确率。
- Future Due：未来每天的到期数量（柱状图）。
- Reviews：每天的复习数量和用时，按 learn、review、relearn 分色。
- Card counts：new、learning、young（ivl < 21 天）、mature（ivl ≥ 21 天）、suspended 各多少。
- Intervals 和 Ease 的分布直方图。
- Hourly breakdown：各时段的正确率。
- Answer buttons：young 卡和 mature 卡各自的按钮分布和正确率。

---

## 5. 导入与导出

### 5.1 CSV 或纯文本导入
- 支持的分隔符：Tab（默认）、逗号、分号、竖线，按第一行自动检测，也可以手动选。
- 文件头指令（Anki 2.1.55 及以后的格式），可以选择支持：`#separator:tab`、`#html:true`、`#notetype:Basic`、`#deck:English`、`#tags:dance`、`#columns:Front Back Tags`。
- 导入流程：选文件，预览前几行，把每一列映射到某个 field、Tags 或忽略，选 note type 和 deck，再选重复处理方式。
- 重复处理：按第一个字段或 guid 判断，可选“更新已有 note”“跳过”或“照样导入”。
- 编码统一用 UTF-8；字段里有分隔符或换行时用双引号包起来，引号写成两个双引号（RFC 4180）。
- HTML 开关：关闭时把 `<`、`>` 转义。

### 5.2 导出
- 纯文本 Notes：每行一条 note，字段之间用 Tab 分隔，可选是否带标签、是否保留 HTML，加上文件头指令。
- 纯文本 Cards：每行是渲染后的正面和背面。
- 完整备份（可选）：把数据库和媒体文件打包成 zip，用于备份或迁移。`.apkg` 兼容属于加分项，放在第二阶段。

---

## 6. 同步（第二阶段，概要）

AnkiWeb 的同步机制大致如下，可以作为自建同步服务的参考：
- 每个 collection 有 `mod`（最后修改时间）、`scm`（schema 修改时间）、`usn`（update sequence number）和 `ls`（上次同步时间）。
- 每次修改记录时，usn 设为 -1，表示本地未同步。
- 同步时先交换 meta：如果 scm 不一致（比如改了 note type 结构），只能**整库上传或下载（full sync）**，由用户选择保留哪边。
- scm 一致时做**增量同步**：客户端把 usn = -1 的记录（notes、cards、decks、configs、tags、revlog、删除记录 graves）发给服务端，服务端返回客户端上次同步之后服务端 usn 更大的变更。同一条记录冲突时按 mtime 新的为准。完成后，客户端把本地记录的 usn 更新为服务端的新 usn。
- 媒体文件单独同步，按文件名和哈希判断增删。
- 最后比较双方的卡片数量等校验信息（sanity check），不一致就要求 full sync。
- 自建方案：Anki 官方开源了 sync server（anki 仓库里的 `anki-sync-server`），可以直接部署来兼容官方协议；也可以做一套自己的 REST 增量同步，思路同上。

---

## 7. 建议的开发顺序

1. 数据层：2.1 到 2.6 的表，加上 note 生成 card 的逻辑。
2. 调度器：把 1.2 写成纯函数，输入 card、按钮、当前时间和 preset，输出新的 card 状态和 revlog。先用 1.2.5 的示例写单元测试。
3. 队列和每日上限（第 3 节），然后是学习界面（4.2）。
4. 添加和浏览（4.3、4.4），然后是 CSV 导入导出（第 5 节）。
5. 统计（4.5）。
6. 第二阶段：FSRS、同步、.apkg 兼容。

---

## 8. 参考来源

- Anki Manual – Deck Options（learning steps、各类 interval、ease、leech 等参数）：https://docs.ankiweb.net/deck-options.html
- Anki Manual – Studying（四个按钮的含义）：https://docs.ankiweb.net/studying.html
- Anki Manual – Leeches：https://docs.ankiweb.net/leeches.html
- Anki Manual – Importing / Exporting（文本格式和文件头）：https://docs.ankiweb.net/importing/text-files.html 、https://docs.ankiweb.net/exporting.html
- Anki Manual – Templates / Field Replacements：https://docs.ankiweb.net/templates/fields.html
- Anki Manual – Syncing 与 Sync Server：https://docs.ankiweb.net/syncing.html 、https://docs.ankiweb.net/sync-server.html
- Anki FAQ – What spaced repetition algorithm does Anki use?：https://faqs.ankiweb.net/what-spaced-repetition-algorithm.html
- Anki 源码（v3 scheduler，Rust）：https://github.com/ankitects/anki/tree/main/rslib/src/scheduler/states
- AnkiDroid 数据库结构 wiki：https://github.com/ankidroid/Anki-Android/wiki/Database-Structure
- SuperMemo SM-2 原始描述（Wozniak, 1990）：https://super-memory.com/english/ol/sm2.htm
- FSRS：https://github.com/open-spaced-repetition/fsrs4anki/wiki/ABC-of-FSRS

> 说明：表里的数值是按 Anki 官方手册和 SM-2 原文整理的默认值。v3 scheduler 中 Hard 按钮的首个 step 和 fuzz 的具体区间，以源码 `rslib/src/scheduler/states` 为准，实现前建议对照看一遍。
