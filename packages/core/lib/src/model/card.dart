/// card.type
enum CardType { newCard, learn, review, relearn } // 存库时 0,1,2,3

/// card.queue
enum CardQueue {
  userBuried,
  schedBuried,
  suspended,
  newCard,
  learn,
  review,
  dayLearn;

  /// 存库值
  int get dbValue => switch (this) {
        CardQueue.userBuried => -3,
        CardQueue.schedBuried => -2,
        CardQueue.suspended => -1,
        CardQueue.newCard => 0,
        CardQueue.learn => 1,
        CardQueue.review => 2,
        CardQueue.dayLearn => 3,
      };

  /// 从存库值还原队列
  static CardQueue fromDb(int value) => CardQueue.values.firstWhere(
        (q) => q.dbValue == value,
        orElse: () => throw ArgumentError('未知的 CardQueue 值: $value'),
      );
}

/// 卡片（M2 会用 drift 存，M1 只是纯对象）
class Card {
  final int id, noteId, deckId, ord;
  final CardType type;
  final CardQueue queue;
  final int due;
  final int ivl;
  final int ease;
  final int reps, lapses, left, flags, mtimeMs;

  /// 创建卡片
  const Card({
    required this.id,
    required this.noteId,
    required this.deckId,
    required this.ord,
    required this.type,
    required this.queue,
    required this.due,
    required this.ivl,
    required this.ease,
    required this.reps,
    required this.lapses,
    required this.left,
    required this.flags,
    required this.mtimeMs,
  });

  /// 复制一份并覆盖指定字段
  Card copyWith({
    int? id,
    int? noteId,
    int? deckId,
    int? ord,
    CardType? type,
    CardQueue? queue,
    int? due,
    int? ivl,
    int? ease,
    int? reps,
    int? lapses,
    int? left,
    int? flags,
    int? mtimeMs,
  }) {
    return Card(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      deckId: deckId ?? this.deckId,
      ord: ord ?? this.ord,
      type: type ?? this.type,
      queue: queue ?? this.queue,
      due: due ?? this.due,
      ivl: ivl ?? this.ivl,
      ease: ease ?? this.ease,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      left: left ?? this.left,
      flags: flags ?? this.flags,
      mtimeMs: mtimeMs ?? this.mtimeMs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card &&
          other.id == id &&
          other.noteId == noteId &&
          other.deckId == deckId &&
          other.ord == ord &&
          other.type == type &&
          other.queue == queue &&
          other.due == due &&
          other.ivl == ivl &&
          other.ease == ease &&
          other.reps == reps &&
          other.lapses == lapses &&
          other.left == left &&
          other.flags == flags &&
          other.mtimeMs == mtimeMs;

  @override
  int get hashCode => Object.hash(
        id,
        noteId,
        deckId,
        ord,
        type,
        queue,
        due,
        ivl,
        ease,
        reps,
        lapses,
        left,
        flags,
        mtimeMs,
      );
}
