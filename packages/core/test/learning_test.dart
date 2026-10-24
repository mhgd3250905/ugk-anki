import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  const p = DeckPreset();
  const review4 = ReviewState(
    scheduledDays: 4,
    elapsedDays: 0,
    ease: 2500,
    lapses: 0,
  );
  const review1 = ReviewState(
    scheduledDays: 1,
    elapsedDays: 0,
    ease: 2500,
    lapses: 0,
  );

  test('NewState 四分支', () {
    final s = nextStates(const NewState(), p);
    expect(s.current, const NewState());
    expect(s.again, const LearnState(remainingSteps: 2, scheduledSecs: 60));
    expect(s.hard, const LearnState(remainingSteps: 2, scheduledSecs: 330));
    expect(s.good, const LearnState(remainingSteps: 1, scheduledSecs: 600));
    expect(s.easy, review4);
  });

  test('Learn(r=2) 四分支', () {
    final s = nextStates(
      const LearnState(remainingSteps: 2, scheduledSecs: 60),
      p,
    );
    expect(s.again, const LearnState(remainingSteps: 2, scheduledSecs: 60));
    expect(s.hard, const LearnState(remainingSteps: 2, scheduledSecs: 330));
    expect(s.good, const LearnState(remainingSteps: 1, scheduledSecs: 600));
    expect(s.easy, review4);
  });

  test('Learn(r=1) 四分支', () {
    final s = nextStates(
      const LearnState(remainingSteps: 1, scheduledSecs: 600),
      p,
    );
    expect(s.again, const LearnState(remainingSteps: 2, scheduledSecs: 60));
    expect(s.hard, const LearnState(remainingSteps: 1, scheduledSecs: 600));
    expect(s.good, review1);
    expect(s.easy, review4);
  });

  test('learnSteps [10] 时 Learn(r=1) Hard', () {
    final s = nextStates(
      const LearnState(remainingSteps: 1, scheduledSecs: 600),
      p.copyWith(learnSteps: const <double>[10]),
    );
    expect(s.again, const LearnState(remainingSteps: 1, scheduledSecs: 600));
    expect(s.hard, const LearnState(remainingSteps: 1, scheduledSecs: 900));
    expect(s.good, review1);
    expect(s.easy, review4);
  });

  test('learnSteps [] 时 NewState 全毕业', () {
    final s = nextStates(
      const NewState(),
      p.copyWith(learnSteps: const <double>[]),
    );
    expect(s.again, review1);
    expect(s.hard, review1);
    expect(s.good, review1);
    expect(s.easy, review4);
  });
}
