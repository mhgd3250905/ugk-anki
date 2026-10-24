import '../model/card.dart';
import '../model/revlog.dart';
import 'fuzz.dart';
import 'learning_steps.dart';
import 'next_states.dart';
import 'preset.dart';
import 'states.dart';

/// 评分结果
class AnswerResult {
  final Card card;
  final RevlogEntry revlog;
  final bool leechTriggered;

  /// 创建评分结果
  const AnswerResult({
    required this.card,
    required this.revlog,
    required this.leechTriggered,
  });
}

/// 把卡片转换成调度状态
CardState stateFromCard(Card c, int today) => switch (c.type) {
      CardType.newCard => const NewState(),
      CardType.learn => LearnState(
          remainingSteps: c.left,
          scheduledSecs: 0,
        ),
      CardType.review => ReviewState(
          scheduledDays: c.ivl,
          elapsedDays: _nonNegative(today - (c.due - c.ivl)),
          ease: c.ease,
          lapses: c.lapses,
        ),
      CardType.relearn => RelearnState(
          learning: LearnState(
            remainingSteps: c.left,
            scheduledSecs: 0,
          ),
          review: ReviewState(
            scheduledDays: c.ivl,
            elapsedDays: 0,
            ease: c.ease,
            lapses: c.lapses,
          ),
        ),
    };

int _nonNegative(int value) => value < 0 ? 0 : value;

/// 对一张卡评分。nowMs 是当前时间戳，today 是当前 day number（由调用方按 04:00 分界算好传进来）
AnswerResult answerCard(
  Card card,
  Rating rating, {
  required int nowMs,
  required int today,
  required DeckPreset preset,
  required int timeTakenMs,
  bool fuzz = true,
}) {
  final state = stateFromCard(card, today);
  final f = fuzz ? fuzzFactorFor(card.id, card.reps) : null;
  final next = nextStates(state, preset, fuzzFactor: f).forRating(rating);

  final (Card newCard, int revlogIvl) = switch (next) {
    LearnState l => (
        card.copyWith(
          type: CardType.learn,
          queue: _minuteQueue(l.scheduledSecs),
          due: _minuteDue(l.scheduledSecs, nowMs, today),
          ivl: 0,
          ease: 0,
          left: l.remainingSteps,
          reps: card.reps + 1,
          mtimeMs: nowMs,
        ),
        -l.scheduledSecs,
      ),
    RelearnState r => (
        card.copyWith(
          type: CardType.relearn,
          queue: _minuteQueue(r.learning.scheduledSecs),
          due: _minuteDue(r.learning.scheduledSecs, nowMs, today),
          ivl: r.review.scheduledDays,
          ease: r.review.ease,
          left: r.learning.remainingSteps,
          lapses: r.review.lapses,
          reps: card.reps + 1,
          mtimeMs: nowMs,
        ),
        -r.learning.scheduledSecs,
      ),
    ReviewState r => (
        card.copyWith(
          type: CardType.review,
          queue: CardQueue.review,
          due: today + r.scheduledDays,
          ivl: r.scheduledDays,
          ease: r.ease,
          left: 0,
          lapses: r.lapses,
          reps: card.reps + 1,
          mtimeMs: nowMs,
        ),
        r.scheduledDays,
      ),
    NewState() => throw StateError('nextStates 不会返回 NewState'),
  };

  final reviewPart = switch (next) {
    RelearnState r => r.review,
    ReviewState r => r,
    LearnState() => null,
    NewState() => throw StateError('nextStates 不会返回 NewState'),
  };
  var resultCard = newCard;
  var leechTriggered = false;
  if (reviewPart != null && reviewPart.leeched) {
    leechTriggered = true;
    if (preset.leechAction == LeechAction.suspend) {
      resultCard = resultCard.copyWith(queue: CardQueue.suspended);
    }
  }

  final revlog = RevlogEntry(
    id: nowMs,
    cardId: card.id,
    button: rating.index + 1,
    ivl: revlogIvl,
    lastIvl: switch (card.type) {
      CardType.review || CardType.relearn => card.ivl,
      CardType.learn =>
        -LearningSteps(preset.learnSteps).currentDelaySecs(card.left),
      CardType.newCard => 0,
    },
    factor: resultCard.type == CardType.learn ? 0 : resultCard.ease,
    timeTakenMs: timeTakenMs > 60000 ? 60000 : timeTakenMs,
    type: switch (card.type) {
      CardType.newCard || CardType.learn => RevlogType.learn,
      CardType.review => RevlogType.review,
      CardType.relearn => RevlogType.relearn,
    },
  );

  return AnswerResult(
    card: resultCard,
    revlog: revlog,
    leechTriggered: leechTriggered,
  );
}

CardQueue _minuteQueue(int secs) =>
    secs < kDaySecs ? CardQueue.learn : CardQueue.dayLearn;

int _minuteDue(int secs, int nowMs, int today) => secs < kDaySecs
    ? nowMs + secs * 1000
    : today + (secs / kDaySecs).round();
