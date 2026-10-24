/// 卡片的调度状态（纯值对象，不含数据库字段）
sealed class CardState {
  const CardState();
}

/// 新卡
class NewState extends CardState {
  const NewState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'NewState()';
}

/// 学习中（分钟级）
class LearnState extends CardState {
  final int remainingSteps;
  final int scheduledSecs;
  const LearnState({required this.remainingSteps, required this.scheduledSecs});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearnState &&
          other.remainingSteps == remainingSteps &&
          other.scheduledSecs == scheduledSecs;

  @override
  int get hashCode => Object.hash(LearnState, remainingSteps, scheduledSecs);

  @override
  String toString() =>
      'LearnState(remainingSteps: $remainingSteps, scheduledSecs: $scheduledSecs)';
}

/// 复习中（天级）
class ReviewState extends CardState {
  final int scheduledDays; // 上次安排的间隔
  final int elapsedDays; // 距上次复习实际过了几天
  final int ease; // 千分比
  final int lapses;
  final bool leeched; // 本次评分是否触发 leech
  const ReviewState({
    required this.scheduledDays,
    required this.elapsedDays,
    required this.ease,
    required this.lapses,
    this.leeched = false,
  });

  /// 迟到的天数
  int get daysLate => elapsedDays - scheduledDays;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewState &&
          other.scheduledDays == scheduledDays &&
          other.elapsedDays == elapsedDays &&
          other.ease == ease &&
          other.lapses == lapses &&
          other.leeched == leeched;

  @override
  int get hashCode => Object.hash(
        ReviewState,
        scheduledDays,
        elapsedDays,
        ease,
        lapses,
        leeched,
      );

  @override
  String toString() =>
      'ReviewState(scheduledDays: $scheduledDays, elapsedDays: $elapsedDays, '
      'ease: $ease, lapses: $lapses, leeched: $leeched)';
}

/// 遗忘后重学（分钟级），同时记住重学结束后要回到的复习状态
class RelearnState extends CardState {
  final LearnState learning;
  final ReviewState review;
  const RelearnState({required this.learning, required this.review});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelearnState &&
          other.learning == learning &&
          other.review == review;

  @override
  int get hashCode => Object.hash(RelearnState, learning, review);

  @override
  String toString() => 'RelearnState(learning: $learning, review: $review)';
}

/// 四个按钮
enum Rating { again, hard, good, easy }

/// 四个按钮各自的结果
class SchedulingStates {
  final CardState current, again, hard, good, easy;
  const SchedulingStates({
    required this.current,
    required this.again,
    required this.hard,
    required this.good,
    required this.easy,
  });

  /// 取指定评分对应的下一个状态
  CardState forRating(Rating r) => switch (r) {
        Rating.again => again,
        Rating.hard => hard,
        Rating.good => good,
        Rating.easy => easy
      };
}
