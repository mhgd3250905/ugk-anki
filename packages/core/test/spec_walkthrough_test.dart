import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

const _baseMs = 1000000000000;

int _msFor(int today, {bool secondInDay = false}) =>
    _baseMs + (today - 100) * 86400000 + (secondInDay ? 600000 : 0);

AnswerResult _answer(
  Card card,
  Rating rating,
  int today, {
  bool secondInDay = false,
}) =>
    answerCard(
      card,
      rating,
      nowMs: _msFor(today, secondInDay: secondInDay),
      today: today,
      preset: const DeckPreset(),
      timeTakenMs: 1000,
      fuzz: false,
    );

void main() {
  test('规格书完整示例 7 步', () {
    const newCard = Card(
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

    final step1a = _answer(newCard, Rating.good, 100);
    expect(step1a.card.type, CardType.learn);
    expect(step1a.card.left, 1);

    final step1b = _answer(step1a.card, Rating.good, 100, secondInDay: true);
    expect(step1b.card.type, CardType.review);
    expect(step1b.card.ivl, 1);
    expect(step1b.card.ease, 2500);
    expect(step1b.card.due, 101);

    final step2 = _answer(step1b.card, Rating.good, 101);
    expect(step2.card.ivl, 3);
    expect(step2.card.due, 104);

    final step3 = _answer(step2.card, Rating.good, 104);
    expect(step3.card.ivl, 8);
    expect(step3.card.due, 112);

    final step4 = _answer(step3.card, Rating.easy, 112);
    expect(step4.card.ivl, 26);
    expect(step4.card.ease, 2650);
    expect(step4.card.due, 138);

    final step5 = _answer(step4.card, Rating.hard, 138);
    expect(step5.card.ivl, 31);
    expect(step5.card.ease, 2500);
    expect(step5.card.due, 169);

    final step6a = _answer(step5.card, Rating.again, 169);
    expect(step6a.card.type, CardType.relearn);
    expect(step6a.card.lapses, 1);
    expect(step6a.card.ease, 2300);
    expect(step6a.card.ivl, 1);

    final step6b = _answer(step6a.card, Rating.good, 169, secondInDay: true);
    expect(step6b.card.type, CardType.review);
    expect(step6b.card.ivl, 1);
    expect(step6b.card.due, 170);

    final step7 = _answer(step6b.card, Rating.good, 170);
    expect(step7.card.ivl, 3);
    expect(step7.card.due, 173);
  });
}
