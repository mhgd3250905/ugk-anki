/// 达到 leech 阈值后的处理方式
enum LeechAction { suspend, tagOnly }

/// 卡组参数（对应 Anki 的 Deck Options Preset）
class DeckPreset {
  final List<double> learnSteps;
  final List<double> relearnSteps;
  final int graduatingIntervalGood;
  final int graduatingIntervalEasy;
  final int initialEase;
  final double easyMultiplier;
  final double hardMultiplier;
  final double intervalMultiplier;
  final double lapseMultiplier;
  final int minimumLapseInterval;
  final int maximumReviewInterval;
  final int leechThreshold;
  final LeechAction leechAction;
  final int newPerDay;
  final int reviewsPerDay;
  final int dayRolloverHour;
  final int learnAheadSecs;
  final bool buryNewSiblings;
  final bool buryReviewSiblings;

  /// 创建卡组参数
  const DeckPreset({
    this.learnSteps = const [1, 10],
    this.relearnSteps = const [10],
    this.graduatingIntervalGood = 1,
    this.graduatingIntervalEasy = 4,
    this.initialEase = 2500,
    this.easyMultiplier = 1.3,
    this.hardMultiplier = 1.2,
    this.intervalMultiplier = 1.0,
    this.lapseMultiplier = 0.0,
    this.minimumLapseInterval = 1,
    this.maximumReviewInterval = 36500,
    this.leechThreshold = 8,
    this.leechAction = LeechAction.tagOnly,
    this.newPerDay = 20,
    this.reviewsPerDay = 200,
    this.dayRolloverHour = 4,
    this.learnAheadSecs = 1200,
    this.buryNewSiblings = true,
    this.buryReviewSiblings = true,
  });

  /// 复制一份并覆盖指定字段
  DeckPreset copyWith({
    List<double>? learnSteps,
    List<double>? relearnSteps,
    int? graduatingIntervalGood,
    int? graduatingIntervalEasy,
    int? initialEase,
    double? easyMultiplier,
    double? hardMultiplier,
    double? intervalMultiplier,
    double? lapseMultiplier,
    int? minimumLapseInterval,
    int? maximumReviewInterval,
    int? leechThreshold,
    LeechAction? leechAction,
    int? newPerDay,
    int? reviewsPerDay,
    int? dayRolloverHour,
    int? learnAheadSecs,
    bool? buryNewSiblings,
    bool? buryReviewSiblings,
  }) {
    return DeckPreset(
      learnSteps: learnSteps ?? this.learnSteps,
      relearnSteps: relearnSteps ?? this.relearnSteps,
      graduatingIntervalGood:
          graduatingIntervalGood ?? this.graduatingIntervalGood,
      graduatingIntervalEasy:
          graduatingIntervalEasy ?? this.graduatingIntervalEasy,
      initialEase: initialEase ?? this.initialEase,
      easyMultiplier: easyMultiplier ?? this.easyMultiplier,
      hardMultiplier: hardMultiplier ?? this.hardMultiplier,
      intervalMultiplier: intervalMultiplier ?? this.intervalMultiplier,
      lapseMultiplier: lapseMultiplier ?? this.lapseMultiplier,
      minimumLapseInterval:
          minimumLapseInterval ?? this.minimumLapseInterval,
      maximumReviewInterval:
          maximumReviewInterval ?? this.maximumReviewInterval,
      leechThreshold: leechThreshold ?? this.leechThreshold,
      leechAction: leechAction ?? this.leechAction,
      newPerDay: newPerDay ?? this.newPerDay,
      reviewsPerDay: reviewsPerDay ?? this.reviewsPerDay,
      dayRolloverHour: dayRolloverHour ?? this.dayRolloverHour,
      learnAheadSecs: learnAheadSecs ?? this.learnAheadSecs,
      buryNewSiblings: buryNewSiblings ?? this.buryNewSiblings,
      buryReviewSiblings: buryReviewSiblings ?? this.buryReviewSiblings,
    );
  }
}
