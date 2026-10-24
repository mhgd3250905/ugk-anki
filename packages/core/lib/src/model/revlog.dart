/// 复习日志类型：0 learn，1 review，2 relearn，3 filtered，4 manual
enum RevlogType { learn, review, relearn, filtered, manual }

/// 一次评分的记录（FSRS 和统计都靠它）
class RevlogEntry {
  final int id; // 评分时间戳 ms
  final int cardId;
  final int button; // 1 Again 2 Hard 3 Good 4 Easy
  final int ivl; // 新间隔：正数=天，负数=秒
  final int lastIvl; // 旧间隔：同上
  final int factor; // 评分后的 ease 千分比；学习阶段为 0
  final int timeTakenMs; // 上限 60000
  final RevlogType type;

  /// 创建一条复习日志
  const RevlogEntry({
    required this.id,
    required this.cardId,
    required this.button,
    required this.ivl,
    required this.lastIvl,
    required this.factor,
    required this.timeTakenMs,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevlogEntry &&
          other.id == id &&
          other.cardId == cardId &&
          other.button == button &&
          other.ivl == ivl &&
          other.lastIvl == lastIvl &&
          other.factor == factor &&
          other.timeTakenMs == timeTakenMs &&
          other.type == type;

  @override
  int get hashCode => Object.hash(
        id,
        cardId,
        button,
        ivl,
        lastIvl,
        factor,
        timeTakenMs,
        type,
      );
}
