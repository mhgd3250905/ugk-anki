import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

ReviewState _review(CardState s) => switch (s) {
      ReviewState r => r,
      RelearnState r => r.review,
      _ => throw StateError('not a review state: $s'),
    };

void main() {
  const p = DeckPreset();

  group('Review 四分支表', () {
    const rows = [
      (1, 1, 2500, 2, 3, 4, 2350, 2650),
      (3, 3, 2500, 4, 8, 10, 2350, 2650),
      (8, 8, 2500, 10, 20, 26, 2350, 2650),
      (26, 26, 2650, 31, 69, 90, 2500, 2800),
      (31, 31, 2500, 37, 78, 101, 2350, 2650),
      (1, 1, 2300, 2, 3, 4, 2150, 2450),
      (10, 14, 2500, 12, 30, 46, 2350, 2650),
      (10, 10, 1300, 12, 13, 17, 1300, 1450),
      (10, 10, 2500, 12, 25, 33, 2350, 2650),
      (100, 100, 2500, 120, 250, 325, 2350, 2650),
    ];

    for (final (sd, el, ease, hardDays, goodDays, easyDays, hardEase,
        easyEase) in rows) {
      test('Review($sd, $el, $ease)', () {
        final s = nextStates(
          ReviewState(
            scheduledDays: sd,
            elapsedDays: el,
            ease: ease,
            lapses: 0,
          ),
          p,
        );
        expect((s.hard as ReviewState).scheduledDays, hardDays);
        expect((s.good as ReviewState).scheduledDays, goodDays);
        expect((s.easy as ReviewState).scheduledDays, easyDays);
        expect((s.hard as ReviewState).ease, hardEase);
        expect((s.easy as ReviewState).ease, easyEase);
      });
    }
  });

  group('Review Again', () {
    test('默认 preset', () {
      final s = nextStates(
        const ReviewState(
          scheduledDays: 31,
          elapsedDays: 31,
          ease: 2500,
          lapses: 0,
        ),
        p,
      );
      expect(
        s.again,
        const RelearnState(
          learning: LearnState(remainingSteps: 1, scheduledSecs: 600),
          review: ReviewState(
            scheduledDays: 1,
            elapsedDays: 0,
            ease: 2300,
            lapses: 1,
          ),
        ),
      );
    });

    test('ease 最低 1300', () {
      final s = nextStates(
        const ReviewState(
          scheduledDays: 10,
          elapsedDays: 10,
          ease: 1300,
          lapses: 0,
        ),
        p,
      );
      expect(_review(s.again).ease, 1300);
    });

    test('relearnSteps [] 时直接回 Review', () {
      final s = nextStates(
        const ReviewState(
          scheduledDays: 31,
          elapsedDays: 31,
          ease: 2500,
          lapses: 0,
        ),
        p.copyWith(relearnSteps: const <double>[]),
      );
      expect(
        s.again,
        const ReviewState(
          scheduledDays: 1,
          elapsedDays: 0,
          ease: 2300,
          lapses: 1,
        ),
      );
    });

    test('lapseMultiplier 0.5', () {
      final s = nextStates(
        const ReviewState(
          scheduledDays: 31,
          elapsedDays: 31,
          ease: 2500,
          lapses: 0,
        ),
        p.copyWith(lapseMultiplier: 0.5),
      );
      expect(_review(s.again).scheduledDays, 16);
    });
  });

  group('参数', () {
    test('maximumReviewInterval 30', () {
      final s = nextStates(
        const ReviewState(
          scheduledDays: 25,
          elapsedDays: 25,
          ease: 2500,
          lapses: 0,
        ),
        p.copyWith(maximumReviewInterval: 30),
      );
      expect((s.hard as ReviewState).scheduledDays, 30);
      expect((s.good as ReviewState).scheduledDays, 30);
      expect((s.easy as ReviewState).scheduledDays, 30);
    });

    test('intervalMultiplier 0.5', () {
      final s = nextStates(
        const ReviewState(
          scheduledDays: 10,
          elapsedDays: 10,
          ease: 2500,
          lapses: 0,
        ),
        p.copyWith(intervalMultiplier: 0.5),
      );
      expect((s.hard as ReviewState).scheduledDays, 11);
      expect((s.good as ReviewState).scheduledDays, 13);
      expect((s.easy as ReviewState).scheduledDays, 16);
    });
  });

  group('fuzz', () {
    const start = ReviewState(
      scheduledDays: 10,
      elapsedDays: 10,
      ease: 2500,
      lapses: 0,
    );

    test('fuzz 0.0', () {
      final s = nextStates(start, p, fuzzFactor: 0.0);
      expect((s.hard as ReviewState).scheduledDays, 11);
      expect((s.good as ReviewState).scheduledDays, 22);
      expect((s.easy as ReviewState).scheduledDays, 29);
    });

    test('fuzz 0.5', () {
      final s = nextStates(start, p, fuzzFactor: 0.5);
      expect((s.hard as ReviewState).scheduledDays, 13);
      expect((s.good as ReviewState).scheduledDays, 25);
      expect((s.easy as ReviewState).scheduledDays, 33);
    });

    test('fuzz 0.99', () {
      final s = nextStates(start, p, fuzzFactor: 0.99);
      expect((s.hard as ReviewState).scheduledDays, 14);
      expect((s.good as ReviewState).scheduledDays, 28);
      expect((s.easy as ReviewState).scheduledDays, 36);
    });
  });

  group('leechThresholdMet', () {
    test('阈值 8', () {
      expect(leechThresholdMet(7, 8), false);
      expect(leechThresholdMet(8, 8), true);
      expect(leechThresholdMet(9, 8), false);
      expect(leechThresholdMet(11, 8), false);
      expect(leechThresholdMet(12, 8), true);
      expect(leechThresholdMet(16, 8), true);
    });

    test('阈值 3', () {
      expect(leechThresholdMet(0, 3), false);
      expect(leechThresholdMet(1, 3), false);
      expect(leechThresholdMet(2, 3), false);
      expect(leechThresholdMet(3, 3), true);
      expect(leechThresholdMet(4, 3), false);
      expect(leechThresholdMet(5, 3), true);
    });

    test('阈值 0', () {
      expect(leechThresholdMet(0, 0), false);
      expect(leechThresholdMet(1, 0), false);
      expect(leechThresholdMet(100, 0), false);
    });
  });

  test('Again 触发 leech', () {
    final s = nextStates(
      const ReviewState(
        scheduledDays: 10,
        elapsedDays: 10,
        ease: 2500,
        lapses: 7,
      ),
      p,
    );
    final r = _review(s.again);
    expect(r.leeched, true);
    expect(r.lapses, 8);
  });
}
