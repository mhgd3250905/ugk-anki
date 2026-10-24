import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  const p = DeckPreset();
  const start = RelearnState(
    learning: LearnState(remainingSteps: 1, scheduledSecs: 600),
    review: ReviewState(
      scheduledDays: 1,
      elapsedDays: 0,
      ease: 2300,
      lapses: 1,
    ),
  );
  const review = ReviewState(
    scheduledDays: 1,
    elapsedDays: 0,
    ease: 2300,
    lapses: 1,
  );

  test('Again', () {
    final s = nextStates(start, p);
    expect(
      s.again,
      const RelearnState(
        learning: LearnState(remainingSteps: 1, scheduledSecs: 600),
        review: review,
      ),
    );
  });

  test('Hard', () {
    final s = nextStates(start, p);
    expect(
      s.hard,
      const RelearnState(
        learning: LearnState(remainingSteps: 1, scheduledSecs: 900),
        review: review,
      ),
    );
  });

  test('Good 重学毕业', () {
    final s = nextStates(start, p);
    expect(s.good, review);
  });

  test('Easy', () {
    final s = nextStates(start, p);
    expect(
      s.easy,
      const ReviewState(
        scheduledDays: 2,
        elapsedDays: 0,
        ease: 2300,
        lapses: 1,
      ),
    );
  });
}
