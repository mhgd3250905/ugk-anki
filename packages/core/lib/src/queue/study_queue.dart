import 'dart:math';

import '../model/card.dart';
import '../scheduler/preset.dart';

/// 由卡片 id 和 seed 生成稳定的洗牌键
int shuffleKey(int cardId, int seed) =>
    ((cardId & 0xffffffff) * 2654435761 + seed) & 0xffffffff;

/// 把新卡均匀插进复习卡
List<T> intersperse<T>(List<T> reviews, List<T> newCards) {
  final r = reviews.length;
  final n = newCards.length;
  if (n == 0) return List<T>.of(reviews);
  if (r == 0) return List<T>.of(newCards);
  final result = <T>[];
  var ri = 0;
  for (var k = 0; k < n; k++) {
    final target = min(r, (k + 1) * (r + 1) ~/ (n + 1));
    while (ri < target) {
      result.add(reviews[ri++]);
    }
    result.add(newCards[k]);
  }
  while (ri < r) {
    result.add(reviews[ri++]);
  }
  return result;
}

/// 今日学习队列
class StudyQueue {
  final List<Card> learning;
  final List<Card> main;

  /// 创建队列
  const StudyQueue({required this.learning, required this.main});

  /// main 里的新卡数量
  int get newCount => main.where((c) => c.queue == CardQueue.newCard).length;

  /// learning 卡数量 + main 里的 dayLearn 数量
  int get learnCount =>
      learning.length + main.where((c) => c.queue == CardQueue.dayLearn).length;

  /// main 里的复习卡数量
  int get reviewCount => main.where((c) => c.queue == CardQueue.review).length;

  /// 取下一张该学的卡
  Card? next(int nowMs, int learnAheadSecs) {
    if (learning.isNotEmpty && learning.first.due <= nowMs) {
      return learning.first;
    }
    if (main.isNotEmpty) return main.first;
    if (learning.isNotEmpty &&
        learning.first.due <= nowMs + learnAheadSecs * 1000) {
      return learning.first;
    }
    return null;
  }
}

/// 按今日上限和排序规则构建学习队列
StudyQueue buildQueue({
  required List<Card> cards,
  required int today,
  required DeckPreset preset,
  required int newDoneToday,
  required int reviewsDoneToday,
  required int seed,
}) {
  final active = cards.where((c) => c.queue.dbValue >= 0).toList();

  final learning = active.where((c) => c.queue == CardQueue.learn).toList()
    ..sort((a, b) {
      final byDue = a.due.compareTo(b.due);
      return byDue != 0 ? byDue : a.id.compareTo(b.id);
    });

  final dayLearn = active
      .where((c) => c.queue == CardQueue.dayLearn && c.due <= today)
      .toList()
    ..sort((a, b) {
      final byDue = a.due.compareTo(b.due);
      return byDue != 0 ? byDue : a.id.compareTo(b.id);
    });

  final reviews = active
      .where((c) => c.queue == CardQueue.review && c.due <= today)
      .toList()
    ..sort((a, b) {
      final byDue = a.due.compareTo(b.due);
      if (byDue != 0) return byDue;
      final byShuffle =
          shuffleKey(a.id, seed).compareTo(shuffleKey(b.id, seed));
      if (byShuffle != 0) return byShuffle;
      return a.id.compareTo(b.id);
    });

  final reviewLimit = max(0, preset.reviewsPerDay - reviewsDoneToday);
  final reviewPart = [...dayLearn, ...reviews].take(reviewLimit).toList();

  final newLimit = max(
    0,
    min(preset.newPerDay - newDoneToday, reviewLimit - reviewPart.length),
  );
  final newCards = active.where((c) => c.queue == CardQueue.newCard).toList()
    ..sort((a, b) {
      final byDue = a.due.compareTo(b.due);
      return byDue != 0 ? byDue : a.id.compareTo(b.id);
    });
  final limitedNew = newCards.take(newLimit).toList();

  return StudyQueue(
    learning: learning,
    main: intersperse(reviewPart, limitedNew),
  );
}
