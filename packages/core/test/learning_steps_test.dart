import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  group('learning steps 表', () {
    test('[10] remaining 1', () {
      const s = LearningSteps([10]);
      expect(s.againDelaySecs(), 600);
      expect(s.hardDelaySecs(1), 900);
      expect(s.goodDelaySecs(1), isNull);
    });

    test('[4320] remaining 1', () {
      const s = LearningSteps([4320]);
      expect(s.againDelaySecs(), 259200);
      expect(s.hardDelaySecs(1), 345600);
      expect(s.goodDelaySecs(1), isNull);
    });

    test('[1, 10] remaining 2', () {
      const s = LearningSteps([1, 10]);
      expect(s.againDelaySecs(), 60);
      expect(s.hardDelaySecs(2), 330);
      expect(s.goodDelaySecs(2), 600);
    });

    test('[1, 10] remaining 1', () {
      const s = LearningSteps([1, 10]);
      expect(s.againDelaySecs(), 60);
      expect(s.hardDelaySecs(1), 600);
      expect(s.goodDelaySecs(1), isNull);
    });

    test('[1, 10, 100] remaining 3', () {
      const s = LearningSteps([1, 10, 100]);
      expect(s.againDelaySecs(), 60);
      expect(s.hardDelaySecs(3), 330);
      expect(s.goodDelaySecs(3), 600);
    });

    test('[1, 10, 100] remaining 2', () {
      const s = LearningSteps([1, 10, 100]);
      expect(s.againDelaySecs(), 60);
      expect(s.hardDelaySecs(2), 600);
      expect(s.goodDelaySecs(2), 6000);
    });

    test('[1, 10, 100] remaining 1', () {
      const s = LearningSteps([1, 10, 100]);
      expect(s.againDelaySecs(), 60);
      expect(s.hardDelaySecs(1), 6000);
      expect(s.goodDelaySecs(1), isNull);
    });
  });

  test('remainingForGood / remainingForFailed', () {
    const s = LearningSteps([1, 10]);
    expect(s.remainingForGood(2), 1);
    expect(s.remainingForGood(1), 0);
    expect(s.remainingForFailed(), 2);
  });
}
