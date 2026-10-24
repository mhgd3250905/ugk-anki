import '../model/card.dart';
import 'answer.dart';
import 'learning_steps.dart';
import 'next_states.dart';
import 'preset.dart';
import 'states.dart';

/// 把状态的间隔格式化成按钮上的短文字
String formatInterval(CardState s) => switch (s) {
      LearnState l => _formatSecs(l.scheduledSecs),
      RelearnState r => _formatSecs(r.learning.scheduledSecs),
      ReviewState r => _formatDays(r.scheduledDays),
      NewState() => throw ArgumentError('NewState 没有间隔'),
    };

/// 一次算好四个按钮的文字（复习页用）
Map<Rating, String> previewLabels(
  Card card,
  DeckPreset p, {
  required int today,
}) {
  final states = nextStates(stateFromCard(card, today), p);
  return {
    for (final rating in Rating.values)
      rating: formatInterval(states.forRating(rating)),
  };
}

String _formatSecs(int secs) {
  if (secs < 3600) return '<${(secs / 60).ceil()}m';
  if (secs < kDaySecs) return '<${(secs / 3600).ceil()}h';
  return '${(secs / kDaySecs).round()}d';
}

String _formatDays(int d) {
  if (d < 30) return '${d}d';
  if (d < 365) return '${_trimZero((d / 30).toStringAsFixed(1))}mo';
  return '${_trimZero((d / 365).toStringAsFixed(1))}y';
}

String _trimZero(String s) =>
    s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
