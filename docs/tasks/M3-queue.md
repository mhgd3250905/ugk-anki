# M3：今日队列与每日上限（纯 Dart，packages/core）

- 分支：`feat/m3-queue`（从最新 `main` 拉，main 已包含 M1）
- 预计：一个 agent 一次完成
- 依赖：M1 已合并。和 M2 互不依赖，可以两个 agent 同时做。
- 完成后打 tag：`m3-done`（开哥审核通过后才打，你不要打）

## 0. 背景（只读）
规格书第 3.1、3.2 节：每天 04:00 分界、每日新卡/复习上限、三个队列的出卡顺序。本任务只写**纯函数**：给一堆卡，算出今天的队列。数据库在 M4。
本期简化（不要多做）：只看当前选中卡组自己的 preset，不做父卡组上限叠加；新卡和复习只做「混合」一种排列；learning 计数按卡数，不按剩余步数。

## 1. 硬性规则
- 沿用 M1 的规则：`packages/core` 不能有任何 dependencies；不允许 `DateTime.now()`、`DateTime` 的本地时区功能、无种子 `Random()`。时间全部是 int 毫秒，从参数传入。
- 只新建本文件列出的文件，只修改 `lib/ugk_core.dart`（加 export）。**不要改 M1 的任何文件。**
- 测试文件本文件里**已经写好全文**，原样复制，一个字符都不要改。
- **不要用 `List.sort` 依赖稳定排序**（Dart 的 sort 不稳定）：所有排序都必须按本文件给的完整比较键排，键相同再比 id。
- 每个公开类和函数写一行中文 doc 注释。写完跑 `dart format lib test`。

---

## 步骤 1：建文件
- [x] 1.1 建以下文件：
```
packages/core/lib/src/queue/day.dart
packages/core/lib/src/queue/study_queue.dart
packages/core/test/queue_day_test.dart
packages/core/test/queue_build_test.dart
```
- [x] 1.2 在 `lib/ugk_core.dart` 末尾加 2 行 export：`src/queue/day.dart`、`src/queue/study_queue.dart`。
- [x] 1.3 把第 6 节的 2 个测试文件原样复制进去。提交推送。

## 步骤 2：day.dart
```dart
int dayNumber({required int nowMs, required int collectionCreatedMs,
    required int utcOffsetMinutes, int rolloverHour = 4});
int dayCutoffMs({required int today, required int collectionCreatedMs,
    required int utcOffsetMinutes, int rolloverHour = 4});
```
- 先定义 `shift = utcOffsetMinutes * 60000 - rolloverHour * 3600000`，`absDay(ms) = ((ms + shift) / 86400000).floor()`（**必须用 `/` 再 `.floor()`，不要用 `~/`**，负数时结果不同）。
- `dayNumber = absDay(nowMs) - absDay(collectionCreatedMs)`。创建当天 = 0。
- `dayCutoffMs`（第 today 天结束、下一天开始的时刻）= `(absDay(collectionCreatedMs) + today + 1) * 86400000 - shift`。
- 上海 utcOffsetMinutes = 480；调用方以后从手机时区取，本任务不管。
- [x] 2.1 实现，`dart test test/queue_day_test.dart` 全绿。提交推送。

## 步骤 3：study_queue.dart 之一：工具函数
```dart
int shuffleKey(int cardId, int seed) =>
    ((cardId & 0xffffffff) * 2654435761 + seed) & 0xffffffff;   // 照抄

List<T> intersperse<T>(List<T> reviews, List<T> newCards);
```
`intersperse`（把新卡均匀插进复习卡）：设 r = reviews.length，n = newCards.length。
- n == 0 → 返回 reviews 的拷贝；r == 0 → 返回 newCards 的拷贝。
- 否则 `ri = 0`；对 k = 0..n-1：`target = min(r, (k+1)*(r+1) ~/ (n+1))`；当 `ri < target` 时输出 `reviews[ri++]`；然后输出 `newCards[k]`。循环结束后把剩下的 reviews 全部输出。
- 例：reviews `[1,2,3,4]`、new `[10]` → `[1,2,10,3,4]`。

## 步骤 4：study_queue.dart 之二：StudyQueue
```dart
class StudyQueue {
  final List<Card> learning;   // queue == learn 的卡
  final List<Card> main;       // dayLearn + review + new 混合后的顺序
  const StudyQueue({required this.learning, required this.main});
  int get newCount;     // main 里 queue == newCard 的数量
  int get learnCount;   // learning.length + main 里 queue == dayLearn 的数量
  int get reviewCount;  // main 里 queue == review 的数量
  Card? next(int nowMs, int learnAheadSecs);
}
```
`next` 按顺序判断，命中就返回：
1. learning 非空且 `learning.first.due <= nowMs` → learning.first
2. main 非空 → main.first
3. learning 非空且 `learning.first.due <= nowMs + learnAheadSecs * 1000` → learning.first
4. 否则 null

（StudyQueue 不改自己。答完一张卡后由调用方用新的卡片数据重新 `buildQueue`。）

## 步骤 5：study_queue.dart 之三：buildQueue
```dart
StudyQueue buildQueue({required List<Card> cards, required int today,
    required DeckPreset preset, required int newDoneToday,
    required int reviewsDoneToday, required int seed});
```
严格按下面顺序：
1. `active` = `cards` 里 `queue.dbValue >= 0` 的（跳过 buried、suspended）。
2. `learning` = active 中 `queue == CardQueue.learn`，按 (due 升序, id 升序) 排。**learning 不看 today，全部放进来**。
3. `dayLearn` = active 中 `queue == CardQueue.dayLearn && due <= today`，按 (due, id) 升序。
4. `reviews` = active 中 `queue == CardQueue.review && due <= today`，按 (due 升序, shuffleKey(id, seed) 升序, id 升序) 排。
5. `reviewLimit = max(0, preset.reviewsPerDay - reviewsDoneToday)`；`reviewPart` = `[...dayLearn, ...reviews]` 的前 reviewLimit 张。
6. `newLimit = min(preset.newPerDay - newDoneToday, reviewLimit - reviewPart.length)`，小于 0 取 0；`newCards` = active 中 `queue == CardQueue.newCard` 按 (due, id) 升序的前 newLimit 张。
7. 返回 `StudyQueue(learning: learning, main: intersperse(reviewPart, newCards))`。
- [ ] 5.1 步骤 3～5 写完，`dart test test/queue_build_test.dart` 全绿。提交推送。

## 步骤 5.9：总检查
- [ ] 5.9.1 `cd packages/core && dart format lib test && dart analyze && dart test`：analyze 0 issue，全部测试通过（包括 M1 的）。贴最后一行。
- [ ] 5.9.2 提交推送，开 Draft PR `M3 今日队列` 到 main，正文贴验收清单。

## 6. 测试文件全文（原样复制，不许改）

```dart
// packages/core/test/queue_day_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  // collection 创建于 2026-10-01 10:00 上海时间（= 2026-10-01 02:00 UTC）
  const created = 1790820000000;

  group('dayNumber（上海 +480，04:00 分界）', () {
    test('创建当刻是第 0 天', () {
      expect(
          dayNumber(
              nowMs: created,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          0);
    });
    test('次日 03:59 上海时间还是第 0 天', () {
      // 2026-10-01 19:59 UTC = 2026-10-02 03:59 上海
      expect(
          dayNumber(
              nowMs: 1790884740000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          0);
    });
    test('次日 04:00 上海时间变成第 1 天', () {
      expect(
          dayNumber(
              nowMs: 1790884800000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          1);
    });
    test('2026-10-24 18:00 上海时间是第 23 天', () {
      expect(
          dayNumber(
              nowMs: 1792836000000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          23);
    });
    test('比创建还早一天得 -1', () {
      expect(
          dayNumber(
              nowMs: 1790794800000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          -1);
    });
    test('rolloverHour = 0 时午夜分界', () {
      // 2026-10-01 16:00 UTC = 2026-10-02 00:00 上海
      expect(
          dayNumber(
              nowMs: 1790870400000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480,
              rolloverHour: 0),
          1);
      expect(
          dayNumber(
              nowMs: 1790870399999,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480,
              rolloverHour: 0),
          0);
    });
  });

  test('dayNumber 洛杉矶 -420', () {
    // 创建 2026-10-01 15:00 UTC（洛杉矶 08:00）；现在 2026-10-24 10:00 UTC（洛杉矶 03:00，还没到 04:00）
    expect(
        dayNumber(
            nowMs: 1792836000000,
            collectionCreatedMs: 1790866800000,
            utcOffsetMinutes: -420),
        22);
  });

  group('dayCutoffMs', () {
    test('第 0 天在 2026-10-02 04:00 上海时间结束', () {
      expect(
          dayCutoffMs(
              today: 0, collectionCreatedMs: created, utcOffsetMinutes: 480),
          1790884800000);
    });
    test('第 23 天在 2026-10-25 04:00 上海时间结束', () {
      expect(
          dayCutoffMs(
              today: 23, collectionCreatedMs: created, utcOffsetMinutes: 480),
          1792872000000);
    });
  });
}
```

```dart
// packages/core/test/queue_build_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

Card card(int id, CardQueue queue, int due) => Card(
      id: id,
      noteId: id,
      deckId: 1,
      ord: 0,
      type: switch (queue) {
        CardQueue.newCard => CardType.newCard,
        CardQueue.learn || CardQueue.dayLearn => CardType.learn,
        _ => CardType.review,
      },
      queue: queue,
      due: due,
      ivl: queue == CardQueue.review ? 3 : 0,
      ease: queue == CardQueue.review ? 2500 : 0,
      reps: 0,
      lapses: 0,
      left: 0,
      flags: 0,
      mtimeMs: 0,
    );

List<int> ids(List<Card> cs) => [for (final c in cs) c.id];

void main() {
  const today = 100;
  const preset = DeckPreset();

  group('shuffleKey', () {
    test('固定值', () {
      expect(shuffleKey(101, 7), 1810039516);
      expect(shuffleKey(102, 7), 169507981);
      expect(shuffleKey(103, 7), 2823943742);
      expect(shuffleKey(104, 7), 1183412207);
      expect(shuffleKey(105, 7), 3837847968);
    });
  });

  group('intersperse', () {
    test('边界', () {
      expect(intersperse(<int>[], <int>[]), <int>[]);
      expect(intersperse([1, 2], <int>[]), [1, 2]);
      expect(intersperse(<int>[], [10, 11]), [10, 11]);
    });
    test('均匀插入', () {
      expect(intersperse([1, 2, 3, 4], [10]), [1, 2, 10, 3, 4]);
      expect(intersperse([1, 2], [10, 11]), [1, 10, 2, 11]);
      expect(intersperse([1], [10, 11, 12]), [10, 1, 11, 12]);
      expect(intersperse([1, 2, 3, 4, 5, 6], [10, 11]),
          [1, 2, 10, 3, 4, 11, 5, 6]);
      expect(intersperse([1, 2, 3], [10, 11, 12, 13, 14]),
          [10, 1, 11, 2, 12, 13, 3, 14]);
    });
  });

  group('buildQueue 过滤和排序', () {
    final cards = [
      card(1, CardQueue.newCard, 5),
      card(2, CardQueue.newCard, 3),
      card(3, CardQueue.newCard, 3),
      card(4, CardQueue.suspended, 0),
      card(5, CardQueue.schedBuried, 0),
      card(6, CardQueue.userBuried, 0),
      card(7, CardQueue.learn, 2000),
      card(8, CardQueue.learn, 1000),
      card(9, CardQueue.review, 101), // 明天才到期
      card(10, CardQueue.review, 100),
      card(11, CardQueue.review, 99),
      card(12, CardQueue.dayLearn, 100),
      card(13, CardQueue.dayLearn, 101), // 明天才到期
    ];
    final q = buildQueue(
        cards: cards,
        today: today,
        preset: preset,
        newDoneToday: 0,
        reviewsDoneToday: 0,
        seed: 7);

    test('learning 按 due 排', () {
      expect(ids(q.learning), [8, 7]);
    });
    test('main = intersperse([12, 11, 10], [2, 3, 1])', () {
      // reviewPart: dayLearn 12 在前，然后 review 按 due：11(99) 10(100)
      // newCards: due 3 的 2、3（同 due 按 id），然后 due 5 的 1
      expect(ids(q.main), [12, 2, 11, 3, 10, 1]);
    });
    test('计数', () {
      expect(q.newCount, 3);
      expect(q.learnCount, 3); // learning 2 张 + dayLearn 1 张
      expect(q.reviewCount, 2);
    });
  });

  test('同一天的 review 用 shuffleKey 打乱', () {
    final cards = [
      for (final id in [101, 102, 103, 104, 105])
        card(id, CardQueue.review, 100)
    ];
    final q = buildQueue(
        cards: cards,
        today: today,
        preset: preset,
        newDoneToday: 0,
        reviewsDoneToday: 0,
        seed: 7);
    expect(ids(q.main), [102, 104, 101, 103, 105]);
  });

  test('输入顺序不影响结果', () {
    final a = [
      for (final id in [101, 102, 103, 104, 105])
        card(id, CardQueue.review, 100)
    ];
    final b = a.reversed.toList();
    List<int> run(List<Card> cs) => ids(buildQueue(
            cards: cs,
            today: today,
            preset: preset,
            newDoneToday: 0,
            reviewsDoneToday: 0,
            seed: 7)
        .main);
    expect(run(a), run(b));
  });

  group('每日上限', () {
    List<Card> make(int reviews, int news) => [
          for (var i = 0; i < reviews; i++)
            card(1000 + i, CardQueue.review, 90 + (i % 5)),
          for (var i = 0; i < news; i++) card(2000 + i, CardQueue.newCard, i),
        ];

    StudyQueue run(List<Card> cs, DeckPreset p,
            {int newDone = 0, int revDone = 0}) =>
        buildQueue(
            cards: cs,
            today: today,
            preset: p,
            newDoneToday: newDone,
            reviewsDoneToday: revDone,
            seed: 1);

    test('默认 20 新 / 200 复习', () {
      final q = run(make(50, 30), preset);
      expect(q.reviewCount, 50);
      expect(q.newCount, 20);
    });
    test('今天已学 15 张新卡，只剩 5', () {
      final q = run(make(50, 30), preset, newDone: 15);
      expect(q.newCount, 5);
    });
    test('新卡超额时为 0', () {
      final q = run(make(50, 30), preset, newDone: 25);
      expect(q.newCount, 0);
    });
    test('复习上限截断 review', () {
      final q = run(make(50, 30), preset.copyWith(reviewsPerDay: 30));
      expect(q.reviewCount, 30);
      expect(q.newCount, 0);
    });
    test('新卡也受复习上限：剩余额度 = 上限 - review 数', () {
      final q = run(make(190, 30), preset);
      expect(q.reviewCount, 190);
      expect(q.newCount, 10);
    });
    test('今天已复习 195 张', () {
      final q = run(make(50, 30), preset, revDone: 195);
      expect(q.reviewCount, 5);
      expect(q.newCount, 0);
    });
    test('今天已复习超过上限', () {
      final q = run(make(50, 30), preset, revDone: 250);
      expect(q.reviewCount, 0);
      expect(q.newCount, 0);
    });
    test('dayLearn 先占复习额度', () {
      final cs = [
        card(1, CardQueue.review, 100),
        card(2, CardQueue.review, 100),
        card(3, CardQueue.dayLearn, 100),
        card(4, CardQueue.newCard, 0),
      ];
      final q = run(cs, preset.copyWith(reviewsPerDay: 2));
      expect(q.main.first.id, 3);
      expect(q.main.length, 2);
      expect(q.learnCount, 1);
      expect(q.reviewCount, 1);
      expect(q.newCount, 0);
    });
    test('learning 卡不受上限', () {
      final cs = [
        for (var i = 0; i < 5; i++) card(i + 1, CardQueue.learn, 1000 + i)
      ];
      final q = run(cs, preset.copyWith(reviewsPerDay: 0, newPerDay: 0));
      expect(q.learning.length, 5);
      expect(q.main, isEmpty);
    });
  });

  group('next', () {
    const now = 1000000;
    final rev = card(1, CardQueue.review, 100);
    final dueLearn = card(2, CardQueue.learn, now - 1);
    final soonLearn = card(3, CardQueue.learn, now + 600000); // 10 分钟后
    final lateLearn = card(4, CardQueue.learn, now + 1800000); // 30 分钟后

    test('到期的 learning 最优先', () {
      final q = StudyQueue(learning: [dueLearn], main: [rev]);
      expect(q.next(now, 1200)!.id, 2);
    });
    test('learning 没到期先出 main', () {
      final q = StudyQueue(learning: [soonLearn], main: [rev]);
      expect(q.next(now, 1200)!.id, 1);
    });
    test('main 空了可以提前 20 分钟出 learning', () {
      final q = StudyQueue(learning: [soonLearn], main: const []);
      expect(q.next(now, 1200)!.id, 3);
    });
    test('超过提前量返回 null', () {
      final q = StudyQueue(learning: [lateLearn], main: const []);
      expect(q.next(now, 1200), isNull);
    });
    test('全空返回 null', () {
      expect(const StudyQueue(learning: [], main: []).next(now, 1200), isNull);
    });
    test('due 正好等于 now 算到期', () {
      final q =
          StudyQueue(learning: [card(5, CardQueue.learn, now)], main: [rev]);
      expect(q.next(now, 1200)!.id, 5);
    });
  });
}
```

---

## 验收清单（汇报时原样贴，逐项勾选）
- [ ] `pubspec.yaml` 没变，仍然没有任何 dependencies
- [ ] 没有修改 M1 的任何文件（`git diff main --stat` 里只有 `lib/src/queue/`、2 个 `test/queue_*`、`lib/ugk_core.dart`、本任务文件）
- [ ] 2 个测试文件和本文件第 6 节一字不差
- [ ] 排序都用完整比较键，没有依赖稳定排序
- [ ] `dart analyze` 0 issue，`dart test` 全部通过（贴最后一行）
- [ ] Draft PR 已开，未合并

## 问题记录
（照做跑不通时写在这里：哪一步、做了什么、报错原文）
