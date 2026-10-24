import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

const _review = ReviewState(
  scheduledDays: 1,
  elapsedDays: 0,
  ease: 2500,
  lapses: 0,
);

void main() {
  test('分钟为单位的标签', () {
    expect(
      formatInterval(const LearnState(remainingSteps: 1, scheduledSecs: 60)),
      '<1m',
    );
    expect(
      formatInterval(const LearnState(remainingSteps: 1, scheduledSecs: 330)),
      '<6m',
    );
    expect(
      formatInterval(const LearnState(remainingSteps: 1, scheduledSecs: 600)),
      '<10m',
    );
  });

  test('小时和天为单位的标签', () {
    expect(
      formatInterval(const LearnState(remainingSteps: 1, scheduledSecs: 3600)),
      '<1h',
    );
    expect(
      formatInterval(const LearnState(remainingSteps: 1, scheduledSecs: 7200)),
      '<2h',
    );
    expect(
      formatInterval(const LearnState(remainingSteps: 1, scheduledSecs: 86400)),
      '1d',
    );
  });

  test('重学用 learning.scheduledSecs', () {
    expect(
      formatInterval(
        const RelearnState(
          learning: LearnState(remainingSteps: 1, scheduledSecs: 330),
          review: _review,
        ),
      ),
      '<6m',
    );
  });

  test('天级标签', () {
    expect(
      formatInterval(
        const ReviewState(
          scheduledDays: 29,
          elapsedDays: 0,
          ease: 2500,
          lapses: 0,
        ),
      ),
      '29d',
    );
    expect(
      formatInterval(
        const ReviewState(
          scheduledDays: 45,
          elapsedDays: 0,
          ease: 2500,
          lapses: 0,
        ),
      ),
      '1.5mo',
    );
    expect(
      formatInterval(
        const ReviewState(
          scheduledDays: 60,
          elapsedDays: 0,
          ease: 2500,
          lapses: 0,
        ),
      ),
      '2mo',
    );
    expect(
      formatInterval(
        const ReviewState(
          scheduledDays: 365,
          elapsedDays: 0,
          ease: 2500,
          lapses: 0,
        ),
      ),
      '1y',
    );
    expect(
      formatInterval(
        const ReviewState(
          scheduledDays: 400,
          elapsedDays: 0,
          ease: 2500,
          lapses: 0,
        ),
      ),
      '1.1y',
    );
  });

  test('新卡 previewLabels', () {
    const card = Card(
      id: 1,
      noteId: 10,
      deckId: 20,
      ord: 0,
      type: CardType.newCard,
      queue: CardQueue.newCard,
      due: 5,
      ivl: 0,
      ease: 0,
      reps: 0,
      lapses: 0,
      left: 0,
      flags: 0,
      mtimeMs: 0,
    );
    expect(
      previewLabels(card, const DeckPreset(), today: 100),
      {
        Rating.again: '<1m',
        Rating.hard: '<6m',
        Rating.good: '<10m',
        Rating.easy: '4d',
      },
    );
  });
}
