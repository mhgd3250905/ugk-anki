import 'dart:math';

import 'fuzz.dart';
import 'learning_steps.dart';
import 'preset.dart';
import 'states.dart';

/// 计算当前状态下四个按钮分别会得到什么状态
SchedulingStates nextStates(
  CardState current,
  DeckPreset p, {
  double? fuzzFactor,
}) {
  final steps = LearningSteps(p.learnSteps);
  final relearn = LearningSteps(p.relearnSteps);
  return switch (current) {
    NewState n => _learnStates(
        LearnState(
          remainingSteps: steps.remainingForFailed(),
          scheduledSecs: 0,
        ),
        n,
        p,
        steps,
        fuzzFactor,
      ),
    LearnState s => _learnStates(s, s, p, steps, fuzzFactor),
    ReviewState s => _reviewStates(s, p, relearn, fuzzFactor),
    RelearnState s => _relearnStates(s, relearn),
  };
}

(int, int) _minMax(DeckPreset p, int minimum) {
  final maximum = p.maximumReviewInterval < 1 ? 1 : p.maximumReviewInterval;
  return (minimum.clamp(1, maximum), maximum);
}

int _constrainPassing(
  DeckPreset p,
  double interval,
  int minimum,
  double? fuzz,
) {
  final (mn, mx) = _minMax(p, minimum);
  return withReviewFuzz(fuzz, interval * p.intervalMultiplier, mn, mx);
}

/// 判断本次遗忘是否达到 leech 阈值
bool leechThresholdMet(int lapses, int threshold) {
  if (threshold <= 0) return false;
  final half = (threshold / 2).ceil() < 1 ? 1 : (threshold / 2).ceil();
  return lapses >= threshold && (lapses - threshold) % half == 0;
}

ReviewState _graduate(DeckPreset p, int days, double? fuzz) {
  final (mn, mx) = _minMax(p, 1);
  return ReviewState(
    scheduledDays: withReviewFuzz(fuzz, days.toDouble(), mn, mx),
    elapsedDays: 0,
    ease: p.initialEase,
    lapses: 0,
  );
}

SchedulingStates _learnStates(
  LearnState s,
  CardState current,
  DeckPreset p,
  LearningSteps steps,
  double? fuzz,
) {
  final r = s.remainingSteps;
  final againDelay = steps.againDelaySecs();
  final hardDelay = steps.hardDelaySecs(r);
  final goodDelay = steps.goodDelaySecs(r);
  return SchedulingStates(
    current: current,
    again: againDelay != null
        ? LearnState(
            remainingSteps: steps.remainingForFailed(),
            scheduledSecs: againDelay,
          )
        : _graduate(p, p.graduatingIntervalGood, fuzz),
    hard: hardDelay != null
        ? LearnState(remainingSteps: r, scheduledSecs: hardDelay)
        : _graduate(p, p.graduatingIntervalGood, fuzz),
    good: goodDelay != null
        ? LearnState(
            remainingSteps: steps.remainingForGood(r),
            scheduledSecs: goodDelay,
          )
        : _graduate(p, p.graduatingIntervalGood, fuzz),
    easy: _graduate(p, p.graduatingIntervalEasy, fuzz),
  );
}

SchedulingStates _reviewStates(
  ReviewState s,
  DeckPreset p,
  LearningSteps relearn,
  double? fuzz,
) {
  final current = max(s.scheduledDays, 1).toDouble();
  final daysLate = max(s.daysLate, 0).toDouble();
  final ef = s.ease / 1000.0;
  final hardMin = p.hardMultiplier <= 1.0 ? 0 : s.scheduledDays + 1;
  final hard = _constrainPassing(p, current * p.hardMultiplier, hardMin, fuzz);
  final goodMin = p.hardMultiplier <= 1.0 ? s.scheduledDays + 1 : hard + 1;
  final good =
      _constrainPassing(p, (current + daysLate / 2) * ef, goodMin, fuzz);
  final easy = _constrainPassing(
    p,
    (current + daysLate) * ef * p.easyMultiplier,
    good + 1,
    fuzz,
  );

  final lapses = s.lapses + 1;
  final leeched = leechThresholdMet(lapses, p.leechThreshold);
  final (mn, mx) = _minMax(p, p.minimumLapseInterval);
  var failDays = withReviewFuzz(
    fuzz,
    max(s.scheduledDays, 1) * p.lapseMultiplier,
    mn,
    mx,
  );
  failDays = max(failDays, 1);
  final review = ReviewState(
    scheduledDays: failDays,
    elapsedDays: 0,
    ease: max(s.ease - 200, 1300),
    lapses: lapses,
    leeched: leeched,
  );
  final againDelay = relearn.againDelaySecs();
  final CardState again = againDelay != null
      ? RelearnState(
          learning: LearnState(
            remainingSteps: relearn.remainingForFailed(),
            scheduledSecs: againDelay,
          ),
          review: review,
        )
      : review;

  return SchedulingStates(
    current: s,
    again: again,
    hard: ReviewState(
      scheduledDays: hard,
      elapsedDays: 0,
      ease: max(s.ease - 150, 1300),
      lapses: s.lapses,
    ),
    good: ReviewState(
      scheduledDays: good,
      elapsedDays: 0,
      ease: s.ease,
      lapses: s.lapses,
    ),
    easy: ReviewState(
      scheduledDays: easy,
      elapsedDays: 0,
      ease: s.ease + 150,
      lapses: s.lapses,
    ),
  );
}

SchedulingStates _relearnStates(
  RelearnState s,
  LearningSteps relearn,
) {
  final r = s.learning.remainingSteps;
  final againDelay = relearn.againDelaySecs();
  final hardDelay = relearn.hardDelaySecs(r);
  final goodDelay = relearn.goodDelaySecs(r);
  final review = _relearnReview(s.review);
  return SchedulingStates(
    current: s,
    again: againDelay != null
        ? RelearnState(
            learning: LearnState(
              remainingSteps: relearn.remainingForFailed(),
              scheduledSecs: againDelay,
            ),
            review: review,
          )
        : review,
    hard: hardDelay != null
        ? RelearnState(
            learning: LearnState(remainingSteps: r, scheduledSecs: hardDelay),
            review: review,
          )
        : review,
    good: goodDelay != null
        ? RelearnState(
            learning: LearnState(
              remainingSteps: relearn.remainingForGood(r),
              scheduledSecs: goodDelay,
            ),
            review: review,
          )
        : review,
    easy: ReviewState(
      scheduledDays: s.review.scheduledDays + 1,
      elapsedDays: 0,
      ease: s.review.ease,
      lapses: s.review.lapses,
    ),
  );
}

ReviewState _relearnReview(ReviewState r) => ReviewState(
      scheduledDays: r.scheduledDays,
      elapsedDays: 0,
      ease: r.ease,
      lapses: r.lapses,
    );
