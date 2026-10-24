# M1：调度器（纯 Dart，packages/core）

- 分支：`feat/m1-scheduler`（从 `main` 拉）
- 预计：一个 agent 一次完成
- 依赖：无（不需要 Flutter，只需要 Dart SDK；Flutter 自带的 `dart` 命令即可）
- 完成后打 tag：`m1-done`（只有开哥审核通过后才打，你不要打）

## 0. 背景（只读，不用做）
本任务把 Anki 的 v3 调度器（SM-2 变体）翻译成 Dart。参考的 Anki 源码在
`https://github.com/ankitects/anki/tree/main/rslib/src/scheduler/states`，
文件 `steps.rs`、`fuzz.rs`、`learning.rs`、`review.rs`、`relearning.rs`。
本文件已经把需要的逻辑全部写出来了，**照本文件写即可，不需要读 Rust 源码**。
FSRS、提前复习（filtered deck）、load balancer 本期都**不做**。

## 1. 硬性规则
- `packages/core` 不能依赖 Flutter。`pubspec.yaml` 只允许 `test` 一个 dev 依赖，不允许任何 dependencies。
- 不允许调用 `DateTime.now()`；不允许无种子的 `Random()`。
- **难度系数（ease）一律用整数千分比存储和加减**：2.5 存成 `2500`，Again 是 `-200`，Hard `-150`，Easy `+150`，最低 `1300`。只在乘法计算间隔时临时转换成 `ease / 1000.0`。这样可以避免浮点误差，测试数值依赖这一点。
- 四舍五入一律用 Dart 的 `double.round()`（.5 远离零，和 Rust 一致）；向下取整用 `.floor()`。
- 每个公开类和函数写一行中文 doc 注释。

---

## 步骤 1：建包
- [x] 1.1 新建目录 `packages/core`，在里面执行 `dart create -t package ugk_core --force .`（或手动建），然后删掉生成的示例代码和示例测试。
- [x] 1.2 `packages/core/pubspec.yaml` 改成：
```yaml
name: ugk_core
description: ugk-anki 核心逻辑（纯 Dart）
version: 0.1.0
publish_to: none
environment:
  sdk: ^3.5.0
dev_dependencies:
  test: ^1.25.0
```
- [x] 1.3 建以下空文件（后面步骤填内容）：
```
packages/core/lib/ugk_core.dart                 // 只写 export
packages/core/lib/src/scheduler/preset.dart
packages/core/lib/src/scheduler/learning_steps.dart
packages/core/lib/src/scheduler/fuzz.dart
packages/core/lib/src/scheduler/states.dart
packages/core/lib/src/scheduler/next_states.dart
packages/core/lib/src/scheduler/answer.dart
packages/core/lib/src/scheduler/interval_format.dart
packages/core/lib/src/model/card.dart
packages/core/lib/src/model/revlog.dart
packages/core/test/learning_steps_test.dart
packages/core/test/fuzz_test.dart
packages/core/test/learning_test.dart
packages/core/test/review_test.dart
packages/core/test/relearning_test.dart
packages/core/test/answer_test.dart
packages/core/test/interval_format_test.dart
packages/core/test/spec_walkthrough_test.dart
```
- [x] 1.4 `ugk_core.dart` 内容：把 `lib/src/` 下所有文件 `export` 出来。
- [x] 1.5 `cd packages/core && dart pub get && dart analyze` 无报错。提交推送。

---

## 步骤 2：preset.dart（卡组参数）

```dart
/// 达到 leech 阈值后的处理方式
enum LeechAction { suspend, tagOnly }

/// 卡组参数（对应 Anki 的 Deck Options Preset）
class DeckPreset {
  final List<double> learnSteps;        // 分钟，默认 [1, 10]
  final List<double> relearnSteps;      // 分钟，默认 [10]
  final int graduatingIntervalGood;     // 天，默认 1
  final int graduatingIntervalEasy;     // 天，默认 4
  final int initialEase;                // 千分比，默认 2500
  final double easyMultiplier;          // 默认 1.3
  final double hardMultiplier;          // 默认 1.2
  final double intervalMultiplier;      // 默认 1.0
  final double lapseMultiplier;         // 遗忘后保留比例，默认 0.0
  final int minimumLapseInterval;       // 天，默认 1
  final int maximumReviewInterval;      // 天，默认 36500
  final int leechThreshold;             // 默认 8
  final LeechAction leechAction;        // 默认 tagOnly
  final int newPerDay;                  // 默认 20（M1 只存，不用）
  final int reviewsPerDay;              // 默认 200（M1 只存，不用）
  final int dayRolloverHour;            // 默认 4（M1 只存，不用）
  final int learnAheadSecs;             // 默认 1200（M1 只存，不用）
  final bool buryNewSiblings;           // 默认 true（M1 只存，不用）
  final bool buryReviewSiblings;        // 默认 true（M1 只存，不用）
  const DeckPreset({ ...所有字段带上面的默认值... });
  DeckPreset copyWith({ ...所有字段可选... });
}
```
- [x] 2.1 按上面写完，所有字段 `final`，构造函数 `const`，默认值必须和注释一致。
- [x] 2.2 写 `copyWith`。提交推送。

---

## 步骤 3：learning_steps.dart（分钟级步骤）

逐行照抄下面的逻辑（这是 Anki `steps.rs` 的翻译）：

```dart
const int kDaySecs = 86400;

/// 学习/重学步骤计算
class LearningSteps {
  final List<double> steps; // 分钟
  const LearningSteps(this.steps);

  static int _toSecs(double minutes) => (minutes * 60).truncate();

  /// remaining 是“剩余步数”，可能带千位（Anki 旧格式），只取 % 1000
  int _index(int remaining) {
    final total = steps.length;
    final i = total - (remaining % 1000);
    final clamped = i < 0 ? 0 : i;
    final maxIdx = total - 1 < 0 ? 0 : total - 1;
    return clamped > maxIdx ? maxIdx : clamped;
  }

  int? _secsAt(int index) =>
      (index >= 0 && index < steps.length) ? _toSecs(steps[index]) : null;

  /// Again：回到第 1 步。没有步骤时返回 null
  int? againDelaySecs() => _secsAt(0);

  /// Hard：第 1 步特殊处理，其他步重复当前步
  int? hardDelaySecs(int remaining) {
    final idx = _index(remaining);
    final current = _secsAt(idx) ?? (steps.isEmpty ? null : _toSecs(steps.first));
    if (current == null) return null;
    if (idx != 0) return current;
    final next = _secsAt(1);
    if (next != null) return _maybeRoundInDays((current + next) ~/ 2);
    final a = current * 3 ~/ 2;
    final b = current + kDaySecs;
    return _maybeRoundInDays(a < b ? a : b);
  }

  /// Good：进入下一步；已经是最后一步返回 null（表示毕业）
  int? goodDelaySecs(int remaining) => _secsAt(_index(remaining) + 1);

  /// 当前步的延迟（写 revlog 的 last_ivl 用）
  int currentDelaySecs(int remaining) => _secsAt(_index(remaining)) ?? 0;

  /// 按 Good 后的剩余步数
  int remainingForGood(int remaining) {
    final r = steps.length - (_index(remaining) + 1);
    return r < 0 ? 0 : r;
  }

  /// 按 Again 后的剩余步数
  int remainingForFailed() => steps.length;

  bool get isEmpty => steps.isEmpty;
}

int _maybeRoundInDays(int secs) =>
    secs > kDaySecs ? (secs / kDaySecs).round() * kDaySecs : secs;
```
- [x] 3.1 写完上面代码。
- [x] 3.2 `test/learning_steps_test.dart`，下面每一行一个断言，**全部必须通过**：

| steps（分钟） | remaining | againDelaySecs | hardDelaySecs | goodDelaySecs |
|---|---|---|---|---|
| [10] | 1 | 600 | 900 | null |
| [4320]（3 天） | 1 | 259200 | 345600 | null |
| [1, 10] | 2 | 60 | 330 | 600 |
| [1, 10] | 1 | 60 | 600 | null |
| [1, 10, 100] | 3 | 60 | 330 | 600 |
| [1, 10, 100] | 2 | 60 | 600 | 6000 |
| [1, 10, 100] | 1 | 60 | 6000 | null |

另加：`[1,10]` 的 `remainingForGood(2) == 1`，`remainingForGood(1) == 0`，`remainingForFailed() == 2`。

- [x] 3.3 `dart test test/learning_steps_test.dart` 全绿。提交推送。

---

## 步骤 4：fuzz.dart（间隔随机抖动）

```dart
/// fuzzFactor 为 null 表示不抖动；否则是 [0,1) 之间的数
int withReviewFuzz(double? fuzzFactor, double interval, int minimum, int maximum) {
  if (fuzzFactor == null) {
    return interval.round().clamp(minimum, maximum);
  }
  final (lower, upper) = constrainedFuzzBounds(interval, minimum, maximum);
  return (lower + fuzzFactor * (1 + upper - lower)).floor();
}

(int, int) constrainedFuzzBounds(double interval, int minimum, int maximum) {
  final mn = minimum < maximum ? minimum : maximum;
  final iv = interval.clamp(mn.toDouble(), maximum.toDouble());
  var (lower, upper) = fuzzBounds(iv);
  lower = lower.clamp(mn, maximum);
  upper = upper.clamp(mn, maximum);
  if (upper == lower && upper > 2 && upper < maximum) upper = lower + 1;
  return (lower, upper);
}

(int, int) fuzzBounds(double interval) {
  final d = fuzzDelta(interval);
  return ((interval - d).round(), (interval + d).round());
}

/// 区间：<2.5 天不抖；2.5–7 天每天 +0.15；7–20 天每天 +0.1；20 天以上每天 +0.05；起步 1.0
double fuzzDelta(double interval) {
  if (interval < 2.5) return 0;
  const ranges = [(2.5, 7.0, 0.15), (7.0, 20.0, 0.10), (20.0, double.infinity, 0.05)];
  var delta = 1.0;
  for (final (start, end, factor) in ranges) {
    final span = (interval < end ? interval : end) - start;
    if (span > 0) delta += factor * span;
  }
  return delta;
}

/// 由卡片 id 和复习次数得到确定的抖动因子（同一张卡同一次复习结果固定）
double fuzzFactorFor(int cardId, int reps) => Random(cardId + reps).nextDouble();
```
（`Random` 来自 `dart:math`，这里带种子，允许使用。）

- [x] 4.1 写完上面代码。
- [x] 4.2 `test/fuzz_test.dart`，min=1，max=36500，全部必须通过：

| interval | fuzzDelta（误差 1e-9） | constrainedFuzzBounds | fuzz=0.0 | fuzz=0.5 | fuzz=0.99 |
|---|---|---|---|---|---|
| 1 | 0 | (1, 1) | 1 | 1 | 1 |
| 2 | 0 | (2, 2) | 2 | 2 | 2 |
| 3 | 1.075 | (2, 4) | 2 | 3 | 4 |
| 5 | 1.375 | (4, 6) | 4 | 5 | 6 |
| 10 | 1.975 | (8, 12) | 8 | 10 | 12 |
| 26 | 3.275 | (23, 29) | 23 | 26 | 29 |
| 30 | 3.475 | (27, 33) | 27 | 30 | 33 |
| 100 | 6.975 | (93, 107) | 93 | 100 | 107 |

另加：`withReviewFuzz(null, 2.5, 1, 36500) == 3`；`withReviewFuzz(null, 62.5, 1, 30) == 30`；`fuzzFactorFor(123, 4)` 连续调用两次结果相同。
- [x] 4.3 测试全绿。提交推送。

---

## 步骤 5：states.dart（调度状态）

```dart
/// 卡片的调度状态（纯值对象，不含数据库字段）
sealed class CardState { const CardState(); }

/// 新卡
class NewState extends CardState { const NewState(); }

/// 学习中（分钟级）
class LearnState extends CardState {
  final int remainingSteps;
  final int scheduledSecs;
  const LearnState({required this.remainingSteps, required this.scheduledSecs});
}

/// 复习中（天级）
class ReviewState extends CardState {
  final int scheduledDays;   // 上次安排的间隔
  final int elapsedDays;     // 距上次复习实际过了几天
  final int ease;            // 千分比
  final int lapses;
  final bool leeched;        // 本次评分是否触发 leech
  const ReviewState({required this.scheduledDays, required this.elapsedDays,
      required this.ease, required this.lapses, this.leeched = false});
  int get daysLate => elapsedDays - scheduledDays;
}

/// 遗忘后重学（分钟级），同时记住重学结束后要回到的复习状态
class RelearnState extends CardState {
  final LearnState learning;
  final ReviewState review;
  const RelearnState({required this.learning, required this.review});
}

/// 四个按钮
enum Rating { again, hard, good, easy }

/// 四个按钮各自的结果
class SchedulingStates {
  final CardState current, again, hard, good, easy;
  const SchedulingStates({required this.current, required this.again,
      required this.hard, required this.good, required this.easy});
  CardState forRating(Rating r) => switch (r) {
    Rating.again => again, Rating.hard => hard, Rating.good => good, Rating.easy => easy };
}
```
- [x] 5.1 写完。四个状态类都要实现 `==`、`hashCode`、`toString`（测试要比较对象）。
- [x] 5.2 `dart analyze` 无报错。提交推送。

---

## 步骤 6：next_states.dart（核心算法）

入口：
```dart
/// 计算当前状态下四个按钮分别会得到什么状态
SchedulingStates nextStates(CardState current, DeckPreset p, {double? fuzzFactor});
```
内部辅助（文件私有即可）：
```dart
(int, int) _minMax(DeckPreset p, int minimum) {
  final maximum = p.maximumReviewInterval < 1 ? 1 : p.maximumReviewInterval;
  return (minimum.clamp(1, maximum), maximum);
}
int _constrainPassing(DeckPreset p, double interval, int minimum, double? fuzz) {
  final (mn, mx) = _minMax(p, minimum);
  return withReviewFuzz(fuzz, interval * p.intervalMultiplier, mn, mx);
}
bool leechThresholdMet(int lapses, int threshold) {   // 这个要 public，测试要用
  if (threshold <= 0) return false;
  final half = (threshold / 2).ceil() < 1 ? 1 : (threshold / 2).ceil();
  return lapses >= threshold && (lapses - threshold) % half == 0;
}
```
设 `steps = LearningSteps(p.learnSteps)`，`relearn = LearningSteps(p.relearnSteps)`。

### 6.1 NewState
等同于 `LearnState(remainingSteps: steps.remainingForFailed(), scheduledSecs: 0)` 的 nextStates，但 `current` 字段保持原来的 NewState。

### 6.2 LearnState（设当前 remaining = r）
「毕业到 N 天」的写法：`ReviewState(scheduledDays: withReviewFuzz(fuzz, N.toDouble(), mn, mx), elapsedDays: 0, ease: p.initialEase, lapses: 0)`，其中 `(mn, mx) = _minMax(p, 1)`。

| 按钮 | 规则 |
|---|---|
| Again | `steps.againDelaySecs()` 不为 null → `LearnState(remainingSteps: steps.remainingForFailed(), scheduledSecs: 它)`；为 null（没有步骤）→ 毕业到 `graduatingIntervalGood` |
| Hard | `steps.hardDelaySecs(r)` 不为 null → `LearnState(remainingSteps: r, scheduledSecs: 它)`；否则毕业到 `graduatingIntervalGood` |
| Good | `steps.goodDelaySecs(r)` 不为 null → `LearnState(remainingSteps: steps.remainingForGood(r), scheduledSecs: 它)`；否则毕业到 `graduatingIntervalGood` |
| Easy | 一律毕业到 `graduatingIntervalEasy` |

### 6.3 ReviewState（设 s = 当前状态）
先算三个通过间隔：
```
current  = max(s.scheduledDays, 1).toDouble()
daysLate = max(s.daysLate, 0).toDouble()
ef       = s.ease / 1000.0
hardMin  = p.hardMultiplier <= 1.0 ? 0 : s.scheduledDays + 1
hard     = _constrainPassing(p, current * p.hardMultiplier, hardMin, fuzz)
goodMin  = p.hardMultiplier <= 1.0 ? s.scheduledDays + 1 : hard + 1
good     = _constrainPassing(p, (current + daysLate / 2) * ef, goodMin, fuzz)
easy     = _constrainPassing(p, (current + daysLate) * ef * p.easyMultiplier, good + 1, fuzz)
```
| 按钮 | 结果 |
|---|---|
| Again | 见下 |
| Hard | `ReviewState(scheduledDays: hard, elapsedDays: 0, ease: max(s.ease - 150, 1300), lapses: s.lapses)` |
| Good | `ReviewState(scheduledDays: good, elapsedDays: 0, ease: s.ease, lapses: s.lapses)` |
| Easy | `ReviewState(scheduledDays: easy, elapsedDays: 0, ease: s.ease + 150, lapses: s.lapses)` |

Again：
```
lapses    = s.lapses + 1
leeched   = leechThresholdMet(lapses, p.leechThreshold)
(mn, mx)  = _minMax(p, p.minimumLapseInterval)
failDays  = withReviewFuzz(fuzz, max(s.scheduledDays, 1) * p.lapseMultiplier, mn, mx)
failDays  = max(failDays, 1)
review    = ReviewState(scheduledDays: failDays, elapsedDays: 0,
                        ease: max(s.ease - 200, 1300), lapses: lapses, leeched: leeched)
如果 relearn.againDelaySecs() 不为 null：
    结果 = RelearnState(learning: LearnState(remainingSteps: relearn.remainingForFailed(),
                                             scheduledSecs: 它), review: review)
否则：结果 = review
```

### 6.4 RelearnState（设 s，r = s.learning.remainingSteps）
| 按钮 | 结果 |
|---|---|
| Again | `relearn.againDelaySecs()` 不为 null → `RelearnState(learning: LearnState(remainingSteps: relearn.remainingForFailed(), scheduledSecs: 它), review: s.review 但 elapsedDays=0)`；否则 → `s.review`（elapsedDays=0）。**ease、lapses 都不变** |
| Hard | `relearn.hardDelaySecs(r)` 不为 null → `RelearnState(learning: LearnState(remainingSteps: r, scheduledSecs: 它), review: s.review)`；否则 → `s.review` |
| Good | `relearn.goodDelaySecs(r)` 不为 null → `RelearnState(learning: LearnState(remainingSteps: relearn.remainingForGood(r), scheduledSecs: 它), review: s.review)`；否则 → `s.review`（重学毕业，间隔就是 Again 时算好的 failDays） |
| Easy | `ReviewState(scheduledDays: s.review.scheduledDays + 1, elapsedDays: 0, ease: s.review.ease, lapses: s.review.lapses)` |

注意：重学阶段任何按钮都**不改 ease**，返回的 ReviewState 的 `leeched` 一律为 false。

- [x] 6.5 写完 6.1–6.4。
- [x] 6.6 `test/learning_test.dart`（默认 preset，fuzz=null）：

| 起始状态 | Again | Hard | Good | Easy |
|---|---|---|---|---|
| NewState | Learn(r=2, 60s) | Learn(r=2, 330s) | Learn(r=1, 600s) | Review(4d, ease 2500, lapses 0) |
| Learn(r=2) | Learn(r=2, 60s) | Learn(r=2, 330s) | Learn(r=1, 600s) | Review(4d) |
| Learn(r=1) | Learn(r=2, 60s) | Learn(r=1, 600s) | Review(1d, ease 2500) | Review(4d) |

另加两条：
  - preset `learnSteps: [10]`，Learn(r=1) 的 Hard = Learn(r=1, 900s)。
  - preset `learnSteps: []`，NewState 的 Again/Hard/Good = Review(1d)，Easy = Review(4d)。

- [x] 6.7 `test/review_test.dart`（默认 preset，fuzz=null）。表中 Review(sd, el, ease) 表示 `scheduledDays, elapsedDays, ease`。

| 起始 Review(sd, el, ease) | Hard 天数 | Good 天数 | Easy 天数 | Hard 后 ease | Easy 后 ease |
|---|---|---|---|---|---|
| (1, 1, 2500) | 2 | 3 | 4 | 2350 | 2650 |
| (3, 3, 2500) | 4 | 8 | 10 | 2350 | 2650 |
| (8, 8, 2500) | 10 | 20 | 26 | 2350 | 2650 |
| (26, 26, 2650) | 31 | 69 | 90 | 2500 | 2800 |
| (31, 31, 2500) | 37 | 78 | 101 | 2350 | 2650 |
| (1, 1, 2300) | 2 | 3 | 4 | 2150 | 2450 |
| (10, 14, 2500)（迟 4 天） | 12 | 30 | 46 | 2350 | 2650 |
| (10, 10, 1300) | 12 | 13 | 17 | 1300 | 1450 |
| (10, 10, 2500) | 12 | 25 | 33 | 2350 | 2650 |
| (100, 100, 2500) | 120 | 250 | 325 | 2350 | 2650 |

Again 测试：
  - (31, 31, 2500, lapses 0) 按 Again → `RelearnState(learning: Learn(r=1, 600s), review: Review(1d, el 0, ease 2300, lapses 1, leeched false))`
  - (10, 10, 1300) 按 Again → review.ease == 1300
  - preset `relearnSteps: []`，(31,31,2500) 按 Again → 直接是 `Review(1d, ease 2300, lapses 1)`
  - preset `lapseMultiplier: 0.5`，(31,31,2500) 按 Again → review.scheduledDays == 16

参数测试：
  - preset `maximumReviewInterval: 30`，(25,25,2500)：Hard 30、Good 30、Easy 30
  - preset `intervalMultiplier: 0.5`，(10,10,2500)：Hard 11、Good 13、Easy 16

带抖动测试（10,10,2500）：
  - fuzz 0.0 → Hard 11、Good 22、Easy 29
  - fuzz 0.5 → Hard 13、Good 25、Easy 33
  - fuzz 0.99 → Hard 14、Good 28、Easy 36

Leech 测试（直接测 `leechThresholdMet`）：
  - 阈值 8：lapses 7→false，8→true，9→false，11→false，12→true，16→true
  - 阈值 3：0→false，1→false，2→false，3→true，4→false，5→true
  - 阈值 0：任何值 false
  - Review(10,10,2500, lapses 7) 按 Again → review.leeched == true，lapses == 8

- [x] 6.8 `test/relearning_test.dart`（默认 preset，relearnSteps [10]），起始 `RelearnState(learning: Learn(r=1, 600s), review: Review(1d, el 0, ease 2300, lapses 1))`：
  - Again → RelearnState(Learn(r=1, 600s), review 不变)
  - Hard → RelearnState(Learn(r=1, 900s), review 不变)
  - Good → Review(1d, ease 2300, lapses 1)
  - Easy → Review(2d, ease 2300, lapses 1)
- [x] 6.9 全部测试全绿。提交推送。

---

## 步骤 7：model/card.dart 和 model/revlog.dart（数据对象）

```dart
/// card.type
enum CardType { newCard, learn, review, relearn }   // 存库时 0,1,2,3

/// card.queue
enum CardQueue { userBuried, schedBuried, suspended, newCard, learn, review, dayLearn }
// 存库值依次为 -3, -2, -1, 0, 1, 2, 3；写一个 int get dbValue 和 static fromDb(int)

/// 卡片（M2 会用 drift 存，M1 只是纯对象）
class Card {
  final int id, noteId, deckId, ord;
  final CardType type;
  final CardQueue queue;
  final int due;      // new：排序号；learn：到期时间戳(ms)；review/dayLearn：到期 day number
  final int ivl;      // 天
  final int ease;     // 千分比，新卡为 0
  final int reps, lapses, left, flags, mtimeMs;
  // const 构造 + copyWith + == / hashCode
}
```
```dart
/// 复习日志类型：0 learn，1 review，2 relearn，3 filtered，4 manual
enum RevlogType { learn, review, relearn, filtered, manual }

/// 一次评分的记录（FSRS 和统计都靠它）
class RevlogEntry {
  final int id;         // 评分时间戳 ms
  final int cardId;
  final int button;     // 1 Again 2 Hard 3 Good 4 Easy
  final int ivl;        // 新间隔：正数=天，负数=秒
  final int lastIvl;    // 旧间隔：同上
  final int factor;     // 评分后的 ease 千分比；学习阶段为 0
  final int timeTakenMs;// 上限 60000
  final RevlogType type;
}
```
- [x] 7.1 写完，带 `==`/`hashCode`/`copyWith`（RevlogEntry 不需要 copyWith）。提交推送。

---

## 步骤 8：answer.dart（把评分应用到卡片上）

```dart
/// 评分结果
class AnswerResult {
  final Card card;
  final RevlogEntry revlog;
  final bool leechTriggered;
}

/// 把卡片转换成调度状态
CardState stateFromCard(Card c, int today);

/// 对一张卡评分。nowMs 是当前时间戳，today 是当前 day number（由调用方按 04:00 分界算好传进来）
AnswerResult answerCard(Card card, Rating rating, {
  required int nowMs, required int today, required DeckPreset preset,
  required int timeTakenMs, bool fuzz = true});
```

`stateFromCard` 规则：
| card.type | 状态 |
|---|---|
| newCard | `NewState()` |
| learn | `LearnState(remainingSteps: c.left, scheduledSecs: 0)` |
| review | `ReviewState(scheduledDays: c.ivl, elapsedDays: today - (c.due - c.ivl), ease: c.ease, lapses: c.lapses)`；如果 elapsedDays < 0 就取 0 |
| relearn | `RelearnState(learning: LearnState(remainingSteps: c.left, scheduledSecs: 0), review: ReviewState(scheduledDays: c.ivl, elapsedDays: 0, ease: c.ease, lapses: c.lapses))`（重学卡的 due 是毫秒时间戳，不能拿来算天数） |

`answerCard` 步骤：
1. `state = stateFromCard(card, today)`
2. `f = fuzz ? fuzzFactorFor(card.id, card.reps) : null`
3. `next = nextStates(state, preset, fuzzFactor: f).forRating(rating)`
4. 按 `next` 的类型生成新卡（其他字段从旧卡 copy，`reps + 1`，`mtimeMs = nowMs`）：

| next 类型 | type | queue / due | ivl | ease | left | lapses |
|---|---|---|---|---|---|---|
| LearnState | learn | 见下「分钟级到期」 | 0 | 0 | remainingSteps | 旧值 |
| RelearnState | relearn | 见下「分钟级到期」（用 learning.scheduledSecs） | review.scheduledDays | review.ease | learning.remainingSteps | review.lapses |
| ReviewState | review | queue=review，due = today + scheduledDays | scheduledDays | ease | 0 | lapses |

「分钟级到期」：`secs < 86400` → `queue = learn, due = nowMs + secs * 1000`；否则 → `queue = dayLearn, due = today + (secs / 86400).round()`。

5. 如果 `next` 是 RelearnState 或 ReviewState，且其 review 部分 `leeched == true`：`leechTriggered = true`；并且 `preset.leechAction == suspend` 时新卡 `queue = suspended`（type、ivl、due 不动）。给笔记加 `leech` 标签是 M2 的事，这里只返回标志。
6. Revlog：
   - `id = nowMs`，`cardId = card.id`，`button = rating.index + 1`
   - `ivl`：新卡是 review → `scheduledDays`；否则 → `-(scheduledSecs)`（RelearnState 用 learning.scheduledSecs）
   - `lastIvl`：旧卡 type 为 review 或 relearn → `card.ivl`；learn → `-LearningSteps(preset.learnSteps).currentDelaySecs(card.left)`；newCard → 0
   - `factor`：新卡 type 是 learn → 0，否则新卡的 ease
   - `timeTakenMs = min(timeTakenMs, 60000)`
   - `type`：旧卡 newCard/learn → learn；review → review；relearn → relearn

- [ ] 8.1 写完。
- [ ] 8.2 `test/answer_test.dart`（fuzz: false，preset 默认，today = 100，nowMs = 1_000_000_000_000）：
  - 新卡（id 1，type newCard，queue newCard，due 5）按 Good → type learn，queue learn，due = nowMs + 600000，left 1，reps 1；revlog：button 3，ivl -600，lastIvl 0，factor 0，type learn
  - 上面结果再按 Good（nowMs + 600000，today 仍 100）→ type review，queue review，ivl 1，due 101，ease 2500，left 0；revlog：ivl 1，lastIvl -600，factor 2500，type learn
  - review 卡（ivl 31，due 100，ease 2500，lapses 0）按 Again → type relearn，queue learn，due = nowMs + 600000，ivl 1，ease 2300，lapses 1，left 1；revlog：ivl -600，lastIvl 31，factor 2300，type review
  - review 卡（ivl 10，due 100，ease 2500，lapses 7）按 Again → leechTriggered true；同样的卡但 preset `leechAction: suspend` → queue suspended
  - review 卡（ivl 10，due 96，即迟 4 天，ease 2500）按 Good → ivl 30，due 130
  - timeTakenMs 传 90000 → revlog.timeTakenMs == 60000
  - learnSteps `[1440]`（1 天），新卡按 Again → queue dayLearn，due 101
- [ ] 8.3 全绿。提交推送。

---

## 步骤 9：interval_format.dart（按钮上显示的间隔）

```dart
/// 把状态的间隔格式化成按钮上的短文字
String formatInterval(CardState s);
/// 一次算好四个按钮的文字（复习页用）
Map<Rating, String> previewLabels(Card card, DeckPreset p, {required int today});   // 内部 fuzz 一律 null
```
规则：
- 分钟级（LearnState、RelearnState 用 scheduledSecs）：
  - secs < 3600 → `'<${(secs / 60).ceil()}m'`（60→`<1m`，330→`<6m`，600→`<10m`）
  - secs < 86400 → `'<${(secs / 3600).ceil()}h'`
  - 否则 → `'${(secs / 86400).round()}d'`
- 天级（ReviewState 用 scheduledDays，记为 d）：
  - d < 30 → `'${d}d'`
  - d < 365 → 月数 `d / 30` 保留 1 位小数，去掉末尾 `.0`，加 `mo`（45→`1.5mo`，60→`2mo`）
  - 否则 → 年数 `d / 365` 保留 1 位小数，去掉 `.0`，加 `y`（365→`1y`，400→`1.1y`）

- [ ] 9.1 写完。
- [ ] 9.2 `test/interval_format_test.dart`：上面括号里的每个例子一个断言；再加：新卡默认 preset 的 `previewLabels` == `{again: '<1m', hard: '<6m', good: '<10m', easy: '4d'}`。
- [ ] 9.3 全绿。提交推送。

---

## 步骤 10：规格书完整示例（总回归）

`test/spec_walkthrough_test.dart`：用 `answerCard`（fuzz: false，默认 preset），一张卡按顺序走完下面 7 步，每步断言结果。day number 从 100 开始，`nowMs` 每天加 86_400_000，同一天内的第二次评分加 600_000。

| 步 | today | 按钮 | 期望 |
|---|---|---|---|
| 1a | 100 | Good | learn，left 1 |
| 1b | 100 | Good | review，ivl 1，ease 2500，due 101 |
| 2 | 101 | Good | ivl 3，due 104 |
| 3 | 104 | Good | ivl 8，due 112 |
| 4 | 112 | Easy | ivl 26，ease 2650，due 138 |
| 5 | 138 | Hard | ivl 31，ease 2500，due 169 |
| 6a | 169 | Again | relearn，lapses 1，ease 2300，ivl 1 |
| 6b | 169 | Good | review，ivl 1，due 170 |
| 7 | 170 | Good | ivl 3，due 173 |

- [ ] 10.1 写完，全绿。
- [ ] 10.2 在 `packages/core` 执行 `dart analyze` 和 `dart test`，**全部通过、0 warning**。把 `dart test` 最后一行输出（如 `+87: All tests passed!`）贴进汇报。
- [ ] 10.3 提交推送，开 Draft PR `M1 调度器` 到 main。

---

## 验收清单（汇报时原样贴，逐项勾选）
- [ ] `packages/core` 没有任何 dependencies，只有 dev 依赖 test
- [ ] core 里搜不到 `DateTime.now`，搜不到无参数的 `Random()`
- [ ] ease 全程是 int 千分比
- [ ] 步骤 3/4/6/8/9/10 的所有表格都写成了测试，期望值一个没改
- [ ] `dart analyze` 0 issue，`dart test` 全部通过（贴最后一行）
- [ ] Draft PR 已开，未合并

## 问题记录
（照做跑不通时写在这里：哪一步、做了什么、报错原文）
