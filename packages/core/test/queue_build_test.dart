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
