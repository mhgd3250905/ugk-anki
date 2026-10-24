import 'dart:convert';

import 'package:ugk_core/ugk_core.dart';

/// DeckPreset 转 JSON 字符串
String presetToJson(DeckPreset p) => jsonEncode({
  'learnSteps': p.learnSteps,
  'relearnSteps': p.relearnSteps,
  'graduatingIntervalGood': p.graduatingIntervalGood,
  'graduatingIntervalEasy': p.graduatingIntervalEasy,
  'initialEase': p.initialEase,
  'easyMultiplier': p.easyMultiplier,
  'hardMultiplier': p.hardMultiplier,
  'intervalMultiplier': p.intervalMultiplier,
  'lapseMultiplier': p.lapseMultiplier,
  'minimumLapseInterval': p.minimumLapseInterval,
  'maximumReviewInterval': p.maximumReviewInterval,
  'leechThreshold': p.leechThreshold,
  'leechAction': p.leechAction.index,
  'newPerDay': p.newPerDay,
  'reviewsPerDay': p.reviewsPerDay,
  'dayRolloverHour': p.dayRolloverHour,
  'learnAheadSecs': p.learnAheadSecs,
  'buryNewSiblings': p.buryNewSiblings,
  'buryReviewSiblings': p.buryReviewSiblings,
});

/// JSON 字符串转 DeckPreset（缺的键用默认值）
DeckPreset presetFromJson(String s) {
  final m = jsonDecode(s) as Map<String, dynamic>;
  const d = DeckPreset();
  List<double> steps(String k, List<double> def) => m[k] == null
      ? def
      : [for (final v in m[k] as List) (v as num).toDouble()];
  int i(String k, int def) => (m[k] as num?)?.toInt() ?? def;
  double f(String k, double def) => (m[k] as num?)?.toDouble() ?? def;
  bool b(String k, bool def) => (m[k] as bool?) ?? def;
  return DeckPreset(
    learnSteps: steps('learnSteps', d.learnSteps),
    relearnSteps: steps('relearnSteps', d.relearnSteps),
    graduatingIntervalGood: i(
      'graduatingIntervalGood',
      d.graduatingIntervalGood,
    ),
    graduatingIntervalEasy: i(
      'graduatingIntervalEasy',
      d.graduatingIntervalEasy,
    ),
    initialEase: i('initialEase', d.initialEase),
    easyMultiplier: f('easyMultiplier', d.easyMultiplier),
    hardMultiplier: f('hardMultiplier', d.hardMultiplier),
    intervalMultiplier: f('intervalMultiplier', d.intervalMultiplier),
    lapseMultiplier: f('lapseMultiplier', d.lapseMultiplier),
    minimumLapseInterval: i('minimumLapseInterval', d.minimumLapseInterval),
    maximumReviewInterval: i('maximumReviewInterval', d.maximumReviewInterval),
    leechThreshold: i('leechThreshold', d.leechThreshold),
    leechAction: LeechAction.values[i('leechAction', d.leechAction.index)],
    newPerDay: i('newPerDay', d.newPerDay),
    reviewsPerDay: i('reviewsPerDay', d.reviewsPerDay),
    dayRolloverHour: i('dayRolloverHour', d.dayRolloverHour),
    learnAheadSecs: i('learnAheadSecs', d.learnAheadSecs),
    buryNewSiblings: b('buryNewSiblings', d.buryNewSiblings),
    buryReviewSiblings: b('buryReviewSiblings', d.buryReviewSiblings),
  );
}

/// 字段列表转 JSON：[{"name":..,"ord":..}]
String fieldsToJson(List<NoteField> fields) => jsonEncode([
  for (final f in fields) {'name': f.name, 'ord': f.ord},
]);

/// JSON 转字段列表
List<NoteField> fieldsFromJson(String s) => [
  for (final e in jsonDecode(s) as List)
    NoteField(e['name'] as String, e['ord'] as int),
];

/// 模板列表转 JSON：[{"name":..,"ord":..,"qfmt":..,"afmt":..}]
String templatesToJson(List<CardTemplate> ts) => jsonEncode([
  for (final t in ts)
    {'name': t.name, 'ord': t.ord, 'qfmt': t.qfmt, 'afmt': t.afmt},
]);

/// JSON 转模板列表
List<CardTemplate> templatesFromJson(String s) => [
  for (final e in jsonDecode(s) as List)
    CardTemplate(
      name: e['name'] as String,
      ord: e['ord'] as int,
      qfmt: e['qfmt'] as String,
      afmt: e['afmt'] as String,
    ),
];
