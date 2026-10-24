import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  group('fuzz 表', () {
    const rows = [
      (1.0, 0.0, (1, 1), 1, 1, 1),
      (2.0, 0.0, (2, 2), 2, 2, 2),
      (3.0, 1.075, (2, 4), 2, 3, 4),
      (5.0, 1.375, (4, 6), 4, 5, 6),
      (10.0, 1.975, (8, 12), 8, 10, 12),
      (26.0, 3.275, (23, 29), 23, 26, 29),
      (30.0, 3.475, (27, 33), 27, 30, 33),
      (100.0, 6.975, (93, 107), 93, 100, 107),
    ];

    for (final (interval, delta, bounds, fuzz0, fuzzHalf, fuzz99) in rows) {
      test('interval $interval', () {
        expect(fuzzDelta(interval), closeTo(delta, 1e-9));
        expect(constrainedFuzzBounds(interval, 1, 36500), bounds);
        expect(withReviewFuzz(0.0, interval, 1, 36500), fuzz0);
        expect(withReviewFuzz(0.5, interval, 1, 36500), fuzzHalf);
        expect(withReviewFuzz(0.99, interval, 1, 36500), fuzz99);
      });
    }
  });

  test('无 fuzz 时四舍五入并夹取', () {
    expect(withReviewFuzz(null, 2.5, 1, 36500), 3);
    expect(withReviewFuzz(null, 62.5, 1, 30), 30);
  });

  test('fuzzFactorFor 确定性', () {
    expect(fuzzFactorFor(123, 4), fuzzFactorFor(123, 4));
  });
}
