import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

const nowMs = 1000000000000;
const today = 100;

Card _card({
  int id = 1,
  CardType type = CardType.newCard,
  CardQueue queue = CardQueue.newCard,
  int due = 5,
  int ivl = 0,
  int ease = 0,
  int reps = 0,
  int lapses = 0,
  int left = 0,
}) =>
    Card(
      id: id,
      noteId: 10,
      deckId: 20,
      ord: 0,
      type: type,
      queue: queue,
      due: due,
      ivl: ivl,
      ease: ease,
      reps: reps,
      lapses: lapses,
      left: left,
      flags: 0,
      mtimeMs: 0,
    );

AnswerResult _answer(
  Card c,
  Rating rating, {
  DeckPreset preset = const DeckPreset(),
  int at = nowMs,
  int timeTakenMs = 1000,
}) =>
    answerCard(
      c,
      rating,
      nowMs: at,
      today: today,
      preset: preset,
      timeTakenMs: timeTakenMs,
      fuzz: false,
    );

void main() {
  test('新卡按 Good', () {
    final r = _answer(_card(), Rating.good);
    expect(r.card.type, CardType.learn);
    expect(r.card.queue, CardQueue.learn);
    expect(r.card.due, nowMs + 600000);
    expect(r.card.left, 1);
    expect(r.card.reps, 1);
    expect(r.revlog.button, 3);
    expect(r.revlog.ivl, -600);
    expect(r.revlog.lastIvl, 0);
    expect(r.revlog.factor, 0);
    expect(r.revlog.type, RevlogType.learn);
  });

  test('学习卡再按 Good 毕业', () {
    final first = _answer(_card(), Rating.good);
    final r = _answer(first.card, Rating.good, at: nowMs + 600000);
    expect(r.card.type, CardType.review);
    expect(r.card.queue, CardQueue.review);
    expect(r.card.ivl, 1);
    expect(r.card.due, 101);
    expect(r.card.ease, 2500);
    expect(r.card.left, 0);
    expect(r.revlog.ivl, 1);
    expect(r.revlog.lastIvl, -600);
    expect(r.revlog.factor, 2500);
    expect(r.revlog.type, RevlogType.learn);
  });

  test('复习卡按 Again 进重学', () {
    final r = _answer(
      _card(
        type: CardType.review,
        queue: CardQueue.review,
        due: 100,
        ivl: 31,
        ease: 2500,
        reps: 5,
      ),
      Rating.again,
    );
    expect(r.card.type, CardType.relearn);
    expect(r.card.queue, CardQueue.learn);
    expect(r.card.due, nowMs + 600000);
    expect(r.card.ivl, 1);
    expect(r.card.ease, 2300);
    expect(r.card.lapses, 1);
    expect(r.card.left, 1);
    expect(r.revlog.ivl, -600);
    expect(r.revlog.lastIvl, 31);
    expect(r.revlog.factor, 2300);
    expect(r.revlog.type, RevlogType.review);
  });

  test('leech 触发与 suspend', () {
    final card = _card(
      type: CardType.review,
      queue: CardQueue.review,
      due: 100,
      ivl: 10,
      ease: 2500,
      reps: 7,
      lapses: 7,
    );
    final tagged = _answer(card, Rating.again);
    expect(tagged.leechTriggered, true);

    final suspended = _answer(
      card,
      Rating.again,
      preset: const DeckPreset(leechAction: LeechAction.suspend),
    );
    expect(suspended.leechTriggered, true);
    expect(suspended.card.queue, CardQueue.suspended);
  });

  test('迟 4 天按 Good', () {
    final r = _answer(
      _card(
        type: CardType.review,
        queue: CardQueue.review,
        due: 96,
        ivl: 10,
        ease: 2500,
        reps: 3,
      ),
      Rating.good,
    );
    expect(r.card.ivl, 30);
    expect(r.card.due, 130);
  });

  test('timeTakenMs 上限 60000', () {
    final r = _answer(_card(), Rating.good, timeTakenMs: 90000);
    expect(r.revlog.timeTakenMs, 60000);
  });

  test('learnSteps [1440] 按 Again 进 dayLearn', () {
    final r = _answer(
      _card(),
      Rating.again,
      preset: const DeckPreset(learnSteps: <double>[1440]),
    );
    expect(r.card.queue, CardQueue.dayLearn);
    expect(r.card.due, 101);
  });
}
